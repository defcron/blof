#!/bin/bash
# Generate a .blof (Binary Linear Object File) format file and output it to stdout.

generate_blof_crumb() {
    local args=${@}

    (tar cOPS ${args} --owner=0 <(cat) | gzip -9 | xxd -b -c256 | awk -F": |  |\n" '{print $2}' | sed 's/\s//g' | tr -d '\n') 2>&1
}

blof() {
    local BLOF_CRUMB=$(generate_blof_crumb "$@")
    local bit0=$(echo $BLOF_CRUMB | head -c 1)

    if [ $bit0 != "0" -a $bit0 != "1" ]; then
        echo "$BLOF_CRUMB" 1>&2
	return 1
    fi

    printf "%s" "$BLOF_CRUMB"

    return 0
}

blof "$@"

exit $?
