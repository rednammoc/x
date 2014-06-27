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

    # Parse/Execute commandline-arguments
	if [ "$1" == "-r" ] ; then
        local path=$(get_entry "$2")
        [ -n "${path}" ] && cd "${path}"
	elif [ "$1" == "-l" ] ; then
        local records=0; local line_count=$(wc -l < "${_X_LIST}")
        if [ -f "${_X_LIST}" ] && [[ "${line_count}" -gt 0 ]] ; then
            print_entry "Index" "Folder" 
            cat -n "${_X_LIST}"
            records=$(wc -l < "${_X_LIST}")
        fi
        echo "(Profile: $(basename "${_X_LIST}"), Records: ${records})"
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
            index=$(wc -l < "${_X_LIST}") 
        elif [ "$1" == "-p" ] ; then 
            echo "${path}" | 
                cat - "${_X_LIST}" > "${_X_LIST}.tmp" &&
                mv "${_X_LIST}.tmp" "${_X_LIST}"
            index=1 
        fi
        print_entry "${index}" "${path}"
    elif [ "$1" == "-d" ] ; then
        local index="$2" ; local path=$(get_entry "${index}")
        [ -z "${path}" ] && return 1
        print_entry "${index}" "${path}"
        sed -e "${index}d" "${_X_LIST}" > "${_X_LIST}.tmp" && 
            mv "${_X_LIST}.tmp"  "${_X_LIST}"
    else
        echo "Usage: x [-aplrdc] [args]"
    fi
}
