#!/usr/bin/env bash
# set -xe

DRIVERS_REPO="https://download.falco.org/driver"
DRIVER_NAME="falco"
PROBE_NAME="falco"
KERNEL_RELEASE=$(uname -r)
KERNEL_VERSION=$(uname -v | sed 's/#\([[:digit:]]\+\).*/\1/')

get_target_id() {
	if [ -f "${HOST_ROOT}/etc/os-release" ]; then
		# freedesktop.org and systemd
		# shellcheck source=/dev/null
		source "${HOST_ROOT}/etc/os-release"
		OS_ID=$ID
	elif [ -f "${HOST_ROOT}/etc/debian_version" ]; then
		# Older debian distros
		# fixme > Can this happen on older Ubuntu?
		OS_ID=debian
	elif [ -f "${HOST_ROOT}/etc/centos-release" ]; then
		# Older CentOS distros
		OS_ID=centos
	elif [ -f "${HOST_ROOT}/etc/VERSION" ]; then
		OS_ID=minikube
	else
		echo "Detected an unsupported target system, please get in touch with the Falco community"
		exit 1
	fi

	case "${OS_ID}" in
	("amzn")
		if [[ $VERSION_ID == "2" ]]; then
			TARGET_ID="amazonlinux2"
		else
			TARGET_ID="amazonlinux"
		fi
		;;
	("ubuntu")
		if [[ $KERNEL_RELEASE == *"aws"* ]]; then
			TARGET_ID="ubuntu-aws"
		else
			TARGET_ID="ubuntu-generic"
		fi
		;;
	(*)
		TARGET_ID=$(echo "${OS_ID}" | tr '[:upper:]' '[:lower:]')
		;;
	esac
}

check_probe_availability() {
	local BPF_PROBE_FILENAME="${PROBE_NAME}_${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.o"

	local URL
	URL=$(echo "${DRIVERS_REPO}/${FALCO_LIBS_VERSION}/${BPF_PROBE_FILENAME}" | sed s/+/%2B/g)

	STATUS="$(curl -s -L -I ${URL} | grep HTTP | grep 404)"
	if [ -n "${STATUS}" ]; then
		return
	fi
	PROBE_AVAILABLE="true"
}

check_module_availability() {
	local FALCO_KERNEL_MODULE_FILENAME="${DRIVER_NAME}_${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.ko"

	local URL
	URL=$(echo "${DRIVERS_REPO}/${FALCO_LIBS_VERSION}/${FALCO_KERNEL_MODULE_FILENAME}" | sed s/+/%2B/g)

	STATUS="$(curl -s -L -I ${URL} | grep HTTP | grep 404)"
	if [ -n "${STATUS}" ]; then
		return
	fi
	MODULE_AVAILABLE="true"
}

get_last_falco_release() {
FALCO_VERSION="${1}"
if [ -z "${1}" ]; then
	FALCO_VERSION="$(curl -s https://api.github.com/repos/falcosecurity/falco/git/refs/tags | jq -r ".[-1] | .ref" | cut -f3 -d"/")"
fi
}

get_falco_libs_sha() {
	FALCO_LIBS_VERSION="$(curl -s  https://raw.githubusercontent.com/falcosecurity/falco/${FALCO_VERSION}/cmake/modules/falcosecurity-libs.cmake | grep 'set(FALCOSECURITY_LIBS_VERSION' | cut -f2 -d'"')"
}

print_usage() {
	echo "Usage:"
	echo "  falco-driver-check [version]"
	echo ""
	echo "Arguments:"
	echo "  version       version of Falco to check"
	echo "                (if empty, last version is checked)"
	echo "Options:"
	echo "  --help         show brief help"
	echo ""
}

while test $# -gt 0; do
	case "$1" in
		-h|--help)
			print_usage
			exit 0
			;;
	esac
done

get_target_id

get_last_falco_release ${1}
get_falco_libs_sha

if [ -z "${FALCO_LIBS_VERSION}" ]; then
	echo "This version of Falco is not available"
	exit 1
fi

check_probe_availability
check_module_availability

echo "• Falco version: ${FALCO_VERSION}"
echo "• Lib version: ${FALCO_LIBS_VERSION}"
if [ "${PROBE_AVAILABLE}" == "true" ]; then
	echo "• Probe: ✔"
else
	echo "• Probe: x"
fi
if [ "${MODULE_AVAILABLE}" == "true" ]; then
	echo "• Module: ✔"
else
	echo "• Module: x"
fi

if [ "${PROBE_AVAILABLE}" == "true" -o "${MODULE_AVAILABLE}" == "true" ]; then
	echo ""
	echo "Congratulations! Your system is ready for running Falco!"
	echo ""
	echo "• Get Started in Falco.org (https://falco.org)"
	echo "• Check out the Falco project and contribute in Github (https://github.com/falcosecurity/falco)"
	echo "• Get involved in the Falco community (https://github.com/falcosecurity/community)"
	echo "• Meet the maintainers on the Falco Slack (https://kubernetes.slack.com#falco)"
	echo "• Follow @falco_org on Twitter"
	exit 0
fi

echo ""
echo "We're sorry, the ebpf probe or kernel module is not already built for your system."
echo ""
echo "Please, help the community and yourself by submitting a PR on https://github.com/falcosecurity/test-infra"
echo "for adding the following content in new file 'driverkit/config/${FALCO_LIBS_VERSION}/${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.yaml':"
echo ""
echo '```'
echo "kernelversion: ${KERNEL_VERSION}"
echo "kernelrelease: ${KERNEL_RELEASE}"
echo "target: ${TARGET_ID}"
echo "output:"
echo "  module: output/${FALCO_LIBS_VERSION}/${DRIVER_NAME}_${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.ko"
echo "  probe: output/${FALCO_LIBS_VERSION}/${DRIVER_NAME}_${TARGET_ID}_${KERNEL_RELEASE}_${KERNEL_VERSION}.o"
echo '```'