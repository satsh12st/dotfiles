# dotfiles
The perfect dotfiles in my opinion

## Features
- My dotfiles managed by Chezmoi
- Automatic dev-environment setup

## These contain...
- Cool ZSH setup with [Zinit](https://github.com/zdharma-continuum/zinit)
- Beautiful shell prompt by [Starship](https://github.com/starship/starship)

## Supported OS
- Ubuntu on WSL2
- So many Linux distribution
- macOS

## How to install
It's amazingly easy! Way to install dotfiles is to execute...

```sh
sudo sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b /usr/local/bin
chezmoi init --apply satsh12st
```

### For use with WSL2
If you are using it in WSL2, you will need to pass some of the Windows environment variables to Linux via `$WSLENV`.

1. Start Command Prompt or PowerShell and execute the following command.  
**However, if you are already using `$WSLENV`, set up manually using the Control Panel.**
2. Then *reboot your computer* just to be sure.

```powershell
setx WSLENV SystemRoot/up:USERPROFILE/up
```

### For use with devcontainer (by VSCode Remote Container)
If you want to use this repository in devcontainer by VSCode Remote Container,
plsease set the VSCode `setting.json` as follows.

```json
"dotfiles.repository": "satsh12st/dotfiles",
"dotfiles.targetPath": "~/.dotfiles",
"dotfiles.installCommand": "~/.dotfiles/install.sh",
```
