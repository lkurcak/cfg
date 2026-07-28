#### configs
- [git](#git)
- [nu](#nu)
- [nvim](https://github.com/lkurcak/nvim)
- [tmux](./.tmux.conf)
- [zsh](#zsh)

---

#### git

|command|action|
|---|---|
|`git s`|show status|
|`git l`|show commit history|
|`git last`|show last commit|
|`git c`|short for commit|
|`git co`|short for checkout|
|`git b`|short for branch|

```
# commands
git config --global alias.s "status -s"
git config --global alias.l "log --oneline --graph --decorate --all"
git config --global alias.last "log --oneline --graph --decorate -p -1"
git config --global alias.c "commit"
git config --global alias.co "checkout"
git config --global alias.b "branch"

# settings
git config --global core.autocrlf false
git config --global core.eol lf
git config --global core.safecrlf warn
git config --global init.defaultBranch main
git config --global push.default current
git config --global pull.ff only
git config --global fetch.prune true
git config --global core.editor nvim
```

<details>
  <summary><code>git branchdiff</code></summary>
  <img width="602" height="92" alt="image" src="https://github.com/user-attachments/assets/077b19eb-2772-49b5-9e4f-67e91d1efde7" />
  <pre><code class="language-sh">git config --global alias.branchdiff '!f() { base="${1:-origin/main}"; current=$(git symbolic-ref --short HEAD 2>/dev/null); cap=20; max=0; fifo1=$(mktemp -u); mkfifo "$fifo1"; git for-each-ref --sort=refname --format="%(refname:short)" refs/heads/ > "$fifo1" & while read -r branch; do [ ${#branch} -gt "$max" ] && max=${#branch}; done < "$fifo1"; rm -f "$fifo1"; fifo2=$(mktemp -u); mkfifo "$fifo2"; git for-each-ref --sort=refname --format="%(refname:short)" refs/heads/ > "$fifo2" & while read -r branch; do [ "$branch" = "$base" ] && continue; set -- $(git rev-list --left-right --count "$branch"..."$base"); ahead=$1; behind=$2; alen=$ahead; [ "$alen" -gt "$cap" ] && alen=$cap; blen=$behind; [ "$blen" -gt "$cap" ] && blen=$cap; abar=$(printf "%${alen}s" "" | tr " " "+"); bbar=$(printf "%${blen}s" "" | tr " " "-"); [ "$ahead" -gt "$cap" ] && abar="${abar}»"; [ "$behind" -gt "$cap" ] && bbar="${bbar}»"; padded=$(printf "%-*s" "$max" "$branch"); if [ "$branch" = "$current" ]; then marker="* "; name="\033[1;36m${padded}\033[0m"; else marker="  "; name="$padded"; fi; printf "%s%b \033[32m%s\033[0m\033[31m%s\033[0m  (ahead %s, behind %s)\n" "$marker" "$name" "$abar" "$bbar" "$ahead" "$behind"; done < "$fifo2"; rm -f "$fifo2"; }; f "$1"'</code></pre>
</details>

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
$env.config.edit_mode = "vi"
$env.config.history.file_format = "sqlite"

$env.config.keybindings ++= [
  {
    name: "ctrl-h-as-backspace"
    modifier: control
    keycode: char_h
    mode: vi_insert
    event: { edit: backspace }
  }
]

alias vi = nvim
```

#### zsh
```
nvim ~/.zshrc
```
```
export EDITOR="nvim"

alias vi="nvim"

bindkey -v
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
```
