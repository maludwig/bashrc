FROM ubuntu:18.04

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y sudo python rsync git passwd zsh net-tools netcat-openbsd
RUN useradd -m -G sudo mitchell
RUN sed --in-place=.bak -E 's/^%sudo.*/%sudo  ALL=(ALL)      NOPASSWD: ALL/' /etc/sudoers
RUN chsh -s /bin/bash mitchell

USER mitchell
ADD --chown=mitchell:mitchell ./ /home/mitchell/bashrc/
WORKDIR /home/mitchell/bashrc/
ENTRYPOINT [ "/home/mitchell/bashrc/scripts/docker/test_script.sh" ]
