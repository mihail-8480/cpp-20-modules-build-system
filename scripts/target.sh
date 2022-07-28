#!/usr/bin/env bash

target_start_init() {
    export OBJECT_FILES=()
    export CXX_COMPILER="g++"
    export OUTPUT_DIR="build"
    export DEEP_CHECK=1
    export DELETE_OBSOLETE=1
    export STANDARD="c++20"
    export CFLAGS=""
    export LFLAGS=""
    export SYSTEM_HEADERS=()
    export FILES=()
    export OUTPUT="a.out"
    export ARCHIVE=0
    export AR=ar
    export ARFLAGS="rcs"
}

include() {
    for SOURCE in "$@"
    do
        source "${SOURCE}"
    done 
}

add_compiler_flags() {
    CFLAGS+=" $@"
}

add_linker_flags() {
    LFLAGS+=" $@"
}

add_ar_flags() {
    ARFLAGS+=" $@"
}

add_files() {
    FILES+=( "$@" )
}

add_system_headers() {
    SYSTEM_HEADERS+=( "$@" )
}

standard() {
    STANDARD="c++${1}"
}

output_directory() {
    OUTPUT_DIR=${1}
}


shared_library() {
    LFLAGS+=" -shared"
    CFLAGS+=" -fPIC"
    OUTPUT="lib${1}.so"
    ARCHIVE=0
}

executable() {
    CFLAGS+=" -flto -fwhole-program"
    OUTPUT="${1}"
    ARCHIVE=0
}

static_library() {
    OUTPUT="lib${1}.a"
    ARCHIVE=1
}

target_end_init() {
    export CXX_FLAGS="-std=${STANDARD} -fmodules-ts ${CFLAGS}"

    if [ ! -f "${OUTPUT_DIR}" ]
    then
        mkdir -p "${OUTPUT_DIR}"
    fi
    export FLAG_HASH=$(echo "${CXX_FLAGS}" "${LFLAGS}" | sha1sum | cut -f1 -d" ")
    export OLD_HASH=${FLAG_HASH}
    if [ -f "${OUTPUT_DIR}/flags.sha1" ]
    then
        read -r OLD_HASH < "${OUTPUT_DIR}/flags.sha1"
    fi
    echo $FLAG_HASH > "${OUTPUT_DIR}/flags.sha1"
    if [ "${OLD_HASH}" != "${FLAG_HASH}" ]
    then
        rm ${OUTPUT_DIR}/*.o 2> /dev/null
        rm ${OUTPUT_DIR}/*.sysh 2> /dev/null
    fi
}

load_target_file() {
    cd "${OLD_DIR}"
    export TARGET_DIR=$( cd -- "$( dirname -- "${1}" )" &> /dev/null && pwd )
    export TARGET_NAME=$( basename "${1}" )
    OLD_DIR=`pwd`
    cd "${TARGET_DIR}" | exit 1
    cd $TARGET_DIR
    if [ ! -f "${TARGET_NAME}" ]
    then
        echo ${0}: cannot load ${TARGET_NAME}: No such file or directory 
        exit 1
    fi
    source ${TARGET_NAME}
    target_end_init
}

compile_file() {
    export i=$1
    export OBJ_NAME="$(basename $i)"
    OBJ_NAME="${OBJ_NAME%.*}"
    if [ "$DEEP_CHECK" = 1 ]
    then
        export HASH=$("${CXX_COMPILER}" "-E" "${i}" ${CXX_FLAGS} | sha1sum | cut -f1 -d" ")
    else
        export HASH=$(cat ${i} | sha1sum | cut -f1 -d" ")
    fi
    export FILE="${OUTPUT_DIR}/${HASH}.o"
    OBJECT_FILES+=("${FILE}")
    if [ ! -f "${FILE}" ]
    then
        echo "[${CXX_COMPILER}] ${i}: ${FILE}"
        "${CXX_COMPILER}" "-c" "${i}" ${CXX_FLAGS} -o "${FILE}"
    fi
}

compile_system_header() {
    export i=$1
    export HASH=$(echo ${i} | sha1sum | cut -f1 -d" ")
    if [ ! -f "${OUTPUT_DIR}/${HASH}.sysh" ]
    then
        echo "${i}" > "${OUTPUT_DIR}/${HASH}.sysh"
        echo "[${CXX_COMPILER}] ${i}.gcm"
        "${CXX_COMPILER}" ${CXX_FLAGS} -xc++-system-header "${i}" 
    fi
}


compile_system_headers() {
    for i in "${SYSTEM_HEADERS[@]}"
    do
        compile_system_header "${i}"
    done
}


compile_target() {
    compile_system_headers
    for i in "${FILES[@]}"
    do
        compile_file "${i}"
    done
    echo "[${CXX_COMPILER}] ${OUTPUT}"
    if [ $ARCHIVE = 0 ]
    then
        "${CXX_COMPILER}" -o "${OUTPUT_DIR}/${OUTPUT}" ${OBJECT_FILES[@]} ${LFLAGS}
    else
        "${AR}" "${ARFLAGS}" "${OUTPUT_DIR}/${OUTPUT}" ${OBJECT_FILES[@]}
    fi
}

delete_obsolete() {
    if [ "$DELETE_OBSOLETE" = 1 ]
    then
        for FILE in "${OUTPUT_DIR}"/*.o
        do
            case "${OBJECT_FILES[@]}" in 
                *$FILE*)
                    ;;
                *)
                    rm $FILE
                    ;;
            esac
        done
    fi
}

