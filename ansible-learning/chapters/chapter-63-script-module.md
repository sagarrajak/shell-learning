# Chapter 63: Run a Python Script on Remote Machines - Ansible module script

While Ansible has modules for almost everything, sometimes you have an existing Python, Bash, or Perl script that you just want to run on multiple remote servers without rewrite. The `script` module is designed exactly for this.

## 1. What is the `script` module?

The `script` module takes a script from your **local control node**, transfers it to the **remote host**, and executes it.

- **Advantage**: The script does not need to exist on the remote host before running the playbook.
- **Cleanup**: Ansible automatically removes the script from the remote host after execution finishes.
- **Language**: It can run any script (Bash, Python, etc.) as long as the remote host has the required interpreter (like `/usr/bin/python3`) in the shebang.

## 2. Basic Syntax

```yaml
- name: Run my custom script
  ansible.builtin.script: /path/to/local/script.py
```

## 3. Passing Arguments

You can pass arguments to your script just like you would on the command line.

```yaml
- name: Run script with arguments
  ansible.builtin.script: /path/to/local/script.sh --argument value
```

## 4. Skip if file exists (`creates`)

To make the task idempotent (so it doesn't run every time), use the `creates` or `removes` parameter.

```yaml
- name: Run script only if output file doesn't exist
  ansible.builtin.script: setup_db.sh
  args:
    creates: /var/lib/myapp/db_initialized
```

---

## Examples

### Example 1: Running a Python script
Imagine you have a file named `hello.py` on your machine:
```python
#!/usr/bin/python3
import os
print(f"Hello from {os.uname()[1]}!")
```

**Playbook:**
```yaml
---
- name: Python Script Demo
  hosts: all
  tasks:
    - name: Execute local python script on remote
      ansible.builtin.script: hello.py
      register: script_output

    - name: Show output
      ansible.builtin.debug:
        msg: "{{ script_output.stdout }}"
```

---

## Key Notes
- **Shebang**: Your script MUST have a shebang line (e.g., `#!/bin/bash` or `#!/usr/bin/env python3`).
- **Permissions**: Ansible handles the execution permissions automatically.
- **Output**: The results are captured in standard variables like `stdout` and `stderr`.

## Exercises
1. Write a simple bash script that prints the current system uptime. Run it on your VM using the `script` module.
2. Create a Python script that lists all files in `/tmp`. Capture the output in an Ansible variable and print it.
3. Use the `args: executable: /usr/bin/python3` parameter if your script doesn't have a shebang. (Note: check Ansible docs for `executable` support in script module).
