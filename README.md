#### configs
- [git](#git)
- [nvim](lkurcak/nvim)
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
```

|command|action|
|---|---|
|`git s`|show status|
|`git l`|show commit history|
|`git last`|show last commit|

