# Chapter 65: Run an Ansible Execution Environment - ansible-runner

Once you have built an Execution Environment (EE), you need a way to run it. **Ansible Runner** is the tool that executes playbooks inside those containerized environments, ensuring consistency across different infrastructure.

## 1. What is `ansible-runner`?

`ansible-runner` is a tool and a python library that provides a stable interface for running Ansible. It can run playbooks locally, but its primary modern use case is running playbooks **inside** an Execution Environment.

## 2. Running a Playbook with an EE

To run a playbook using a specific container image (the EE you built in Chapter 64), use the following command:

```bash
ansible-runner run . -p my-playbook.yml --container-image my_custom_ee:v1
```

### Key Arguments:
- `.`: The private data directory (contains project, inventory, env).
- `-p`: The playbook file to run.
- `--container-image`: The name of the EE image to use.

## 3. Directory Structure

Ansible Runner expects a specific directory structure for its "Private Data Directory":

```text
project_dir/
├── inventory/
│   └── hosts
├── project/
│   └── site.yml
└── env/
    └── settings
```

## 4. Why use `ansible-runner`?

- **Isolation**: Each run happens in a fresh container, avoiding "works on my machine" issues.
- **Automation**: It's designed to be used inside CI/CD pipelines or integrated into other Python applications.
- **Output Storage**: It captures all results, logs, and artifacts in a structured way under an `artifacts/` folder.

---

## Examples

### Example 1: Basic Run command
```bash
ansible-runner run /home/user/ansible_project -p playbooks/install_nginx.yml
```

### Example 2: Running with Podman
```bash
ansible-runner run . -p site.yml --process-isolation --container-image quay.io/ansible/awx-ee:latest
```

---

## Key Notes
- **Process Isolation**: Using `--process-isolation` (default when using an image) ensures that the playbook cannot access your local file system except for what is explicitly mounted.
- **Integration**: It is the engine behind **Ansible Automation Platform (AAP)** and **AWX**.

## Exercises
1. Install `ansible-runner` (`pip install ansible-runner`).
2. Explore the `artifacts` directory created after running a command. Find the `stdout` file.
3. Try running a simple playbook that prints the Ansible version using `ansible-runner`.
4. How does `ansible-runner` help in a multi-tenant environment where different teams need different versions of collections?
