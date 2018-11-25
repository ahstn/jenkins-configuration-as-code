# Jenkins Configuration-as-Code Starter

This repo demonstrates how to setup a full configuaration-as-code Jenkins instance
using Docker with Jenkins Shared Libraries and Groovy Init Scripts.

:exclamation: This is still in early development and is not recommened for
production usage!

### Usage
Build image:
```shell
docker build -t ahstn/jenkins-casc .
```

Run image:
```shell
docker run --rm -e DEV_HOST=$(hostname) -p 8080:8080 -p 50000:50000 ahstn/jenkins-casc
```

A Docker TCP host endpoint is required for local development, so Jenkins can
schedule build agents.

When using Docker for Mac you can expose a Docker TCP host using socat:
```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 2376:2375 bobrik/socat TCP4-LISTEN:2375,fork,reuseaddr UNIX-CONNECT:/var/run/docker.sock
```

#### Developing Pipeline libraries
In the _Development_ folder there is a _PipelineLib_ folder, which allows local building and testing of the library.
This folder can be mapped to a local repository in order to develop the library without committing changes:

```shell
docker run --rm -v ${MY_PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library -v ${MY_OTHER_PIPELINE_LIBS_DIRS}:/var/jenkins_home/pipeline-libs -e DEV_HOST=${CURRENT_HOST} -p 8080:8080 -p 50000:50000  ahstn/jsasc
```

Once started, you can just start editing the Pipeline library locally.
On every job start the changes will be reflected in the directory without committing anything.


### Commit Message Convention
If you've seen my other repos you might have noticed that I tend to use emojis
quite a lot. I'm a fan of using them in commit messages as it allows myself
(and others) to see the commit's purpose or component affected at a quick
glance.

With this in mind, the repo loosely follows [gitmoji] and the following acts as
a key to what certain emojis mean in commit messages:
* :factory: - Jenkins     (`:factory:`)
* :whale: - Docker        (`:whale:`)
* :fire: - Prometheus     (`:fire:`)
* :bar_chart: - Grafana   (`:bar_chart:`)
* :lock: - Vault          (`:lock:`)
* :book: - Documentation  (`:book:`)

### Credit
This repo was inspired by [Praqma/JenkinsAsCodeReference] and
[oleg-nenashev/demo-jenkins-config-as-code] so major thanks to them. And
of course utilises the plugin [jenkinsci/configuration-as-code-plugin] and the
work done by it's maintainers.

[Praqma/JenkinsAsCodeReference]: https://github.com/Praqma/JenkinsAsCodeReference
[oleg-nenashev/demo-jenkins-config-as-code]: https://github.com/oleg-nenashev/demo-jenkins-config-as-code
[jenkinsci/configuration-as-code-plugin]: https://github.com/jenkinsci/configuration-as-code-plugin
[gitmoji]: https://gitmoji.carloscuesta.me
