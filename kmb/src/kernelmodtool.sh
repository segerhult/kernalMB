#!/bin/bash

# Function to check if a module exists in the current directory
function check_module {
    if [ -f "$MODULE_NAME.c" ]; then
        echo "Module $MODULE_NAME found."
    else
        echo "Module $MODULE_NAME not found."
    fi
}

# Function to compile the module
function compile_module {
    make
}

# Function to load the module
function load_module {
    sudo insmod $MODULE_NAME.ko
}

# Function to unload the module
function unload_module {
    sudo modprobe -r $MODULE_NAME
}

# Function to test the module
function test_module {
    # Call your testing script here
    ./test.sh $MODULE_NAME.ko
}

# Get the module name from the current directory
MODULE_NAME=$(basename $(pwd))

# Set the kernel version
KERNEL_VERSION=$(uname -r)

# Set the template file for the C source code
TEMPLATE_FILE="module_template.c"

# Create the C source file based on the template
sed "s/MODULE_NAME/$MODULE_NAME/g" $TEMPLATE_FILE > "$MODULE_NAME.c"

# Create the Makefile
cat <<EOF > Makefile
obj-m += $MODULE_NAME.o

all:
\tmake -C /lib/modules/\$(KERNEL_VERSION)/build M=\$(PWD) modules

clean:
\trm -rf *.o *.ko *.mod.* .\$(MODULE_NAME).* .tmp_versions

install:
\tmake -C /lib/modules/\$(KERNEL_VERSION)/build M=\$(PWD) modules_install

load:
\tinsmod $MODULE_NAME.ko

unload:
\tmodprobe -r $MODULE_NAME

reload: unload load

dmesg:
\tdmesg | grep $MODULE_NAME

test:
\ttest_module
EOF

# Add the source file to the Makefile
echo "$MODULE_NAME-objs += $MODULE_NAME.o" >> Makefile

# Case statement to execute the specified action
case "$1" in
    check)
        check_module
        ;;
    compile)
        compile_module
        ;;
    load)
        load_module
        ;;
    unload)
        unload_module
        ;;
    test)
        test_module
        ;;
    *)
        echo "Usage: $0 {check|compile|load|unload|test}"
        exit 1
esac

exit 0

