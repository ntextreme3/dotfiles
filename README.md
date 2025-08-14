# dotfiles

All my settings, managed by chezmoi!

## Quick Start

### wsl2

- Create `.wslconfig` in `%UserProfile%` as:
    ```
    [wsl2]
    # choose some value that makes sense
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
- set accent color #9BCC29
- set background (fill)
- update explorer to show file extensions and hidden items
- disable windows aero shake
    - `gpedit.msc > User Config > Admin Templates > Desktop > Turn off Aero Shake`
- restore documents and pictures

### Install

- password manager
- Cascadia Code NF - https://github.com/microsoft/cascadia-code (or Fira Code)
- Logseq - https://logseq.com/
- Sublime Text 3 - http://sublimetext.com/3
- vs code

#### Microsoft Store

- Windows Terminal
- Slack

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
            "command":
            {
                "action": "prevTab"
            },
            "id": "User.prevTab.0"
        },
        {
            "command":
            {
                "action": "nextTab"
            },
            "id": "User.nextTab.0"
        }
    ],
    "copyFormatting": "none",
    "copyOnSelect": true,
    "defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "keybindings":
    [
        {
            "id": "User.prevTab.0",
            "keys": "ctrl+pgup"
        },
        {
            "id": "User.nextTab.0",
            "keys": "ctrl+pgdn"
        },
        {
            "id": "Terminal.CopyToClipboard",
            "keys": "ctrl+c"
        },
        {
            "id": "Terminal.PasteFromClipboard",
            "keys": "shift+insert"
        }
    ],
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
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell"
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "hidden": false,
                "name": "Command Prompt"
            },
            {
                "font":
                {
                    "face": "Cascadia Code NF"
                },
                "guid": "{963ff2f7-6aed-5ce3-9d91-90d99571f53a}",
                "hidden": true,
                "name": "Ubuntu-24.04",
                "source": "Windows.Terminal.Wsl"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": true,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            },
            {
                "guid": "{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}",
                "hidden": true,
                "name": "Git Bash",
                "source": "Git"
            },
            {
                "bellStyle":
                [
                    "window",
                    "taskbar"
                ],
                "colorScheme": "Campbell",
                "font":
                {
                    "face": "Cascadia Code NF"
                },
                "guid": "{d8e96812-b789-5068-a5ae-10b2fb53e95f}",
                "hidden": false,
                "name": "Ubuntu 24.04.1 LTS",
                "source": "CanonicalGroupLimited.Ubuntu24.04LTS_79rhkp1fndgsc"
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

> [!WARNING]
> Launching from WSL might not work without updating everything

- settings sync
- update extensions

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

## Startup Apps

Run `shell:startup` and add shortcuts.

## Smoke Tests

- wsl2
    - setup new venv
    - install numpy
    - git pull and commit
    - apt update
    - tmux session and restore
    - `code .` from in wsl

## Notes

You might also want to consider merging / copying `~/.bash_history` from other PCs. Below does NOT necessarily preserve timestamp order, but should be good enough if the history files are roughly in order.

```sh
cp ~/.bash_history ~/.bash_history.backup
cat .bash_history.backup.1 .bash_history.backup.2 .bash_history.backup.n \
  > .bash_history.merged
```

Inspect `.bash_history.merged` and if all looks good

```
history -c
history -r .bash_history.merged
history -w
```

## Teardown

Reminder to purge old pc. Check the Teardown note.
