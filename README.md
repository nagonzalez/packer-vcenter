# Packer templates

If you're looking to build vSpehre templates on the latest and greatest then this is the repo is for you.

# Requirements

- vSphere 6.7
- ESXi host with ssh enabled
- ESXi firewall allowing VNC traffic
- dvSwitch port group for VM template
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
