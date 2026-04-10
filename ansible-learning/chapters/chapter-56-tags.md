# Chapter 56: How to Run Only One Task in Ansible Playbook? - Ansible Tags

When working with large playbooks, you often want to run only a subset of tasks without executing the entire file. Ansible **Tags** allow you to label tasks and filter execution from the command line.

## 1. What are Tags?

Tags are attributes you can add to tasks, blocks, or even entire plays. They act as "labels" that you can reference when running `ansible-playbook`.

### Syntax
```yaml
tasks:
  - name: Install Nginx
    ansible.builtin.apt:
      name: nginx
      state: present
    tags: install
```

## 2. Running Specific Tags

To run only the tasks with a specific tag, use the `--tags` (or `-t`) flag.

```bash
ansible-playbook -i inventory.ini site.yml --tags "install"
```

To run multiple tags, separate them with commas:
```bash
ansible-playbook -i inventory.ini site.yml --tags "install,setup"
```

## 3. Skipping Tags

If you want to run everything *except* specific tasks, use `--skip-tags`.

```bash
ansible-playbook -i inventory.ini site.yml --skip-tags "debug"
```

## 4. Special Tags

Ansible has a few built-in special tags:

- **`always`**: Tasks with this tag will run unless you specifically skip them with `--skip-tags always`.
- **`never`**: Tasks with this tag will *only* run if you specifically request them with `--tags never`.
- **`tagged`**: Run only tasks that have at least one tag.
- **`untagged`**: Run only tasks that have no tags.
- **`all`**: (Default) Run all tasks.

---

## Examples

### Example 1: Basic Tagging
**File:** `lab/chapters/tags/tags-demo.yaml`

```yaml
---
- name: Tags Demo Playbook
  hosts: localhost
  connection: local
  tasks:
    - name: Task 1 - Update System
      ansible.builtin.debug:
        msg: "Updating system..."
      tags: setup

    - name: Task 2 - Install Web Server
      ansible.builtin.debug:
        msg: "Installing Apache..."
      tags: install

    - name: Task 3 - Start Web Server
      ansible.builtin.debug:
        msg: "Starting Apache service..."
      tags:
        - service
        - install
```

### How to Run

1. Run only installation tasks:
   ```bash
   ansible-playbook lab/chapters/tags/tags-demo.yaml --tags install
   ```
2. Run everything except setup:
   ```bash
   ansible-playbook lab/chapters/tags/tags-demo.yaml --skip-tags setup
   ```

---

## Key Notes
- **Inheritance**: If you tag a `block`, all tasks inside that block inherit the tag.
- **Play Level**: You can tag an entire play to run/skip all its tasks.
- **Multiple Tags**: A single task can have multiple tags as a list.

## Exercises
1. Create a playbook with 3 tasks: "Create Folder", "Create File", "Delete File". Tag them appropriately.
2. Run the playbook so only "Create Folder" and "Create File" run.
3. Use the `always` tag on a "Print Status" task and observe its behavior when you run other specific tags.
4. Try to run a task tagged with `never`. What flag do you need to use?
