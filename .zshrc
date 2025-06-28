echo -e "Welcome back, $(whoami)! You're currently on $(hostname)'s machine.\n$(date '+%H:%M:%S // %A %d, %B %Y (%d/%m/%Y) // %j day')\n"

# The following lines were added by compinstall
zstyle :compinstall filename "/home/$(whoami)/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=2000
setopt autocd extendedglob nomatch notify
unsetopt beep
#bindkey -v
# End of lines configured by zsh-newuser-install

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

PS1="%F{cyan}%~%f $ %F{green}>>%f "

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

alias shutdown="shutdown -P 0"
alias stfu="shutdown -P 0"
alias ls="eza --color=always"
alias sex="fastfetch"
alias nya="paru"
alias mpv-audio="mpv --vo=null -ytdl-format=ba"

eval "$(ssh-agent -s)"
eval "$(zoxide init zsh)"
