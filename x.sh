#!/bin/bash
# @name: x.sh
# @version: 0.97
# @description: store and jump.
# @author: rednammoc
# @date: 14/06/25

# INSTALL:  put ". /path/to/x.sh" in your .bashrc

# Default configuration-file
_X_CONFIG="${HOME}/.x.conf"

x () {
    # Initialize/Load configuration
    local _X_CONFIG_DIR=$(dirname "${_X_CONFIG}")
    ! [ -d "${_X_CONFIG_DIR}" ] && mkdir -p "${_X_CONFIG_DIR}"
    ! [ -f "${_X_CONFIG}" ] &&
        echo "_X_LIST=\"${_X_CONFIG_DIR}/.x\"" >> "${_X_CONFIG}"
    . "${_X_CONFIG}"

    # Assert that index is 1 <= x <= size(list)
    validate_index () {
        local index="${1}" ; local line_count=$(wc -l < "${_X_LIST}") ;
        if ! [[ "${index}" =~ ^[1-9][0-9]*$ ]] ||
              [ "${index}" -gt ${line_count} ] ; then
            echo "Illegal argument." >&2
            return 1
        fi
    }

    # Return list-entry at specified position
    get_entry () {
        local index="$1" ; validate_index "${index}" || return 1
        sed -n ${index}p < "${_X_LIST}"
    }

    # Print formatted list-entry
    print_entry () {
        local index="$1"; local path="$2"
        printf "%+6s  ${path}\n" "${index}"
    }

    # Ask the user for "Y" or "N" until valid answer is given. 
    # 
    # @param question to ask as string.
    # @param optional default answer (Y,N).
    # @returns 1 when the answer was Y or y. 
    # @returns 0 when the answer was N or n. 
    #
    # (thanks to davejamesmiller for this little snippet.)
    ask () {
      while true; do
        if   [ "${2:-}" = "Y" ]; then prompt="Y/n"; default=Y;
        elif [ "${2:-}" = "N" ]; then prompt="y/N"; default=N;
        else                          prompt="y/n"; default= ; fi
        read -p "$1 [$prompt] " REPLY                 # Ask the question
        if [ -z "$REPLY" ]; then REPLY=${default}; fi # Default?
        case "$REPLY" in                              # Check if reply is valid
          Y*|y*) return 0 ;;
          N*|n*) return 1 ;;
        esac
      done
    }

    # Parse/Execute commandline-arguments
    if [ "$1" == "-r" ] ; then
        local path=$(get_entry "$2")
        [ -z "${path}" ] && return 1
        if ! [ -d "${path}" ] ; then
          echo "The specified entry '${path}' does not exist anymore!"
          local question="Do you want to remove the entry from your current profile?"
          if ask "${question}" Y ; then x -d "${2}"; return 0; fi
          return 1;
        fi
        [ -n "${path}" ] && cd "${path}"
    elif [ "$1" == "-l" ] ; then
        local line_count=$(wc -l < "${_X_LIST}")
        if [ -f "${_X_LIST}" ] && [[ "${line_count}" -gt 0 ]] ; then
            cat -n "${_X_LIST}"
        fi
    elif [ "$1" == "-c" ] ; then
        > "${_X_LIST}"
    elif ( [ "$1" == "-a" ] || [ "$1" == "-p" ] ) ; then
        local path="${2}" ; local index=0
        if [ -z "${path}" ] ; then
            # Default to current directory
            path="`pwd`"
        else
            # Validate and normalize path
            if ! [ -d "${path}" ] ; then echo "Illegal argument." >&2; return 1; fi
            # Relative or absolute path?
            if ! [[ "$2" = /* ]] ; then path="`pwd`/$2" ; fi
            # Remove trailing slash/dot
            path="${path%/.}" ; path="${path%/}"
        fi

        # Check for duplicate entries
        if [ -f "${_X_LIST}" ] ; then
            if grep -Fxq "${path}" "${_X_LIST}" ; then
                index=`grep -Fxnm 1 "${path}" "${_X_LIST}" | grep -oEi '^[0-9]+'`
                echo "The folder '${path}' is already in your list (#${index})." >&2
                return 1
            fi
        fi

        if   [ "$1" == "-a" ] ; then
            echo "${path}" >> "${_X_LIST}"
        elif [ "$1" == "-p" ] ; then
            echo "${path}" |
                cat - "${_X_LIST}" > "${_X_LIST}.tmp" &&
                mv "${_X_LIST}.tmp" "${_X_LIST}"
        fi
    elif [ "$1" == "-d" ] ; then
        local index="$2" ; local path=$(get_entry "${index}")
        [ -z "${path}" ] && return 1
        sed -e "${index}d" "${_X_LIST}" > "${_X_LIST}.tmp" &&
            mv "${_X_LIST}.tmp"  "${_X_LIST}"
    elif [ "$1" == "-i" ] ; then
        local records=0; 
        if [ -f "${_X_LIST}" ] ; then 
            records=$(wc -l < "${_X_LIST}")
        fi
        echo "(Profile: $(basename "${_X_LIST}"), Records: ${records})"
    else
        echo "Usage: x [-aplrdci] [args]"
        echo
        echo "Options:"
        echo 
        echo "  -a [folder] || -p [folder]"
        echo "    append or prepend folder to current profile. "
        echo "    when no folder is specified, the current folder "
        echo "    will be used."
        echo "  -l  list folders within current profile."
        echo "  -r <number>  restore nth folder from the current profile."
        echo "  -d <number>  delete nth folder from the current profile." 
        echo "  -c  clear current profile."
        echo "  -h  show this help."
        echo

    fi
}
