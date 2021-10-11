from flask import Flask, request, render_template

# ...
@app.route("/search")
def search():
    query = request.args.get("s")
    results = lookup(query)

    if len(results) > 0:
        return render_template("search.html", results=results)
    else:
        return "No results found for: " + query
