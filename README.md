# ansible-winscan

Ansible playbook to scan Windows hosts for security vulnerabilities and potential backdoors using PowerShell scripts.

## Stack

Ansible (YAML), PowerShell

## Usage

```bash
# Configure inventory
# Edit inventory/hosts with your Windows targets

# Run the playbook
ansible-playbook playbooks/scan.yml
```

## Structure

```
ansible-winscan/
├── inventory/       # Windows host inventory
├── playbooks/       # Ansible playbooks
├── roles/           # Scan role with PowerShell scripts
└── scripts/         # PowerShell scan scripts
```

## Requirements

- Ansible control node
- Windows hosts configured for WinRM
- PowerShell execution policy

## License

MIT
