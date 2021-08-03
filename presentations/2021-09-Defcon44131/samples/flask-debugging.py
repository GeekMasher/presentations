from flask import Flask, render_template

app = Flask("MyApp")

@app.route("/")
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run("127.0.0.1", 80, debug=True)