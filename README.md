# dotfiles

All my settings, managed by chezmoi!

## Quick Start

### wsl2

- Create `.wslconfig` in `%UserProfile%` as:
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
  - If you don't do this step first: https://superuser.com/a/1834374/485811
- Install the latest Ubuntu LTS from the Microsoft Store.

### chezmoi

```
# "--classic" mode gives apps more permissions
sudo snap install --classic chezmoi

chezmoi init --apply --verbose https://github.com/ntextreme3/dotfiles.git

# Hack: Should run chezmoi apply again until I get all this working
# right. delta is installed, but not yet on PATH, so .gitconfig doesn't
# see it til the next run.
chezmoi apply
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

- <details>
    <summary>Copy settings (or use these for some good defaults)</summary>

    ```jsonc
    {
        "$help": "https://aka.ms/terminal-documentation",
        "$schema": "https://aka.ms/terminal-profiles-schema",
        "actions":
        [
            {
                "command": "paste",
                "id": "User.paste",
                "keys": "shift+insert"
            },
            {
                "command":
                {
                    "action": "prevTab"
                },
                "id": "User.prevTab.0",
                "keys": "ctrl+pgup"
            },
            {
                "command":
                {
                    "action": "nextTab"
                },
                "id": "User.nextTab.0",
                "keys": "ctrl+pgdn"
            }
        ],
        "copyOnSelect": true,
        "defaultProfile": "{963ff2f7-6aed-5ce3-9d91-90d99571f53a}",
        "newTabMenu":
        [
            {
                "type": "remainingProfiles"
            }
        ],
        "profiles":
        {
            "defaults": {},
            "list":
            [
                {
                    "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                    "hidden": false,
                    "name": "Windows PowerShell"
                },
                {
                    "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                    "hidden": false,
                    "name": "cmd"
                },
                {
                    "bellStyle":
                    [
                        "window",
                        "taskbar"
                    ],
                    "font":
                    {
                        "face": "Fira Code"
                    },
                    "guid": "{963ff2f7-6aed-5ce3-9d91-90d99571f53a}",
                    "hidden": false,
                    "name": "Ubuntu-24.04",
                    "source": "Windows.Terminal.Wsl"
                }
            ]
        },
        "schemes": [],
        "tabSwitcherMode": "disabled",
        "themes": []
    }
    ```
  </details>

### Slack

- unset 'shift+enter' to send in code mode
- set noise to 'Ding'

### vs-code

- settings sync

### Sublime Text 3

- copy `%APPDATA%/Sublime Text 3` from old laptop
    - restore drafts
    - <details>
        <summary>restore settings (the "User" package, or merge with this:)</summary>

        ```json
        {
            "default_line_ending": "unix",
            "highlight_modified_tabs": true,
            "index_files": true,
            "translate_tabs_to_spaces": true,
            "update_check": false,
            "word_wrap": true,
            // '0' wraps at window size
            "wrap_width": 0
        }
        ```
    - install Package Control (probably manually, bc proxy)
    - package Control should install all extensions from settings
- open files + drafts from original
- register with my Personal license



</details>

## Smoke Tests

- wsl2
    - setup new venv
    - pip install numpy
    - git pull and commit
    - apt update
    - tmux session and restore
    - `code .` from in wsl
