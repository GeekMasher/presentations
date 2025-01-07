---
marp: true
theme: tokyonight
# class: lead
paginate: true
---
<!-- _class: lead -->
<!-- _footer: "v1.1" -->
<!-- _paginate: false -->
# Deep-dive into Containers and How To Secure Then

**Defcon 44131 - January 2025**


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

- Who has heard of and used **Containers**?
- How many of you have heard of **Software Composition Analysis / SCA**?
- How many of you have heard of **Konarr** already?

---
# 📦 Why would you use Containers?

- **Containers** are a great way to run software
- **Self-Contained** images of software
- **Isolated** from the host*
- **Easy to deploy and manage**
- **Open standards** (Docker, OCI)
- **Portability** between platforms

---
# 📦 How do containers work?

- Containers have 2 core elements:
  - **Container / Image** - File system and configuration
  - **Engine / Runtime** - Runs the container

- **Images** are built of **layers**
  - Using **Dockerfile** and **BuildKit**
  - Contains **libraries, components, binaries, etc.**
  - **Base** image and **additional** layers

---
# 📦 What are layers?

- **Layers** are **stacked** on top of each other
- **Dockerfiles** define **instructions** to create layers
  - Some modify the **file system** (e.g. `RUN`, `COPY`)
  - Some modify the **container configuration** (e.g. `ENTRYPOINT`, `ENV`)
- **Layers** are **read-only** and **immutable** once created
- **Layers** can be **shared** between containers
  - **Cached** layers help speed up builds
  - **Reused** layers help reduce disk space

---
# 📦 Example Dockerfile

```docker
# Base layer - https://hub.docker.com/_/debian
FROM debian:bullseye-slim
# Layer 1 - Set the environment variable
ENV URL https://api.github.com/repos/
# Layer 2 - Run this command
RUN apt-get update && apt-get install -y curl git jq
# Layer 3 - Copy this file
COPY entrypoint.sh /entrypoint.sh
# Layer 4 - Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
```

---
## 📦 Building and Examining a Container

```bash
# Building the container
docker build -t myimage:latest .
# Running the container
docker run -it --rm myimage:latest

# Inspect the container history
docker history myimage:latest
# Inspect the container
docker image inspect myimage:latest
```

---
<!-- _class: lead -->
# 📦 Examining Containers using Dive

> A tool for exploring a docker image, layer contents, and discovering ways to shrink the size of your Docker/OCI image.

```bash
dive myimage:latest
```

--- 
# 🕹️ Union File System

- **Layers** are stored in a **Union File System**
  - **OverlayFS** (Linux)
- **Layers** are unioned together to create the **container file system**
  - This is the final runtime container file system

You can mount the layers using the **overlay** filesystem:

```bash
mount -t overlay overlay ...
```

<!--
https://dev.to/pemcconnell/docker-overlayfs-network-namespaces-docker-bridge-and-dns-52jo
-->
---
<!-- _class: lead -->
# 🤨 What does this have to do with SCA?

---
<!-- _class: lead -->
# 🔍 Software Composition Analysis

> Software Composition Analysis (SCA) is a security process that involves **identifying and inventorying open source components within an application**, checking the components for **known security vulnerabilities**, and **monitoring the components for new vulnerabilities**.

---
# ❗ The Challenges and Questions

- **Components** in the container
  - What are they? Which versions?
- **Security vulnerabilities** in the container
  - How do you know?
- **Monitoring** for changes to containers and vulnerabilities
- **Outdated** components
  - How do you keep up to date?
  - Can you even update them if they aren't yours?

---

# 🔭 Discovering Components

- Indentifying **libraries**, **binaries**, **dependencies** in the container
- **Dockerfile** can help
  - Build from scratch
  - But what if you don't have the **Dockerfile**?
- **Scan** the container for components
  - We need to know the **components and versions**
  - This data is **critical** for SCA

---
# 🧰 Open Source tools are available

- **Grype** from Anchore
  - **Syft** (component analysis) from Anchore
- **Docker Scout** from Docker
- **Trivy** from Aqua Security
- **Clair** from RedHat
- **Konarr** from 42ByteLabs

These tools can generate a **Software Bill of Materials (SBOM)**

---
<!-- _class: lead -->
# 📦 Software Bill of Materials

> A Software Bill of Materials (SBOM) is a complete, formally structured list of components, libraries, and modules that make up a piece of software.

---
# 🔒 Scanning Containers

- Scan during **build**
  - **Prevent** vulnerable images from being deployed in the first place
  - **Integrate** into CI/CD pipelines and **security** platforms
- Scan **running** containers
  - **Actively** monitor for new vulnerabilities

---
<!-- _class: lead -->
# 🛠️ Grype Demo 

**Syft generating a SBOM:**

```bash
syft scan -o cyclonedx-json=./ddd-sbom.json ghcr.io/geekmasher/digitalocean-dynamic-dns:main
```

**Grype Scanning a Container:**

```bash
grype -o cyclonedx-json=./ddd-results.json ghcr.io/geekmasher/digitalocean-dynamic-dns:main
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
# 🚀 Enter Konarr

- **Konarr** is a **Software Composition Analysis** platform
  - **Built for Containers** in mind
- **Free and Open Source** (Apache 2.0)
- **Written in Rust 🦀 and TypeScript 🦄**
  - **Web UI**, **API** and **CLI**

---
<!-- _class: lead -->
# 🚀 Konarr in Action

**Demo Time!**

- https://github.com/42ByteLabs/konarr

---
<!-- _class: lead -->
# 🔐 How so we secure our containers?

- **Actively monitoring** for **vulnerabilities**
  - **Automatically** scan containers for SBOMs and vulnerabilities

---
# 🛡️ Patching Containers

- **Regularly** update **base images**
  - **Alpine**, **Debian**, **Ubuntu**, etc.
- **Rebuild** and **redeploy** containers
  - **Automate** the process
  - **CI/CD** pipelines
- **Patch existing containers**
  - **Copacetic**, etc.

---
# 🛡️ Reducing the Attack Surface

- **Use** minimal base images
  - **Alpine**, **Scratch**, **Distroless**
- Only installing **what is needed**
  - **Multi-stage builds** can help with this
  - **Copy** only what is needed
- **Hardening** the container
  - **Security** configurations
  - **AppArmor**, **SELinux**, **Seccomp**

---
<!-- _class: lead -->
# 👏 Thank you!

### Questions ❓

---
<!-- _class: lead -->
# 🍻 Beer Time 🍻 

