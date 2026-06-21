using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string connectionString = builder.Configuration.GetConnectionString("Default")
    ?? throw new InvalidOperationException("Connection string 'Default' is not configured.");

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapGet("/books", async () =>
{
    var books = new List<object>();
    await using var conn = new MySqlConnection(connectionString);
    await conn.OpenAsync();
    await using var cmd = new MySqlCommand("""
        SELECT b.id, b.title, b.ISBN, b.price, b.category,
               p.name AS publisher_name, a.name AS author_name
        FROM book b
        JOIN publisher p ON p.id = b.publisher_id
        LEFT JOIN author a ON a.id = b.author_id
        ORDER BY b.title
        """, conn);
    await using var reader = await cmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        books.Add(new
        {
            id = reader.GetInt32("id"),
            title = reader.GetString("title"),
            isbn = reader.GetString("ISBN"),
            price = reader.GetDecimal("price"),
            category = reader.GetString("category"),
            publisher_name = reader.GetString("publisher_name"),
            author_name = reader.IsDBNull(reader.GetOrdinal("author_name"))
                ? null
                : reader.GetString("author_name"),
        });
    }
    return Results.Ok(books);
});

app.MapGet("/books/{id:int}", async (int id) =>
{
    await using var conn = new MySqlConnection(connectionString);
    await conn.OpenAsync();
    await using var cmd = new MySqlCommand("""
        SELECT b.id, b.title, b.ISBN, b.price, b.category,
               p.name AS publisher_name, a.name AS author_name
        FROM book b
        JOIN publisher p ON p.id = b.publisher_id
        LEFT JOIN author a ON a.id = b.author_id
        WHERE b.id = @id
        """, conn);
    cmd.Parameters.AddWithValue("@id", id);
    await using var reader = await cmd.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
        return Results.NotFound(new { error = "Book not found" });

    return Results.Ok(new
    {
        id = reader.GetInt32("id"),
        title = reader.GetString("title"),
        isbn = reader.GetString("ISBN"),
        price = reader.GetDecimal("price"),
        category = reader.GetString("category"),
        publisher_name = reader.GetString("publisher_name"),
        author_name = reader.IsDBNull(reader.GetOrdinal("author_name"))
            ? null
            : reader.GetString("author_name"),
    });
});

app.MapPut("/books/{id:int}/price", async (int id, PriceUpdateRequest body) =>
{
    // The value actually stored is adjusted automatically by
    // trg_before_update_book_price (defined in schema.sql): lowering the
    // price triggers a partial markup, raising it applies a popularity
    // discount. We read the price back after the UPDATE to return the
    // final value the trigger settled on.
    if (body.Price is null)
        return Results.BadRequest(new { error = "price is required" });

    await using var conn = new MySqlConnection(connectionString);
    await conn.OpenAsync();

    await using (var update = new MySqlCommand("UPDATE book SET price = @price WHERE id = @id", conn))
    {
        update.Parameters.AddWithValue("@price", body.Price);
        update.Parameters.AddWithValue("@id", id);
        var affected = await update.ExecuteNonQueryAsync();
        if (affected == 0)
            return Results.NotFound(new { error = "Book not found" });
    }

    await using var select = new MySqlCommand("SELECT price FROM book WHERE id = @id", conn);
    select.Parameters.AddWithValue("@id", id);
    var finalPrice = (decimal)(await select.ExecuteScalarAsync())!;

    return Results.Ok(new
    {
        message = "Price updated (trigger may have adjusted the final value)",
        book_id = id,
        price = finalPrice,
    });
});

app.MapPost("/book_reader", async (BorrowRequest body) =>
{
    if (body.BookId is null || body.ReaderId is null)
        return Results.BadRequest(new { error = "book_id and reader_id are required" });

    await using var conn = new MySqlConnection(connectionString);
    await conn.OpenAsync();
    await using var cmd = new MySqlCommand(
        "INSERT INTO book_reader (book_id, reader_id) VALUES (@book_id, @reader_id)", conn);
    cmd.Parameters.AddWithValue("@book_id", body.BookId);
    cmd.Parameters.AddWithValue("@reader_id", body.ReaderId);

    try
    {
        await cmd.ExecuteNonQueryAsync();
    }
    catch (MySqlException ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }

    return Results.Created($"/book_reader/{body.BookId}/{body.ReaderId}", new
    {
        message = "Book borrowed",
        book_id = body.BookId,
        reader_id = body.ReaderId,
    });
});

app.MapPut("/book_reader/{bookId:int}/{readerId:int}/return", async (int bookId, int readerId) =>
{
    await using var conn = new MySqlConnection(connectionString);
    await conn.OpenAsync();
    await using var cmd = new MySqlCommand("""
        UPDATE book_reader
        SET date_returned = NOW()
        WHERE book_id = @book_id AND reader_id = @reader_id AND date_returned IS NULL
        """, conn);
    cmd.Parameters.AddWithValue("@book_id", bookId);
    cmd.Parameters.AddWithValue("@reader_id", readerId);
    var affected = await cmd.ExecuteNonQueryAsync();

    if (affected == 0)
        return Results.NotFound(new { error = "No active loan found for this book/reader pair" });

    return Results.Ok(new { message = "Book returned", book_id = bookId, reader_id = readerId });
});

app.MapGet("/readers/{id:int}/history", async (int id) =>
{
    var history = new List<object>();
    await using var conn = new MySqlConnection(connectionString);
    await conn.OpenAsync();
    await using var cmd = new MySqlCommand("""
        SELECT b.title, br.date_taken, br.date_returned
        FROM book_reader br
        JOIN book b ON b.id = br.book_id
        WHERE br.reader_id = @id
        ORDER BY br.date_taken DESC
        """, conn);
    cmd.Parameters.AddWithValue("@id", id);
    await using var reader = await cmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        history.Add(new
        {
            title = reader.GetString("title"),
            date_taken = reader.GetDateTime("date_taken"),
            date_returned = reader.IsDBNull(reader.GetOrdinal("date_returned"))
                ? (DateTime?)null
                : reader.GetDateTime("date_returned"),
        });
    }
    return Results.Ok(history);
});

app.Run("http://localhost:5050");

record PriceUpdateRequest(decimal? Price);
record BorrowRequest(int? BookId, int? ReaderId);
