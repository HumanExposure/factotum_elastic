FROM logstash:7.3.1

ARG MYSQL_CONNECTOR_VERSION=8.0.17

ENV JDBC_DRIVER_LIBRARY="" \
    QUERY_PATH="/usr/share/logstash/query.sql" \
    TEMPLATE_PATH="/usr/share/logstash/template.json"

# Add MySQL connector
ADD https://repo1.maven.org/maven2/mysql/mysql-connector-java/"${MYSQL_CONNECTOR_VERSION}"/mysql-connector-java-"${MYSQL_CONNECTOR_VERSION}".jar /usr/share/logstash/logstash-core/lib/jars/mysql-connector.jar

# Add repository files
COPY query.sql /usr/share/logstash/
COPY logstash.conf /usr/share/logstash/pipeline
COPY template.json /usr/share/logstash/

# Fix file permissions
USER root
RUN chown logstash:logstash \
        /usr/share/logstash/query.sql \
        /usr/share/logstash/pipeline/logstash.conf \
        /usr/share/logstash/template.json \
        /usr/share/logstash/logstash-core/lib/jars/mysql-connector.jar \
 && chmod +x /usr/share/logstash/logstash-core/lib/jars/mysql-connector.jar

USER logstash
