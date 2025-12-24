# P.R.I.S.M.

**P**olicy **R**igid **I**nfrastructure for **S**ecure **M**achines

An automated deployment framework for hardening and securing Linux servers through systematic configuration and security policy enforcement. Designed for Wazuh agent integration, achieving a Lynis hardening index score of 84 (pre-Wazuh installation).

## Quick Start

### Prerequisites

- **Control node**: 
  - Ansible >= 2.12
  - Python 3.6+
  - Make (optional, for shortcuts)
- **Target hosts**: 
  - Debian 12
  - Python 3
  - SSH access with sudo privileges

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Creaous/PRISM.git
   cd PRISM
   ```

2. **Install Ansible dependencies**
   ```bash
   make install
   # or manually:
   ansible-galaxy install -r requirements.yml
   ```

3. **Create inventory file**
   ```bash
   make init-inventory
   # or manually create inventory.ini:
   cat > inventory.ini << EOF
   [staging]
   192.168.1.113
   EOF
   ```

4. **Create and customize configuration**
   ```bash
   make init-config
   # or manually:
   cp config.yml.example config.yml
   # Edit config.yml to match your requirements
   ```

5. **Validate configuration**
   ```bash
   make validate
   # or:
   ansible-playbook -i inventory.ini validate.yml -e "@config.yml"
   ```

### Deployment

**Full deployment:**
```bash
make deploy
# or:
ansible-playbook -i inventory.ini all.yml -u root -k -e "@config.yml"
```

**Dry run (check mode):**
```bash
make dry-run
```

**Deploy specific components:**
```bash
make deploy-tags TAGS=ssh,firewall
# Available tags: grub, boot, hardening, kernel, sysctl, authentication, 
#                 ssh, access, firewall, network, audit, logging, 
#                 monitoring, security-tools, tools, users, accounts, motd, ui
```

**Skip specific components:**
```bash
make deploy-skip-tags SKIP_TAGS=grub,users
```

## Technology Stack

Built on Ansible for rapid, scalable infrastructure deployment.

## Tested Distributions

- Debian 12

## Project Structure

```
PRISM/
├── all.yml                    # Main playbook orchestrator
├── validate.yml               # Pre-flight validation playbook
├── config.yml.example         # Configuration template
├── inventory.ini              # Target hosts (create from template)
├── ansible.cfg                # Ansible configuration
├── requirements.yml           # Ansible Galaxy dependencies
├── Makefile                   # Shortcuts for common operations
├── group_vars/
│   └── all.yml               # Global variables
├── playbooks/                 # Individual feature playbooks
│   ├── 00-requirements.yml
│   ├── 01-grub-configuration.yml
│   ├── 02-system-hardening.yml
│   ├── 03-authentication-hardening.yml
│   ├── 04-firewall.yml
│   ├── 05-audit-logging.yml
│   ├── 06-security-tools.yml
│   ├── 07-user-management.yml
│   ├── 08-dynamic-motd.yml
│   ├── 09-network-configuration.yml
│   ├── handlers/
│   │   └── main.yml          # Shared handlers
│   ├── tasks/
│   │   ├── backup_file.yml   # Reusable backup task
│   │   └── install_packages.yml  # Reusable package installation
│   └── templates/            # Jinja2 templates
```

## Key Features

- **Configuration-Driven**: Centralized YAML-based hardening control
- **Modular Architecture**: Granular control per security component
- **Comprehensive Coverage**: 40+ Lynis security recommendations implemented
- **Kernel Hardening**: Disable unused protocols (DCCP, SCTP, RDS, TIPC, USB, FireWire)
- **SSH Security**: Modern ciphers and enhanced configurations
- **Authentication**: Password policies, PAM configuration, core dump restrictions
- **Compliance**: Pre-configured legal warning banners
- **Audit & Logging**: Integrated auditd, sysstat, process accounting (Wazuh-ready)
- **Automated Updates**: Security patching with package integrity verification
- **GRUB Protection**: Password-protected bootloader
- **Sysctl Hardening**: Optimized kernel security parameters
- **VM Optimized**: Tuned for virtualized environments
- **Serial Console**: Configurable remote access
- **Idempotent**: Safe for repeated execution
- **Drop-in Ready**: Compatible with existing infrastructure

## Security Hardening

### Boot & System
- GRUB password protection (BOOT-5122)
- Kernel module blacklisting
- Core dump prevention

### Network
- Disabled protocols: DCCP, SCTP, RDS, TIPC
- Hardened sysctl network parameters
- SSH hardening (10+ configurations)

### Authentication & Access
- Password aging and complexity enforcement
- PAM-based password quality
- Legal banners for login interfaces
- Restrictive umask (027)

### Auditing & Monitoring
- Comprehensive auditd rules
- Process accounting (acct)
- System activity monitoring (sysstat)
- Wazuh-compatible logging
- Package integrity verification (debsums)

### Package Management
- Automated security updates (unattended-upgrades)
- Package verification (debsums, apt-show-versions)

### Physical Security
- USB storage blocking
- FireWire device restrictions

## Available Make Commands

Run `make help` to see all available commands:

```bash
make help              # Show help with all commands
make install           # Install Ansible dependencies
make validate          # Run pre-flight validation
make check             # Run syntax check and validation
make deploy            # Deploy full hardening
make deploy-tags       # Deploy specific components (TAGS=ssh,firewall)
make dry-run           # Test deployment without changes
make diff              # Show what would change
make list-tags         # List all available tags
make ping              # Test connectivity
make clean             # Clean temporary files
make init-config       # Create config.yml from example
make init-inventory    # Create inventory.ini template
```

## Testing

### Pre-flight Validation

Always run validation before deployment:
```bash
make validate
```

This checks:
- Ansible version compatibility
- Configuration file validity
- OS compatibility (Debian 12)
- Python availability
- Privilege escalation
- GRUB password format
- SSH port configuration
- Firewall settings
- Disk space and memory

## Troubleshooting

### Common Issues

**1. Configuration not loaded**
```
Error: features is not defined
```
Solution: Ensure you're passing the config file with `-e "@config.yml"`

**2. SSH connection issues**
```
Permission denied (publickey,password)
```
Solution: Use `-k` flag for password authentication or configure SSH keys

**3. Privilege escalation fails**
```
Missing sudo password
```
Solution: Use `-K` flag or configure passwordless sudo

**4. Firewall locks you out**
```
Unable to connect after firewall configuration
```
Prevention: Always ensure SSH port is allowed before setting default_target to DROP

### Getting Help

- Check the [CONTRIBUTING.md](CONTRIBUTING.md) guide
- Review [CHANGELOG.md](CHANGELOG.md) for recent changes
- Open an issue on GitHub
- Email: sec-vms@creaous.net

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development workflow
- Coding standards
- Testing requirements
- Pull request process

## Security

To report security vulnerabilities, please email sec-vms@creaous.net with "PRISM SECURITY" in the subject line.

## License

See [LICENSE](LICENSE) file for details.

---

**Attribution**: Please reference this project as **Creaous' P.R.I.S.M.**
