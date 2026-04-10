# Chapter 60: Ansible Playbook Dry Run - Check and Diff Mode

Before running a playbook on production systems, it is vital to know exactly what changes will be made. Ansible provides two flags for this: `--check` and `--diff`.

## 1. Check Mode (`--check` / `-C`)

Check mode is a "dry run". It simulates what would happen if the playbook were run, without actually making any changes to the remote systems.

- **Reports**: It will report "ok", "changed", "failed", etc.
- **Limitation**: Not all modules support check mode. Some tasks (like complex shell commands) might always report "changed" or might be skipped.

### Usage
```bash
ansible-playbook -i inventory.ini site.yml --check
```

## 2. Diff Mode (`--diff` / `-D`)

Diff mode shows the actual line-by-line changes being made to files, similar to the `diff` command in Linux.

- **Use case**: Best used with the `template`, `copy`, `lineinfile`, or `replace` modules.
- **Safety**: Usually used *with* `--check` so you can see the changes before they are applied.

### Usage
```bash
ansible-playbook -i inventory.ini site.yml --diff
```

### Combined Usage (Recommended)
```bash
ansible-playbook -i inventory.ini site.yml --check --diff
```

## 3. Controlling Check Mode per Task

Sometimes you want a task to run even during a dry run (like a read-only command), or you want to always skip a task during a dry run.

- **`check_mode: no`**: The task will run normally even if the playbook is in check mode. (Useful for `command` or `shell` tasks that gather info needed by later tasks).
- **`check_mode: yes`**: The task will *always* run in check mode, even if the playbook is not.

---

## Examples

### Example 1: Checking a configuration change
```yaml
---
- name: Diff Demo
  hosts: all
  tasks:
    - name: Ensure MOTD has correct content
      ansible.builtin.copy:
        content: "Property of TechCorp - Authorized Access Only\n"
        dest: /etc/motd
```
Run with: `ansible-playbook demo.yml --check --diff`

### Example 2: Using `check_mode: no`
```yaml
- name: Get current kernel version
  ansible.builtin.command: uname -r
  register: kernel_info
  check_mode: no # This command is safe and needed for logic, so run it even in dry run
```

---

## Key Notes
- **False Positives**: In check mode, a task might fail if it depends on a file or directory that *would* have been created by a previous task.
- **Security**: `--diff` can reveal sensitive information (like passwords in config files). Be careful when using it on shared CI/CD logs.

## Exercises
1. Run a playbook that creates a file. Use `--check` and verify the file was NOT created.
2. Modify an existing file on your VM using `lineinfile` and use `--diff` to see the exact line being added.
3. Combine `--check` and `--diff`. What is the benefit of using both together?
