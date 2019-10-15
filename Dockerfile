# s2i-openliberty-springapp
FROM openliberty/open-liberty:springBoot2-ubi-min

LABEL maintainer="Tim Robinson <timroster@gmail.com>"

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Used for building and running Spring Boot application on Open Liberty" \
      io.k8s.display-name="SpringApp-In-OpenLiberty" \
      io.openshift.expose-services="9080:http" \
      io.openshift.tags="builder,liberty,open-liberty" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.s2i.scripts-url="image:///opt/s2i/"

# set up build environment
USER root
RUN curl -Lo /tmp/openjdk-18.tar.gz https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_x64_linux_8u222b10.tar.gz \
    && cd /tmp; tar -xf openjdk-18.tar.gz \
    && rm -rf /tmp/openjdk-18.tar.gz \
    && curl -L curl http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz > /tmp/maven-3.6.tar.gz \
    && cd /tmp; tar -xf maven-3.6.tar.gz \
    && rm -rf /tmp/maven-3.6.tar.gz

# change JAVA_HOME to have JDK during maven build
ENV JAVA_HOME=/tmp/openjdk-8u222-b10

# update path
ENV PATH=/tmp/openjdk-8u222-b10/bin:/tmp/apache-maven-3.6.2/bin:$PATH

# Copy scripts to build s2i
COPY ./s2i/bin/* /opt/s2i/

# Create dir and update permissions
RUN mkdir -p /home/default/.m2/repository \
    && mkdir -p /config/dropins/spring/ \
    && chown -R 1001:0 /opt/s2i/ && chmod -R +x /opt/s2i/ \
    && chown -R 1001:0 /home/default/.m2 && chmod g=u /home/default/.m2 \
    && chown -R 1001:0 /config/dropins/spring && chmod g=u /config/dropins/spring

# This default user is created in the openshift/base-centos7 image
USER 1001

# default ports for applications built using this image
EXPOSE 9080 

# default CMD for the image
CMD ["/opt/s2i/usage"]
