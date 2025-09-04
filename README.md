#### configs
- [nvim](#nvim)
- [git](#git)

---

#### nvim
see [`nvim`](lkurcak/nvim)

---

#### git

```
git config --global core.autocrlf false
git config --global core.eol lf
git config --global core.safecrlf warn
git config --global init.defaultBranch main
git config --global push.default current
```

|command|action|
|---|---|
|s|show status|
|l|show commit history|
```
git config --global alias.s "status -s"
git config --global alias.l "log --oneline --graph --decorate --all"
```
