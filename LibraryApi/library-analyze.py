import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

DB_USER = os.environ.get("DB_USER", "root")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "rootpassword")
DB_HOST = os.environ.get("DB_HOST", "127.0.0.1")
DB_PORT = os.environ.get("DB_PORT", "3306")
DB_NAME = os.environ.get("DB_NAME", "2024_TU_Lab1")

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

OUTPUT_DIR = "analysis_output"
os.makedirs(OUTPUT_DIR, exist_ok=True)


def most_borrowed_books(limit=10):
    query = """
        SELECT b.title, COUNT(*) AS times_borrowed
        FROM book_reader br
        JOIN book b ON b.id = br.book_id
        GROUP BY b.id, b.title
        ORDER BY times_borrowed DESC
        LIMIT %(limit)s
    """
    df = pd.read_sql(query, engine, params={"limit": limit})
    print("\nMost borrowed books:")
    print(df.to_string(index=False))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.barh(df["title"], df["times_borrowed"], color="#1D9E75")
    ax.invert_yaxis()
    ax.set_title("Most borrowed books")
    ax.set_xlabel("Times borrowed")
    plt.tight_layout()
    fig.savefig(f"{OUTPUT_DIR}/most_borrowed_books.png", dpi=150)
    plt.close(fig)
    return df


def books_per_category():
    query = """
        SELECT category, COUNT(*) AS book_count
        FROM book
        GROUP BY category
        ORDER BY book_count DESC
    """
    df = pd.read_sql(query, engine)
    print("\nBooks per category:")
    print(df.to_string(index=False))

    fig, ax = plt.subplots(figsize=(7, 5))
    ax.bar(df["category"], df["book_count"], color="#378ADD")
    ax.set_title("Books per category")
    ax.set_ylabel("Number of books")
    plt.xticks(rotation=30, ha="right")
    plt.tight_layout()
    fig.savefig(f"{OUTPUT_DIR}/books_per_category.png", dpi=150)
    plt.close(fig)
    return df


def loan_status_breakdown():
    query = """
        SELECT
            CASE WHEN date_returned IS NULL THEN 'Still borrowed' ELSE 'Returned' END AS status,
            COUNT(*) AS total
        FROM book_reader
        GROUP BY status
    """
    df = pd.read_sql(query, engine)
    print("\nLoan status breakdown:")
    print(df.to_string(index=False))

    fig, ax = plt.subplots(figsize=(6, 6))
    ax.pie(df["total"], labels=df["status"], autopct="%1.1f%%", startangle=90,
           colors=["#BA7517", "#1D9E75"])
    ax.set_title("Returned vs. still borrowed")
    plt.tight_layout()
    fig.savefig(f"{OUTPUT_DIR}/loan_status_breakdown.png", dpi=150)
    plt.close(fig)
    return df


def avg_loan_duration_by_category():
    query = """
        SELECT b.category,
               ROUND(AVG(DATEDIFF(COALESCE(br.date_returned, NOW()), br.date_taken)), 1) AS avg_days
        FROM book_reader br
        JOIN book b ON b.id = br.book_id
        GROUP BY b.category
        ORDER BY avg_days DESC
    """
    df = pd.read_sql(query, engine)
    print("\nAverage loan duration by category (days):")
    print(df.to_string(index=False))

    fig, ax = plt.subplots(figsize=(7, 5))
    ax.bar(df["category"], df["avg_days"], color="#9B6CD8")
    ax.set_title("Average loan duration by category")
    ax.set_ylabel("Days")
    plt.xticks(rotation=30, ha="right")
    plt.tight_layout()
    fig.savefig(f"{OUTPUT_DIR}/avg_loan_duration_by_category.png", dpi=150)
    plt.close(fig)
    return df


if __name__ == "__main__":
    print(f"Connecting to {DB_NAME} at {DB_HOST}:{DB_PORT} ...")
    most_borrowed_books()
    books_per_category()
    loan_status_breakdown()
    avg_loan_duration_by_category()
    print(f"\nDone. Charts saved to ./{OUTPUT_DIR}/")
