#!/bin/bash
# 2025 - Voidus X
# Sparrow TUI Color Components

ANSI='\e['
FILL='\e[K'
CLEAR='\e[0K'
MOV_UP='\e[1A'
WIPE='\e[2K'
no_color='0m'

color_normal='0;'
color_bold='1;'
color_italic='3;'
color_underline='4;'
color_strikethrough='9;'
color_highlight='0;'

pick(){
    local -n ref="codec_$1"

    if ! [ -n "${2-}" ]; then
        target_color_mode=1
    else
        target_color_mode=$2
    fi

    if [ -n "${3-}" ]; then
        local -n type_ref="color_$3"
    else
        type_ref=$color_normal
    fi
    if ! [ -n "$type_ref" ]; then
      type_ref=$color_normal
    fi

    if [ -n "$ref" ]; then
        real_pointer=$(($target_color_mode - 1))
        if [ $real_pointer -lt 0 ]; then
            echo ""
        else
            if [ $real_pointer -gt 1 ]; then
                echo ""
            else
                echo "${ANSI}${type_ref}${ref[$real_pointer]}m"
            fi
        fi
    fi

}
highlight(){
    local -n ref="codec_$1"

    if ! [ -n "${2-}" ]; then
        target_color_mode=2
    else
        target_color_mode=$2
    fi

    if [ -n "$ref" ]; then
        real_pointer=$(($target_color_mode - 1))
        if [ $real_pointer -lt 0 ]; then
            echo ""
        else
            if [ $real_pointer -gt 1 ]; then
                echo ""
            else
                echo "${ANSI}$((${ref[$real_pointer]} + 10))m"
            fi
        fi
    fi
}

print(){
    local str="$1" # With second argument, becomes color format instead

    if [ -n "${2-}" ]; then
        if [ "$2" == "center" ]; then
            if ! [ -n "${3-}" ]; then
                text=""
            else
                text="$3"
            fi
            local columns=$(tput cols)
            local text_width=${#text}
            local padding=$(( (columns - text_width) / 2 ))
            printf "${1}%*s%s${FILL}${ANSI}${no_color}\n" $padding "" "$text"
        fi
        if [ "$2" == "center-leak" ]; then
            if ! [ -n "${3-}" ]; then
                text=""
            else
                text="$3"
            fi
            local columns=$(tput cols)
            local text_width=${#text}
            local padding=$(( (columns - text_width) / 2 ))
            printf "${1}%*s%s${FILL}\n" $padding "" "$text"
        fi
        if [ "$2" == "seperator" ]; then
            local columns=$(tput cols)
            local padding=$((columns))
            printf "${1}%*s%s${FILL}${ANSI}${no_color}\n" $padding "" ""
        fi
        if [ "$2" == "seperator-leak" ]; then
            local columns=$(tput cols)
            local padding=$((columns + 1))
            printf "${1}%*s%s${FILL}\n" $padding "" ""
        fi
        if [ "$2" == "leak" ]; then
            echo -e "${1}${FILL}"
        fi
    else
        echo -e "${1}${FILL}${ANSI}${no_color}"
    fi
}

print_previous(){
    local str="$1" # With second argument, becomes color format instead

    if [ -n "${2-}" ]; then
        if [ "$2" == "center" ]; then
            if ! [ -n "${3-}" ]; then
                text=""
            else
                text="$3"
            fi
            local columns=$(tput cols)
            local text_width=${#text}
            local padding=$(( (columns - text_width) / 2 ))
            printf "\r${MOV_UP}${WIPE}${1}%*s%s${FILL}${ANSI}${no_color}\n" $padding "" "$text"
        fi
        if [ "$2" == "center-leak" ]; then
            if ! [ -n "${3-}" ]; then
                text=""
            else
                text="$3"
            fi
            local columns=$(tput cols)
            local text_width=${#text}
            local padding=$(( (columns - text_width) / 2 ))
            printf "\r${MOV_UP}${WIPE}${1}%*s%s${FILL}\n" $padding "" "$text"
        fi
        if [ "$2" == "seperator" ]; then
            local columns=$(tput cols)
            local padding=$((columns))
            printf "\r${MOV_UP}${WIPE}${1}%*s%s${FILL}${ANSI}${no_color}\n" $padding "" ""
        fi
        if [ "$2" == "seperator-leak" ]; then
            local columns=$(tput cols)
            local padding=$((columns))
            printf "\r${MOV_UP}${WIPE}${1}%*s%s${FILL}\n" $padding "" ""
        fi
        if [ "$2" == "leak" ]; then
            echo -en "\r${MOV_UP}${WIPE}${1}${FILL}"
        fi
    else
        echo -en "\r${MOV_UP}${WIPE}${1}${FILL}${ANSI}${no_color}"
    fi

}

print_override(){
    local str="$1" # With second argument, becomes color format instead

    if [ -n "${2-}" ]; then
        if [ "$2" == "center" ]; then
            if ! [ -n "${3-}" ]; then
                text=""
            else
                text="$3"
            fi
            local columns=$(tput cols)
            local text_width=${#text}
            local padding=$(( (columns - text_width) / 2 ))
            printf "\r${WIPE}${1}%*s%s${FILL}${ANSI}${no_color}\n" $padding "" "$text"
        fi
        if [ "$2" == "center-leak" ]; then
            if ! [ -n "${3-}" ]; then
                text=""
            else
                text="$3"
            fi
            local columns=$(tput cols)
            local text_width=${#text}
            local padding=$(( (columns - text_width) / 2 ))
            printf "\r${WIPE}${1}%*s%s${FILL}\n" $padding "" "$text"
        fi
        if [ "$2" == "seperator" ]; then
            local columns=$(tput cols)
            local padding=$((columns))
            printf "\r${WIPE}${1}%*s%s${FILL}${ANSI}${no_color}\n" $padding "" ""
        fi
        if [ "$2" == "seperator-leak" ]; then
            local columns=$(tput cols)
            local padding=$((columns))
            printf "\r${WIPE}${1}%*s%s${FILL}\n" $padding "" ""
        fi
        if [ "$2" == "leak" ]; then
            echo -en "\r${WIPE}${1}${FILL}"
        fi
        if [ "$2" == "progress" ]; then
            local columns=$(( $(tput cols)))
            local percent=$(echo "scale=2; $3 / $5" | bc)
            local filled_num=$(echo "scale=0; ($columns * $percent)/1" | bc)

            local filled=$(printf "%*s" $filled_num | tr ' ' ' ')
            local empty=$(printf "${1}%*s" $((columns - filled_num)) | tr ' ' ' ')

            echo -en "\r${4}${filled}${empty}\r"
            #printf "\r${1}%*s%s\n" $padding "" ""
        fi
    else
        echo -en "\r${WIPE}${1}${FILL}${ANSI}${no_color}"
    fi

}

print_end(){
    echo -en "${1}${FILL}${ANSI}${no_color}"
}

codec_red=(31 91)
codec_green=(32 92)
codec_yellow=(33 93)
codec_blue=(34 94)
codec_purple=(35 95)
codec_cyan=(36 96)
codec_black=(30 90)
codec_white=(37 97)
