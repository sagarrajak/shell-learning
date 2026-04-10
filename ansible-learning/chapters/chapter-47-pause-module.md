# Chapter 47: Pause execution - Ansible module pause

The `pause` module in Ansible allows you to pause playbook execution for a specified amount of time or until the user presses Enter. This is particularly useful for:
- Waiting for services to start
- Creating deliberate delays between operations
- Allowing manual intervention
- Preventing overwhelming systems with rapid changes

## Overview

The `pause` module can pause execution for a specific number of seconds, minutes, or wait indefinitely for user input.

## Basic Syntax

```yaml
- name: Pause for 30 seconds
  ansible.builtin.pause:
    seconds: 30
```

## Examples

### Example 1: Simple Timed Pause

**File:** `chapters/chapter-47-example-1.yaml`

```yaml
---
- name: Pause Module Examples - Timed Pause
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print starting message
      ansible.builtin.debug:
        msg: "Starting deployment process..."

    - name: Pause for 10 seconds
      ansible.builtin.pause:
        seconds: 10

    - name: Print completion message
      ansible.builtin.debug:
        msg: "Deployment process started 10 seconds ago"
```

### Example 2: Pause with Minutes

**File:** `chapters/chapter-47-example-2.yaml`

```yaml
---
- name: Pause Module Examples - Minutes Pause
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print initial message
      ansible.builtin.debug:
        msg: "Initiating system backup..."

    - name: Pause for 2 minutes
      ansible.builtin.pause:
        minutes: 2

    - name: Print backup message
      ansible.builtin.debug:
        msg: "Backup should be complete by now"
```

### Example 3: Interactive Pause (Wait for User Input)

**File:** `chapters/chapter-47-example-3.yaml`

```yaml
---
- name: Pause Module Examples - Interactive Pause
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Print warning message
      ansible.builtin.debug:
        msg: "WARNING: This task will modify system configuration"

    - name: Wait for user confirmation
      ansible.builtin.pause:
        prompt: "Press Enter to continue or Ctrl+C to cancel"

    - name: Print confirmation
      ansible.builtin.debug:
        msg: "User confirmed - proceeding with changes"

    - name: Another checkpoint
      ansible.builtin.debug:
        msg: "About to restart services"

    - name: Wait for user input with custom message
      ansible.builtin.pause:
        prompt: "Press Enter to restart services"

    - name: Print restart message
      ansible.builtin.debug:
        msg: "Services will be restarted now"
```

### Example 4: Pause with Custom Prompt Message

**File:** `chapters/chapter-47-example-4.yaml`

```yaml
---
- name: Pause Module Examples - Custom Prompts
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: First pause with informative prompt
      ansible.builtin.pause:
        prompt: "Please verify the target hosts are correct: {{ inventory_hostname }}. Press Enter to continue."

    - name: Second pause with warning
      ansible.builtin.pause:
        prompt: "WARNING: This will delete data. Press Enter to confirm or Ctrl+C to abort."

    - name: Third pause with instruction
      ansible.builtin.pause:
        prompt: "Open another terminal to monitor the service logs. Press Enter when ready."
```

### Example 5: Pause with Conditional Logic

**File:** `chapters/chapter-47-example-5.yaml`

```yaml
---
- name: Pause Module Examples - Conditional Pause
  hosts: all
  become: false
  gather_facts: true

  tasks:
    - name: Print system information
      ansible.builtin.debug:
        msg: "System: {{ ansible_distribution }} {{ ansible_distribution_version }}"

    - name: Pause only on Ubuntu systems
      ansible.builtin.pause:
        seconds: 5
        prompt: "Ubuntu system detected - pausing for 5 seconds"
      when: ansible_distribution == "Ubuntu"

    - name: Pause only on CentOS systems
      ansible.builtin.pause:
        seconds: 3
      when: ansible_distribution == "CentOS"

    - name: Print continuation message
      ansible.builtin.debug:
        msg: "Continuing with the playbook"
```

### Example 6: Pause in Service Restart Workflow

**File:** `chapters/chapter-47-example-6.yaml`

```yaml
---
- name: Pause Module Examples - Service Restart Workflow
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Stop the service
      ansible.builtin.systemd:
        name: nginx
        state: stopped

    - name: Wait for service to stop
      ansible.builtin.pause:
        seconds: 5

    - name: Update configuration
      ansible.builtin.debug:
        msg: "Configuration updated (simulated)"

    - name: Pause before starting
      ansible.builtin.pause:
        seconds: 2
        prompt: "Configuration updated. Press Enter to start the service."

    - name: Start the service
      ansible.builtin.systemd:
        name: nginx
        state: started

    - name: Wait for service to be fully operational
      ansible.builtin.pause:
        seconds: 10

    - name: Verify service status
      ansible.builtin.systemd:
        name: nginx
      register: service_status

    - name: Print service status
      ansible.builtin.debug:
        msg: "Service is {{ service_status.status.ActiveState }}"
```

### Example 7: Pause with Loops

**File:** `chapters/chapter-47-example-7.yaml`

