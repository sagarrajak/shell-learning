# Chapter 49: Break a string over multiple lines - Literal and Folded Block Operators

Handling long strings or multi-line configurations is common in Ansible. YAML provides special "Block Scalar" operators to handle these gracefully: the **Literal (`|`)** and **Folded (`>`)** operators.

## 1. Literal Block Operator (`|`)

The literal operator preserves newlines exactly as they are written. It is commonly used for shell scripts, SSH keys, or configuration files where line breaks matter.

### Syntax
```yaml
description: |
  This is line one.
  This is line two.
  The newlines are preserved.
```

## 2. Folded Block Operator (`>`)

The folded operator converts single newlines into spaces. It "folds" a long paragraph into a single line in the final string, unless there is a blank line or a line with more indentation.

### Syntax
```yaml
long_paragraph: >
  This string will be
  folded into a single
  line when processed.
```

## 3. Chomping Operators (`+` and `-`)

You can control how trailing newlines at the end of a block are handled using chomping indicators:

| Operator | Name | Effect |
| :--- | :--- | :--- |
| `|` or `>` | Clip (Default) | Keeps the single final newline at the end. |
| `|-` or `>-` | Strip | Removes all trailing newlines. |
| `|+` or `>+` | Keep | Preserves all trailing newlines (up to the end of the file/block). |

---

## Examples

### Example 1: Literal vs Folded Strings
**File:** `chapters/chapter-49-example-1.yaml`
```yaml
---
- name: Multiline String Examples
  hosts: localhost
  gather_facts: false
  vars:
    literal_string: |
      First Line
      Second Line
    folded_string: >
      First Line
      Second Line

  tasks:
    - name: Show Literal string
      ansible.builtin.debug:
        var: literal_string

    - name: Show Folded string
      ansible.builtin.debug:
        var: folded_string
```

### Example 2: Creating a Script with Literal Operator
**File:** `chapters/chapter-49-example-2.yaml`
```yaml
---
- name: Create a script using literal block
  hosts: all
  tasks:
    - name: Create a bash script on target
      ansible.builtin.copy:
        dest: /tmp/test_script.sh
        content: |
          #!/bin/bash
          echo "Current user: $(whoami)"
          echo "System Uptime: $(uptime)"
        mode: '0755'
```

### Example 3: Long Command with Folded Operator
**File:** `chapters/chapter-49-example-3.yaml`
```yaml
---
- name: Long command example
  hosts: all
  tasks:
    - name: Run a long command folded for readability
      ansible.builtin.shell: >
        docker run -d 
        --name my-web-server 
        -p 8080:80 
        -v /tmp/data:/usr/share/nginx/html:ro 
        nginx:latest
```

### Example 4: Stripping Newlines (`|-`)
**File:** `chapters/chapter-49-example-4.yaml`
```yaml
---
- name: Chomping indicator example
  hosts: localhost
  vars:
    stripped: |-
      This text has no
      trailing newline.

  tasks:
    - name: Debug stripped content
      ansible.builtin.debug:
        msg: "Content: '{{ stripped }}'"
```

## How to Run
```bash
ansible-playbook -i inventory.ini chapters/chapter-49-example-1.yaml
```

## Best Practices
1. **Use `|`** for code, scripts, or formatted configs (e.g., `/etc/motd`).
2. **Use `>`** for long messages or commands to keep your YAML file skinny and readable.
3. **Use `|-`** if you are templating a value into a config file where a trailing newline might break syntax (e.g., certain SSH or API keys).

## Exercises
1. Create a playbook that uses a Literal block to create a multi-line `/etc/issue` file on your Ubuntu VM.
2. Experiment with the Folded operator and double newlines. What happens to the double newline in the output?
3. Use the `copy` module with `content: |+` and check the resulting file using `cat -e` on the destination.
