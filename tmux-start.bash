#!/bin/sh
SESSION="london-housing"

tmux -2 new-session -d -s $SESSION

tmux new-window -t $SESSION:1 -k -n R
tmux send-keys -t $SESSION:1 'vim README.Rmd' C-m
tmux send-keys -t $SESSION:1 ':' 'tabe osmar.Rmd' C-m

tmux new-window -t $SESSION:2 -n bash
tmux select-window -t $SESSION:2
tmux send-keys -t $SESSION:2 'xdg-open README.html &' C-m
tmux send-keys -t $SESSION:2 'vim makefile' C-m
tmux send-keys -t $SESSION:2 ':' 'tabe tmux-start.bash' C-m

tmux split-window -h
tmux send-keys -t $SESSION:2 'git st' C-m
tmux select-pane -t 0

tmux select-window -t $SESSION:1

tmux attach -t $SESSION
