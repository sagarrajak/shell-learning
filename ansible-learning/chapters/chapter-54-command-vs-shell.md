# Chapter 54: Ansible Modules - command vs shell

Executing commands on remotes is a core feature of Ansible. The two most common modules for this are `command` and `shell`. While they look similar, they behave differently and choosing the right one is important for both functionality and security.

## 1. The `command` Module

The `command` module is the **default** way to run commands. It executes the specified command directly without involving a shell on the remote system (like `/bin/sh`).

- **Security**: Safer because it is not vulnerable to shell injection.
- **Support**: Does **NOT** support pipes (`|`), redirection (`>`, `<`), or variables like `$HOME`.
- **Best For**: Running simple scripts or binaries (e.g., `apt-get`, `hostname`).

### Example
```yaml
- name: Simple command
  ansible.builtin.command:
    cmd: uptime
```

## 2. The `shell` Module

The `shell` module runs the command through a shell (usually `/bin/sh`) on the remote node.

- **Security**: Less safe; variables passed to it could be used for command injection.
- **Support**: Supports all shell features: pipes (`|`), logical operators (`&&`, `||`), redirection (`>>`), and environment variables.
- **Best For**: Complex commands involving multiple steps or pipes.

### Example
```yaml
- name: Complex shell command
  ansible.builtin.shell:
    cmd: cat /etc/passwd | grep "/bin/bash" > /tmp/bash_users.txt
```

---

## Comparison Table

| Feature | `command` | `shell` |
| :--- | :--- | :--- |
| **Shell expansion (`$VAR`)** | No | Yes |
| **Pipes (`\|`) and Redirects (`>`)** | No | Yes |
| **Executes via** | Binary directly | `/bin/sh` |
| **Security** | High | Medium (Risk of injection) |
| **Recommended?** | Use by default | Use only if necessary |

---

## Making Commands Idempotent

Both modules are **not idempotent** by default (they run every single time). You can make them smarter using `creates` and `removes`.

- **`creates`**: Only run the command if this file **does NOT exist**.
- **`removes`**: Only run the command if this file **DOES exist**.

### Example
```yaml
- name: Download a file only if it doesn't exist
  ansible.builtin.command:
    cmd: curl -O https://example.com/bigfile.zip
    creates: /home/sagar/bigfile.zip
```

---

## Examples

### Example 1: `command` will fail with pipes
**File:** `chapters/chapter-54-example-1.yaml`
```yaml
---
- name: Command Failure Example
  hosts: all
  tasks:
    - name: Try using pipe with command (This will literally look for a file named '|')
      ansible.builtin.command:
        cmd: ls -l /tmp | grep test
      ignore_errors: true
```

### Example 2: `shell` for complex operations
**File:** `chapters/chapter-54-example-2.yaml`
```yaml
---
- name: Shell Success Example
  hosts: all
  tasks:
    - name: Use pipe and redirect with shell
      ansible.builtin.shell: 
        cmd: ps aux | grep "nginx" | wc -l
      register: process_count

    - name: Show count
      ansible.builtin.debug:
        msg: "Nginx processes: {{ process_count.stdout }}"
```

### Example 3: `removes` for cleanup
**File:** `chapters/chapter-54-example-3.yaml`
```yaml
---
- name: Cleanup Task
  hosts: all
  tasks:
    - name: Delete a temporary folder ONLY if it exists
      ansible.builtin.command:
        cmd: rm -rf /tmp/my_temp_dir
      args:
        removes: /tmp/my_temp_dir
```

## How to Run
```bash
ansible-playbook -i inventory.ini chapters/chapter-54-example-2.yaml
```

## Key Notes
- If you need to use a specific shell (like `bash`), use the `executable` argument with the `shell` module.
- Always try to use a dedicated Ansible module (like `apt`, `yum`, `file`) before resorting to `command` or `shell`.
- When using `shell`, always quote your commands to avoid YAML parsing issues.

## Exercises
1. Run a `command` task that tries to echo `$PATH`. What is the result? Then do it with `shell`.
2. Use the `command` module with `creates` to run a "one-time setup" script on your Ubuntu VM.
3. Write a `shell` task that finds all `.log` files in `/var/log` that are older than 7 days and lists them in a local file.
4. Try using the `executable: /bin/bash` argument in a `shell` task and run a bash-specific command (like a process substitution `<(...)`).
