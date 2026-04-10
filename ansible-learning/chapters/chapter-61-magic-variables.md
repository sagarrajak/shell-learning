# Chapter 61: Ansible Magic Variables - Ansible Tip and Tricks

Magic variables are variables that are automatically defined by Ansible. They provide information about the inventory, groups, and the status of other hosts in the network.

## 1. What are Magic Variables?

Unlike standard variables or facts, magic variables are "reserved" names. They allow you to access data that Ansible tracks internally.

## 2. Most Commonly Used Magic Variables

### `hostvars`
Allows you to access variables (and gathered facts) of other hosts in the inventory.
```jinja2
{{ hostvars['db_server']['ansible_eth0']['ipv4']['address'] }}
```

### `inventory_hostname`
The name of the current host as it appears in the inventory file. (Useful if the VM matches a DNS name but you want the short name from inventory).

### `groups`
A dictionary of all groups in the inventory and the hosts belonging to them.
```jinja2
{{ groups['webservers'] }} # Returns a list of hostnames in the group
```

### `group_names`
A list of all groups the current host belongs to.

### `ansible_play_hosts`
A list of all hosts currently being managed in the active play.

---

## Examples

### Example 1: Accessing variables from another host
```yaml
---
- name: Magic Vars Demo
  hosts: webservers
  tasks:
    - name: Get Database IP from DB Group
      ansible.builtin.debug:
        msg: "The database IP is {{ hostvars[groups['db'][0]]['ansible_default_ipv4']['address'] }}"
```

### Example 2: Checking group membership
```yaml
- name: Perform task only for production nodes
  ansible.builtin.debug:
    msg: "System is in production!"
  when: "'production' in group_names"
```

---

## Key Notes
- **Fact Gathering**: To access facts of *other* hosts via `hostvars`, you must have run a play against those hosts in the same session, or use fact caching.
- **Read Only**: Do not try to overwrite magic variables.
- **Inventory Dependencies**: These variables rely heavily on how your `inventory.ini` or `hosts.yaml` is structured.

## Exercises
1. Print the value of `inventory_hostname` for your VM.
2. Create a task that prints all the groups your current host belongs to using `group_names`.
3. Loop through all hosts in the `all` group and print their names using `groups['all']`.
4. What happens if you try to access `hostvars['non_existent_host']`?
