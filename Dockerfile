FROM opensuse/leap:15.5
LABEL maintainer="Jeff Geerling"
ENV container=docker

ENV pip_packages="ansible"

# Install systemd (based on official CentOS instructions).
RUN zypper -n install systemd && zypper clean && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/*

# Install base requirements and Python 3.11.
RUN zypper refresh && \
    zypper install -y \
      sudo \
      which \
      hostname \
      iproute2 \
      python311 \
      python311-pip \
      python311-wheel \
      python311-PyYAML && \
    zypper clean -a

# Ensure python3 points to Python 3.11.
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.11 1

# Upgrade pip, setuptools, and wheel.
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install Ansible via Pip (latest).
RUN pip3 install --no-cache-dir $pip_packages

# Disable requiretty in sudo.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

# Install a minimal Ansible inventory.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
