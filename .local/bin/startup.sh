day=$(python3 ~/.local/bin/dust.py)
date=$(date '+%Y%m%d')
cbonsai -p -l -t 0.001 -m  "$day" --seed=$date 


