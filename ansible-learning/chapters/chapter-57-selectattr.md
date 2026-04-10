# Chapter 57: Filter A List By Its Attributes - Ansible selectattr filter

In Ansible, you often work with lists of objects (dictionaries). The `selectattr` filter is a powerful tool used to filter these lists based on the values of specific attributes.

## 1. What is `selectattr`?

The `selectattr` filter works with a list of dictionaries. It iterates through the list and selects only the items where a specific attribute matches a given condition.

### Syntax
```jinja2
{{ list_of_dicts | selectattr('attribute_name', 'test_name', 'value') | list }}
```
*Note: You must almost always pipe the result to `| list` because Jinja2 filters return a generator by default.*

## 2. Common Tests for `selectattr`

- **`equalto`**: Matches an exact value.
- **`defined`**: Matches if the attribute exists.
- **`undefined`**: Matches if the attribute does not exist.
- **`match`**: Matches a regular expression.
- **`search`**: Searches for a substring.

## 3. Combining with `map`

Often, you want to filter a list and then extract a single attribute from the remaining items. You can combine `selectattr` with `map`.

```jinja2
{{ users | selectattr('active', 'equalto', true) | map(attribute='name') | list }}
```
This filters for active users and returns just a list of their names.

---

## Examples

### Example 1: Filtering Users
**File:** `lab/chapters/filters/selectattr-demo.yaml`

```yaml
---
- name: selectattr Filter Demo
  hosts: localhost
  connection: local
  vars:
    users:
      - { name: "alice", role: "admin", active: true }
      - { name: "bob", role: "developer", active: false }
      - { name: "charlie", role: "developer", active: true }

  tasks:
    - name: Get all admin users
      ansible.builtin.set_fact:
        admin_users: "{{ users | selectattr('role', 'equalto', 'admin') | list }}"

    - name: Get active developers
      ansible.builtin.set_fact:
        active_devs: "{{ users | selectattr('role', 'equalto', 'developer') | selectattr('active', 'equalto', true) | list }}"
```

### How to Run
```bash
ansible-playbook lab/chapters/filters/selectattr-demo.yaml
```

---

## Key Notes
- **Case Sensitivity**: Tests like `equalto` are case-sensitive.
- **Multiple Filters**: You can chain multiple `selectattr` filters together to apply multiple conditions (AND logic).
- **Default Values**: If an attribute might be missing, combine with `default` or use the `defined` test.

## Exercises
1. Create a list of 5 servers, each with a `name`, `type` (web/db), and `ram_gb`.
2. Filter the list to show only "web" servers.
3. Filter the list to show servers that have more than 8GB of RAM (Hint: use the `greaterthan` test).
4. Extract only the `name` of all "db" servers into a new list.
