# falco-driver-check

This script allows to check if falco ebpf probe and kernel module are available for your system. If once is available, you will be noticed and can start to secure your insfrastructure.
If none is available, the script will help you by giving details about how to contribute for the sake of community, you have all intels for submitting a 
PR for allowing Falco test-infra platform to build the driver you need.

## Usage

The only argument is the version of falco you want to install:
```shell
./falco-driver-check.sh <version>
```
If `version` is empty, the last version of Falco is checked.

Examples:
```shell
./falco-driver-check

• Falco version: 0.30.0
• Lib version: 3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4
• Probe: x
• Module: x

We're sorry, the ebpf probe or kernel module is not already built for your system.

Please, help the community and yourself by submitting a PR on https://github.com/falcosecurity/test-infra
for adding the following content in new file 'driverkit/config/3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4/manjaro_5.15.12-1-MANJARO_1.yaml':

kernelversion: 1
kernelrelease: 5.15.12-1-MANJARO
target: manjaro
output:
  module: output/3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4/falco_manjaro_5.15.12-1-MANJARO_1.ko
  probe: output/3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4/falco_manjaro_5.15.12-1-MANJARO_1.o
```
```shell
./falco-driver-check 0.29.1

• Falco version: 0.29.1
• Lib version: 3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4
• Probe: x
• Module: x

We're sorry, the ebpf probe or kernel module is not already built for your system.

Please, help the community and yourself by submitting a PR on https://github.com/falcosecurity/test-infra
for adding the following content in new file 'driverkit/config/3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4/debian_5.10.0-10-amd64_1.yaml':

kernelversion: 1
kernelrelease: 5.10.0-10-amd64
target: debian
output:
  module: output/3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4/falco_debian_5.10.0-10-amd64_1.ko
  probe: output/3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4/falco_debian_5.10.0-10-amd64_1.o
```
```shell
./falco-driver-check

• Falco version: 0.30.0
• Lib version: 3aa7a83bf7b9e6229a3824e3fd1f4452d1e95cb4
• Probe: x
• Module: ✔

Congratulations! Your system is ready for running Falco!

• Get Started in Falco.org (https://falco.org)
• Check out the Falco project and contribute in Github (https://github.com/falcosecurity/falco)
• Get involved in the Falco community (https://github.com/falcosecurity/community)
• Meet the maintainers on the Falco Slack (https://kubernetes.slack.com#falco)
• Follow @falco_org on Twitter
```

## Docker

You can run this script in `Docker` with:
```shell
docker run -ti -v /etc/os-release:/etc/os-release -v /etc/debian_version:/etc/debian_version -v /etc/centos-release:/etc/centos-release -v /etc/VERSION:/etc/VERSION issif/falco-driver-check
```

## Kubernetes

It might be really useful to test your kubernetes nodes, following the procedure:
```shell
kubectl apply -f Job.yaml -n default 
kubectl logs job/falco-driver-check -n default 
kubectl delete job falco-driver-check -n default 
```


