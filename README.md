# Motivation

I spent a significant amount of time setting up the machine everytime I get a new one. `Time Machine` did help me a lot
in the past. But with time the system get filled with junk.

There are many open-source projects out there for provisioning a new mac, but I didn't trust them much. So instead of
diving deeply in those codes, I prefer to write this script on my own. This script just does the following tasks:

- Installing the **Xcode Command Line Tools**
- Install the [**homebrew**](https://brew.sh/)
- Install some essentials tools
- Install the development setup:
    - [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) and install some plugins
    - [tmux](https://github.com/tmux/tmux) and install some plugins
    - ssh/git setup
- Install languages
    - python
    - rust
    - jvm
- Install **AWS** tools
- Install some GUI tools
- Install some tools from MAS

# Usage

```
./scripts/provisioning.sh
```

# Manual steps

However, there are a few manual step:

- Setup keyboard, trackpad options in the setting
- Map Caps Lock to escape
- iterm2
    - copy on selection:
        - General -> Selection
            - copy to pasteboard on selection
            - Applications in terminal may access to clipboard
    - import the profile to iterm2
- import the colour scheme for idea
- import ssh public key for Git
