FROM centos:7

RUN yum update -y
RUN yum install -y sudo which rsync git passwd zsh net-tools nmap-ncat
RUN useradd -m -G wheel mitchell
RUN sed --in-place=.bak -E 's/^%wheel.*/%wheel  ALL=(ALL)      NOPASSWD: ALL/' /etc/sudoers

USER mitchell
ADD --chown=mitchell:mitchell ./ /home/mitchell/bashrc/
WORKDIR /home/mitchell/bashrc/
ENTRYPOINT [ "/home/mitchell/bashrc/scripts/docker/test_script.sh" ]
