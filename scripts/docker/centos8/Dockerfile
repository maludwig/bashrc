FROM centos:8

RUN dnf install -y sudo which python36 rsync git passwd zsh
RUN alternatives --set python /usr/bin/python3
RUN useradd -m -G wheel mitchell
RUN sed --in-place=.bak -E 's/^%wheel.*/%wheel  ALL=(ALL)      NOPASSWD: ALL/' /etc/sudoers

USER mitchell
ADD --chown=mitchell:mitchell test_script.sh /home/mitchell/test_script.sh
RUN chmod +x /home/mitchell/test_script.sh
ENTRYPOINT [ "/home/mitchell/test_script.sh" ]
