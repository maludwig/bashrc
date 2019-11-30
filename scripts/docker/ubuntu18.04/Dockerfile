FROM ubuntu:18.04

RUN apt-get update
RUN apt install -y sudo python rsync git passwd zsh
RUN useradd -m -G sudo mitchell
RUN sed --in-place=.bak -E 's/^%sudo.*/%sudo  ALL=(ALL)      NOPASSWD: ALL/' /etc/sudoers
RUN chsh -s /bin/bash mitchell

USER mitchell
ADD --chown=mitchell:mitchell test_script.sh /home/mitchell/test_script.sh
RUN chmod +x /home/mitchell/test_script.sh
ENTRYPOINT [ "/home/mitchell/test_script.sh" ]
