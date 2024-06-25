FROM pgpool/pgpool
USER root
RUN apk update && apk add --no-cache openssh curl sshpass
RUN mkdir /var/run/sshd && \
    echo 'root:0000' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config    
USER pgpool