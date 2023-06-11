FROM maven:3.8.5-openjdk-17

ARG user=spring
ARG group=spring

ENV SPRING_HOME=/home/spring

RUN groupadd -g 1000 ${group} \
	&& useradd -d "$SPRING_HOME" -u 1000 -g 1000 -m -s /bin/bash ${user} \
	&& mkdir -p $SPRING_HOME/config \
	&& mkdir -p $SPRING_HOME/logs \
	&& chown -R ${user}:${group} $SPRING_HOME/config $SPRING_HOME/logs

# VOLUME ["$SPRING_HOME/config", "$SPRING_HOME/logs"]
USER ${user}
WORKDIR $SPRING_HOME

COPY . .

RUN mvn clean package \
    && mv target/midjourney-proxy-*.jar ./app.jar \
    && rm -rf target

EXPOSE 8081 9877

ENV JAVA_OPTS -XX:MaxRAMPercentage=85 -Djava.awt.headless=true -XX:+HeapDumpOnOutOfMemoryError \
 -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -Xlog:gc:file=/home/spring/logs/gc.log \
 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9877 -Dcom.sun.management.jmxremote.ssl=false \
 -Dcom.sun.management.jmxremote.authenticate=false -Dlogging.file.path=/home/spring/logs \
 -Dserver.port=8081 -Duser.timezone=Asia/Shanghai

ENTRYPOINT ["bash","-c","java $JAVA_OPTS -jar app.jar"]