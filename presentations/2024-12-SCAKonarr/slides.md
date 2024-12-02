---
marp: true
theme: tokyonight
# class: lead
paginate: true
---
<!-- _class: lead -->
<!-- _footer: "v1.0" -->

<!-- _paginate: false -->
# Konarr

## A Story of Building a Software Composition Analysis Platform

**Defcon 44131 - December 2024**

---
<!-- _class: -->

# # Whoami

**Mathew Payne - @GeekMasher**

🖥️ Princial Field Security Specialist at GitHub
❤️  Founder of [42ByteLabs](https://42bytelabs.com)

_Focus on:_

- :computer: Static Code Analysis
- :eyes: Code Review & Automatic Security Testing
- :handshake: DevOps / DevSecOps

---
# ✋ Let's start with some questions

- How many of you have heard of **Software Composition Analysis**?
- Who has heard of and used **Containers**?
- Who has managed containers in **Production**?
  - *HomeLab/Self-Host, Work, Cloud*
- How many of you have heard of **Konarr** already?

---
<!-- _class: lead -->
# 📚 Personal Lore

- December 2021...
- Great start to the month...
- **HomeLab** running smoothly...
- And something happened...

---
# 🤯 Log4Shell Dropped

- **CVE-2021-44228**
  - ... and the other CVEs
- **RCE** vulnerability
- **Log4j** vulnerability
- **Java** logging library

*But what does this have to do with me?*

---
# 💻 My Homelab and the question...

- **Self-hosting** a lot of software
  - 12-15 services...
  - 10 are not mine
- Running **Docker containers** based services
  - *Traefik, Heimdall, Portainer, PiHole, Jellyfin, HomeAssistant, ...*

... am I running **Log4j** in any of my containers?

---
<!-- _class: lead -->

# 🎉 New Quest Unlocked

### "Finding a solution to scan my containers for vulnerabilities"

---
# 🔍 Software Composition Analysis

> Software Composition Analysis (SCA) is a security process that involves **identifying and inventorying open source components within an application**, checking the components for **known security vulnerabilities**, and **monitoring the components for new vulnerabilities**.

---
# 📦 What about for Containers?

- **Containers** are a great way to run software
  - **Self-Contained** images of software
  - **Isolated** from the host*
  - **Easy to deploy and manage**
- **Images** are built of **layers**
  - Contains **libraries, components, binaries, etc.**
- But they also bring **challenges**

---
# ❗ The Challenges

- **Components** in the container
  - What are they?
- **Security vulnerabilities** in the container
  - How do you know?
- **Monitoring** for changes to containers and vulnerabilities
- **Outdated** components
  - How do you keep up to date?
  - Can you even update them if they aren't yours?

---
# 🧰 The tools in the space...

- **Snyk**
- **Black Duck**
- **Mend**
- **Sonatype**
- ...

*But what is the issue with these tools?*

---
# 🧰 What about Open Source tools?

- **Anchore/Grype** from Anchore
- **Docker Scout** from Docker
- **Trivy** from Aqua Security
- **Clair** from RedHat
- **Dependency Track** from OWASP*
- ...

*But what do they have in common?*

---
# ❗ Some of the Problems

- **Closed Source**
- **Cost money** which I refuse to pay for
- **Data Privacy concerns** due to the nature of SaaS
- **Open Source** tools are **limited** in features
  - CLI only tools
- **Not Customisable**

---
# 🧰 Dependency Track + Grype

- First I tried **Dependency Track** with **Grype**
- Built a tool called [**Gungnir**](https://github.com/GeekMasher/gungnir)
  - The glue between **Grype** and **Dependency Track**

**Gungnir** was a CLI tool/container to run **Grype** against all running containers and submit the results to **Dependency Track**

---

![bg h:90%](https://github.com/GeekMasher/gungnir/blob/main/assets/dependency-track-example.png?raw=true)

---
# 🧰 Dependency Track + Grype

> This works fine...

*Mathew, 2022*

---
# ❗ My Problems

- Dependency Track
  - **Not a perfect fit** for my use case
    - Built to integrate with CI/CD
  - **Heavy** on resources and **slow**
    - **Java** based 😬
- Grype is great
  - **No Web UI / API**

---
<!-- _class: lead -->

![bg h:90%](https://i.imgflip.com/9cbgc4.jpg)

---
<!-- _class: lead -->

![bg w:50%](https://i.imgflip.com/9cbc7w.jpg)

---
# 🚀 Enter Konarr

- **Konarr** is a **Software Composition Analysis** platform
  - **Built for Containers** in mind
- **Free and Open Source** (Apache 2.0)
- **Written in Rust 🦀 and TypeScript 🦄**
  - **Web UI**, **API** and **CLI**

---
# 🖌️ Architecture

- **Konarr** is built of **2 main components**
  - **Web UI / API** - Centralised management
    - **Cluster / Container** management
    - Stores **Components and, Vulnerabilities** associated with projects
    - **Admins** can manage **Agents**
  - **Agent / Scanner**
    - Deployed as a Service in your machine / cluster

---
<!-- _class: lead -->
# 📦 Software Bill of Materials

> A Software Bill of Materials (SBOM) is a complete, formally structured list of components, libraries, and modules that make up a piece of software.

---
# 📦 Software Bill of Materials

- **Konarr** uses a **SBOM** to track components in a specific container
- **SBOM** is generated by the **Agent** and sent to the **API**
- Major formats:
  - **CycloneDX**
  - **SPDX**
- **Different tools can generate SBOMs** (Grype, Trivy, ...)
  - **Konarr** is **agnostic** to the tool used

---
<!-- _class: lead -->
# 🛠️ Grype Demo 

**Grype Scanning a Container:**

```bash
grype -o cyclonedx-json=./ddd-results.json ghcr.io/geekmasher/digitalocean-dynamic-dns:main
```

**Syft generating a SBOM:**

```bash
syft scan -o cyclonedx-json=./ddd-sbom.json ghcr.io/geekmasher/digitalocean-dynamic-dns:main
```

---
# ⚒️  Which tool is better?

*It depends...*

- They all work simularly but have **different strengths** and **weaknesses**
- Results can **vary** between tools
  - Mainly about what components they find
- **Grype** is **fast** and **accurate**
  - **Open Source** and **free** to use

---
<!-- _class: lead -->
# 🚀 Konarr in Action

---
# 😑 The Problems with building Konarr

- Complete snapshot of **all components** in a container 
- Source of **vulnerabilities** / **Advisories**
- Versions... are hard...
- **Installed** versus **used** components

---
<!-- _class: lead -->
# ❓ So was a vulnerable to Log4Shell?

---

# 🧯 So was a vulnerable to Log4Shell?

Sadly, I was...

- Minecraft Server
- ELK Stack
  - ElasticSearch was impacted
- HomeAssistant
  - 3rd party plugins

---
# 🚀 Konarr Links

- https://github.com/42ByteLabs/konarr

---
# Thank you!

### Questions?

---
# 🍻 Beer Time 

