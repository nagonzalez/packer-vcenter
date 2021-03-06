# Packer templates

I set off to build CentOS 7.6 & Windows 2019 packer templates on vSphere 6.7 w/ vSAN. This ededed up being non trivial so I created this repo to capture my findings.

# Requirements
Any one of the following are required to build templates depending on your needs.

### VMware Desktop
- VMware Workstation/Fusion
- [OVF Tool](https://code.vmware.com/web/tool/4.3.0/ovf)
    - After installation, create a symlink (MacOS)
        - `ln -s /Applications/VMware\ OVF\ Tool/ovftool /usr/local/bin/ovftool`
- Packer

### VMware vSphere
- vSphere 6.7 (tested on U2)
- ESXi host with ssh enabled
- ESXi firewall allowing VNC traffic
- vSwitch for VM template
- [OVF Tool](https://code.vmware.com/web/tool/4.3.0/ovf)
    - After installation, create a symlink (MacOS)
        - `ln -s /Applications/VMware\ OVF\ Tool/ovftool /usr/local/bin/ovftool`
- Packer

### Virtualbox
- Virtualbox
- [OVF Tool](https://code.vmware.com/web/tool/4.3.0/ovf)
    - After installation, create a symlink (MacOS)
        - `ln -s /Applications/VMware\ OVF\ Tool/ovftool /usr/local/bin/ovftool`
- Packer

# Variables and secrets

- Copy `.env_example` to `.env`
- Modify `vars/vsphere.json` & `.env` to suit your needs

# Setup ESXi Host
### Enable SSH:
Inside the web UI, navigate to “Manage”, then the “Services” tab. Find the entry called: “TSM-SSH”, and enable it.

You may wish to enable it to start up with the host by default. You can do this inside the “Actions” dropdown (it’s nested inside “Policy”).

### Enable GuestIPHack on ESXi Host:
```shell
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```
This allows Packer to infer the guest IP from ESXi, without the VM needing to report it itself.

### Open VNC Ports on the Firewall:
Packer connects to the VM using VNC, so we’ll open a range of ports to allow it to connect to it.

Install VIB for persistent firewall setting:
https://github.com/umich-vci/packer-vib

For a one time setting, follow these steps.

First, ensure we can edit the firewall configuration:

```shell
chmod 644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml
```

Then append the range we want to open to the end of the file:

```xml
<service id="1000">
  <id>packer-vnc</id>
  <rule id="0000">
    <direction>inbound</direction>
    <protocol>tcp</protocol>
    <porttype>dst</porttype>
    <port>
      <begin>5900</begin>
      <end>6000</end>
    </port>
  </rule>
  <enabled>true</enabled>
  <required>true</required>
</service>
```

Finally, restore the permissions and reload the firewall:

```shell
chmod 444 /etc/vmware/firewall/service.xml
esxcli network firewall refresh
```

### Reference:
* https://nickcharlton.net/posts/using-packer-esxi-6.html

# Packer builds

### VMware Workstation

CentOS 7.6
```shell
source .env
packer build -var-file=vars/vmware/centos_7.6.json vmware_desktop_centos.json
```

CentOS 8.0
```shell
source .env
packer build -var-file=vars/vmware/centos_8.0.json vmware_desktop_centos.json
```

Windows 2019
```shell
source .env
packer build vmware_desktop_windows_2019.json
```

### VMware vSphere

Setup the VMware vSphere connection variables by creating a `vsphere.json` file under `vars/vmware`

Example:
```json
{
    "esxi_remote_host": "192.168.1.126",
    "esxi_remote_username": "root",
    "vcenter_host": "192.168.1.136",
    "vcenter_username": "administrator@vsphere.local",
    "vcenter_insecure": "true",
    "vcenter_datacenter": "Home",
    "vcenter_datastore": "datastore1"
}
```

CentOS 7.6
```shell
source .env
packer build -var-file=vars/vmware/vsphere.json -var-file=vars/vmware/centos_7.6.json vmware_vsphere_centos.json
```

```powershell
.env.ps1
packer build -var-file="vars\vmware\vsphere.json" -var-file="vars\vmware\centos_7.6.json"
```

CentOS 8.0
```shell
source .env
packer build -var-file=vars/vmware/vsphere.json -var-file=vars/vmware/centos_8.0.json vmware_vsphere_centos.json
```

```powershell
.env.ps1
packer build -var-file="vars\vmware\vsphere.json" -var-file="vars\vmware\centos_8.0.json"
```

Windows 2019
```shell
source .env
packer build -var-file=vars/vmware/vsphere.json vmware_vsphere_windows_2019.json
```

```powershell
.env.ps1
packer build -var-file="vars\vmware\vsphere.json" vmware_vsphere_windows_2019.json
```

#### Optional
If you want to apply Windows updates as part of the template creation process, you'll need to install an additional provisioner.

[Packer Windows Update Provisioner](https://github.com/rgl/packer-provisioner-windows-update)

You can install it in one of two ways.

Chocolatey:
`choco install packer-provisioner-windows-update`

Manually:
[Download Link](https://github.com/rgl/packer-provisioner-windows-update/releases)

Once installed, use the `vmware_vsphere_windows_2019_windows_update.json` builder file instead.

### Virtualbox

CentOS 7.6
```shell
source .env
packer build -var-file=vars/virtualbox/centos_7.6.json virtualbox_centos.json
```

CentOS 8.0
```shell
source .env
packer build -var-file=vars/virtualbox/centos_8.0.json virtualbox_centos.json
```

# To Do:
Centos 8 doesn't seem to have the `sys-unconfig` script anymore so we just shutdown the VM using `shutdown -h now`. We'll need to update this to ensure we're prepping the image properly. Currently, I don't see any alternate methods to achieve the same thing.
