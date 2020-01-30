FROM adoptopenjdk/openjdk11:alpine-jre
RUN apk add --no-cache bash curl
COPY target/universal/other-name-0.0-SNAPSHOT.zip .
RUN unzip other-name-0.0-SNAPSHOT.zip
RUN keytool -keystore $JAVA_HOME/lib/security/cacerts -alias postgresql -import -file other-name-0.0-SNAPSHOT/conf/rds-ca-2019-root.pem -storepass changeit -noprompt
COPY buildinfo.conf other-name-0.0-SNAPSHOT/conf/buildinfo.conf
WORKDIR other-name-0.0-SNAPSHOT/bin
CMD ["./other-name", "-Dhttp.port=80"]
EXPOSE 80