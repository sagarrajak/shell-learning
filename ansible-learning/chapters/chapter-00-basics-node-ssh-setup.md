# Chapter 00: Ansible Fundamentals - Node Setup, SSH, and First Playbook

Before you can orchestrate your infrastructure with Ansible, you need a solid foundation. This chapter covers how to set up your Ubuntu nodes, configure secure access via SSH, and run your very first "Hello World" playbook.

## 1. Setting up your Ubuntu Node (Proxmox/VM)

If you are using a VM in Proxmox, ensure the following:
- **OS**: Ubuntu 22.04 or 24.04 recommended.
- **Network**: The VM must have a static IP or a reserved DHCP address so Ansible can consistently find it.
- **User**: Create a standard user with sudo privileges (e.g., `sagar`).

### Update the Node
Log into your VM manually one last time to prepare it:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install python3 -y  # Ansible requires Python on the target node
```

## 2. Setting Up Passwordless SSH

Ansible works best when it can log in without being prompted for a password.

### Step A: Generate SSH Key on your Control Node (Host)
On your main machine (where Ansible is installed), generate a key pair if you don't have one:
```bash
ssh-keygen -t ed25519 -C "ansible-key"
# Press Enter for defaults, or set a passphrase
```

### Step B: Copy the Key to your Ubuntu VM
Use the `ssh-copy-id` tool to transfer your public key:
```bash
ssh-copy-id sagar@192.168.1.100  # Replace with your VM IP
```
*Note: You will be asked for the VM user's password once.*

### Step C: Verify Connection
You should now be able to log in without a password:
```bash
ssh sagar@192.168.1.100
exit
```

## 3. Creating Your First Inventory

Ansible needs to know which machines to manage. Create a file named `inventory.ini`.

**File:** `inventory.ini`
```ini
[my_nodes]
ubuntu-vm ansible_host=192.168.1.100 ansible_user=sagar
```

## 4. Your First "Hello World" Playbook

Now, let's create a simple playbook to verify everything is working.

**File:** `chapters/chapter-00-hello-world.yaml`
```yaml
---
- name: Ansible Hello World
  hosts: my_nodes
  gather_facts: false

  tasks:
    - name: Print a welcome message
      ansible.builtin.debug:
        msg: "Hello World! Ansible is successfully connected to {{ inventory_hostname }}"

    - name: Run a simple shell command
      ansible.builtin.command:
        cmd: uptime
      register: uptime_result

    - name: Show the uptime
      ansible.builtin.debug:
        msg: "System Uptime: {{ uptime_result.stdout }}"
```

## 5. Running the Playbook

Execute the playbook using the `ansible-playbook` command:

```bash
ansible-playbook -i inventory.ini chapters/chapter-00-hello-world.yaml
```

### Expected Output
```text
PLAY [Ansible Hello World] *****************************************************

TASK [Print a welcome message] *************************************************
ok: [ubuntu-vm] => {
    "msg": "Hello World! Ansible is successfully connected to ubuntu-vm"
}

TASK [Run a simple shell command] **********************************************
changed: [ubuntu-vm]

TASK [Show the uptime] *********************************************************
ok: [ubuntu-vm] => {
    "msg": "System Uptime:  13:45:01 up 2 days,  4:12,  1 user,  load average: 0.00, 0.01, 0.05"
}

PLAY RECAP *********************************************************************
ubuntu-vm                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## Key Concept: The Control Node vs. Managed Node
- **Control Node**: Your local machine or server where Ansible is installed.
- **Managed Node**: The remote servers (like your Proxmox Ubuntu VM) that you are managing.

## Exercises
1. Add a second VM to your `inventory.ini` and run the hello-world playbook against both.
2. Change the `msg` in the debug task to include your VM's IP address.
3. Try running the command with `-v` (verbose) to see the background details of the connection.
