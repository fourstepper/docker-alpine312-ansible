FROM alpine:3.12
LABEL maintainer="Robin Opletal"
ENV container=docker

ENV pip_packages "ansible"

RUN mkdir -p /etc/apk &&\
# Add the main repo
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" > /etc/apk/repositories &&\
# Add the community repo
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories &&\
    cat /etc/apk/repositories &&\
# Install OpenRC
    apk -U upgrade && apk add openrc &&\
# Tell openrc its running inside a container, till now that has meant LXC
    sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# clean apk cache
    rm -rf /var/cache/apk/*

# Ansible stuff
RUN apk -U upgrade && apk add python3 py3-pip python3-dev sudo gcc musl-dev libffi-dev libressl-dev

RUN pip3 install $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

CMD ["/sbin/init"]
