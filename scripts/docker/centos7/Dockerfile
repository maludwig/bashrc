FROM centos:7

RUN yum install -y sudo which rsync git passwd zsh
RUN useradd -m -G wheel mitchell
RUN sed --in-place=.bak -E 's/^%wheel.*/%wheel  ALL=(ALL)      NOPASSWD: ALL/' /etc/sudoers
RUN yum update -y

USER mitchell
ADD --chown=mitchell:mitchell test_script.sh /home/mitchell/test_script.sh
RUN chmod +x /home/mitchell/test_script.sh
ENTRYPOINT [ "/home/mitchell/test_script.sh" ]
