FROM postgres:16
RUN apt-get update && apt-get install -y openssh-server sshpass
RUN apt-get install -y curl 
RUN mkdir /var/run/sshd && \
    echo 'root:0000' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \    
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
EXPOSE 22

ENTRYPOINT ["/usr/local/bin/run.sh"]
