# Chapter 72: Decrypt an Ansible Vault - ansible-vault

Sometimes you need to permanently decrypt a file (e.g., if you are moving the data to a different secrets manager or if you made a mistake and want to start over).

## 1. Permanent Decryption

To remove encryption from a file permanently, use the `decrypt` command:

```bash
ansible-vault decrypt secrets.yml
```
After providing the current password, the file will be converted back to plain-text YAML.

## 2. Converting Plain-text to Vault

If you already have a plain-text file and want to encrypt it:

```bash
ansible-vault encrypt secrets.yml
```

## 3. Inline Vaulting (Variable-level encryption)

Instead of encrypting a whole file, you can encrypt a single string. This is useful for keeping some variables public while others are private within the same file.

### Encrypt a string:
```bash
ansible-vault encrypt_string 'my_super_secret' --name 'db_pass'
```
**Output Example:**
```yaml
db_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          3638363335343632313331303233363334333133313430333036313136343336
          ...
```
You can copy-paste this block directly into any YAML file.

## 4. Best Practices

1.  **Never commit `.vault_pass`**: Always add your password files to `.gitignore`.
2.  **Separate Files**: Keep sensitive variables in a dedicated file (like `secrets.yml` or `vault.yml`) rather than mixing them into every file.
3.  **Backup**: Don't lose your vault password! There is no "Forgot Password" feature. If you lose it, the data is gone forever.
4.  **no_log**: Always use `no_log: true` on tasks that handle vaulted data to prevent the password from appearing in job logs.

---

## Examples

### Example 1: `no_log` in action
```yaml
- name: Set database password
  ansible.builtin.shell: "mysql -u root -p{{ db_pass }} ..."
  no_log: true  # This prevents the command (with the password) from being logged
```

---

## Key Notes
- **Security**: AES256 is extremely strong. Your password length and complexity are the only real weak points.
- **Git diffs**: Encrypted files show as blobs in Git diffs, making it hard to see what changed. This is why some people prefer `encrypt_string` for specific variables.

## Exercises
1. Take a plain text file `test.txt` and encrypt it using `ansible-vault encrypt`.
2. Decrypt it back to plain text.
3. Use `encrypt_string` to create an encrypted version of the word "Welcome123" and paste it into a playbook.
4. Run the playbook and verify that Ansible can correctly read the string.
