#!/bin/bash
# Generate a .blch (Binary Linear with Checksum Header) format file and output it to stdout.

generate_blch_crumb() {
    local args=${@}

    (tar cOPS ${args} --owner=0 <(cat) | gzip -9 | xxd -b -c256 | awk -F": |  |\n" '{print $2}' | sed 's/\s//g' | tr -d '\n') 2>&1
}

blch() {
    local BLCH_CRUMB=$(generate_blch_crumb "$@")
    local bit0=$(echo $BLCH_CRUMB | head -c 1)

    if [ $bit0 != "0" -a $bit0 != "1" ]; then
	echo "error: ${BLCH_CRUMB}" 1>&2
        return 1
    fi

    printf "%s %s" "$(echo "$BLCH_CRUMB" | sha256sum -z --tag | awk '{print $1 $2 $3 $4}' | tr -d '\0')" "$BLCH_CRUMB"
}

blch "$@"

exit $?
