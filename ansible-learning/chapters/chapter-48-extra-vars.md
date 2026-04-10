# Chapter 48: How to Pass Variables to Ansible Playbook in the command line? - Ansible extra-vars

Passing variables from the command line is a powerful feature in Ansible that allows you to make your playbooks dynamic and reusable. The `--extra-vars` (or `-e`) flag enables you to pass variables at runtime without modifying playbook files.

## Overview

Command-line variables override variables defined in playbooks, inventory files, and group/host vars. This makes them perfect for:
- Environment-specific configurations
- One-off parameter changes
- Dynamic values during CI/CD pipelines
- Testing with different configurations

## Basic Syntax

```bash
# Single variable
ansible-playbook playbook.yml -e "variable_name=value"

# Multiple variables
ansible-playbook playbook.yml -e "var1=value1" -e "var2=value2"

# JSON format
ansible-playbook playbook.yml -e '{"var1": "value1", "var2": "value2"}'

# Variables from file
ansible-playbook playbook.yml -e "@variables.json"
ansible-playbook playbook.yml -e "@variables.yml"
```

## Examples

### Example 1: Simple String Variables

**File:** `chapters/chapter-48-example-1.yaml`

```yaml
---
- name: Command Line Variables - Simple Strings
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print deployment environment
      ansible.builtin.debug:
        msg: "Deploying to environment: {{ deployment_env }}"

    - name: Print application version
      ansible.builtin.debug:
        msg: "Application version: {{ app_version }}"

    - name: Print database name
      ansible.builtin.debug:
        msg: "Database: {{ db_name }}"
```

**Run command:**
```bash
ansible-playbook -i inventory.ini chapters/chapter-48-example-1.yaml \
  -e "deployment_env=staging" \
  -e "app_version=2.3.1" \
  -e "db_name=app_staging"
```

### Example 2: Numeric Variables

**File:** `chapters/chapter-48-example-2.yaml`

```yaml
---
- name: Command Line Variables - Numeric Values
  hosts: all
  become: false
  gather_facts: true

  tasks:
    - name: Set timeout value
      ansible.builtin.debug:
        msg: "Timeout set to {{ timeout }} seconds"

    - name: Create directories based on count
      ansible.builtin.debug:
        msg: "Will create {{ dir_count }} directories"

    - name: Calculate total based on count and multiplier
      ansible.builtin.debug:
        msg: "Total: {{ item_count * multiplier }}"
```

**Run command:**
```bash
ansible-playbook -i inventory.ini chapters/chapter-48-example-2.yaml \
  -e "timeout=30" \
  -e "dir_count=5" \
  -e "item_count=10" \
  -e "multiplier=2"
```

### Example 3: Boolean Variables

**File:** `chapters/chapter-48-example-3.yaml`

```yaml
---
- name: Command Line Variables - Boolean Values
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Debug mode enabled?
      ansible.builtin.debug:
        msg: "Debug mode is {{ 'enabled' if debug_mode else 'disabled' }}"

    - name: Enable verbose logging?
      ansible.builtin.debug:
        msg: "Verbose logging is {{ 'enabled' if verbose_logging else 'disabled' }}"

    - name: Perform backup?
      ansible.builtin.debug:
        msg: "Backup will be performed: {{ perform_backup }}"

    - name: Install optional packages?
      ansible.builtin.debug:
        msg: "Optional packages installation: {{ install_optional }}"
```

**Run commands:**
```bash
# With booleans enabled
ansible-playbook -i inventory.ini chapters/chapter-48-example-3.yaml \
  -e "debug_mode=true" \
  -e "verbose_logging=true" \
  -e "perform_backup=true" \
  -e "install_optional=false"

# With booleans disabled
ansible-playbook -i inventory.ini chapters/chapter-48-example-3.yaml \
  -e "debug_mode=false" \
  -e "perform_backup=false"
```

### Example 4: List Variables

**File:** `chapters/chapter-48-example-4.yaml`

```yaml
---
- name: Command Line Variables - List Values
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print package list
      ansible.builtin.debug:
        msg: "Packages to install: {{ packages }}"

    - name: Print each package
      ansible.builtin.debug:
        msg: "Package: {{ item }}"
      loop: "{{ packages }}"

    - name: Print user list
      ansible.builtin.debug:
        msg: "Users to create: {{ users }}"

    - name: Print each user
      ansible.builtin.debug:
        msg: "User: {{ item }}"
      loop: "{{ users }}"
```

**Run command:**
```bash
ansible-playbook -i inventory.ini chapters/chapter-48-example-4.yaml \
  -e 'packages=["nginx","mysql-server","redis-server","python3-pip"]' \
  -e 'users=["admin","developer","tester"]'
```

### Example 5: Dictionary/Map Variables

**File:** `chapters/chapter-48-example-5.yaml`

