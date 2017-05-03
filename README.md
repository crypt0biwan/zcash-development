# zcash dev environment
Corresponding blog post:
TBD

In the crazy world of crypto, there is always a new project or wallet to look into. Many of these projects are open source and can be compiled from source to try out new features.

This is the baseline of my [zcash](https://z.cash/) development environment to test new features, test compilation and look for distribution specific bugs. If this is something you do on a regular basis, you can probably make use of this short article.

The end result will be at least one VM that compiled and runs the cash release you specified in the configuration file. I mostly test with Ubuntu and CentOS.

It will work no matter if you are on Windows, OSX or Linux. That's the true beauty of this.

## Tools
My preferred setup to test and develop [zcash](https://z.cash/) is (as almost always) designed around Vagrant. Vagrant is an open source tool from the DevOps world that is often used to provision development environments automatically. 

You need the following set of tools to start:  

* VirtualBox (newest version from the [VirtualBox-Homepage])
* Vagrant (newest version from the [Vagrant-Homepage])
* **Only on Windows**: Git for Windows (newest version from the [Git-Homepage])

## Start of the Environment
The `Vagrantfile` in this repository contains the complete configuration of the environment.

This means the definition of the Linux distribution, the networking parameter, packages to install and many things more. Check the Vagrant documentation for pointers whats possible.

Additionally for this specific environment, there is a configuration file named `machines.yml` that is evaluated by Vagrant.

This `machines.yml` file defines how many VM will be provisioned and the details of their individual configuration.

> Since the configuration of Vagrant and the environment to create is all part of the source (git) repository, the environment can easily be destroyed and re-created within a couple of minutes.

### Clone the repo
Exactly like with any other development workflow,  the initialisation of this environment is created by checking out this source code repository.
```sh
$ git clone https://github.com/marsmensch/zcash-development.git
```

### Edit the machine specific config
In this example, two VMs are provisioned:

* CentOS 7.1 64 Bit
* Ubuntu 16.04 LTS 64 Bit

Both VMs are compile and install the `v1.0.8-1` Release of cash from source. In most cases, you will want to change the `zecversion`.   

```yml
---
- name: centos64
  vmw_box: centos/7
  vb_box: centos/7
  ram: 3072
  vcpu: 2
  script: provision/bootstrap_centos.sh
  zecversion: v1.0.8-1
  
- name: xenial64
  vmw_box: ubuntu/xenial64
  vb_box: ubuntu/xenial64
  ram: 3072
  vcpu: 2
  script: provision/bootstrap_ubuntu.sh
  zecversion: v1.0.8-1 
```

### One command to rule them all
After modifying the `machines.yml` config file, open a console (for Windows use `Git-Bash`) open the cloned directory `altcoin-testenv` and execute the **one and only required command to create the environment**:

```sh
$ vagrant up
```

No kidding, that's it!

What happens now is a bit of DevOps magic. After a couple of minutes (it compiles cash from source multiple times!), the following things happened:

* Vagrant created and configured two virtual machines via VirtualBox
* The shell scripts `bootstrap_centos.sh` and `bootstrap_ubuntu.sh` installed our desired set of packages
* zcash `v1.0.8-1` was compiled and installed from source   
* Vagrant automatically configures a couple of useful shortcuts like a shared folder in `/vagrant` with the host system and convenient passwordless logins via SSH Keys to the VM. 

>         The box has 3072 MB of RAM and 2 CPU cores assigned. Change that in the `Vagrantfile` if you want more or less RAM/CPU. You will not have much fun with less for zcash ;-)

## Connect to your VM
Connecting to your VM is as easy as run a command in a terminal. You need exactly one command to connect:

```sh
$ vagrant ssh xenial64 
OR
$ vagrant ssh centos64 
```

> For SSH connections Vagrant looks for a SSH client (`ssh.exe`) in your $PATH. This is already the case for OSX and Linux. On Windows you want to install Git for Windows for this.

## Working with your new VM
As noted above, the included shell script `vagrant_provision.sh` installs your desired set of packages.  

Have fun and stay tuned for the next blog post!

[Git-Homepage]: <https://github.com/git-for-windows/git/releases/latest>
[VirtualBox-Homepage]: <https://www.virtualbox.org/wiki/Downloads>
[Vagrant-Homepage]: <https://www.vagrantup.com/downloads.html>
[MaibornWolff-Git]: <http://git.maibornwolff.de/mwea/ADEmployeeService>
