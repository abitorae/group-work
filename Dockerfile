# ---------- Stage 1: 用 Maven 编译打包 ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
COPY pom.xml ./
COPY src/ src/
COPY web/ web/
RUN --mount=type=cache,target=/root/.m2 mvn -B -ntp -DskipTests package

# ---------- Stage 2: 运行时镜像 ----------
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV CATALINA_HOME=/usr/share/tomcat10
ENV CATALINA_BASE=/etc/tomcat10

# Install Java, Tomcat and MariaDB (Debian trixie package names)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk \
    tomcat10 \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Runtime dirs for MariaDB and Tomcat temp
RUN mkdir -p /var/run/mysqld /var/log/mysql /usr/share/tomcat10/temp /etc/tomcat10/conf \
    && chown -R mysql:mysql /var/run/mysqld /var/log/mysql \
    && ln -sf ../server.xml /etc/tomcat10/conf/server.xml \
    && ln -sf ../web.xml /etc/tomcat10/conf/web.xml \
    && ln -sf ../context.xml /etc/tomcat10/conf/context.xml \
    && ln -sf ../tomcat-users.xml /etc/tomcat10/conf/tomcat-users.xml

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# 部署 Maven 打出的 ROOT 应用（含 Servlet class 与依赖 jar）
RUN rm -rf /etc/tomcat10/webapps/ROOT
COPY --from=build /build/target/ROOT /etc/tomcat10/webapps/ROOT

EXPOSE 8080 3306

ENTRYPOINT ["/entrypoint.sh"]
