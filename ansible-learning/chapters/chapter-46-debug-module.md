# Chapter 46: Print a text/variable during execution - Ansible module debug

The `debug` module is one of the most essential and frequently used modules in Ansible. It allows you to print messages and variable values during playbook execution, making it invaluable for debugging, troubleshooting, and providing information to operators.

## Overview

The `debug` module doesn't make any changes to the target system; it simply prints output to the console. This makes it safe to use in production environments for logging and debugging purposes.

## Basic Syntax

```yaml
- name: Print a simple message
  ansible.builtin.debug:
    msg: "This is a debug message"
```

## Examples

### Example 1: Printing Simple Messages

**File:** `chapters/chapter-46-example-1.yaml`

```yaml
---
- name: Debug Module Examples - Simple Messages
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print a hello message
      ansible.builtin.debug:
        msg: "Hello from Ansible!"

    - name: Print multiple messages
      ansible.builtin.debug:
        msg: "Task completed successfully"

    - name: Print information about current task
      ansible.builtin.debug:
        msg: "Running task on {{ inventory_hostname }}"
```

### Example 2: Printing Variables

**File:** `chapters/chapter-46-example-2.yaml`

```yaml
---
- name: Debug Module Examples - Variables
  hosts: all
  become: false
  gather_facts: true

  tasks:
    - name: Print hostname
      ansible.builtin.debug:
        msg: "System hostname is {{ ansible_hostname }}"

    - name: Print OS distribution
      ansible.builtin.debug:
        msg: "Operating System: {{ ansible_distribution }} {{ ansible_distribution_version }}"

    - name: Print IP address
      ansible.builtin.debug:
        msg: "Primary IP: {{ ansible_default_ipv4.address }}"

    - name: Print memory information
      ansible.builtin.debug:
        msg: "Total Memory: {{ ansible_memtotal_mb }} MB"
```

### Example 3: Using Custom Variables

**File:** `chapters/chapter-46-example-3.yaml`

```yaml
---
- name: Debug Module Examples - Custom Variables
  hosts: all
  become: false
  gather_facts: false

  vars:
    app_name: "web-server"
    app_version: "1.2.3"
    deployment_env: "production"

  tasks:
    - name: Print application information
      ansible.builtin.debug:
        msg: "Deploying {{ app_name }} version {{ app_version }} to {{ deployment_env }}"

    - name: Print variable with custom format
      ansible.builtin.debug:
        msg: |
          Application: {{ app_name }}
          Version: {{ app_version }}
          Environment: {{ deployment_env }}
          Target Host: {{ inventory_hostname }}
```

### Example 4: Debug with Variable Directly

**File:** `chapters/chapter-46-example-4.yaml`

```yaml
---
- name: Debug Module Examples - Direct Variable Printing
  hosts: all
  become: false
  gather_facts: true

  tasks:
    - name: Print variable directly (no msg parameter)
      ansible.builtin.debug:
        var: ansible_distribution

    - name: Print complex variable
      ansible.builtin.debug:
        var: ansible_facts

    - name: Print specific fact
      ansible.builtin.debug:
        var: ansible_facts['default_ipv4']
```

### Example 5: Debug with Verbosity Control

**File:** `chapters/chapter-46-example-5.yaml`

```yaml
---
- name: Debug Module Examples - Verbosity Control
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: This message always shows
      ansible.builtin.debug:
        msg: "This message always appears"

    - name: This message only shows with -v or higher verbosity
      ansible.builtin.debug:
        msg: "This message requires verbosity level 1"
        verbosity: 1

    - name: This message only shows with -vv or higher verbosity
      ansible.builtin.debug:
        msg: "This message requires verbosity level 2"
        verbosity: 2

    - name: This message only shows with -vvv or higher verbosity
      ansible.builtin.debug:
        msg: "This message requires verbosity level 3"
        verbosity: 3
```

### Example 6: Debug in Conditional Statements

**File:** `chapters/chapter-46-example-6.yaml`

