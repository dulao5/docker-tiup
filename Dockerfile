FROM centos:7.7.1908

LABEL __copyright__="(C) Guido U. Draheim, licensed under the EUPL" \
      __version__="1.4.4147"
ARG PASSWORD=TiDB.P@ssw0rd
EXPOSE 22

#RUN yum install -y sysfsutils \
# && echo 'kernel/mm/transparent_hugepage/enabled = never' >> /etc/sysfs.conf \
# && echo 'kernel/mm/transparent_hugepage/defrag = never' >> /etc/sysfs.conf

# ssh server
# RUN yum install -y epel-release
RUN yum search sshd
RUN yum install -y openssh-server
RUN rpm -q --list openssh-server
COPY files/systemctl.py /usr/bin/systemctl
RUN : \
  ; mkdir /etc/systemd/system/sshd-keygen.service.d \
  ; { echo "[Install]"; echo "WantedBy=multi-user.target"; } \
        > /etc/systemd/system/sshd-keygen.service.d/enabled.conf
RUN systemctl enable sshd-keygen
RUN systemctl enable sshd

# ssh-keys
COPY files/root_dot_ssh /root/.ssh

RUN yum install -y openssh-clients
RUN rpm -q --list openssh-clients

RUN echo "root:$PASSWORD" | chpasswd

# for tiup packages
RUN yum install -y sudo iproute

# tiup

WORKDIR /root
RUN curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
ENV PATH=/root/.tiup/bin:$PATH

COPY tiup-configs /root/tiup-configs

CMD ["/usr/bin/python", "/usr/bin/systemctl"]
