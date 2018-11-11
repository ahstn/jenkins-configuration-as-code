# Jenkins Configuration-as-Code Starter

This repo demonstrates how to setup a full configuaration-as-code Jenkins instance
using Docker with Jenkins Shared Libraries and Groovy Init Scripts.

:exclamation: This is still in early development and is not recommened for
production usage!

### Usage
Build image:
```shell
docker build -t ahstn/jsasc .
```

Run image:
```shell
docker run --rm -e DEV_HOST=$CURRENT_HOST -p 8080:8080 -p 50000:50000 ahstn/jsasc
```

#### Developing Pipeline libraries
In the _Development_ folder there is a _PipelineLib_ folder, which allows local building and testing of the library.
This folder can be mapped to a local repository in order to develop the library without committing changes:

```shell
docker run --rm -v ${MY_PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library -v ${MY_OTHER_PIPELINE_LIBS_DIRS}:/var/jenkins_home/pipeline-libs -e DEV_HOST=${CURRENT_HOST} -p 8080:8080 -p 50000:50000  ahstn/jsasc
```

Once started, you can just start editing the Pipeline library locally.
On every job start the changes will be reflected in the directory without committing anything.

### Credit
This repo was inspired by [Praqma/JenkinsAsCodeReference] and
[oleg-nenashev/demo-jenkins-config-as-code] so major thanks to them. And
of course utilises the plugin [jenkinsci/configuration-as-code-plugin] and the
work done by it's maintainers.

[Praqma/JenkinsAsCodeReference]: https://github.com/Praqma/JenkinsAsCodeReference
[oleg-nenashev/demo-jenkins-config-as-code]: https://github.com/oleg-nenashev/demo-jenkins-config-as-code
[jenkinsci/configuration-as-code-plugin]: https://github.com/jenkinsci/configuration-as-code-plugin
