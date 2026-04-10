# Chapter 71: Use Ansible Vault in Ansible Playbook - ansible-vault

Learning the basic commands of `ansible-vault` is essential for managing encrypted secrets.

## 1. Creating an Encrypted File

To create a new encrypted file from scratch:
```bash
ansible-vault create secrets.yml
```
Ansible will ask for a password and then open your default text editor (like `vi` or `nano`). Anything you save in this file will be encrypted on disk.

## 2. Viewing and Editing

You cannot use `cat` to view an encrypted file. Instead, use:
- **`view`**: Shows the content in your terminal.
- **`edit`**: Opens the file in an editor to change its contents.

```bash
ansible-vault view secrets.yml
ansible-vault edit secrets.yml
```

## 3. Running a Playbook with Vault

When your playbook uses a vaulted file, you must tell Ansible how to decrypt it.

### Method A: Manual Input
```bash
ansible-playbook site.yml --ask-vault-pass
```

### Method B: Password File (Recommended for automation)
Create a file containing your password (and exclude it from Git!):
```bash
echo "mypassword" > .vault_pass
chmod 600 .vault_pass
ansible-playbook site.yml --vault-password-file .vault_pass
```

## 4. Rekeying (Changing the password)
If a password is compromised, you can change it without decrypting the data:
```bash
ansible-vault rekey secrets.yml
```

---

## Examples

### Example 1: Defining Vaulted Variables
**File:** `secrets.yml` (Encrypted)
```yaml
db_password: "SuperSecretPassword123"
api_token: "xyz-789-abc"
```

**Playbook:**
```yaml
---
- name: Use vaulted variables
  hosts: all
  vars_files:
    - secrets.yml
  tasks:
    - name: Connect to database
      ansible.builtin.debug:
        msg: "Connecting with password: {{ db_password }}"
```

---

## Key Notes
- **Visibility**: Even with Vault, be careful not to print sensitive variables to the screen using the `debug` module in production. Use `no_log: true` on sensitive tasks.
- **Default Editor**: Ansible uses the `$EDITOR` environment variable.

## Exercises
1. Create a vaulted file named `api_keys.yml` with a dummy key.
2. Use `ansible-vault view` to read it.
3. Try to run a playbook that uses this file without the `--ask-vault-pass` flag. What is the error message?
4. Setup a `.vault_pass` file and run the playbook using the `--vault-password-file` argument.
