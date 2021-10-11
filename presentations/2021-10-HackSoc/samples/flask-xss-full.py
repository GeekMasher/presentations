from flask import Flask, request, render_template, escape

app = Flask("MyApp")


def lookup(search: str):
    if search == "result":
        return ["Result 1", "Results 2"]
    else:
        return []


@app.route("/search")
def search():
    query = request.args.get("s")
    results = lookup(query)
    if len(results) > 0:
        return render_template("search.html", results=results)
    else:
        return "No results found for: " + query


if __name__ == "__main__":
    app.run()
