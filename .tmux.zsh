function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }

function tmuxx
{
 if is_screen_or_tmux_running; then
   if is_tmux_runnning; then
     echo "${fg_bold[red]} _____ __  __ _   ___  __  _                              _               _ _  ${reset_color}"
     echo "${fg_bold[red]}|_   _|  \/  | | | \ \/ / (_)___   _ __ _   _ _ __  _ __ (_)_ __   __ _  | | | ${reset_color}"
     echo "${fg_bold[red]}  | | | |\/| | | | |\  /  | / __| | '__| | | | '_ \| '_ \| | '_ \ / _\ | | | | ${reset_color}"
     echo "${fg_bold[red]}  | | | |  | | |_| |/  \  | \__ \ | |  | |_| | | | | | | | | | | | (_| | |_|_| ${reset_color}"
     echo "${fg_bold[red]}  |_| |_|  |_|\___//_/\_\ |_|___/ |_|   \__,_|_| |_|_| |_|_|_| |_|\__, | (_|_) ${reset_color}"
     echo "${fg_bold[red]}                                                                  |___/        ${reset_color}"
   elif is_screen_running; then
     echo "This is on screen."
   fi
 else
   # get the IDs
   if ! ID="$(tmux list-sessions 2>/dev/null)"; then
     # tmux returned error, so try cleaning up /tmp
     /bin/rm -rf /tmp/tmux*
   fi

   create_new_session="Create New Session"
   select_tmuxinator="Select tmuxinator"
   ID="${create_new_session}:\n${select_tmuxinator}:\n$ID"
   ID="$(echo $ID | percol | cut -d: -f1)"

   if [[ "$ID" = "${create_new_session}" ]]; then
     tmux new-session

     if [ $? -eq 0 ]; then
       echo "$(tmux -V) new session"
       return 0
     fi
   elif [[ "$ID" = "${select_tmuxinator}" ]]; then
     TMUXINATOR="$(tmuxinator list 2>/dev/null)"
     TMUXINATOR="$(echo $TMUXINATOR | tail -n +2 | sed -e "s/  */,/g" | tr "," "\n" | percol)"

     tmuxinator start "$TMUXINATOR"

     if [ $? -eq 0 ]; then
       echo "$(tmux -V) start tmuxinator"
       return 0
     fi
   elif [[ -n "$ID" ]]; then
     tmux attach-session -t "$ID"

     if [ $? -eq 0 ]; then
       echo "$(tmux -V) attached session"
       return 0
     fi
   else
     :  # Start terminal normally
   fi
 fi
}
