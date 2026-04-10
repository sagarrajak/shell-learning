# Chapter 51: Set remote environment - Ansible environment statement

Sometimes you need to run tasks that require specific environment variables, such as a custom `PATH`, a proxy URL, or an API key. Ansible provides the `environment` keyword to handle this at the play or task level.

## 1. How it Works

The `environment` keyword accepts a dictionary of environment variables. These variables are only set **for the duration of the task or play** and do not permanently change the environment of the remote user.

- **Play Level**: Apply variables to every task in the play.
- **Task Level**: Apply variables only to a specific task.

## 2. Basic Syntax

```yaml
- name: Run a task with specific environment variables
  ansible.builtin.shell: echo $MY_VAR
  environment:
    MY_VAR: "Hello from Ansible"
    PATH: "/opt/custom/bin:{{ ansible_env.PATH }}"
```

---

## Examples

### Example 1: Task-Level Environment
**File:** `chapters/chapter-51-example-1.yaml`
```yaml
---
- name: Task Level Environment Example
  hosts: all
  tasks:
    - name: Print a custom environment variable
      ansible.builtin.shell: echo "Value of APP_STAGE is $APP_STAGE"
      environment:
        APP_STAGE: "production"
      register: result

    - name: Show output
      ansible.builtin.debug:
        msg: "{{ result.stdout }}"
```

### Example 2: Play-Level Environment (Global for Play)
**File:** `chapters/chapter-51-example-2.yaml`
```yaml
---
- name: Play Level Environment Example
  hosts: all
  environment:
    HTTP_PROXY: "http://proxy.example.com:8080"
    HTTPS_PROXY: "http://proxy.example.com:8080"

  tasks:
    - name: Download a file using the proxy
      ansible.builtin.get_url:
        url: "http://example.com/file.txt"
        dest: "/tmp/file.txt"

    - name: Install a package via proxy
      ansible.builtin.apt:
        name: git
        state: present
```

### Example 3: Using a Dictionary for environment
For cleaner code, you can define your environment in a separate variable.

**File:** `chapters/chapter-51-example-3.yaml`
```yaml
---
- name: Environment via Variables
  hosts: all
  vars:
    my_env:
      DB_URL: "mysql://localhost:3306"
      DB_USER: "admin"

  tasks:
    - name: Use the environment dictionary
      ansible.builtin.shell: "echo Connecting to $DB_URL as $DB_USER"
      environment: "{{ my_env }}"
```

### Example 4: Modifying the PATH
**File:** `chapters/chapter-51-example-4.yaml`
```yaml
---
- name: Update PATH for session
  hosts: all
  tasks:
    - name: Run a command in a non-standard location
      ansible.builtin.shell: "my-custom-tool --version"
      environment:
        PATH: "/usr/local/custom/bin:{{ ansible_env.PATH }}"
```

## How to Run
```bash
ansible-playbook -i inventory.ini chapters/chapter-51-example-1.yaml
```

## Comparison: `vars` vs `environment`

| Feature | `vars` | `environment` |
| :--- | :--- | :--- |
| **Usage** | Jinja2 templating (`{{ var }}`) | Shell variables (`$VAR`) |
| **Scope** | Available anywhere in Ansible | Available only to the executed shell/command |
| **Purpose** | Ansible logic | Remote execution context |

## Key Notes
- `environment` does **not** permanently export variables to `~/.bashrc` or `/etc/environment`.
- When using `become: true`, environment variables are passed through to the new user session (though some OS security settings like `env_keep` in sudoers may restrict this).
- Use `ansible_env` to access existing remote environment variables (requires `gather_facts: true`).

## Exercises
1. Create a playbook that sets a `VERSION` environment variable and uses a shell command to print it.
2. Define a "proxy" dictionary in `group_vars/all` and apply it to a task that uses the `uri` module.
3. Try setting an environment variable at the Play level and then overriding it at the Task level. Which one wins?
4. Use `environment` to set a temporary `TMPDIR` for a task that generates large temporary files.
