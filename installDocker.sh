sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf repolist -v
dnf list docker-ce --showduplicates | sort -r
sudo dnf install --nobest docker-ce
sudo yum remove docker
sudo yum remove podman
sudo dnf install --nobest --allowerasing docker-ce
