# Contributing to PRISM

Thank you for your interest in contributing to PRISM (Policy Rigid Infrastructure for Secure Machines)! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Contributing to PRISM](#contributing-to-prism)
  - [Table of Contents](#table-of-contents)
  - [Code of Conduct](#code-of-conduct)
  - [Getting Started](#getting-started)
  - [Development Workflow](#development-workflow)
  - [Coding Standards](#coding-standards)
    - [Ansible Playbooks](#ansible-playbooks)
    - [File Organization](#file-organization)
    - [Security Considerations](#security-considerations)
  - [Testing](#testing)
    - [Local Testing](#local-testing)
    - [Manual Testing](#manual-testing)
  - [Submitting Changes](#submitting-changes)
    - [Pull Request Process](#pull-request-process)
    - [Pull Request Template](#pull-request-template)
  - [Reporting Bugs](#reporting-bugs)
    - [Before Submitting](#before-submitting)
    - [Bug Report Template](#bug-report-template)
  - [Feature Requests](#feature-requests)
    - [Feature Request Template](#feature-request-template)
  - [Questions?](#questions)
  - [License](#license)

## Code of Conduct

This project adheres to a code of professionalism and respect. By participating, you are expected to uphold this standard. Please report unacceptable behavior to sec-vms@creaous.net.

## Getting Started

1. **Fork the repository**
   ```bash
   git fork https://github.com/Creaous/PRISM.git
   cd PRISM
   ```

2. **Install dependencies**
   ```bash
   make install
   # or manually:
   ansible-galaxy install -r requirements.yml
   ```

3. **Create a test configuration**
   ```bash
   cp config.yml.example config.yml
   # Edit config.yml as needed
   ```

4. **Validate your setup**
   ```bash
   make check
   ```

## Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the coding standards below
   - Test your changes thoroughly
   - Update documentation as needed

3. **Test locally**
   ```bash
   make syntax          # Check syntax
   make dry-run         # Test without applying changes
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new hardening feature"
   ```

   Use conventional commit messages:
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `refactor:` Code refactoring
   - `test:` Test additions/changes
   - `chore:` Maintenance tasks

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### Ansible Playbooks

1. **Use fully qualified collection names (FQCN)**
   ```yaml
   # Good
   - name: Install packages
     ansible.builtin.apt:
       name: curl
   
   # Bad
   - name: Install packages
     apt:
       name: curl
   ```

2. **Follow YAML best practices**
   - Use 2 spaces for indentation
   - Quote strings when necessary
   - Use descriptive task names
   - Add comments for complex logic

3. **Use defaults and conditionals properly**
   ```yaml
   when: features.firewall.enabled | default(false)
   ```

4. **Add tags to tasks**
   ```yaml
   tags: ['firewall', 'network']
   ```

5. **Use handlers for service restarts**
   ```yaml
   notify: Restart SSH service
   ```

### File Organization

- Playbooks: `playbooks/`
- Shared tasks: `playbooks/tasks/`
- Handlers: `playbooks/handlers/`
- Templates: `playbooks/templates/`
- Variables: `group_vars/`

### Security Considerations

1. **Never commit sensitive data**
   - Passwords
   - API keys
   - Private keys
   - Real IP addresses

2. **Use Ansible Vault for secrets**
   ```bash
   ansible-vault encrypt_string 'secret_password' --name 'vault_password'
   ```

3. **Validate user input**
   ```yaml
   - name: Validate configuration
     ansible.builtin.assert:
       that:
         - variable is defined
         - variable | length > 0
   ```

## Testing

### Local Testing

1. **Syntax check**
   ```bash
   ansible-playbook --syntax-check all.yml
   ```

2. **Dry run**
   ```bash
   make dry-run
   ```

3. **Validation**
   ```bash
   make validate
   ```

### Manual Testing

Test on a clean Debian 12 VM or container before submitting changes.

## Submitting Changes

### Pull Request Process

1. **Update documentation**
   - Update README.md if adding features
   - Update CHANGELOG.md following Keep a Changelog format
   - Add inline comments for complex logic

2. **Ensure tests pass**
   - All syntax checks must pass
   - Manual testing completed

3. **Create pull request**
   - Use a clear, descriptive title
   - Reference any related issues
   - Provide detailed description of changes
   - Include test results

4. **Code review**
   - Address reviewer feedback promptly
   - Make requested changes
   - Maintain professional communication

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Syntax check passed
- [ ] Dry run completed
- [ ] Manual testing on Debian 12

## Checklist
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No sensitive data included
- [ ] All tests passing
```

## Reporting Bugs

### Before Submitting

1. Check existing issues
2. Verify it's reproducible
3. Test on a clean system

### Bug Report Template

```markdown
**Description**
Clear description of the bug

**Environment**
- PRISM Version:
- Ansible Version:
- Target OS: Debian 12
- Python Version:

**Steps to Reproduce**
1. Step 1
2. Step 2
3. ...

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Logs/Output**
```
Paste relevant logs
```

**Additional Context**
Any other relevant information
```

## Feature Requests

We welcome feature requests! Please:

1. **Check existing requests** to avoid duplicates
2. **Provide clear use case** explaining the need
3. **Describe the solution** you envision
4. **Consider security implications**

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature

**Use Case**
Why is this needed?

**Proposed Solution**
How should it work?

**Security Considerations**
Any security implications?

**Alternatives Considered**
What alternatives did you consider?
```

## Questions?

- Open an issue for questions
- Email: sec-vms@creaous.net
- Include "PRISM" in the subject line

## License

By contributing to PRISM, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to PRISM! Your efforts help make server hardening accessible and reliable for everyone.