```yaml
---
- name: Command Line Variables - Dictionary Values
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print application configuration
      ansible.builtin.debug:
        msg: "App name: {{ app_config.name }}, Port: {{ app_config.port }}"

    - name: Print database configuration
      ansible.builtin.debug:
        msg: "DB Host: {{ db_config.host }}, Port: {{ db_config.port }}, Name: {{ db_config.name }}"

    - name: Print feature flags
      ansible.builtin.debug:
        msg: "Feature {{ item.key }} is {{ 'enabled' if item.value else 'disabled' }}"
      loop: "{{ feature_flags | dict2items }}"
```

**Run command:**
```bash
ansible-playbook -i inventory.ini chapters/chapter-48-example-5.yaml \
  -e '{"app_config": {"name": "webapp", "port": 8080}}' \
  -e '{"db_config": {"host": "localhost", "port": 3306, "name": "appdb"}}' \
  -e '{"feature_flags": {"cache": true, "logging": true, "analytics": false}}'
```

### Example 6: Variables from File

**File:** `chapters/chapter-48-example-6.yaml`

```yaml
---
- name: Command Line Variables - From File
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print environment configuration
      ansible.builtin.debug:
        msg: "Environment: {{ config.environment }}"

    - name: Print application settings
      ansible.builtin.debug:
        msg: "Debug: {{ config.debug }}, Log Level: {{ config.log_level }}"

    - name: Print server configuration
      ansible.builtin.debug:
        msg: "Server: {{ config.server.host }}:{{ config.server.port }}"
```

**Variables file:** `chapters/vars-production.yml`

```yaml
config:
  environment: production
  debug: false
  log_level: error
  server:
    host: 0.0.0.0
    port: 8080
```

**Variables file:** `chapters/vars-staging.yml`

```yaml
config:
  environment: staging
  debug: true
  log_level: debug
  server:
    host: 0.0.0.0
    port: 8080
```

**Run commands:**
```bash
# Load from YAML file
ansible-playbook -i inventory.ini chapters/chapter-48-example-6.yaml \
  -e "@chapters/vars-production.yml"

# Load from different environment
ansible-playbook -i inventory.ini chapters/chapter-48-example-6.yaml \
  -e "@chapters/vars-staging.yml"
```

### Example 7: JSON Format Variables

**File:** `chapters/chapter-48-example-7.yaml`

```yaml
---
- name: Command Line Variables - JSON Format
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print deployment configuration
      ansible.builtin.debug:
        msg: "Deploying {{ app.name }} v{{ app.version }} to {{ app.env }}"

    - name: Print servers
      ansible.builtin.debug:
        msg: "Server: {{ item }}"
      loop: "{{ servers }}"

    - name: Print configuration
      ansible.builtin.debug:
        msg: "{{ item.key }}: {{ item.value }}"
      loop: "{{ config | dict2items }}"
```

**Run command:**
```bash
ansible-playbook -i inventory.ini chapters/chapter-48-example-7.yaml \
  -e '{"app": {"name": "myapp", "version": "3.0.0", "env": "production"}, "servers": ["server1", "server2", "server3"], "config": {"replicas": 3, "cpu": "2", "memory": "4Gi"}}'
```

### Example 8: Multiple Variable Sources

**File:** `chapters/chapter-48-example-8.yaml`

```yaml
---
- name: Command Line Variables - Multiple Sources
  hosts: all
  become: false
  gather_facts: false

  vars:
    # Default values in playbook
    default_env: "development"
    default_port: 3000

  tasks:
    - name: Print environment (with precedence)
      ansible.builtin.debug:
        msg: "Environment: {{ deployment_env | default(default_env) }}"

    - name: Print port (with precedence)
      ansible.builtin.debug:
        msg: "Port: {{ app_port | default(default_port) }}"

    - name: Print feature flag
      ansible.builtin.debug:
        msg: "Feature enabled: {{ enable_feature }}"

    - name: Print override value
      ansible.builtin.debug:
        msg: "Override value: {{ override_value }}"
```

**Run commands:**
```bash
# Mix of command-line vars and defaults
ansible-playbook -i inventory.ini chapters/chapter-48-example-8.yaml \
  -e "deployment_env=staging" \
  -e "app_port=8080" \
  -e "enable_feature=true"

# Override everything
ansible-playbook -i inventory.ini chapters/chapter-48-example-8.yaml \
  -e "deployment_env=production" \
  -e "app_port=443" \
  -e "enable_feature=false" \
  -e "override_value=custom"
```

### Example 9: Dynamic Variables with Command Substitution

**File:** `chapters/chapter-48-example-9.yaml`

```yaml
---
- name: Command Line Variables - Dynamic Values
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print deployment ID
      ansible.builtin.debug:
        msg: "Deployment ID: {{ deployment_id }}"

    - name: Print timestamp
      ansible.builtin.debug:
        msg: "Deployment timestamp: {{ deploy_timestamp }}"

    - name: Print build number
      ansible.builtin.debug:
        msg: "Build number: {{ build_number }}"

    - name: Print git branch
      ansible.builtin.debug:
        msg: "Git branch: {{ git_branch }}"
```

