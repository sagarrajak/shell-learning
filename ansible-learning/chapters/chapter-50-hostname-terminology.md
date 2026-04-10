# Chapter 50: Ansible Terminology - ansible_hostname vs inventory_hostname

Understanding the difference between these two variables is crucial for targetting hosts correctly and writing dynamic configurations. 

## 1. `inventory_hostname`

The `inventory_hostname` is a **magic variable** that represents the name of the host as it is defined in your Ansible inventory file (e.g., `inventory.ini` or `hosts`).

- **Source**: Your inventory file.
- **Availability**: Always available (even if `gather_facts` is set to `false`).
- **Use Case**: Used for naming files, identifying hosts in loops, or conditional logic based on inventory labels.

## 2. `ansible_hostname`

The `ansible_hostname` is a **fact** gathered by Ansible from the remote machine itself during the fact-gathering phase.

- **Source**: The remote OS (e.g., the output of the `hostname` command).
- **Availability**: Only available if `gather_facts` is `true`.
- **Use Case**: Used for configurations that must match the actual OS-level hostname (e.g., setting up certificates, kernel logs, or cluster configurations).

---

## Comparison Table

| Feature | `inventory_hostname` | `ansible_hostname` |
| :--- | :--- | :--- |
| **Type** | Magic Variable | Fact |
| **Origin** | `inventory.ini` / `hosts` | Remote System Discovery |
| **Fact Gathering Required?** | No | Yes |
| **Common Value** | Alias (e.g., `web-01`) | OS Name (e.g., `srv-ubuntu-22`) |

---

## Examples

### Example 1: Comparing Both Variables
**File:** `chapters/chapter-50-example-1.yaml`
```yaml
---
- name: Compare Hostname Variables
  hosts: all
  gather_facts: true

  tasks:
    - name: Show inventory name
      ansible.builtin.debug:
        msg: "Name in inventory: {{ inventory_hostname }}"

    - name: Show actual OS hostname
      ansible.builtin.debug:
        msg: "Name on system: {{ ansible_hostname }}"
```

### Example 2: Using `inventory_hostname` without Facts
**File:** `chapters/chapter-50-example-2.yaml`
```yaml
---
- name: Working without Facts
  hosts: all
  gather_facts: false

  tasks:
    - name: This will work
      ansible.builtin.debug:
        msg: "I am working on {{ inventory_hostname }}"

    - name: This will FAIL
      ansible.builtin.debug:
        msg: "Actual hostname: {{ ansible_hostname }}"
      ignore_errors: true
```

### Example 3: Use Case - Creating Per-Host Log Files
Suppose you have an alias in inventory but want to save logs using the inventory name for consistency.

**File:** `chapters/chapter-50-example-3.yaml`
```yaml
---
- name: Setup Log Files
  hosts: all
  tasks:
    - name: Create unique log file
      ansible.builtin.file:
        path: "/tmp/log_{{ inventory_hostname }}.txt"
        state: touch
```

## How to Run
Create an inventory with an alias to see the difference clearly:
**inventory.ini**:
```ini
[web]
my-vm ansible_host=192.168.1.100
```

Run the comparison:
```bash
ansible-playbook -i inventory.ini chapters/chapter-50-example-1.yaml
```

*In this case, `inventory_hostname` will be `my-vm`, while `ansible_hostname` will likely be the actual hostname of the Ubuntu VM (e.g., `ubuntu`).*

## Key Notes
- If your inventory uses an IP address instead of a name (e.g., `[web]\n192.168.1.100`), then `inventory_hostname` will be `192.168.1.100`.
- Always use `inventory_hostname` when you need a stable ID that doesn't change even if the remote machine's configuration changes.
- Use `ansible_hostname` when you are configuring software that strictly requires the system's real name.

## Exercises
1. Modify your `inventory.ini` to use a creative alias for your VM (e.g., `batman-machine`). Run Example 1 and observe the output.
2. What happens if you rename the hostname on your VM using `sudo hostnamectl set-hostname new-name`? Which variable changes in Ansible?
3. Write a task that fails with a helpful message if `inventory_hostname` and `ansible_hostname` are **not** the same.
