~/.local/bin/startup.sh

# Enable colors and git info
autoload -Uz vcs_info
setopt prompt_subst

# Fast git ahead/behind check
git_push_status() {
    # Quick exit if not in git repo
    git rev-parse --git-dir >/dev/null 2>&1 || return

    # Get ahead/behind count (fast operation)
    local ahead_behind
    ahead_behind=$(timeout 1s git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)

    if [[ $? -eq 0 && -n "$ahead_behind" ]]; then
        local behind=$(echo $ahead_behind | cut -f1)
        local ahead=$(echo $ahead_behind | cut -f2)

        local output=""
        [[ $ahead -gt 0 ]] && output+="%F{cyan}↑%f"
        [[ $behind -gt 0 ]] && output+="%F{magenta}↓%f"
        echo $output
    fi
}

# Configure git info format with ahead/behind tracking
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f%c%u'
zstyle ':vcs_info:git:*' actionformats ' %F{red}(%b|%a)%f%c%u'
# Simple indicators: + for staged, !M for unstaged
zstyle ':vcs_info:*' stagedstr '%F{green}+%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}!M%f'

# Hook to update vcs_info before each prompt
precmd() {
    vcs_info
}

# Format: [user@host] ~/current/path (git-branch)+!↑ $
PROMPT='%F{cyan}[%n@%m]%f %F{blue}%~%f${vcs_info_msg_0_}$(git_push_status) %F{green}$%f '
# Right prompt with time
RPROMPT='%F{yellow}%D{%H:%M}%f'

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/maxficco/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<
