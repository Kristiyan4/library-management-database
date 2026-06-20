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

This spins up a MySQL 8 container and automatically runs `schema.sql` on first start, so the database is ready to query right away. Stop it with `docker compose down` (add `-v` to also wipe the stored data).

## Tech

MySQL · DDL, DML, triggers, events

## EER diagram

<img width="1470" height="956" alt="Screenshot 2026-06-20 at 17 49 38" src="https://github.com/user-attachments/assets/9645fd3f-8d23-43d3-81c3-14d3915d998c" />

