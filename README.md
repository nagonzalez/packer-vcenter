# Packer templates

I set off to build CentOS 7.6 & Windows 2019 packer templates on vSphere 6.7 w/ vSAN. This ededed up being non trivial so I created this repo to capture my findings.

# Requirements

- vSphere 6.7 (tested on U2)
- ESXi host with ssh enabled
- ESXi firewall allowing VNC traffic
- vSwitch for VM template
- OVF tool
- packer

# Variables and secrets

- Copy `.env_example` to `.env`
- Modify `vars/vsphere.json` & `.env` to suit your needs

# Packer builds

CentOS 7.6
```
source .env
packer build -var-file=vars/vsphere.json vsphere_centos_7.6.json
```

Windows 2019
```
source .env
packer build -var-file=vars/vsphere.json vsphere_windows_2019.json
```
