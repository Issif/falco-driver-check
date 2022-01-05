#!/usr/bin/env bash
# set -xe

DRIVER_NAME="falco"
PROBE_NAME="falco"

FALCO_LIBS_VERSION=$1
KERNEL_RELEASE=$2
KERNEL_VERSION=$3
TARGET_ID=$4

print_usage() {
	echo "Usage:"
	echo "  generate-driverkit-config [falco_lib_version] [kernel_release] [kernel_version] [target]"
	echo ""
	echo "Arguments:"
	echo "  falco_lib_version       falco library version"
	echo "  kernel_release          kernel release"
	echo "  kernel_version          kernel version"
	echo "  target                  target"
	echo ""
	echo "Options:"
	echo "  --help         show brief help"
	echo ""
}

case "$1" in
	-h|--help)
		print_usage
		exit 0
		;;
esac

FOLDER="driverkit/config/${FALCO_LIBS_VERSION}"
FILE="${FOLDER}/${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.yaml"

mkdir -p ${FOLDER}

echo "kernelversion: ${KERNEL_VERSION}" > ${FILE}
echo "kernelrelease: ${KERNEL_RELEASE}" >> ${FILE}
echo "target: ${TARGET_ID}" >> ${FILE}
echo "output:" >> ${FILE}
echo "  module: output/${FALCO_LIBS_VERSION}/${DRIVER_NAME}_${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.ko" >> ${FILE}
echo "  probe: output/${FALCO_LIBS_VERSION}/${PROBE_NAME}_${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.o" >> ${FILE}