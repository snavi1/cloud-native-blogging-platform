from flask import Flask, jsonify
import os
import mysql.connector

app = Flask(__name__)

def get_db():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "database"),
        user=os.getenv("DB_USER", "bloguser"),
        password=os.getenv("DB_PASSWORD", "blogpass"),
        database=os.getenv("DB_NAME", "blogdb")
    )

@app.route("/api/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/api/posts")
def posts():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT id, title, content FROM posts ORDER BY id DESC")
        result = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/")
def root():
    return "Blogging Platform Backend"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
