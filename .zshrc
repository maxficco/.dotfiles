PROMPT='%F{8}[%F{12}%D{%b %d}%F{8}][%F{5}%T%F{8}][%F{15}%B%~%f%b%F{8}] %f>>'
# %F{ansi color} - %f ends
# %D{%b-month %d-day} - date
# %T - 24hr time
# %~ - path
# %B - bold - %b
RPROMPT='<<'
~/.local/bin/startup.sh

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/maxficco/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<
