# Chapter 53: Three Options to Safely Limit Ansible Playbook Execution

In production, you often want to run a playbook against only one specific machine to test a change or perform maintenance, even if your inventory contains hundreds of servers. Here are the three most common ways to do that safely.

## 1. Using the `--limit` (or `-l`) Flag (Command Line)

This is the most common and safest method because it doesn't require modifying your playbook code. It restricts the execution to a specific host or group at runtime.

### Syntax
```bash
ansible-playbook -i inventory.ini my_playbook.yaml --limit "web-01"
```
- **Works on**: Hosts, Groups, or IP addresses.
- **Safety**: Excellent. If you forget to add it, the playbook runs on everything (so be careful!).

---

## 2. Setting `hosts:` to a Specific Host (In Playbook)

You can hardcode the target host or a specific group directly in the playbook file.

### Example
```yaml
---
- name: Dedicated Maintenance Playbook
  hosts: my-specific-vm  # Only runs on this host
  tasks:
    - name: Restart service
      ansible.builtin.service:
        name: nginx
        state: restarted
```
- **Pros**: Clear intention.
- **Cons**: Less flexible; you have to edit the file to target a different machine.

---

## 3. Using `run_once: true` (At Task Level)

If you have a play running against many hosts, but a specific task only needs to happen once (like creating a database or sending an email), use `run_once`.

### Example
```yaml
---
- name: Deploy to Cluster
  hosts: all
  tasks:
    - name: Update code on all servers
      ansible.builtin.git:
        repo: 'https://github.com/example/repo.git'
        dest: /var/www/html

    - name: Run database migration (ONLY ONCE)
      ansible.builtin.command: php artisan migrate
      run_once: true
```
- **Behavior**: The task will run on the first host in the list and be skipped for all others.

---

## Bonus: Using `serial: 1` (Rolling Updates)

While not strictly "limiting to one machine forever", `serial: 1` ensures that Ansible completes the entire play on one machine before moving to the next. This is a very safe way to perform updates.

```yaml
---
- name: Safe Rolling Update
  hosts: webservers
  serial: 1
  tasks:
    - name: Update and Restart
      ansible.builtin.apt:
        name: nginx
        state: latest
```

---

## Examples

### Example 1: Testing with --limit
**File:** `chapters/chapter-53-example-1.yaml`
```yaml
---
- name: Hello from many hosts
  hosts: all
  tasks:
    - name: Identify myself
      ansible.builtin.debug:
        msg: "I am running on {{ inventory_hostname }}"
```
**Run command:**
```bash
# Only runs on 'vm1' even if inventory has vm1, vm2, vm3
ansible-playbook -i inventory.ini chapters/chapter-53-example-1.yaml --limit "vm1"
```

### Example 2: run_once for Database Setup
**File:** `chapters/chapter-53-example-2.yaml`
```yaml
---
- name: Distributed Task with Single Setup
  hosts: all
  tasks:
    - name: Initialize global config
      ansible.builtin.shell: "echo 'Global Init' > /tmp/global.cfg"
      run_once: true

    - name: Normal task for all
      ansible.builtin.debug:
        msg: "Processing host {{ inventory_hostname }}"
```

## Comparison

| Method | Where to define | Best for... |
| :--- | :--- | :--- |
| `--limit` | Command Line | Ad-hoc maintenance or testing. |
| `hosts: name` | Playbook | Playbooks that are specific to a single server. |
| `run_once` | Task Level | Tasks like DB migrations or global notifications. |
| `serial: 1` | Play Level | Safe, one-by-one deployments. |

## Key Notes
- `run_once` is often used with `delegate_to: localhost` to ensure a local command runs exactly once during a multi-node play.
- You can combine `--limit` with patterns, like `--limit "webservers:&production"` (intersect) or `--limit "webservers:!dbservers"` (exclude).

## Exercises
1. Create an inventory with three dummy hosts and run a debug playbook using `--limit` to target only the second one.
2. Write a playbook targeting `all` that uses `run_once` to create a file in `/tmp/once.txt` and verify it only exists on one server.
3. Try `serial: 1` on a playbook with a `pause` module. Observe how it waits for each server individually.
4. Experiment with exclusion: run a playbook on all hosts *except* your primary VM using `--limit`.
