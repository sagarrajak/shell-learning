# Chapter 70: Ansible terminology - What is an Ansible Vault?

In modern DevOps, security is non-negotiable. You should never store plain-text passwords, API keys, or SSL certificates in your Git repository. **Ansible Vault** is the built-in feature that solves this problem.

## 1. What is Ansible Vault?

Ansible Vault is a feature that allows you to encrypt any structured data file used by Ansible. This include:
- `group_vars` and `host_vars` files.
- Files passed to the `vars_files` directive.
- Variables defined in `inventory` files.
- Any other YAML file containing sensitive data.

## 2. How it Works

Ansible Vault uses **AES256** encryption to provide symmetrical encryption (the same password is used to encrypt and decrypt).

When a file is encrypted with Vault:
1.  The content becomes unreadable to humans and machines without the password.
2.  The file starts with a header like `$ANSIBLE_VAULT;1.1;AES256`.
3.  You can safely commit this encrypted file to your version control system (like GitHub).

## 3. Why Use It?

- **Compliance**: Many security standards (like SOC2 or PCI-DSS) forbid storing secrets in plain text.
- **Collaboration**: You can share your playbooks with teammates without sharing the actual secrets.
- **Simplicity**: No need for complex third-party secret managers (like HashiCorp Vault or AWS Secrets Manager) for basic projects.

---

## Key Notes
- **Granularity**: You can encrypt entire files or just specific strings (inline encryption).
- **Passwords**: You can use a single password for the whole project or different passwords for different environments (Vault IDs).

## Exercises
1. Research the command used to check if a file is an Ansible Vault.
2. What happens if you try to run a playbook that requires an encrypted variable but you don't provide a password?
3. Can Ansible Vault encrypt binary files (like an SSH private key)? (Hint: Yes, any file can be encrypted).
