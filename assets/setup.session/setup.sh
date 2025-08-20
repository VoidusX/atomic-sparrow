#!/bin/bash
# 2025 - Voidus X
# Sparrow TUI Dotfiles Installer

#set -oue pipefail
parent="$(dirname "$0")"
#shopt -s expand_aliases
source $parent/setup.lib/bash-tui-toolkit.bash
source $parent/setup.lib/color-handling.sh
parse_log_level "info"

dry_run=1
startup_pause=1
rebootable=0
if [ "$parent" == "usr/share/sparrow-setup" ]; then
    dry_run=0
fi

notice_window(){
    tput civis
    if [ $dry_run -eq 1 ]; then
        print "${yellow}${black_highlight}Dry-run is enabled." "leak"
    else
        print "${yellow}${black_highlight}"
    fi
    print "${yellow_title}${black_highlight}" "center-leak" "Welcome To Sparrow"
    print "${yellow_bar}${black_highlight}" "seperator"
    print "${yellow}${black_highlight}" "leak"
    print " You are about to start the installation of the end-4 dotfiles." "leak"
    print " Please note, some features may not be installable due to the atomic design of sparrow." "leak"
    print ""

    ready=$(confirm "Proceed with the installation?")
    clear

    if [ "$ready" = "0" ]; then
        main_window
    fi

    if [ "$ready" = "1" ]; then
        if [ $dry_run -eq 0 ]; then
            tput cvvis
            command "bash <(curl -s https://raw.githubusercontent.com/EisregenHaha/fedora-hyprland/f42/setup.sh)" &
            install_pid=$!
            wait $install_pid
            if [ $? -eq 0 ]; then
                clear
                rebootable=1
                main_window
            else
                installation_failed_popup
            fi
        fi
        if [ $dry_run -eq 1 ]; then
            dry_run_unallowed_window
        fi
    fi


}

unimplemented_window(){
    term_lines=$(tput lines)
    best_position=$(($term_lines - 5))
    tput cup $best_position 0

    print "${fail_tag}${black_highlight} Custom dotfiles support is not yet implemented."
    print "${white}${black_highlight}"
    print "${white}${black_highlight}   We are currently working on implementing this feature, please check back later."
    print "${white}${black_highlight}   For more information, visit ${hyperlink}https://github.com/voidusx/atomic-sparrow${white}${black_highlight} and check the issues page."
    print_end "${white}${black_highlight}"
    tput cup 0 0
    main_window
}

dry_run_unallowed_window(){
    term_lines=$(tput lines)
    best_position=$(($term_lines - 5))
    tput cup $best_position 0

    print "${fail_tag}${black_highlight} The end-4 dotfiles installation does not support dry-run."
    print "${white}${black_highlight}"
    print "${white}${black_highlight}   To protect your host machine while developing sparrow, we disabled the ability to install the dotfiles."
    print "${white}${black_highlight}   This is intentional, and this error should be treated as a success."
    print_end "${white}${black_highlight}"
    tput cup 0 0
    main_window
}

installation_success_popup(){
    term_lines=$(tput lines)
    best_position=$(($term_lines - 5))
    tput cup $best_position 0

    print "${success_tag}${black_highlight} Dotfiles installation is finished, and sparrow is ready."
    print "${white}${black_highlight}"
    print "${white}${black_highlight}   You selected the end-4 dotfiles, and it has successfully installed and configured for your next session."
    print "${white}${black_highlight}   You will need to exit and reboot in order to access your newly configured session.."
    print_end "${white}${black_highlight}"
    tput cup 7 0
}

installation_failed_popup(){
    tput civis
    term_lines=$(tput lines)
    best_position=$(($term_lines - 5))
    tput cup $best_position 0

    print "${fail_tag}${black_highlight} Fatal error occured with dotfiles installation!"
    print "${white}${black_highlight}"
    print "${white}${black_highlight}   You will encounter a corrupted dotfiles installation that requires manual intervention."
    print "${white}${black_highlight}   The system will reboot in 5 seconds."
    print_end "${white}${black_highlight}"

    for i in {1..5}; do
        sleep 1
        print_previous "${white}${black_highlight} The system will reboot in $((5 - $i)) seconds."
        print_override "${black_bar_bottom}${black_highlight}" "progress" $i "${black_highlight}${yellow_bar_bottom}" 5 # For outline bars
    done

    print_previous "${white}${black_highlight} The system is rebooting."
    systemctl reboot
}


