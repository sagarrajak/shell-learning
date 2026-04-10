# Chapter 59: Using Date, Time and Timestamp without Facts in Ansible Playbook - Ansible date

Sometimes you turn off fact gathering (`gather_facts: no`) to speed up execution, or you need the current time at the *moment* a specific task runs, rather than when the playbook started.

## 1. Using the `pipe` Lookup

The most dynamic way to get the date without gathering facts is to call the Linux `date` command directly using a lookup plugin.

### Syntax
```jinja2
{{ lookup('pipe', 'date +%Y-%m-%d') }}
```

### Example
```yaml
- name: Get current date via pipe
  ansible.builtin.set_fact:
    current_time: "{{ lookup('pipe', 'date +%H:%M:%S') }}"
```

## 2. Using the `now()` Function (Ansible 2.9+)

Ansible introduced a built-in `now()` function that is much cleaner and doesn't require an external shell command.

### Syntax
```jinja2
{{ now(fmt='%Y-%m-%d %H:%M:%S') }}
```
*Note: `now()` returns a datetime object. Using the `fmt` parameter formats it into a string.*

## 3. Difference from Facts

| Method | When is it set? | Requires Facts? |
| :--- | :--- | :--- |
| `ansible_date_time` | Start of Playbook | Yes |
| `lookup('pipe', 'date')` | When task executes | No |
| `now()` | When task executes | No |

---

## Examples

### Example 1: `now()` with Formatting
```yaml
---
- name: Date without Facts
  hosts: localhost
  gather_facts: no
  tasks:
    - name: Show current year
      ansible.builtin.debug:
        msg: "The year is {{ now(fmt='%Y') }}"

    - name: Filename with precise seconds
      ansible.builtin.debug:
        msg: "Filename: backup-{{ now(fmt='%H%M%S') }}.tar.gz"
```

### Example 2: Pipe lookup for complex shell dates
```yaml
- name: Get date 7 days ago
  ansible.builtin.set_fact:
    last_week: "{{ lookup('pipe', 'date --date=\"7 days ago\" +%Y-%m-%d') }}"
```

---

## Key Notes
- **Local vs Remote**: Lookups (`pipe`) and `now()` execute on the **Control Node** (your machine), not the remote host.
- **Formatting**: Use standard `strftime` formatting strings (e.g., `%Y` for Year, `%m` for Month).

## Exercises
1. Write a playbook with `gather_facts: no` and print the current day of the week (e.g., "Monday").
2. Create a timestamp variable using `now()` that includes microseconds.
3. Why would you use `lookup('pipe', 'date')` instead of `ansible_date_time.date` in a playbook that runs for 2 hours?
