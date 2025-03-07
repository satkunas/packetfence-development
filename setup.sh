#!/usr/bin/env bash
#set -x
if [[ ! -f defaults ]]; then
  cp -p defaults.example defaults
fi
source defaults

GIT_DOTDIR=$PWD/.git
HOSTNAME=$(hostname)

if [[ $# -gt 0 ]]; then
  SCRIPT=$(realpath "$0")
  SCRIPTPATH=$(dirname "$SCRIPT")
  GIT_DOTDIR=$SCRIPTPATH/.git
fi

if [[ ! -d $GIT_DOTDIR ]]; then
  echo "Not a GIT directory $GIT_DOTDIR"
  exit
fi

echo "Using GIT directory $GIT_DOTDIR"
git config core.editor "vi"

read -e -p "GIT email: " -i $GIT_EMAIL GIT_EMAIL
read -e -p "GIT name: " -i $GIT_NAME GIT_NAME
# write:gpg_key
read -e -p "GIT fine-grained PAT: " -i $GIT_TOKEN GIT_TOKEN

# debian w/ apt
if [ -f /etc/debian_version ]; then
  apt-get update
  apt-get install -y \
    gpg \
    git
fi

# rhel w/ yum
if [ -f /usr/bin/yum ]; then
  yum install -y \
    gpg \
    git
fi

gpg --list-keys
cd ~/.gnupg/

###
# https://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
###
cat >~/.gnupg/conf <<EOF
    %echo GPG generating...
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: $GIT_NAME
    Name-Comment: $GIT_NAME
    Name-Email: $GIT_EMAIL
    Expire-Date: 0
  #%no-ask-passphrase
  #%no-protection
  %ask-passphrase
    %pubring pubring.kbx
    %secring trustdb.gpg
    %commit
    %echo GPG done
EOF
gpg --verbose --generate-key --batch ~/.gnupg/conf

GPG_SIGNINGKEY=$(gpg --list-secret-keys --keyid-format=long| sed -En 's/sec\s+.*\/([0-9A-F]+)\s+.*/\1/p')
GPG_PUBLICKEY=$(gpg --armor --export $GPG_SIGNINGKEY)
GPG_PUBLICKEY_ESCAPED=${GPG_PUBLICKEY//$'\n'/\\n}

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GIT_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/gpg_keys \
  --data @<(cat <<EOF
  {
    "name":"GPG Key: $HOSTNAME",
    "armored_public_key":"$GPG_PUBLICKEY_ESCAPED"
  }
EOF
)

cat << EOF > ~/.gitconfig
[credential]
  helper = netrc

[user]
  email = $GIT_EMAIL
  name = $GIT_NAME
  signingkey = $GPG_SIGNINGKEY

[pull]
  ff = only

[alias]
  up = "!git remote update -p; git merge --ff-only @{u}"
  ready = rebase -i @{u}

[commit]
  gpgSign = true

[gpg]
  program = gpg

[format]
  signoff = true
EOF

touch ~/.bashrc
if [[ -z $(grep "export GPG_TTY=\$(tty)" ~/.bashrc) ]]; then
  echo "export GPG_TTY=\$(tty)" >> ~/.bashrc
fi
if [[ -z $(grep "export HISTFILESIZE=" ~/.bashrc) ]]; then
  echo "export HISTFILESIZE=65536" >> ~/.bashrc
fi
if [[ -z $(grep "export HISTSIZE=" ~/.bashrc) ]]; then
  echo "export HISTSIZE=65536" >> ~/.bashrc
fi
source ~/.bashrc

eval "$(ssh-agent -s)"
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519
  ssh-add ~/.ssh/id_ed25519
fi

SSH_PUBLICKEY=$(cat ~/.ssh/id_ed25519.pub)

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GIT_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/keys \
  --data @<(cat <<EOF
  {
    "title":"SSH Key: $HOSTNAME",
    "key":"$SSH_PUBLICKEY"
  }
EOF
)

touch ~/.ssh/config
mkdir -p ~/.ssh/config.d
if [[ -z $(grep "Include config.d/github" ~/.ssh/config) ]]; then
  echo "Include config.d/github" >> ~/.ssh/config;
  cat << EOF > ~/.ssh/config.d/github
Host *
        AddKeysToAgent yes
        #UseKeychain yes
        IdentityFile ~/.ssh/id_ed25519

Host github.com
        Hostname ssh.github.com
        Port 443
        User git
EOF
fi






