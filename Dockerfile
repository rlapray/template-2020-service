FROM adoptopenjdk/openjdk11:alpine-jre
RUN apk add --no-cache bash curl
COPY target/universal/template-2020-service-0.0-SNAPSHOT.zip .
RUN unzip template-2020-service-0.0-SNAPSHOT.zip
RUN keytool -keystore $JAVA_HOME/lib/security/cacerts -alias postgresql -import -file template-2020-service-0.0-SNAPSHOT/conf/rds-ca-2019-root.pem -storepass changeit -noprompt
COPY buildinfo.conf template-2020-service-0.0-SNAPSHOT/conf/buildinfo.conf
WORKDIR template-2020-service-0.0-SNAPSHOT/bin
CMD ["./template-2020-service", "-Dhttp.port=80"]
EXPOSE 80