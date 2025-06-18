~/.local/bin/startup.sh

# Enable colors and git info
autoload -Uz vcs_info
setopt prompt_subst

# Configure git info format
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{red}(%b|%a)%f'

# Function to get git status symbols
git_status() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local git_info=""
        # Check for unstaged changes
        if ! git diff --quiet 2>/dev/null; then
            git_info+="%F{red}●%f"
        fi
        # Check for staged changes
        if ! git diff --cached --quiet 2>/dev/null; then
            git_info+="%F{green}●%f"
        fi
        # Check for untracked files
        if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
            git_info+="%F{blue}●%f"
        fi
        echo $git_info
    fi
}

# Hook to update vcs_info before each prompt
precmd() {
    vcs_info
}

# Format: [user@host] ~/current/path (git-branch)●● $
PROMPT='%F{cyan}[%n@%m]%f %F{blue}%~%f${vcs_info_msg_0_}$(git_status) %F{green}$%f '

# Right prompt with time
RPROMPT='%F{yellow}%D{%H:%M}%f'

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/maxficco/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<
