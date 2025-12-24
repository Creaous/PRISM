# PRISM Quick Reference Card

## Essential Commands

### Setup (First Time)
```bash
# 1. Install dependencies
make install

# 2. Create configuration
make init-config
make init-inventory

# 3. Edit files
vim config.yml       # Customize your settings
vim inventory.ini    # Add your servers
```

### Validation
```bash
make validate        # Pre-flight checks
make check           # Syntax + validation
make dry-run         # Test without changes
make diff            # Show what would change
```

### Deployment
```bash
make deploy                              # Full deployment
make deploy-tags TAGS=ssh                # SSH hardening only
make deploy-tags TAGS=firewall,ssh       # Multiple components
make deploy-skip-tags SKIP_TAGS=grub     # Skip GRUB config
```

### Information
```bash
make list-hosts      # Show target hosts
make list-tasks      # Show all tasks
make list-tags       # Show available tags
make ping            # Test connectivity
make help            # Show all commands
```

### Testing
```bash
make test-converge   # Deploy to test container
make test-verify     # Verify test deployment
```

### Maintenance
```bash
make clean           # Remove temporary files
```

## Available Tags

| Tag                               | Description         |
| --------------------------------- | ------------------- |
| `requirements`                    | System requirements |
| `grub`, `boot`                    | GRUB configuration  |
| `hardening`, `kernel`, `sysctl`   | Kernel hardening    |
| `authentication`, `ssh`, `access` | SSH & auth          |
| `firewall`, `network`             | Firewall            |
| `audit`, `logging`, `monitoring`  | Logging             |
| `security-tools`, `tools`         | Security tools      |
| `users`, `accounts`               | User management     |
| `motd`, `ui`                      | MOTD                |
| `hostname`                        | Network config      |

## Configuration Highlights

### Critical Settings
```yaml
# SSH Port (default 52460)
features.ssh_hardening.port: 52460

# Firewall default action
features.firewall.default_target: "DROP"  # or ACCEPT, REJECT

# GRUB password protection
features.grub_password.enabled: true
```

### Security Levels

**Paranoid (Maximum Security)**
```yaml
features.sysctl_hardening.modules_disabled: true
features.firewall.default_target: "DROP"
features.kernel_modules.disable_usb: true
features.ssh_hardening.permit_root_login: "no"
```

**Balanced (Recommended)**
```yaml
features.sysctl_hardening.modules_disabled: false
features.firewall.default_target: "DROP"
features.kernel_modules.disable_usb: false
features.ssh_hardening.permit_root_login: "prohibit-password"
```

**Minimal (Basic Hardening)**
```yaml
features.sysctl_hardening.enabled: true
features.ssh_hardening.enabled: true
features.auth_hardening.enabled: true
features.firewall.enabled: false  # Manual firewall
```

## Common Workflows

### Initial Server Setup
```bash
make validate
make deploy
```

### Update SSH Configuration Only
```bash
make deploy-tags TAGS=ssh
```

### Update Firewall Rules
```bash
make deploy-tags TAGS=firewall
```

### Add New User
```bash
# Edit config.yml, add user to features.user_management.users
make deploy-tags TAGS=users
```

### Reconfigure GRUB
```bash
make deploy-tags TAGS=grub
```

## Emergency Procedures

### Locked Out of SSH
**Prevention:**
1. Always test with `make dry-run` first
2. Ensure SSH port is in firewall allowed_ports
3. Keep a console/IPMI access available

**Recovery:**
1. Access via console/IPMI
2. Fix `/etc/ssh/sshd_config`
3. Restart SSH: `systemctl restart sshd`

### Firewall Blocking Everything
**Via Console:**
```bash
# Disable firewall temporarily
systemctl stop firewalld

# Fix configuration in config.yml
# Redeploy with correct settings
ansible-playbook all.yml --tags firewall -e "@config.yml"
```

### GRUB Password Forgotten
**Via Console:**
1. Boot into recovery mode (before GRUB locks it)
2. Edit `/etc/grub.d/40_custom`
3. Run `update-grub`
4. Reboot

## Troubleshooting

### Playbook Fails
```bash
# Check syntax
make syntax

# Validate configuration
make validate

# Dry run to see what would happen
make dry-run

# Check logs
tail -f ansible.log
```

### Variables Not Loading
```bash
# Ensure using -e flag
ansible-playbook all.yml -e "@config.yml"

# Or use make (handles automatically)
make deploy
```

### Module Not Found
```bash
# Install dependencies
make install

# Or manually
ansible-galaxy install -r requirements.yml
```

## File Locations

| File                    | Purpose                         |
| ----------------------- | ------------------------------- |
| `config.yml`            | Your configuration (gitignored) |
| `inventory.ini`         | Your servers (gitignored)       |
| `config.yml.example`    | Template                        |
| `inventory.ini.example` | Template                        |
| `group_vars/all.yml`    | Default variables               |
| `ansible.cfg`           | Ansible settings                |
| `validate.yml`          | Pre-flight checks               |
| `all.yml`               | Main playbook                   |

## Getting Help

1. Run `make help`
2. Check `README.md`
3. Review `CONTRIBUTING.md`
4. Check logs: `cat ansible.log`
5. Email: sec-vms@creaous.net

## Best Practices

✅ Always validate before deploying
✅ Test in staging first
✅ Use version control for config.yml (encrypted)
✅ Keep backups of working configurations
✅ Document custom changes
✅ Use tags for incremental updates
✅ Run dry-run before production
✅ Keep a console access method available

## Performance Tips

- Use tags to deploy only what changed
- Enable fact caching (already in ansible.cfg)
- Use `make deploy-tags` instead of full deployment
- Keep inventory.ini organized
- Use SSH key authentication (faster than password)

---

**Quick Start:** `make install && make init-config && make validate && make deploy`

**Most Common:** `make deploy-tags TAGS=ssh,firewall`

**Safe Testing:** `make dry-run`
