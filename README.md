# Uyuni bash completion

Bash completion scripts for Uyuni command line tools.

# Installation

## openSUSE Leap 15.5

The rpm package can be installed from [this repository](https://download.opensuse.org/repositories/home:/cbbayburt:/Uyuni:/Utils/15.5/).

To install from the pre-built rpm package, execute the following on your openSUSE Leap 15.5 system:

```shell
zypper addrepo --no-gpgcheck https://download.opensuse.org/repositories/home:/cbbayburt:/Uyuni:/Utils/15.5/home:cbbayburt:Uyuni:Utils.repo
zypper install uyuni-bash-completion
```

## Manual installation

Copy the script files under `completions` directory to your system's bash completion directory (usually `/etc/bash_completion.d/`).