**Run commands:**
```bash
# Using command substitution for dynamic values
ansible-playbook -i inventory.ini chapters/chapter-48-example-9.yaml \
  -e "deployment_id=DEPLOY-$(date +%Y%m%d-%H%M%S)" \
  -e "deploy_timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  -e "build_number=BUILD-$(git rev-parse --short HEAD)" \
  -e "git_branch=$(git rev-parse --abbrev-ref HEAD)"
```

### Example 10: Complex Configuration Scenario

**File:** `chapters/chapter-48-example-10.yaml`

```yaml
---
- name: Command Line Variables - Complex Configuration
  hosts: all
  become: true
  gather_facts: true

  tasks:
    - name: Print deployment information
      ansible.builtin.debug:
        msg: |
          Deployment Details:
          - Environment: {{ deployment.env }}
          - Region: {{ deployment.region }}
          - Release: {{ deployment.release }}
          - Rollback: {{ deployment.rollback | default(false) }}

    - name: Install packages based on environment
      ansible.builtin.apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop: "{{ packages[deployment.env] }}"
      when: ansible_os_family == "Debian"

    - name: Configure application
      ansible.builtin.debug:
        msg: |
          Application Config:
          - Name: {{ app.name }}
          - Port: {{ app.port }}
          - Workers: {{ app.workers }}
          - Debug: {{ app.debug }}

    - name: Print database connection string
      ansible.builtin.debug:
        msg: "Database URL: {{ db.type }}://{{ db.user }}:{{ db.password }}@{{ db.host }}:{{ db.port }}/{{ db.name }}"
      no_log: true
```

**Run command:**
```bash
ansible-playbook -i inventory.ini chapters/chapter-48-example-10.yaml \
  -e '{"deployment": {"env": "production", "region": "us-west-2", "release": "v2.5.0"}}' \
  -e '{"packages": {"production": ["nginx", "mysql-server"], "staging": ["nginx", "mysql-server", "redis-server"]}}' \
  -e '{"app": {"name": "webapp", "port": 8080, "workers": 4, "debug": false}}' \
  -e '{"db": {"type": "mysql", "user": "appuser", "password": "secretpass", "host": "db.example.com", "port": 3306, "name": "appdb"}}'
```

## How to Run These Examples

1. **Create an inventory file** (`inventory.ini`):

```ini
[webservers]
your-ubuntu-vm-ip ansible_user=your-username ansible_ssh_private_key_file=~/.ssh/id_rsa
```

2. **Run individual examples** with appropriate variables:

```bash
# Example 1: Simple variables
ansible-playbook -i inventory.ini chapters/chapter-48-example-1.yaml \
  -e "deployment_env=staging" \
  -e "app_version=1.0.0"

# Example 6: Variables from file
ansible-playbook -i inventory.ini chapters/chapter-48-example-6.yaml \
  -e "@chapters/vars-production.yml"

# Example 7: JSON format
ansible-playbook -i inventory.ini chapters/chapter-48-example-7.yaml \
  -e '{"app": {"name": "myapp", "version": "1.0.0"}}'
```

## Variable Precedence Order

When the same variable is defined in multiple places, Ansible uses this priority order (highest to lowest):

1. **Command line extra vars** (`-e` or `--extra-vars`)
2. Role defaults
3. Inventory file or script group vars
4. Inventory group_vars/all
5. Playbook group_vars/all
6. Inventory file or script host vars
7. Inventory host_vars/*
8. Playbook host_vars/*
9. Host facts
10. Play vars
11. Play vars_prompt
12. Play vars_files
13. Role vars
14. Block vars
15. Task vars

## Important Notes

- **Command-line variables override all other variable sources**
- Use single quotes when passing variables with special characters
- Boolean values should be lowercase: `true` or `false`
- For complex data structures, use JSON format or external files
- Sensitive data passed via command line may appear in process lists and logs
- Use Ansible Vault for secrets instead of command-line variables

## Best Practices

1. **Use environment-specific variable files** instead of many `-e` flags
2. **Document required variables** in playbook comments
3. **Set sensible defaults** in playbooks for optional variables
4. **Avoid passing sensitive data** via command line (use Ansible Vault)
5. **Validate variables** at the start of playbooks using `assert` module

## Common Use Cases

1. **CI/CD Pipelines**: Pass build numbers, git branches, and deployment targets
2. **Multi-Environment Deployments**: Switch between dev, staging, production
3. **One-Off Tasks**: Override specific values for special cases
4. **Testing**: Test playbooks with different configurations
5. **Dynamic Configuration**: Pass runtime values like timestamps or IDs

## Exercises

1. Create a playbook that accepts `app_name`, `version`, and `environment` variables via command line
2. Write a playbook that uses a list variable passed from command line to install multiple packages
3. Create environment-specific variable files and load them using `@` syntax
4. Implement a playbook with default values that can be overridden via command line
5. Create a deployment playbook that accepts a dictionary with deployment settings
