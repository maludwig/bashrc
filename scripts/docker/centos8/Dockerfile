FROM centos:8

RUN dnf update -y
RUN dnf install -y sudo which python36 rsync git passwd zsh nmap-ncat
RUN alternatives --set python /usr/bin/python3
RUN useradd -m -G wheel mitchell
RUN sed --in-place=.bak -E 's/^%wheel.*/%wheel  ALL=(ALL)      NOPASSWD: ALL/' /etc/sudoers

USER mitchell
ADD --chown=mitchell:mitchell ./ /home/mitchell/bashrc/
WORKDIR /home/mitchell/bashrc/
ENTRYPOINT [ "/home/mitchell/bashrc/scripts/docker/test_script.sh" ]
