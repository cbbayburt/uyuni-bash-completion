#/usr/bin/env bash

__spacewalk_common_channels_options="c:config= u:user= p:password= s:server= k:keys= n:dry-run
    a:archs= v:verbose l:list d:default-channels h:help"

# Adds a trailing space to a word if it does not end with a '=' character
# The resulting word is assigned to the 'opt' variable
# 1: the word to be appended
_add_suffix() {
    case $1 in
        *=) opt="$1" ;;
        *) opt="$1 " ;;
    esac
}

# Fills the completion array with the wordlist that start with the word
# stored in the 'cur' variable
# @: The word list
_complete_list() {
    local wordlist
    wordlist="$@"
    wordlist=($(compgen -W "$wordlist" -- "${cur-}"))
    if [ "${#wordlist[@]}" == "1" ]; then
        # Append a space if there is only one option
        COMPREPLY=("${wordlist[0]} ")
    else
        COMPREPLY=(${wordlist[@]})
    fi
}

# Perform a filename completion for the word stored in the 'cur' variable
_complete_files() {
    local files
    files=($(compgen -f -o filenames -- "${cur-}"))
    COMPREPLY=(${files[@]})

    # use a hack to enable file mode in bash < 4
    # see: https://github.com/git/git/commit/3ffa4df4b2a26768938fc6bf1ed0640885b2bdf1
    compopt -o filenames +o nospace 2>/dev/null ||
    compgen -f /non-existing-dir/ > /dev/null ||
    true
}

# Returns success if the current option matches the option specified in the arguments
# 1: the short option
# 2: the matching long option
_is_option() {
    local prev pprev
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    pprev="${COMP_WORDS[COMP_CWORD-2]}"

    if [ "$prev" = "-$1" ] || [ "$prev" = "--$2" ] ||
            $([ "$prev" = "=" ] && [ "$pprev" = "--$2" ]); then
        return 0
    else
        return 1
    fi
}

_spacewalk_common_channels_completions() {
    local cur IFS=$' \t\n'
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Replace short options with long versions
    local short long c i
    for c in $__spacewalk_common_channels_options; do
        short="${c%%:*}"
        long="${c#*:}"
        if [ "-$short" = "$cur" ]; then
            _add_suffix $long
            COMPREPLY[i++]="--$opt"
            return
        fi
    done

    # Complete filenames for config
    local files
    if _is_option c config; then
        cur="${cur#=}"
        _complete_files
        return
    fi


    # Complete architectures
    if _is_option a archs; then
        cur="${cur#=}"
        _complete_list $(spacewalk-common-channels --list | tail -n +2 |
            sed 's/^[^:]*:\s\+//' | sed 's/, /\n/g' | sort | uniq)
        return
    fi

    # Long options
    case "$cur" in
    --*=) ;;
    -*)
        for o in $__spacewalk_common_channels_options; do
            o="${o#*:}"
            if [[ "--$o" = "$cur"* ]]; then
                _add_suffix $o
                COMPREPLY[i++]="--$opt"
            fi
        done
        ;;
    *)
        # Complete channels
        _complete_list $(spacewalk-common-channels --list | tail -n +2 | sed 's/:.*$//')
        ;;
    esac
}

complete -o nospace -F _spacewalk_common_channels_completions spacewalk-common-channels
