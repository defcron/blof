#!/bin/bash
# Generate a .blch (Binary Linear with Checksum Header) format file and output it to stdout.

generate_blch_crumb() {
    # Read stdin into a temporary file
    local tmpfile=$(mktemp)
    cat > "$tmpfile"

    # Archive that file
    (tar --transform='s|.*/\(.*\)$|\1.blch.out|' --sort=name --owner=0 --group=0 --numeric-owner --format=gnu -cf - -C "$(dirname $tmpfile)" $@ "$(basename $tmpfile)" | gzip -9 | xxd -b -c256 | awk -F": |  |\n" '{print $2}' | sed 's/\s//g' | tr -d '\n') 2>&1

    rm -f "$tmpfile"
    return $?
}

blch() {
    if [ "$1" = "-x" ] || [ "$1" = "x" ]; then
        shift

	(cat | cut -d' ' -f2 | fold -w8 | while read -r byte; do printf "%02x" "$((2#$byte))"; done) | xxd -p -r | tar zxOf - $@
        return $?
    fi
    if [ "$1" = "-t" ] || [ "$1" = "t" ]; then
        # Test checksum
	shift

	local stdin_contents=$(cat)
        local header=$(printf "%s" "$stdin_contents" | cut -d' ' -f1)
        local body=$(printf "%s" "$stdin_contents" | cut -d' ' -f2)
	local stored_checksum=$(printf "%s" "$header" | cut -d\= -f2)
        local calculated_checksum=$(printf "%s" "$body" | sha256sum -z --tag | awk '{print $1 $2 $3 $4}' | tr -d '\0' | cut -d\= -f2)

	if [ "$stored_checksum" = "$calculated_checksum" ]; then
            echo "true"
	    echo "stored_checksum:	$stored_checksum" 1>&2
	    echo "calculated_checksum:	$calculated_checksum" 1>&2
	    return 0
        else
            echo "false"
	    echo "stored_checksum:	$stored_checksum" 1>&2
	    echo "calculated_checksum:	$calculated_checksum" 1>&2
            return 255
        fi
    fi
    if [ "$1" = "-c" ] || [ "$1" = "c" ]; then
        shift
    
	local BLCH_CRUMB=$(generate_blch_crumb $@)
        local bit0=$(echo $BLCH_CRUMB | head -c 1)

	if [ "$bit0" != "0" -a "$bit0" != "1" ]; then
            echo "error: ${BLCH_CRUMB}" 1>&2
	    return 1
        fi

	printf "%s %s" "$(printf '%s' "$BLCH_CRUMB" | sha256sum -z --tag | awk '{print $1 $2 $3 $4}' | tr -d '\0')" "$BLCH_CRUMB"
        return 0
    fi
    
    # Default mode
    "$0" c $@ < <("$0" c $@ < "$0")
    return $?
}

blch "$@"

exit $?