```yaml
---
- name: Debug Module Examples - Conditional Debug
  hosts: all
  become: false
  gather_facts: true

  tasks:
    - name: Check if system is Ubuntu
      ansible.builtin.debug:
        msg: "This system is running Ubuntu {{ ansible_distribution_version }}"
      when: ansible_distribution == "Ubuntu"

    - name: Check if system has at least 2GB RAM
      ansible.builtin.debug:
        msg: "System has sufficient RAM: {{ ansible_memtotal_mb }} MB"
      when: ansible_memtotal_mb >= 2048

    - name: Print warning if disk space is low
      ansible.builtin.debug:
        msg: "WARNING: Root disk space is below 20% - {{ ansible_mounts[0].size_available }} bytes available"
      when: ansible_mounts[0].size_available < ansible_mounts[0].size_total * 0.2
```

### Example 7: Debug with Loops

**File:** `chapters/chapter-46-example-7.yaml`

```yaml
---
- name: Debug Module Examples - Loops
  hosts: all
  become: false
  gather_facts: false

  vars:
    packages_to_install:
      - nginx
      - mysql-server
      - redis-server
      - python3-pip

  tasks:
    - name: Print each package name
      ansible.builtin.debug:
        msg: "Package to install: {{ item }}"
      loop: "{{ packages_to_install }}"

    - name: Print package with index
      ansible.builtin.debug:
        msg: "Package {{ index + 1 }}: {{ item }}"
      loop: "{{ packages_to_install }}"
      loop_control:
        index_var: index
```

### Example 8: Debug for Troubleshooting

**File:** `chapters/chapter-46-example-8.yaml`

```yaml
---
- name: Debug Module Examples - Troubleshooting
  hosts: all
  become: true
  gather_facts: true

  tasks:
    - name: Check if a service is running
      ansible.builtin.systemd:
        name: nginx
        state: started
      register: service_status

    - name: Debug service status
      ansible.builtin.debug:
        var: service_status

    - name: Print specific service information
      ansible.builtin.debug:
        msg: "Service status: {{ service_status.status.ActiveState }}"

    - name: Get file content
      ansible.builtin.slurp:
        src: /etc/hostname
      register: hostname_content

    - name: Decode and print file content
      ansible.builtin.debug:
        msg: "Hostname file content: {{ hostname_content.content | b64decode }}"
```

## How to Run These Examples

1. **Create an inventory file** (`inventory.ini`):

```ini
[webservers]
your-ubuntu-vm-ip ansible_user=your-username ansible_ssh_private_key_file=~/.ssh/id_rsa
```

2. **Run individual examples**:

```bash
# Run with default verbosity
ansible-playbook -i inventory.ini chapters/chapter-46-example-1.yaml

# Run with increased verbosity to see debug messages
ansible-playbook -i inventory.ini chapters/chapter-46-example-2.yaml -v

# Run with even more verbosity
ansible-playbook -i inventory.ini chapters/chapter-46-example-5.yaml -vvv
```

## Common Use Cases

1. **Debugging Playbooks**: Print variable values to understand data flow
2. **Progress Reporting**: Show users what's happening during long operations
3. **Logging**: Record important information in playbook output
4. **Testing**: Verify variables and facts before using them
5. **Conditional Logic**: Check conditions and print appropriate messages

## Key Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `msg` | Custom message to print | No | "Hello world!" |
| `var` | Variable name to print (instead of msg) | No | - |
| `verbosity` | Minimum verbosity level to show message | No | 0 |

## Important Notes

- **Either `msg` or `var` should be used**, not both
- The `msg` parameter supports Jinja2 templating for variable interpolation
- The `var` parameter prints the raw variable, often useful for complex data structures
- Debug output is captured in Ansible logs and can be reviewed later
- Use `verbosity` to control when debug messages appear, reducing noise in normal runs

## Exercises

1. Create a playbook that prints all network interfaces of the target system
2. Write a playbook that prints a custom message only if the system has more than 4 CPU cores
3. Create a playbook that loops through a list of users and prints their home directories
4. Use `debug` with `var` to print the entire `ansible_facts` dictionary
5. Create a playbook that prints debug messages at different verbosity levels and test with `-v`, `-vv`, and `-vvv` flags
