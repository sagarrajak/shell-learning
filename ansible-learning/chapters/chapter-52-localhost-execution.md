# Chapter 52: Execute command on the Ansible host - Ansible localhost

While Ansible is designed to manage remote nodes, you often need to perform tasks on your local machine (the **Control Node**). Examples include making API calls to cloud providers, generating local reports, or sending notifications.

## 1. Using `hosts: localhost`

This is the simplest way to run an entire play locally. Ansible automatically knows how to connect to `localhost`.

### Example
```yaml
- name: Local Playbook
  hosts: localhost
  connection: local  # Bypasses SSH for better performance
  tasks:
    - name: Create a local temporary file
      ansible.builtin.tempfile:
        state: file
      register: tmp_file
```

## 2. Using `delegate_to: localhost`

This allows you to run a single task on the local machine while the rest of the play runs on remote hosts. This is extremely useful for "side-effect" tasks.

### Example
```yaml
- name: Remote Play with Local Steps
  hosts: webservers
  tasks:
    - name: Record deployment start locally
      ansible.builtin.shell: "echo 'Starting deploy on {{ inventory_hostname }}' >> /tmp/deploy.log"
      delegate_to: localhost
```

---

## Examples

### Example 1: Local File Management
**File:** `chapters/chapter-52-example-1.yaml`
```yaml
---
- name: Local File Operations
  hosts: localhost
  connection: local
  gather_facts: false

  tasks:
    - name: Create a local directory for reports
      ansible.builtin.file:
        path: ./reports
        state: directory

    - name: Generate a local timestamped file
      ansible.builtin.copy:
        content: "Report generated at {{ lookup('pipe', 'date') }}\n"
        dest: "./reports/report_{{ lookup('pipe', 'date +%Y%m%d') }}.txt"
```

### Example 2: Delegating to Localhost (Log aggregation)
**File:** `chapters/chapter-52-example-2.yaml`
```yaml
---
- name: Remote Tasks with Local Logging
  hosts: all
  tasks:
    - name: Get uptime from remote
      ansible.builtin.command: uptime
      register: rem_uptime

    - name: Log remote uptime to local file
      ansible.builtin.lineinfile:
        path: /tmp/remote_uptimes.log
        line: "{{ inventory_hostname }}: {{ rem_uptime.stdout }}"
        create: yes
      delegate_to: localhost
```

### Example 3: local_action shorthand
`local_action` is a legacy but common way to write `delegate_to: localhost`.

**File:** `chapters/chapter-52-example-3.yaml`
```yaml
---
- name: Using local_action
  hosts: all
  tasks:
    - name: Print something locally
      local_action:
        module: ansible.builtin.debug
        msg: "Processing host {{ inventory_hostname }}"
```

## How to Run
```bash
ansible-playbook -i inventory.ini chapters/chapter-52-example-1.yaml
```

## When to use what?

| Option | Purpose |
| :--- | :--- |
| `hosts: localhost` | The entire play is for the local machine. |
| `delegate_to: localhost` | A specific task needs to run locally (e.g., updating a local load balancer config while deploying to a node). |
| `connection: local` | Used with `hosts: localhost` to avoid unnecessary SSH overhead. |

## Key Notes
- **Implicit localhost**: You don't usually need to add `localhost` to your inventory file; Ansible provides it by default.
- **Paths**: When running on localhost, paths like `/tmp/` refer to your local machine, not the remote VM.
- **Variables**: `inventory_hostname` will be `localhost` for local plays, but will be the remote node name if using `delegate_to: localhost`.

## Exercises
1. Create a playbook with `hosts: all` that downloads a web page (using `uri` module) on the LOCAL host for each remote server in your inventory.
2. Use `delegate_to: localhost` to append the output of `ls /etc` from your remote VM into a file on your local machine.
3. Compare the time it takes to run a "Hello World" debug on `localhost` with and without `connection: local`.
4. Create a folder locally and generate a separate report file for each server in your group.