main_window(){
    tput civis
    if [ $dry_run -eq 1 ]; then
        print "${yellow}${black_highlight}Dry-run is enabled." "leak"
    else
        print "${yellow}${black_highlight}"
    fi
    print "${yellow_title}${black_highlight}" "center-leak" "Welcome To Sparrow"
    print "${yellow_bar}${black_highlight}" "seperator"
    print "${yellow}${black_highlight}" "leak"
    print " Welcome, This is your first time running Hyprland." "leak"
    print " Before you can get started, a dotfiles configuration needs to be applied." "leak"
    print ""

    if [ $startup_pause -eq 1 ]; then
        sleep 3
        startup_pause=0
    fi

    if [ $rebootable -eq 1 ]; then
      installation_success_popup
    fi

    actions=("Default (end-4)" "Custom" "Exit Installer")
    action=$(list "Select which option to begin applying dotfiles:" "${actions[@]}")
    tput civis

    if [ "$action" == "2" ]; then
      term_lines=$(tput lines)
      best_position=$(($term_lines - 5))
      tput cup $best_position 0


      if [ $rebootable -eq 0 ]; then
          print "${cancel_tag}${black_highlight} The quit option was selected, setup process has been cancelled."
      else
          print "${success_tag}${black_highlight} Dotfiles installation is finished, and sparrow is ready."
      fi
      print "${white}${black_highlight}"
      print "${white}${black_highlight}"
      if [ $rebootable -eq 0 ]; then
          print "${white}${black_highlight}" "center" "The system will be powering off in 5 seconds."
      else
          print "${white}${black_highlight}" "center" "The system will be rebooting off in 5 seconds."
      fi
      print_end "${white}${black_highlight}"

      for i in {1..5}; do
          sleep 1
          if [ $rebootable -eq 0 ]; then
              print_previous "${white}${black_highlight}" "center" "The system will be powering off in $((5 - $i)) seconds."
          else
              print_previous "${white}${black_highlight}" "center" "The system will be rebooting in $((5 - $i)) seconds."
          fi
          # print_override "${black_highlight}" "progress" $i "${white_highlight}" 5 # For simple filled bars
          print_override "${black_bar_bottom}${black_highlight}" "progress" $i "${black_highlight}${yellow_bar_bottom}" 5 # For outline bars
      done

      if [ $rebootable -eq 0 ]; then
          print_previous "${white}${black_highlight}" "center" "The system is powering off."
      else
          print_previous "${white}${black_highlight}" "center" "The system is rebooting."
      fi

      if [ $dry_run -eq 0 ]; then
          if [ $rebootable -eq 0 ]; then
          systemctl poweroff
          else
          systemctl reboot
          fi
      else
          clear
          tput cvvis
          log "2" "Sparrow's setup script was canceled. (dry-run)"
          exit 0
      fi
    fi

    clear

    if [ "$action" == "0" ]; then
        notice_window
    fi

    if [ "$action" == "1" ]; then
        unimplemented_window
    fi

    if [ "$action" == "" ]; then
        term_lines=$(tput lines)
        best_position=$(($term_lines - 5))
        tput cup $best_position 0

        print "${error_tag}${black_highlight} Unexpected input occured."
        print "${white}${black_highlight}"
        print "${white}${black_highlight}   Please try selecting a option again."
        print "${white}${black_highlight}"
        print_end "${white}${black_highlight}"
        tput cup 0 0
        main_window
    fi
}

white="$(pick "white")"
white_highlight="$(highlight "white")"
black="$(pick "black")"
black_bar="$(pick "black" "2" "strikethrough")"
black_bar_bottom="$(pick "black" "2" "underline")"
black_highlight="$(highlight "black")"
green_highlight="$(highlight "green")"
red="$(pick "red")"
red_highlight="$(highlight "red")"
yellow="$(pick "yellow")"
hyperlink="$(pick "cyan" "2" "underline")"
yellow_title="$(pick "yellow" "2" "bold")"
yellow_bar="$(pick "yellow" "2" "strikethrough")"
yellow_bar_bottom="$(pick "yellow" "2" "underline")"
yellow_highlight="$(highlight "yellow")"
cancel_tag="${black}${yellow_highlight}CANCEL${white}"
fail_tag="${black}${red_highlight}FAIL${white}"
error_tag="${black}${red_highlight}ERROR${white}"
success_tag="${black}${green_highlight}SUCCESS${white}"

clear
main_window
