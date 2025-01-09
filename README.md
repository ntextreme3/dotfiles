# dotfiles

All my settings, managed by chezmoi!

## Quick Start

```
# "--classic" mode gives apps more permissions
sudo snap install --classic chezmoi

chezmoi init --apply --verbose https://github.com/ntextreme3/dotfiles.git
```

## Full Setup

Basically, my target when getting a new PC / laptop.

Some things, like the PC settings that only happen once every few years, aren't worth automating. It's quick enough to record which settings I like here.

Other things, like the dotfiles and such, I'll re-run whenever I setup a new VM, which can be frequent.

### BIOS

- disable default fn keys
- swap fn and ctrl

### OS

- trackpad scroll = down moves down
- do all windows updates
- set system dark mode
- set background
- update explorer to show file extensions and hidden items
- disable windows aero shake
    - `gpedit.msc > User Config > Admin Templates > Desktop > Turn off Aero Shake`
- restore documents and pictures

### Install

- password manager
- chocolatey
    - firacode
- insomnia
    - import all
    - setup proxies
    - install plugin: https://insomnia.rest/plugins/insomnia-plugin-inception

### Windows Terminal

- copy settings
- set font to firacode

### Slack

- unset 'shift+enter' to send in code mode
- set noise to 'Ding'

### vs-code

- settings sync

### Sublime Text 3

- copy `%APPDATA%/Sublime` from old laptop
- restore drafts
- restore settings (the "User" package)
- install Package Control (probably manually, bc proxy)
  - package Control should install all extensions from settings
- open files + drafts from original
- register with my Personal license

### wsl2

- `.wslconfig` in `C:\Users\<user>`
    ```
    [wsl2]
    memory=32GB

    # Sets additional kernel parameters, in this case enabling older Linux base
    # images such as Centos 6
    # kernelCommandLine = vsyscall=emulate

    [experimental]
    autoMemoryReclaim=gradual
    sparseVhd=true
    ```

## Smoke Tests

- wsl2
    - setup new venv
    - pip install numpy
    - git pull and commit
    - apt update
    - tmux session and restore
    - `code .` from in wsl
