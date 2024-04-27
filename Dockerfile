FROM  nginx
COPY anil.conf /etc/niginx/conf.d/default.conf
COPY build var/wwww/anil.com/html
