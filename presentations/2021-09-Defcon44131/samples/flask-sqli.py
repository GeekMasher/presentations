from flask import Flask, request, render_template
import psycopg2

app = Flask("MyApp")


@app.route("/signup", methods=["GET", "POST"])
def signup():
    conn = psycopg2.connect("dbname=test user=postgres")
    if request.method == "GET":
        return render_template("signup.html")
    elif request.method == "POST":
        pass
