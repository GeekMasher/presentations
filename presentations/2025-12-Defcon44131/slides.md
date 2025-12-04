---
marp: true
theme: tokyonight
paginate: true
---

<!-- _class: lead -->
<!-- _footer: "v1.0" -->
<!-- _paginate: false -->

# 🐳 Let's have boundaries: Understanding Containers and Namespaces

**Defcon 44131 - December 2025**

---

<!-- _class: -->

# # Whoami

**Mathew Payne - @GeekMasher**

🖥️ Field Engineer at XBOW
❤️ Founder of [42ByteLabs](https://42bytelabs.com)
:computer: Formerly at GitHub, Checkmarx, Synopsys

_Focus on:_

- :computer: Static Code Analysis
- :eyes: Code Review & Automatic Security Testing
- :handshake: DevOps / DevSecOps


---
<!-- _class: lead -->
# Quick Poll

**Who has heard of Containers before?**
**Who has used or built them before?**
**Who trusts them as a security boundary?**


---
<!-- _class: lead -->
# Agenda

1. 📦 What are Containers and Docker?
2. 📜 The Origins of Container Technology
3. 🔧 Linux Namespaces
4. 🔒 Chroot Jails
5. 🛡️ The Security Boundary
6. 🎯 Conclusion

---
<!-- _class: lead -->

# 📦 What are Containers and Docker?

---

# What are Containers?

Containers are a lightweight form of "virtualisation" that package an application and its dependencies together in an isolated environment.

**Unlike VMs**: Containers share the host system's kernel while maintaining process and filesystem isolation.

---

# What is Docker?

**Docker** is the most popular containerisation platform that makes it easy to build, ship, and run applications in containers.

Standardised way to package applications:

- Code
- Runtime
- System tools
- Libraries
- Settings

---

# Key Characteristics of Containers

- **Lightweight**: Containers share the host OS kernel, making them much smaller and faster than VMs
- **Portable**: "Build once, run anywhere" - containers work consistently across different environments
- **Isolated**: Each container runs in its own isolated environment with its own filesystem, network, and process tree
- **Efficient**: Multiple containers can run on the same host without the overhead of multiple operating systems

---

<!-- _class: lead -->

# 📜 The Origins of Container Technology

---

# The Unix Heritage (1970s-1980s)

The concept of process isolation began with Unix's `chroot` command in **1979**, which allowed changing the root directory for a process and its children.

This was the first step toward filesystem isolation.

---

# Linux Containers Evolution

- **2000**: FreeBSD Jails introduced more complete OS-level virtualisation
- **2004**: Solaris Containers (Zones) provided robust isolation mechanisms
- **2006**: Google's Process Containers (later renamed cgroups) merged into Linux kernel
- **2008**: LXC (Linux Containers) combined cgroups and namespaces into a complete container solution
- **2013**: Docker launched, making containers accessible to mainstream developers
- **2015**: Open Container Initiative (OCI) standardised container formats and runtimes

---

# Docker's Innovation

Docker's innovation wasn't inventing containers - it was making them **practical and easy to use** through:

- Simple command-line interface
- Dockerfile for reproducible builds
- Container registry (Docker Hub) for sharing images
- Layered filesystem for efficient storage

---

<!-- _class: lead -->

# 🔧 Linux Namespaces

**The Foundation of Container Isolation**

---

# What are Linux Namespaces?

Linux namespaces are the core kernel feature that provides process isolation in containers.

They create separate instances of global system resources, making processes believe they have their own isolated instance of that resource.

---

# Types of Namespaces

1. **PID (Process ID)**: Isolates process IDs
2. **NET (Network)**: Provides separate network stack
3. **MNT (Mount)**: Isolates filesystem mount points
4. **UTS (Unix Timesharing System)**: Isolates hostname and domain name
5. **IPC (Inter-Process Communication)**: Isolates IPC resources
6. **USER**: Isolates user and group IDs
7. **CGROUP**: Isolates cgroup root directory

---

### Sample Code: C Program with Namespaces

Let's create a simple C program that demonstrates PID and UTS namespace isolation:

```c
#define _GNU_SOURCE
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define STACK_SIZE (1024 * 1024)
```

---

### Namespace Demo - Child Function

```c
/* Child function that runs in new namespaces */
static int child_func(void *arg) {
    /* Set a new hostname in the UTS namespace */
    if (sethostname("container-demo", 14) == -1) {
        perror("sethostname");
        return 1;
    }

    printf("Child process:\n");
    printf("  PID: %d\n", getpid());  /* Will be 1 in new PID namespace */
    printf("  Hostname: ");
    system("hostname");               /* Should print "container-demo" */

    return 0;
}
```

---

### Namespace Demo - Main Function

```c
int main(int argc, char *argv[]) {
    char *stack;
    char *stack_top;
    pid_t pid;

    stack = malloc(STACK_SIZE);
    stack_top = stack + STACK_SIZE;

    /* Create child with new PID and UTS namespaces */
    pid = clone(child_func, stack_top,
                CLONE_NEWPID | CLONE_NEWUTS | SIGCHLD, NULL);

    waitpid(pid, NULL, 0);
    return 0;
}
```

**Compile and run**: `gcc -o namespace_demo namespace_demo.c && sudo ./namespace_demo`

---

# What Docker Does Behind the Scenes

When you run `docker run -it --rm ubuntu bash`, Docker:

1. Creates new PID, NET, MNT, UTS, IPC namespaces
2. Sets up a new root filesystem from the image
3. Configures network isolation and virtual network interfaces
4. Applies resource limits using cgroups

# What is Chroot?

`chroot` (change root) is a Unix operation that changes the apparent root directory for a process and its children.

It was one of the earliest forms of process isolation (1979).

---

# How Chroot Works

```bash
# Create a minimal environment
mkdir -p /tmp/jail/{bin,lib,lib64}

# Copy essential binaries
cp /bin/bash /tmp/jail/bin/
cp /bin/ls /tmp/jail/bin/

# Copy required libraries (use ldd to find them)
ldd /bin/bash | grep "=> /" | awk '{print $3}' | \
    xargs -I '{}' cp -v '{}' /tmp/jail/lib/

# Enter the chroot jail
sudo chroot /tmp/jail /bin/bash
```

---

# Inside the Chroot Jail

- The process sees `/tmp/jail` as its root (`/`)
- Cannot access files outside the jail
- Cannot see the real filesystem structure

---

# Limitations of Chroot

Chroot alone is **not a security boundary**:

1. **Root can escape**: A process with root privileges can break out
2. **No process isolation**: Can still see all pr
# What is Chroot?

`chroot` (change root) is a Unix opocesses via `/proc`
3. **No network isolation**: Shares network stack with host
4. **No resource limits**: Can consume all CPU/memory
5. **Kernel shared**: Kernel vulnerabilities affect both host and jail

---

# Chroot Escape Example

**Don't run this on production systems!**

```c
/* Simple chroot escape for processes running as root */
#include <sys/stat.h>
#include <unistd.h>

int main() {
    mkdir(".out", 0755);
    chroot(".out");                /* Create nested chroot */
    chdir("../../../../../");      /* Walk up directories */
    chroot(".");                   /* Chroot to real root */
    execl("/bin/sh", "-i", NULL);
}
```

This demonstrates why chroot is **not** a security feature!

---

# Docker's Improvements Over Chroot

Docker combines chroot-like filesystem isolation with:

- **Namespaces** for process, network, and resource isolation
- **cgroups** for resource limiting
- **Capabilities** to drop unnecessary root privileges
- **Seccomp** to filter system calls
- **AppArmor/SELinux** for mandatory access control

---

<!-- _class: lead -->

# 🛡️ The Security Boundary

**Is It Really One?**

---

# The Critical Question

**Are containers a security boundary?**

---

# The Short Answer: It Depends

Containers provide **process isolation**, not **security isolation** by default.

The security depends on how they're configured and what assumptions you make.

---

# What Containers ARE Good At

✅ **Resource isolation**: Preventing one app from consuming all CPU/memory  
✅ **Dependency isolation**: Avoiding library conflicts between applications  
✅ **Process isolation**: Preventing accidental interference between processes  
✅ **Network segmentation**: Controlling network access between services  
✅ **Filesystem isolation**: Separating application filesystems

---

# What Containers Are NOT (By Default)

❌ **Not VM-level isolation**: Containers share the host kernel  
❌ **Not a trust boundary**: Don't run untrusted code without additional hardening  
❌ **Not immune to kernel exploits**: A kernel vulnerability affects all containers  
❌ **Not secure by default**: Require proper configuration for security

---

# Attack Surface and Vulnerabilities

**Shared Kernel = Shared Attack Surface**

Since all containers share the host kernel, a kernel vulnerability can allow:

- Container escape to the host
- Access to other containers
- Privilege escalation
- Data exfiltration

---

# Historical Examples

- **Dirty COW (CVE-2016-5195)**: Allowed privilege escalation from container to host
- **RunC vulnerability (CVE-2019-5736)**: Allowed container escape by overwriting host's runc binary
- **Privileged containers**: Running with `--privileged` essentially gives full host access

---

### Defence in Depth: Improving Container Security

To make containers more secure:

1. **Don't run as root inside containers**
2. **Drop capabilities**
3. **Use read-only filesystems**
4. **Apply seccomp profiles**
5. **Never use --privileged** unless absolutely necessary
6. **Keep host kernel updated**
7. **Use vulnerability scanning** on images
8. **Consider VM-based containers** for stronger isolation

---

### Security Best Practices - Examples

**Don't run as root:**

```dockerfile
USER 1000:1000
```

**Drop capabilities:**

```bash
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp
```

**Use read-only filesystems:**

```bash
docker run --read-only myapp
```

---

<!-- _class: lead -->

# 🎯 Conclusion

---

# Key Takeaways

Containers and Docker have revolutionized application deployment by building on decades of Linux isolation technologies - from chroot jails in 1979 to modern namespaces and cgroups.

They provide excellent **process isolation** and **resource management**, making it easy to package and deploy applications consistently.

---

# But Remember...

**Containers are not a silver bullet for security**. They share the host kernel, which means:

- They're not a hard security boundary by default
- Kernel vulnerabilities affect all containers
- Proper configuration is essential for security

---

# Key Takeaways

1. **Containers provide isolation, not security isolation** - understand the difference
2. **Namespaces and cgroups** are powerful but share the kernel with the host
3. **Chroot is not a security feature** - it's easily escapable with root access
4. **Defence in depth** - combine multiple security layers
5. **Trust matters** - don't run untrusted code in containers without additional sandboxing
6. **VM-based containers exist** - use them when you need stronger isolation

---

# The Bottom Line

Docker and containers are incredibly useful tools that, when used correctly with proper security considerations, provide a great balance of convenience, efficiency, and isolation for most use cases.

Just don't treat them as **impenetrable fortresses** - they're more like separate apartments in a building that shares the same foundation.

---

<!-- _class: lead -->

# 📚 Further Reading

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Linux Namespaces Man Page](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Understanding Container Security](https://www.oreilly.com/library/view/container-security/9781492056690/)
- [Kata Containers](https://katacontainers.io/) - VM-based container runtime
- [gVisor](https://gvisor.dev/) - Application kernel for containers

---

<!-- _class: lead -->

# Thank You! 🙏

**Questions?**

**@GeekMasher**
