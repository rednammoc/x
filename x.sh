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
        local INDEX="${1}" ; local LINE_COUNT=$(wc -l < "${_X_LIST}") ; 
        if ! [[ "${INDEX}" =~ ^[1-9][0-9]*$ ]] || 
              [ "${INDEX}" -gt ${LINE_COUNT} ] ; then
            echo "Illegal argument." >&2
            return 1
        fi
    }

    # Return list-entry at specified position
    get_entry () {
        local INDEX="$1" ; validate_index "${INDEX}" || return 1
        sed -n ${INDEX}p < "${_X_LIST}"
    }

    # Print formatted list-entry
    print_entry () {
        local INDEX="$1"; local FOLDER="$2"
        printf "%+6s  ${FOLDER}\n" "${INDEX}"
    }

    # Parse/Execute commandline-arguments
	if [ "$1" == "-r" ] ; then
        local FOLDER=$(get_entry "$2")
        [ -n "${FOLDER}" ] && cd "${FOLDER}"
	elif [ "$1" == "-l" ] ; then
        local RECORDS=0; local LINE_COUNT=$(wc -l < "${_X_LIST}")
        if [ -f "${_X_LIST}" ] && [[ "${LINE_COUNT}" -gt 0 ]] ; then
            print_entry "Index" "Folder" 
            cat -n "${_X_LIST}"
            RECORDS=$(wc -l < "${_X_LIST}")
        fi
        echo "(Profile: $(basename "${_X_LIST}"), Records: ${RECORDS})"
	elif [ "$1" == "-c" ] ; then
		> "${_X_LIST}"
    elif ( [ "$1" == "-a" ] || [ "$1" == "-p" ] ) ; then
        local FOLDER="${2}" ; local INDEX=0
        if [ -z "${FOLDER}" ] ; then
            # Default to current directory
            FOLDER="`pwd`"
        else
            # Validate and normalize path
            if ! [ -d "${FOLDER}" ] ; then echo "Illegal argument." >&2; return 1; fi
            # Relative or absolute path?
            if ! [[ "$2" = /* ]] ; then FOLDER="`pwd`/$2" ; fi
            # Remove trailing slash/dot
            FOLDER="${FOLDER%/.}" ; FOLDER="${FOLDER%/}"
        fi
		
        # Check for duplicate entries
        if [ -f "${_X_LIST}" ] ; then
            if grep -Fxq "${FOLDER}" "${_X_LIST}" ; then
                INDEX=`grep -Fxnm 1 "${FOLDER}" "${_X_LIST}" | grep -oEi '^[0-9]+'`
                echo "The folder '${FOLDER}' is already in your list (#${INDEX})." >&2
                return 1
            fi
        fi

        if   [ "$1" == "-a" ] ; then
            echo "${FOLDER}" >> "${_X_LIST}"	
            INDEX=$(wc -l < "${_X_LIST}") 
        elif [ "$1" == "-p" ] ; then 
            echo "${FOLDER}" | 
                cat - "${_X_LIST}" > "${_X_LIST}.tmp" &&
                mv "${_X_LIST}.tmp" "${_X_LIST}"
            INDEX=1 
        fi
        print_entry "${INDEX}" "${FOLDER}"
    elif [ "$1" == "-d" ] ; then
        local INDEX="$2" ; local FOLDER=$(get_entry "${INDEX}")
        [ -z "${FOLDER}" ] && return 1
        print_entry "${INDEX}" "${FOLDER}"
        sed -e "${INDEX}d" "${_X_LIST}" > "${_X_LIST}.tmp" && 
            mv "${_X_LIST}.tmp"  "${_X_LIST}"
    else
        echo "Usage: x [-aplrdc] [args]"
    fi
}
