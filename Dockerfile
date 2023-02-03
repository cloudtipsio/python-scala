# base image - https://github.com/devfile/developer-images
FROM quay.io/devfile/base-developer-image

### GLOBAL ###

# exec with root user
USER 0

# install internal certificates
COPY files/*.crt /etc/ssl/certs/
RUN update-ca-trust ;

# python
ENV PYTHON_VERSION=38
RUN yum --nodocs install -y \
      python${PYTHON_VERSION} \
      python${PYTHON_VERSION}-pip ; \
    \
    ln -fs /usr/bin/python3 /usr/bin/python ; \
    ln -fs /usr/bin/pip3 /usr/bin/pip ; \
    \
    pip config --global set global.index https://my-company/nexus/repository/pypi-group/pypi ; \
    pip config --global set global.index-url https://my-company/nexus/repository/pypi-group/simple ; \
    pip config --global set pypi.repository http://localhost:8081/repository/pypi-internal ; \
    \
    yum clean all ; \
    rm -rf /var/cache/yum ;


### LOCAL ###

# exec with normal user
USER 10001

# Java
ENV JAVA_HOME=/home/user/.sdkman/candidates/java/current \
    JAVA_VERSION=8.0.362

# maven
ENV MAVEN_HOME=/home/user/.sdkman/candidates/maven/current \
    MAVEN_VERSION=3.3.3

# scala
ENV SBT_HOME=/home/user/.sdkman/candidates/sbt/current \
    SBT_VERSION=1.8.2 \
    SCALA_HOME=/home/user/.sdkman/candidates/scala/current \
    SCALA_VERSION=3.2.2

# path
ENV PATH=${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${SBT_HOME}/bin:${SCALA_HOME}/bin:$PATH

# install packages
RUN curl -fsSL "https://get.sdkman.io" | bash ; \
    source "/home/user/.sdkman/bin/sdkman-init.sh" ; \
    sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" /home/user/.sdkman/etc/config ; \
    sdk update ; \
    sdk install java ${JAVA_VERSION}-tem ; \
    sdk install maven ${MAVEN_VERSION} ; \
    sdk install sbt ${SBT_VERSION} ; \
    sdk install scala ${SCALA_VERSION} ; \
    sdk flush archives ; \
    sdk flush temp ;

# maven default configuration for maven
COPY files/settings.xml /home/user/.sdkman/candidates/maven/current/conf/settings.xml

# default directory
WORKDIR /project
