#### configs
- [git](#git)
- [nu](#nu)
- [nvim](https://github.com/lkurcak/nvim)
- [tmux](./.tmux.conf)

---

#### git

```
git config --global core.autocrlf false
git config --global core.eol lf
git config --global core.safecrlf warn
git config --global init.defaultBranch main
git config --global push.default current

# commands
git config --global alias.s "status -s"
git config --global alias.l "log --oneline --graph --decorate --all"
git config --global alias.last "log --oneline --graph --decorate -p -1"
git config --global alias.c "commit"
git config --global alias.co "checkout"
```

|command|action|
|---|---|
|`git s`|show status|
|`git l`|show commit history|
|`git last`|show last commit|
|`git c`|short for commit|
|`git co`|short for checkout|


#### nu

To edit the config set the editor and type `config nu`:
```sh
$env.config.buffer_editor = "nvim"
config nu
```
then paste in:
```nu
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

alias vi = nvim
```