```yaml
---
- name: Pause Module Examples - Pause with Loops
  hosts: all
  become: false
  gather_facts: false

  vars:
    services:
      - service-a
      - service-b
      - service-c

  tasks:
    - name: Process each service with delay
      ansible.builtin.debug:
        msg: "Processing {{ item }}"

    - name: Pause between service processing
      ansible.builtin.pause:
        seconds: 3
      loop: "{{ services }}"
      loop_control:
        pause: 3
```

### Example 8: Pause for Manual Verification

**File:** `chapters/chapter-47-example-8.yaml`

```yaml
---
- name: Pause Module Examples - Manual Verification
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Stop database service
      ansible.builtin.systemd:
        name: mysql
        state: stopped

    - name: Pause for manual database backup
      ansible.builtin.pause:
        prompt: "Database stopped. Please perform manual backup now. Press Enter when backup is complete."

    - name: Start database service
      ansible.builtin.systemd:
        name: mysql
        state: started

    - name: Wait for database to be ready
      ansible.builtin.pause:
        seconds: 15

    - name: Pause for database connection test
      ansible.builtin.pause:
        prompt: "Database should be ready now. Please test the connection manually. Press Enter to continue."

    - name: Print completion message
      ansible.builtin.debug:
        msg: "Database restoration process complete"
```

### Example 9: Pause with Error Handling

**File:** `chapters/chapter-47-example-9.yaml`

```yaml
---
- name: Pause Module Examples - Error Handling
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Attempt a task that might fail
      ansible.builtin.command:
        cmd: /nonexistent/command
      register: command_result
      ignore_errors: true

    - name: Pause if task failed
      ansible.builtin.pause:
        prompt: "Task failed! Please investigate. Press Enter to continue or Ctrl+C to abort."
      when: command_result.failed

    - name: Print error details if failed
      ansible.builtin.debug:
        msg: "Command failed with error: {{ command_result.stderr }}"
      when: command_result.failed
```

### Example 10: Progressive Pause Pattern

**File:** `chapters/chapter-47-example-10.yaml`

```yaml
---
- name: Pause Module Examples - Progressive Pause
  hosts: all
  become: false
  gather_facts: false

  tasks:
    - name: Initial short pause
      ansible.builtin.pause:
        seconds: 5

    - name: Medium pause
      ansible.builtin.pause:
        minutes: 1

    - name: Longer pause
      ansible.builtin.pause:
        minutes: 3

    - name: Print completion
      ansible.builtin.debug:
        msg: "All pauses completed - total wait time: ~4 minutes"
```

## How to Run These Examples

1. **Create an inventory file** (`inventory.ini`):

```ini
[webservers]
your-ubuntu-vm-ip ansible_user=your-username ansible_ssh_private_key_file=~/.ssh/id_rsa
```

2. **Run individual examples**:

```bash
# Run example with automatic pauses
ansible-playbook -i inventory.ini chapters/chapter-47-example-1.yaml

# Run example with interactive pauses (requires user input)
ansible-playbook -i inventory.ini chapters/chapter-47-example-3.yaml

# Run service restart workflow
ansible-playbook -i inventory.ini chapters/chapter-47-example-6.yaml
```

3. **To bypass interactive pauses**, use the `--skip-tags` or environment variable:

```bash
# Skip all pauses (set ANSIBLE_HOST_KEY_CHECKING=False if needed)
ANSIBLE_STRATEGY=free ansible-playbook -i inventory.ini chapters/chapter-47-example-3.yaml
```

## Key Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `seconds` | Number of seconds to pause | No | - |
| `minutes` | Number of minutes to pause | No | - |
| `prompt` | Custom prompt message to display | No | "Paused" |
| `echo` | Whether to echo user input | No | True |

## Important Notes

- **Only use one time parameter** (`seconds` OR `minutes`, not both)
- If neither time parameter is specified, the pause waits indefinitely for user input
- Interactive pauses require user to press Enter to continue
- Pauses can be skipped by pressing Ctrl+C to abort the playbook
- Use `become: false` with pause module as it runs locally, not on the target host
- The pause module doesn't affect the target system, only playbook execution flow

## Common Use Cases

1. **Service Dependencies**: Wait for one service to fully start before starting another
2. **Manual Interventions**: Allow operator to perform manual tasks
3. **Rate Limiting**: Prevent overwhelming APIs or systems
4. **Staggered Deployments**: Deploy to hosts with delays between them
5. **Verification Points**: Allow manual verification before proceeding

## Best Practices

1. **Use descriptive prompts** to explain what the user should do
2. **Set reasonable timeout values** for automated pauses
3. **Document interactive pauses** in playbook comments
4. **Consider using `serial`** with pause for rolling updates
5. **Test pause durations** in non-production environments first

## Exercises

1. Create a playbook that pauses for 30 seconds between stopping and starting a service
2. Write a playbook that asks for user confirmation before making critical changes
3. Create a playbook that uses conditional pauses based on the target system type
4. Implement a rolling update pattern with pauses between host updates
5. Create a playbook with multiple verification checkpoints requiring user input
