# Ubuntu Setup
Scripts to configure a minimal installation of Ubuntu for WSL2. This script should be run from a non-root user. The commands below can be used to create a non-root user with sudo permissions.


```
apt update
unminimize
adduser --uid xxxx USERNAME
apt install -y sudo git
echo "USERNAME  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/USERNAME
su USERNAME
```
