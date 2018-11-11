FROM jenkins/jenkins:2.138.2
LABEL Version "1.0.0-alpha"

ARG DEV_HOST=127.0.0.1
ARG LOCAL_PIPELINE_LIBRARY_PATH=/var/jenkins_home/pipeline-library

ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins.yaml
ENV CONF_CREATE_ADMIN true
ENV CONF_ALLOW_RUNS_ON_MASTER false
ENV LOCAL_PIPELINE_LIBRARY_PATH ${LOCAL_PIPELINE_LIBRARY_PATH}

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY download-plugins.sh /usr/local/bin/download-plugins.sh
RUN /usr/local/bin/download-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY init_scripts/src/main/groovy/ /usr/share/jenkins/ref/init.groovy.d/

RUN mkdir -p ${LOCAL_PIPELINE_LIBRARY_PATH}

VOLUME /var/jenkins_home/pipeline-library
VOLUME /var/jenkins_home/pipeline-libs
EXPOSE 5005

COPY jenkins.yaml /var/jenkins_home/jenkins.yaml
COPY jenkins-wrapper.sh /usr/local/bin/jenkins-wrapper.sh
ENTRYPOINT ["tini", "--", "/usr/local/bin/jenkins-wrapper.sh"]
