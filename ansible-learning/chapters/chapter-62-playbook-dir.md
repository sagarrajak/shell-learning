# Chapter 62: Current ansible-playbook Path - playbook_dir Magic Variable

Hardcoding paths in playbooks makes them difficult to share or move. The `playbook_dir` magic variable is the best way to reference files relative to the playbook's location on your disk.

## 1. What is `playbook_dir`?

`playbook_dir` is a magic variable that contains the absolute path to the directory where the `.yml` or `.yaml` file you are currently running is located.

- **Purpose**: To find templates, scripts, or configuration files that are stored alongside your playbook.
- **Dynamic**: It changes automatically based on where the playbook file resides.

## 2. Why use it instead of relative paths?

While Ansible often looks for files in a `files/` or `templates/` folder relative to the playbook, sometimes you need to pass an **absolute path** to a command or module.

Using a naked relative path like `./config.txt` might fail if you run the playbook from a different directory (e.g., if you are in your home folder and run `ansible-playbook projects/ansible/site.yml`).

### Correct way
```yaml
- name: Run a local script
  ansible.builtin.shell: "{{ playbook_dir }}/scripts/setup.sh"
```

---

## Examples

### Example 1: Referencing a local file
```yaml
---
- name: Playbook Dir Demo
  hosts: localhost
  tasks:
    - name: Show the playbook directory
      ansible.builtin.debug:
        msg: "The playbook is located at: {{ playbook_dir }}"

    - name: Use it in a path
      ansible.builtin.copy:
        src: "{{ playbook_dir }}/my_custom_config.conf"
        dest: /tmp/config.conf
```

### Example 2: Building paths for multiple files
```yaml
- name: Process logs directory
  ansible.builtin.find:
    paths: "{{ playbook_dir }}/logs"
    patterns: "*.log"
  register: found_logs
```

---

## Key Notes
- **Playbook level**: This variable is defined at the playbook level.
- **Role level**: If you are inside a role, use `role_path` instead to get the directory of the current role.
- **Absolute Path**: It always returns an absolute path (starts with `/`).

## Exercises
1. Create a task that prints `playbook_dir`.
2. Move your playbook to a subdirectory and run it. Observe how the value changes.
3. Try to use `{{ playbook_dir }}/../other_folder/` to reference a file one level above your playbook. This is a common pattern for shared assets.
