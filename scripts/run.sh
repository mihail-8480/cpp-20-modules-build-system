#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE 
done
SOURCE_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

source "${SOURCE_DIR}/target.sh"


handle_target() {
    target_start_init
    load_target_file "${1}"
    target_end_init
    if [ ! -f "${OUTPUT_DIR}/${OUTPUT}" ]
    then
      compile_target
    fi
    "${OUTPUT_DIR}/${OUTPUT}"
}

for TARGET in "$@"
do
    handle_target "${TARGET}"
done

