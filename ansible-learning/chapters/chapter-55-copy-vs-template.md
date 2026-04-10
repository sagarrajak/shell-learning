# Chapter 55: Write a Variable to a File - copy vs template

There are two primary ways to write data or variables into files on remote nodes: the `copy` module and the `template` module. While they can sometimes achieve the same goal, they have distinct purposes.

## 1. The `copy` Module

The `copy` module is used for moving files from the control node to the remote nodes, or for writing simple strings directly into a file using the `content` parameter.

- **Best For**: Binary files, static configuration files, or very small simple strings.
- **Dynamic Content**: Can insert variables using `{{ var }}`, but it gets messy for large or complex files.

### Example (String to File)
```yaml
- name: Save a simple variable to a file
  ansible.builtin.copy:
    content: "The environment is {{ deployment_env }}\n"
    dest: /tmp/env_info.txt
```

## 2. The `template` Module

The `template` module is the "powerhouse" for file management. it uses the **Jinja2** templating engine to generate files on the fly. You create a template file (usually with a `.j2` extension) and Ansible processes it before sending it.

- **Best For**: Complex configuration files with logic (loops, conditionals, math).
- **Features**: Supports loops, `if/else`, and complex filters.

### Example (Template to File)
```yaml
- name: Deploy dynamic Nginx config
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

---

## Comparison Table

| Feature | `copy` (with `content`) | `template` |
| :--- | :--- | :--- |
| **Logic (if/else)** | Very limited | Full Jinja2 support |
| **Source Type** | String or Static File | Template File (`.j2`) |
| **Readability** | Good for short strings | Excellent for large configs |
| **Use Case** | Quick simple writes | Production configurations |

---

## Examples

### Example 1: Writing a simple variable with `copy`
**File:** `chapters/chapter-55-example-1.yaml`
```yaml
---
- name: Simple Variable Write
  hosts: all
  vars:
    app_version: "2.5.4"
  tasks:
    - name: Write version file
      ansible.builtin.copy:
        content: "VERSION={{ app_version }}\nDATE={{ lookup('pipe', 'date') }}\n"
        dest: /tmp/version.txt
```

### Example 2: Using a `template` for multiple variables
**File:** `chapters/chapter-55-example-2.yaml`
**Template File:** `chapters/motd.j2`
```text
Welcome to {{ ansible_hostname }}!
Managed by: {{ inventory_hostname }}
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Memory: {{ ansible_memtotal_mb }} MB
```

**Playbook:**
```yaml
---
- name: Update MOTD using Template
  hosts: all
  tasks:
    - name: Apply MOTD template
      ansible.builtin.template:
        src: motd.j2
        dest: /etc/motd
      become: true
```

### Example 3: Templates with Logic (Loops)
**Template File:** `chapters/users.j2`
```text
{% for user in sys_users %}
User: {{ user.name }} (Role: {{ user.role }})
{% endfor %}
```

**Playbook:**
```yaml
---
- name: Generate User List
  hosts: all
  vars:
    sys_users:
      - { name: "alice", role: "admin" }
      - { name: "bob", role: "developer" }
  tasks:
    - name: Create user report
      ansible.builtin.template:
        src: users.j2
        dest: /tmp/system_users.txt
```

## How to Run
```bash
ansible-playbook -i inventory.ini chapters/chapter-55-example-2.yaml
```

## Key Notes
- **Line Endings**: Both modules ensure the file ends with a newline if configured, but `copy (content)` is safer for simple scripts.
- **Permissions**: Both support `owner`, `group`, and `mode` to set file permissions.
- **Validation**: `template` supports a `validate` parameter (e.g., `validate: 'visudo -cf %s'`) to check syntax before overwriting the target file.

## Exercises
1. Create a `copy` task that saves your current local `$USER` name into `/tmp/ansible_user.txt` on the VM.
2. Write a Jinja2 template (`db.conf.j2`) that defines a database connection string using `db_host`, `db_user`, and `db_pass` variables. Apply it using the `template` module.
3. Use a `template` with an `if` statement to add a line to a file only if the target OS is "Ubuntu".
4. Experiment with the `backup: yes` parameter on both modules. What happens when you run the playbook twice with different content?
