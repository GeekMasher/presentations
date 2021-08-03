---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: '#eae8db'
color: '#392020'
---

# Introduction to Static Code Analysis

**By Mathew Payne - @GeekMasher**

---

!include(./presentations/common/whoami.md)

---
# What is Static Code Analysis?

*OWASP Definition:*

> Static Code Analysis (also known as Source Code Analysis) is usually performed as part of a Code Review (also known as white-box testing) and is carried out at the Implementation phase of a Security Development Lifecycle (SDL).
>
> Static Code Analysis commonly refers to the running of Static Code Analysis tools that attempt to highlight possible vulnerabilities within 'static' (non-running) source code by using techniques such as Taint Analysis and Data Flow Analysis.

---
# What is Static Code Analysis?

- Automatic tool to discover security issues 


---
# Why would you use SAST?


---
#### Example #1 - Detecting Simple Configuration Problems

```python
!include(presentations/2021-09-Defcon44131/samples/flask-debugging.py)
```

*What issue do you see here?*

<!-- 
Simple debugging is enabled
-->

---
#### Example #X - Data Flow

```python
!include(presentations/2021-09-Defcon44131/samples/flask-sqli.py)
```

*What issue do you see here?*

---
#### Example X - 

```python
from flask import Flask
app = Flask("MyApp")

@app.route("/admin")
@login_required
def index():
    return render_template("admin.html")

@app.route("/admin/settings")
def index():
    return render_template("admin/settings.html")
```

*What issue do you see here?*

<!--
What should be 
-->

---
# :thumbsup: The Pros

- Easy to Implement

---
# :thumbsdown: The Cons

- Poorly written tools leading to:
  - False Positives
  - False Negatives (un-discovered true findings)
- Not aware of context


---
# Conclusion


---
# References

- [Carnegie Mellon University - Taint Analysis](https://www.cs.cmu.edu/~ckaestne/15313/2018/20181023-taint-analysis.pdf)
- [Northwestern - Static Analysis](https://users.cs.northwestern.edu/~ychen/classes/cs450-f16/lectures/10.10_Static%20Analysis.pdf)
