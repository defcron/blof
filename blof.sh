#!/bin/bash
# Generate a .blof (Binary Linear Object File) format file and output it to stdout.

generate_blof_crumb() {
    # Read stdin into a temporary file
    local tmpfile=$(mktemp)
    cat > "$tmpfile"

    # Archive that file
    (tar --transform='s|.*/\(.*\)$|\1.blof.out|' --sort=name --owner=0 --group=0 --numeric-owner --format=gnu -cf - -C "$(dirname $tmpfile)" $@ "$(basename $tmpfile)" | gzip -9 | xxd -b -c256 | awk -F": |  |\n" '{print $2}' | sed 's/\s//g' | tr -d '\n') 2>&1

    rm -f "$tmpfile"
    return $?
}

blof() {
    if [ "$1" = "-x" ] || [ "$1" = "x" ]; then
        shift

        (cat | cut -d' ' -f1 | fold -w8 | while read -r byte; do printf "%02x" "$((2#$byte))"; done) | xxd -p -r | tar zxOf - $@
        return $?
    fi
    if [ "$1" = "-c" ] || [ "$1" = "c" ]; then
        shift

        local BLOF_CRUMB=$(generate_blof_crumb $@)
        local bit0=$(echo $BLOF_CRUMB | head -c 1)

        if [ "$bit0" != "0" -a "$bit0" != "1" ]; then
            echo "error: ${BLOF_CRUMB}" 1>&2
            return 1
        fi

        printf "%s" "$BLOF_CRUMB"
	return 0
    fi

    # Default mode
    "$0" c $@ < <("$0" c $@ < "$0")
    return $?
}

blof "$@"

exit $?
