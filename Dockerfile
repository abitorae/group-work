FROM debian:trixie-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    tomcat10 \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# 初始化数据库
RUN service mariadb start && \
    mysql -e "CREATE DATABASE myapp; CREATE USER 'app'@'%' IDENTIFIED BY 'pass'; \
    GRANT ALL ON myapp.* TO 'app'@'%'; FLUSH PRIVILEGES;" && \
    service mariadb stop

COPY app.war /var/lib/tomcat10/webapps/ROOT.war

EXPOSE 8080 3306
CMD ["/bin/sh", "-c", "service mariadb start && service tomcat10 start && wait"]
