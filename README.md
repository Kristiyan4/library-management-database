# Library Management System – Database Project

A relational database for a library / book-lending system, designed as a university project in MySQL. It models books, authors, publishers, readers and staff, and includes triggers and a scheduled event that enforce real business rules at the database level.

## Schema

- **publisher** – publishing houses (name, country)
- **author** – book authors
- **book** – linked to a publisher and (optionally) an author, with a `maintained_by` staff member
- **reader** – library members, optionally linked to a login `account`
- **staff** – library employees, also optionally linked to an `account`
- **account** – shared login table used by both readers and staff (1:1 relationships)
- **book_reader** – junction table tracking which reader has which book, with `date_taken` / `date_returned`, modeling the many-to-many borrowing relationship

All foreign keys enforce referential integrity, and the schema is normalized to avoid duplicated data (e.g. publisher info isn't repeated per book).

## Business logic

- **`trg_before_delete_book`** – before a book is deleted, its borrowing history is archived into `deleted_book_reader_log`, so the rental record isn't silently lost.
- **`trg_before_update_book_price`** – adjusts price changes automatically: lowering a price triggers a partial markup, while raising a price applies a discount scaled to how many readers have borrowed that book (capped at 9%), rewarding popular titles.
- **`ev_daily_book_price_check`** – a daily scheduled event that increases the price of currently checked-out books the longer they go unreturned (a built-in late-fee mechanism).

## Sample data

The script includes ~20 rows per table with fictional names and `@example.com` emails, so the database is ready to query out of the box.

## Running it

```bash
mysql -u your_user -p < schema.sql
```

This drops and recreates the `2024_TU_Lab1` database, creates all tables, triggers, and the scheduled event, and seeds it with sample data.

### Or with Docker

No local MySQL install needed — just Docker:

```bash
docker compose up -d
```

This spins up a MySQL 8 container and automatically runs `schema.sql` on first start, so the database is ready to query right away. Stop it with `docker compose down` (add `-v` to also wipe the stored data). If port 3306 is already taken on your machine (e.g. by a local MySQL install), change the left side of the port mapping in `docker-compose.yml` — for example `"3308:3306"` — and update the port in `appsettings.json` / `.env` to match.

## REST API (C# / ASP.NET Core)

A minimal API project (.NET 8) sits on top of the database for common librarian actions, using `MySqlConnector` for direct SQL access. Price updates go through a plain `UPDATE` statement — the actual stored value is still adjusted automatically by `trg_before_update_book_price`, so the business logic stays in the database, not duplicated in C#.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/books` | List all books with publisher and author |
| GET | `/books/<id>` | Get a single book |
| PUT | `/books/<id>/price` | Update a book's price (trigger adjusts the final value) |
| POST | `/book_reader` | Register a new loan |
| PUT | `/book_reader/<book_id>/<reader_id>/return` | Mark a loan as returned |
| GET | `/readers/<id>/history` | Borrowing history for a reader |

### Setup

Requires the [.NET 8 SDK](https://dotnet.microsoft.com/download). Project files: `LibraryApi.csproj`, `Program.cs`, `appsettings.json`.

```bash
docker compose up -d           # make sure the database is running
dotnet restore
dotnet run
```

Adjust the connection string in `appsettings.json` if your DB host/port/credentials differ. The API runs on `http://localhost:5050`. Try it with:

```bash
curl http://localhost:5050/books
curl -X POST http://localhost:5050/book_reader -H "Content-Type: application/json" -d '{"bookId":1,"readerId":2}'
```

## Data analysis (Python / pandas)

A standalone script (`analyze.py`) connects to the same database and produces a few charts with pandas and matplotlib: most borrowed books, books per category, returned vs. still-borrowed breakdown, and average loan duration by category.

### Setup

```bash
pip install -r requirements-analysis.txt
python analyze.py
```

It needs its own `.env` file (separate from the C# API's `appsettings.json`) — copy `env.example` to `.env` and adjust the port if needed. Charts are saved as PNG files in an `analysis_output/` folder, and a text summary of each table is printed to the console.

## Project files

| File | Purpose |
|---|---|
| `schema.sql` | Database schema, triggers, event, and sample data |
| `docker-compose.yml` | Spins up MySQL with the schema pre-loaded |
| `LibraryApi.csproj`, `Program.cs`, `appsettings.json` | C# / ASP.NET Core REST API |
| `analyze.py`, `requirements-analysis.txt`, `env.example` | Python / pandas data analysis script |

## Tech

MySQL · DDL, DML, triggers, events · C# · ASP.NET Core · Python · pandas · matplotlib
