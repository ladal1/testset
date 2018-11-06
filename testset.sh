#!/bin/bash

# #
#
# testset - test command line programs against Progtest reference data
#
# Do whatever you want with this, just don't blame me for zero points, wasted
#   hints and/or blown up computers.
#
# If you like bash, I'm deeply sorry. If you hate it (you should), please
#   don't ever try to do BI-PS1 like this.
#
# Author/perpetrator: Matyas Cerny
#
# #


if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo 'Usage: testset path/to/tests path/to/executable'
    exit 0
elif [ -z "$2" ]; then
    echo 'Error: missing executable argument' >&2
    exit 1
fi

TEST_DIR="$1"
PRG_EXEC="$2"

if [ ! -d "$TEST_DIR" ]; then
    echo 'Error: invalid test directory path' >&2
    exit 2
fi
if [ -z "`ls ${TEST_DIR}/*_in[^_]* 2>/dev/null`" ]; then
    echo 'Error: no test inputs found in specified folder' >&2
    exit 3
fi
if [ -z "`ls ${TEST_DIR}/*_out[^_]*` 2>/dev/null" ]; then
    echo 'Error: no test outputs found in specified folder' >&2
    exit 3
fi

[ -z "$DIFF_COMMAND" ] && DIFF_COMMAND="`which diff 2>/dev/null`" && \
if [ $? != 0 ]; then
    # Really though, how often will this happen? It even works on fray!
    echo "Error: \`${DIFF_COMMAND}\` not found, use your own \$DIFF_COMMAND or install diff" >&2
    exit 4
fi

INS=()
OUTS=()
i=0
for FILE in "${TEST_DIR}"/*_in[^_]* ; do
    INS[$i]="${FILE}"
    i=$(( $i+1 ))
done

i=0
for FILE in "${TEST_DIR}"/*_out[^_]* ; do
    OUTS[$i]="${FILE}"
    i=$(( $i+1 ))
done

LEN=${#INS[@]}

for TNUM in `seq 0 $(( $LEN - 1 ))` ; do
    printf "\e[1;33mtesting\e[0m: %04d..." $TNUM
    DIFF_OUT="`${PRG_EXEC} < ${INS[$TNUM]} | ${DIFF_COMMAND} --strip-trailing-cr - ${OUTS[$TNUM]}`"
    [ -n "$DIFF_OUT" ] && echo -e "\n\e[1;31mALERT\e[0m: diff produced output:\n${DIFF_OUT}\n" \
            || echo -e " \e[1;32mok\e[0m"
done
