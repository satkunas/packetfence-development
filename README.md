# github-setup

This script configures GPG and SSH for GIT for the current user on the local host.

## Create GIT_TOKEN

 * Visit https://github.com/settings/personal-access-tokens/new
 * Expiration: Any - this token will only be used once and can be removed after setup.
 * Account Permissions:
   * GPG keys: Read & Write
   * Git SSH keys: Read & Write
   * SSH Signing keys: Read & Write

![Screenshot 2025-07-07 at 3 34 41 PM](https://github.com/user-attachments/assets/c1e84ab2-1a89-4a65-9ee8-2ebcaf78b3e1)

## Configure

Copy the example defaults, and enter your `GIT_EMAIL`, `GIT_NAME` and `GIT_TOKEN`.

```bash
cp -p defaults.example defaults
vi defaults
```

## Usage

```bash
bash setup.sh
```

## GIT Remote

The git remote for the repo must use `ssh` rather than `https`.

```bash
git remote -v
origin  ssh://github.com/satkunas/github-setup.git (fetch)
origin  ssh://github.com/satkunas/github-setup.git (push)

# change
git remote set-url origin ssh://github.com/satkunas/github-setup.git
```

## SAML

If SAML is required, click "Configure SSO" on the newly created SSH key.

See: https://docs.github.com/en/enterprise-cloud@latest/authentication/authenticating-with-saml-single-sign-on/authorizing-an-ssh-key-for-use-with-saml-single-sign-on
