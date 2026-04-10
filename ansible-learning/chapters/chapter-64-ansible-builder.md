# Chapter 64: Build a Custom Ansible Execution Environment - ansible-builder

As Ansible environments grow, managing dependencies (Python libraries, Ansible collections, system packages) across different control nodes becomes difficult. **Execution Environments (EE)** solve this by packaging everything into a container image.

## 1. What is an Execution Environment?

An Execution Environment is a container image (Docker or Podman) that contains:
1.  **Ansible Core**
2.  **Ansible Collections**
3.  **Python libraries** (dependencies for modules)
4.  **System dependencies** (RPMs/DEBs)

## 2. What is `ansible-builder`?

`ansible-builder` is a command-line tool that automates the process of creating these container images. Instead of writing a complex Dockerfile by hand, you define your requirements in a simple YAML file.

## 3. The `execution-environment.yml` File

This is the main configuration file for building an EE.

### Example Structure:
```yaml
version: 3
images:
  base_image:
    name: quay.io/ansible/ansible-runner:latest

dependencies:
  ansible_core:
    package_pip: ansible-core==2.15.0
  ansible_runner:
    package_pip: ansible-runner
  galaxy:
    collections:
      - name: community.general
      - name: amazon.aws
  python:
    - boto3
    - requests
  system:
    - iputils
    - git
```

## 4. Building the Image

Once you have your `execution-environment.yml`, run the following command:

```bash
ansible-builder build --tag my_custom_ee:v1
```

This will:
1.  Generate a `context` directory containing a Dockerfile.
2.  Run Podman/Docker to build the image.

---

## Examples

### Example 1: Minimal EE for AWS
**File:** `execution-environment.yml`
```yaml
version: 3
dependencies:
  galaxy:
    collections:
      - amazon.aws
  python:
    - boto3
```
*Run:* `ansible-builder build -t aws-ee`

---

## Key Notes
- **Podman vs Docker**: `ansible-builder` uses Podman by default. Use `--container-runtime docker` if you prefer Docker.
- **Base Images**: Common base images are found on `quay.io/ansible/`.
- **Introspect**: Use `ansible-builder introspect` to see what is going into your build context.

## Exercises
1. Install `ansible-builder` on your local machine (`pip install ansible-builder`).
2. Create an `execution-environment.yml` that includes the `community.docker` collection.
3. Build the image and list it using `podman images` or `docker images`.
4. Why is using an Execution Environment better than installing libraries globally on your host?
