# github-setup

This script configures GPG and SSH for GIT for the current user on the local host.

## Create GIT_TOKEN

 * Visit https://github.com/settings/personal-access-tokens/new
 * Expiration: Any - this token will only be used once and can be removed after setup.
 * Account Permissions:
   * GPG Keys: Read & Write
   * SSH Signing Keys: Read & Write

![Screenshot 2025-03-07 at 2 16 55 PM](https://github.com/user-attachments/assets/fca8efbb-c3e1-40de-8e5b-b80aa7b5ef65)
![Screenshot 2025-03-07 at 2 17 06 PM](https://github.com/user-attachments/assets/ee904ac8-e4b0-43d1-8c32-03686fb38952)


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
