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
#                 monitoring, security-tools, tools, docker, containers, compose,
#                 users, accounts, motd, ui,
#                 performance, cpu, memory
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
│   ├── 09-make-unique.yml
│   ├── 10-network-configuration.yml
│   ├── 11-resource-optimization.yml
│   ├── 12-agent-deployment.yml
│   ├── 13-docker-deployment.yml
│   ├── handlers/
│   │   └── main.yml          # Shared handlers
│   ├── tasks/
│   │   ├── backup_file.yml   # Reusable backup task
│   │   └── install_packages.yml  # Reusable package installation
│   └── templates/            # Jinja2 templates
```

## Key Features

- **Target-Aware Hardening**: Supports VM and LXC/container targets with `features.target.type`
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
- **Resource Optimization**: Lower RAM pressure with zram and tuned runtime memory settings
- **Agent Auto-Deployment**: Automated installation and registration for Checkmk and Wazuh agents
- **Container Runtime Deployment**: Automated secure Docker Engine and Docker Compose plugin installation
- **Serial Console**: Configurable remote access
- **Idempotent**: Safe for repeated execution
- **Drop-in Ready**: Compatible with existing infrastructure

## Security Hardening

### Target Types

- `features.target.type: auto` (recommended): detect target using virtualization facts
- `features.target.type: vm`: force VM behavior
- `features.target.type: lxc` or `container`: force container behavior

Container behavior highlights:

- GRUB and initramfs operations are skipped
- Kernel module blacklist/initramfs regeneration is skipped
- Sysctl hardening is still applied (best-effort)
- Firewall, audit logging, and networking are configurable for containers via:
  - `features.target.container_support.firewall`
  - `features.target.container_support.audit_logging`
  - `features.target.container_support.networking`
  - Default for each is `false` for safety
  - When container audit logging is enabled, PRISM applies `sysstat`; `auditd/acct` units are only managed on VM targets

### Wazuh Mode

- Enable `features.integrations.wazuh_mode.enabled: true` to reduce overlapping tools when Wazuh agent is in use.
- In Wazuh mode with `reduce_redundant_tools: true` (default):
  - `fail2ban` is skipped
  - `debsums` periodic checks are skipped
  - `acct` is skipped
  - `auditd` is kept by default (`keep_auditd: true`)
  - `sysstat` is disabled by default (`keep_sysstat: false`)
- You can override the defaults with:
  - `features.integrations.wazuh_mode.keep_auditd`
  - `features.integrations.wazuh_mode.keep_sysstat`

### Agent Deployment

- Enable `features.agent_deployment.enabled: true` to deploy monitoring/security agents.
- Configure Checkmk in `features.agent_deployment.checkmk`:
  - `package_url`, `server`, `site`, `user`, `password`
- Configure Wazuh in `features.agent_deployment.wazuh`:
  - `package_url`, `manager`
- Deploy only agents with:
  - `make deploy-tags TAGS=agents`

### Docker Deployment

- Enable `features.docker_deployment.enabled: true` to deploy Docker CE and Docker Compose plugin.
- PRISM installs Docker from the official Docker Debian repository.
- Secure defaults are applied in `/etc/docker/daemon.json` when `features.docker_deployment.manage_daemon_config: true`.
- Optional docker group membership can be assigned via `features.docker_deployment.users`.
- Deploy only container runtime setup with:
  - `make deploy-tags TAGS=docker`

### Boot & System

- GRUB password protection (BOOT-5122)
- Kernel module blacklisting
- Core dump prevention

### Network

- Disabled protocols: DCCP, SCTP, RDS, TIPC
- Hardened sysctl network parameters
- SSH hardening (10+ configurations)
- Selectable networking backend via `features.networking.backend`:
  - `networkmanager` for feature-rich management
  - `ifupdown` for lightweight static networking
- Optional automatic gateway derivation from interface CIDR via `features.networking.auto_gateway`
- Optional DNS automation that uses the derived router IP plus `features.networking.dns_extra`
- Managed `systemd-resolved` setup via `features.networking.systemd_resolved`

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
make deploy-tags       # Deploy performance tuning only (TAGS=performance)
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

**5. Networking changes are not applied**
`features.networking.enabled` is disabled by default. Set it to `true` before deploying network changes.

**6. Make-unique tasks do not run**
`features.make_unique.enabled` is disabled by default because it is intended for one-time imaging/clone workflows.

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
