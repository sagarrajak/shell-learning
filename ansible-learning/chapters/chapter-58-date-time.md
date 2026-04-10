# Chapter 58: Using Date, Time and Timestamp in Ansible Playbook - Ansible Tip and Tricks

Timestamps are essential for logging, creating unique filenames, or managing time-sensitive configurations. Ansible provides built-in facts and filters to handle date and time easily.

## 1. Using `ansible_date_time` Facts

By default, when Ansible gathers facts, it collects detailed time information from the remote host. These are stored in the `ansible_date_time` dictionary.

### Key Attributes:
- `ansible_date_time.date`: YYYY-MM-DD
- `ansible_date_time.time`: HH:MM:SS
- `ansible_date_time.iso8601`: Full ISO format
- `ansible_date_time.epoch`: Unix timestamp (seconds since 1970)
- `ansible_date_time.year`, `month`, `day`, `hour`, `minute`, `second`

### Example Usage
```yaml
- name: Print current date
  ansible.builtin.debug:
    msg: "Today's date is {{ ansible_date_time.date }}"

- name: Create a backup file with timestamp
  ansible.builtin.copy:
    src: config.conf
    dest: "/backups/config.conf.{{ ansible_date_time.date }}_{{ ansible_date_time.hour }}{{ ansible_date_time.minute }}"
```

## 2. Important Note on Facts

The `ansible_date_time` fact is collected at the **start** of the play. If your playbook runs for a long time, this value will remain the same as when the play started.

---

## Examples

### Example 1: Logging Job Start Time
```yaml
---
- name: Fact Date Demo
  hosts: all
  tasks:
    - name: Record start time
      ansible.builtin.debug:
        msg: "Job started at {{ ansible_date_time.iso8601 }}"
```

### Example 2: Dynamic Filenames
```yaml
- name: Save report
  ansible.builtin.template:
    src: report.j2
    dest: "/tmp/report-{{ ansible_date_time.epoch }}.txt"
```

---

## Key Notes
- **Timezone**: The facts gathered are based on the **remote host's** timezone.
- **Gather Facts**: Ensure `gather_facts: yes` (default) is set, otherwise these variables won't exist.

## Exercises
1. Create a playbook that prints the current Year and Month.
2. Use the `epoch` fact to create a file in `/tmp/` with a unique name every time the playbook runs.
3. Compare `ansible_date_time.time` vs `ansible_date_time.time_local`. (Note: lookup standard Ansible facts for the difference).
