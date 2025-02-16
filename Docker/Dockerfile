FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openssh-server sudo git fontconfig openjdk-17-jre python3 python3-pip && \
    mkdir /var/run/sshd

COPY Devbox-Access-Key.pub /root/.ssh/authorized_keys

RUN chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

RUN sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# Run > docker run -d -p 2222:22 --name Jenkins-Slave jenkins-agent
