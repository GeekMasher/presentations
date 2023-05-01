---
marp: true
theme: geekmasher
class: lead
paginate: true

---

<!-- _footer: "v1.0" -->
# Introduction to CodeQL

**By Mathew Payne - @GeekMasher**

![bg opacity:.2](assets/background.png)

---

!include(./presentations/common/whoami.md)

---
# Today's Talk

- What is Static Code Analysis and CodeQL?
- Running CodeQL to do research
- Introduction to Query writing

*Questions during presentation is welcome!*

---
# :mag: Static Code Analysis Basics

*Poll Time*

---
# :mag: What is Static Code Analysis?

- :memo: An automated tool to analyse source code
  - "Asking and answering questions about the code"
- :lock: Static Application Security Testing (SAST)
- :hash: Looks at the code without running the code
- :mag: Discover security vulnerabilities
- :link: Perform Taint Tracking Analaysis

<!-- 
- Data-flow, Control-flow, and SSA Graph's

Sources:
- https://owasp.org/www-community/controls/Static_Code_Analysis
-->

---
<!-- _footer: "Source: imgflip.com" -->
# Why Static Code Analysis?

![](assets/meme-source-code.jpg)

---
# :zap: Taint Tracking Analysis

*Track data through an application*

- :mag: Sources (untrustworthy application inputs)
- :interrobang: Sinks (methods / assignments of interest)
- :lock: Sanitizers (secures the user data)
- :lock: Guards (conditional checks)
- :ghost: Passthroughs / Taintsteps

---
# :zap: Example - Code Review

```python
from flask import Flask, request, render_template
# ...
@app.route("/search")
def search():
    search = request.args.get("search")
    results = lookup(search)
    return render_template(
        "search.html", results=results
    )

```

---
# :zap: Example - Code Review

```python
from flask import Flask, request, render_template
# ...
@app.route("/search")
def search():
    search = request.args.get("search")  # <- source, request parameter
    results = lookup(search)             # <- sink?
    return render_template(
        "search.html", results=results   # <- sink?
    )

```

---
# :zap: Example - Code Review

```python
from flask import Flask, request, render_template

def lookup(data):
    cursor = conn.cursor()
    query = f"SELECT * FROM metadata WHERE name='{data}' OR data='{data}'"
    
    cursor.execute(query)
    return cursor.fetchall()

@app.route("/search")
def search():
    search = request.args.get("search")
    results = lookup(search)
    # ...
```
---
# :zap: Example - Taint Tracking Analysis

```python
from flask import Flask, request, render_template

def lookup(data):   # <- 3. function definition
    cursor = conn.cursor()
    query = f"SELECT * FROM metadata WHERE name='{data}' OR data='{data}'"
    # ^ 4. string format, tainting query
    cursor.execute(query)    # <- 5. SINK!
    return cursor.fetchall()

@app.route("/search")
def search():
    search = request.args.get("search")  # <- 1. source, request parameter
    results = lookup(search)             # <- 2. function call
    # ...
```

---
# :zap: Example - Code Review (2nd sink)

```python
from flask import Flask, request, render_template
# ...
@app.route("/search")
def search():
    search = request.args.get("search")
    results = lookup(search)
    return render_template(
        "search.html", results=results   # <- sink?
    )

```

---
<!-- _footer: "Source: flask.palletsprojects.com" -->
# :zap: Researching Framework/Library

**HTML Escaping / Jinja Templates**

> When returning HTML (the default response type in Flask), any user-provided values rendered in the output must be escaped to protect from injection attacks. HTML templates rendered with Jinja, introduced later, will do this automatically.

---
# :mag: CodeQL :lock:

![bg opacity:.1](assets/background.png)

---
# Disclaimer Time :sweat_smile:

![bg opacity:.1](assets/background.png)

---
# What is CodeQL?

- :wrench: Static Code Analysis Engine
- :books: Converts source code into data stored into a Database
- :mag: Queries run on the Database
- :symbols: Domain-specific language called "QL"


---
# CodeQL Pipeline

![width:1100px](assets/codeql-pipline.png)

*Code -> Database -> Queries -> Results*

---
<!-- _footer: "Source: github.com/github/codeql" -->

![width:1100px drop-shadow:0,5px,10px,rgba(0,0,0,.4)](assets/github-codeql.png)

---
# Getting Started

- [VSCode CodeQL Starter](https://github.com/github/vscode-codeql-starter)
- [Insecure Code](https://gist.github.com/GeekMasher/57758192602a045870eb007dcfd35cbb)

```bash
# vscode starter
git clone --depth=1 https://github.com/github/vscode-codeql-starter

# create database (codeql cli)
codeql database create --language python ./python-DC44131-workshop
```

*note: little different for compiled languages*

---
# :mag: CodeQL Query Basics

```codeql
/** 
 * @name SQL Injection
 * @kind path-problem
 * ...
 */

// Imports and components 
import python

// Query Output
from Call call
select call
```

---
# Let's Answer Some Questions...

![bg opacity:.1](assets/background.png)

---
# Question 1

### How do we find the Source?

---
# Python Code

```python 
from flask import request

request.args.get("search")
# ^ Source!
```

---
# CodeQL Query

```codeql
import python
import semmle.python.Concepts
import semmle.python.ApiGraphs

/*
 * How do we find the source?
 */

from DataFlow::Node request, Attribute attr
where
  request = API::moduleImport("flask").getMember("request").getAValueReachableFromSource() and
  attr.getObject() = request.asExpr()
select attr, "Source"
```

---
# Question 2

### What is the Sink?

---
# Python Code

```python 
import psycopg2

conn = psycopg2.connect("dbname=workshop user=postgres")

cursor = conn.cursor()
cursor.execute(query)
     # ^ Sink: execute(query)
```

---

```codeql
import python
import semmle.python.Concepts
import semmle.python.ApiGraphs

/*
 * What is the sink?
 */

from CallNode call, DataFlow::Node sink
where
  // Find all functions called "execute"
  call.getFunction().(AttrNode).getName() in ["execute"] and
  // The first argument is what we are interested in
  sink.asCfgNode() = call.getArg(0)
select sink, "Sink"
```

*Note: being lazy and looking for `execute(...)`*

---
# Question 3

### Can we find a path from Source to Sink?

---
# CodeQL Full - Complete

```codeql
class SqlInjectionConfig extends TaintTracking::Configuration {
  SqlInjectionConfig() { this = "SqlInjectionConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof Sources }

  override predicate isSink(DataFlow::Node sink) { sink instanceof Sinks }
}

from SqlInjectionConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "This SQL query depends on $@.", source.getNode(),
  "a user-provided value"
```

---
# Using built-in queries

- There are hundreds of queries per-language
- Fully extendable


---
# Closing Words

---
# Questions?

---
# Happy Bug Hunting :moneybag:!
![bg opacity:.1](assets/background.png)

- [Slides]
- [Code]
- [CodeQL Docs]


<!-- Resources -->
[Code]: https://gist.github.com/GeekMasher/ce1a06adf9b004baf63fdc59d979c783
[Slides]: https://presentations.geekmasher.dev/2023-05-Defcon44131

<!-- CodeQL -->
[GitHub Advanced Security]: https://github.com/features/security
[CodeQL Docs]: https://codeql.github.com

<!-- Memes -->
[meme-source-code]: https://imgflip.com/memegenerator/Always-Has-Been

