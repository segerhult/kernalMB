#!/bin/bash

MODULE_DIR=$(basename $(pwd))

function compile_module {
    cd $MODULE_DIR
    make
}

function run_kunit_tests {
    kunit-runner --kunit-config=kunit-config.json
}

function run_ltp_tests {
    cd /opt/ltp
    ./runltp -f $MODULE_DIR/module_tests.txt
}

function run_fuzzing_tests {
    afl-fuzz -i input_dir -o output_dir -- ./$MODULE_DIR
}

function run_valgrind {
    valgrind --leak-check=yes ./$MODULE_DIR
}

function run_gcov {
    cd $MODULE_DIR
    make clean
    make gcov
    ./$MODULE_DIR
    gcov $MODULE_DIR.c
}

function enable_kasan {
    make clean
    make CONFIG_KASAN=y
    ./$MODULE_DIR
    dmesg | grep KASAN
}

function usage {
    echo "Usage: $0 [-c|-k|-l|-f|-v|-g|-s]"
    echo "  -c: Compile the kernel module"
    echo "  -k: Run KUnit tests on the module"
    echo "  -l: Run LTP tests on the module"
    echo "  -f: Run fuzzing tests on the module"
    echo "  -v: Run Valgrind to detect memory leaks"
    echo "  -g: Run Gcov to measure code coverage"
    echo "  -s: Enable KASan to detect memory-related bugs"
}

while getopts ":cklfvgs" opt; do
    case $opt in
        c)
            compile_module
            ;;
        k)
            run_kunit_tests
            ;;
        l)
            run_ltp_tests
            ;;
        f)
            run_fuzzing_tests
            ;;
        v)
            run_valgrind
            ;;
        g)
            run_gcov
            ;;
        s)
            enable_kasan
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    usage
    exit 1
fi

