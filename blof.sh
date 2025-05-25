#!/bin/bash
# Generate a .blof (Binary Linear Object File) format file and output it to stdout.

# TODO: This file is currently out-of-date and not working, but just use blch.sh instead, it's better anyway.
# Or you can update this to work the similar way as in blch.sh and if you do, please submit a PR for the fixes.

generate_blof_crumb() {
    local args=${@}

    (tar cOPS ${args} --transform='s|$|.blof.out|' --sort=name --owner=0 --group=0 --numeric-owner --format=gnu <(cat) | gzip -9 | xxd -b -c256 | awk -F": |  |\n" '{print $2}' | sed 's/\s//g' | tr -d '\n') 2>&1

    return $?
}

blof() {
    if [ "$1" = "-x" ] || [ "$1" = "x" ]; then
        # Extract mode
        tail -c +1 | fold -w8 | awk '{ printf("%c", strtonum("0b" $0)) }' | gzip -d | tar xOP

        return $?
    fi

    if [ "$1" = "-c" ] || [ "$1" = "c" ]; then
        shift

        local BLOF_CRUMB=$(generate_blof_crumb "$@")
        local bit0=$(echo $BLOF_CRUMB | head -c 1)

        if [ $bit0 != "0" -a $bit0 != "1" ]; then
            echo "$BLOF_CRUMB" 1>&2
            return 1
        fi

        printf "%s" "$BLOF_CRUMB"

	return 0
    fi

    # Default mode
    "$0" c "$@" < <("$0" c "$@" < "$0")
    return $?
}

blof "$@"

exit $?
