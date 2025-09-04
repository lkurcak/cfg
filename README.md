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
```

|command|action|
|---|---|
|s|show status|
|l|show commit history|

