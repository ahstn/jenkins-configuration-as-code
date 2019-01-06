# Jenkins Configuration-as-Code Starter

This repo demonstrates how to setup a full configuration-as-code Jenkins instance
using Docker with Groovy Init Scripts and the [jenkinsci/configuration-as-code-plugin].
While also showing how to monitor Jenkins' resource usage and general metrics
(jobs, nodes, queue, etc.) via Prometheus to create a Grafana dashboard.

:exclamation: This is still in early development and is not recommended for
production usage!

## Usage
### Docker Requirement
A Docker host endpoint is required for local development, so Jenkins can
schedule build agents.

When using Docker for Mac you can expose a Docker TCP host using socat:
```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 2376:2375 bobrik/socat TCP4-LISTEN:2375,fork,reuseaddr UNIX-CONNECT:/var/run/docker.sock
```
By default `unix:///var/run/docker.sock` is used for connecting Jenkins to
Docker, but this can be overridden through the environment variable `DOCKER_HOST`.
As an example, this is done in repo's [docker-compose.yml](./docker-compose.yml),
setting the `DOCKER_HOST` to an exposed TCP endpoint.

### Running Jenkins Only
Build image:
```shell
docker build -t ahstn/jenkins-casc .
```

Run image:
```shell
docker run --rm -p 8080:8080 -p 50000:50000 ahstn/jenkins-casc
```

### Running Full Stack
The stack, at the moment, features a Jenkins Master, Prometheus monitoring and a
Grafana dashboard.

To run the stack:
```shell
docker stack deploy -c docker-compose.yaml jenkins
```
If you make any changes, the command can be ran again to update the necessary
containers.

As the stack uses overlay network it **has to** be accessed from either a node
IP or the IP assigned docker's network interface on your host machine. Your node
IP will be an local IPv4 address and can be found by running the following:
```shell
# Fetch Node IP
docker info | grep -i 'Node Address'

# Alternatively fetch Docker's network interface IP
ifconfig docker0
```
Then both Jenkins and Grafana can be accessed though their respective ports on
the aforementioned IP. For example, on my machine Jenkins can be viewed at
`http://192.168.0.20:8080`


## Developing Pipeline libraries
:exclamation: In theory this will work, but I haven't tested it recently. I need
to update this documentation section and probably fine-tune this feature.

In the _Development_ folder there is a _PipelineLib_ folder, which allows local building and testing of the library.
This folder can be mapped to a local repository in order to develop the library without committing changes:

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

### Todo
 - [ ] Investigate using Vault to feed credentials and sensitive info to CasC.
 - [ ] Have Prometheus and Vault on a 'backend' network so they aren't exposed like Jenkins.
 - [ ] Add custom Loki and Promtail config.
 - [ ] Utilise Docker Config rather than volues to prevent missed FS updates.

### Credit
This repo was inspired by [Praqma/JenkinsAsCodeReference] and
[oleg-nenashev/demo-jenkins-config-as-code] so major thanks to them. And
of course utilises the plugin [jenkinsci/configuration-as-code-plugin] and the
work done by it's maintainers.

[Praqma/JenkinsAsCodeReference]: https://github.com/Praqma/JenkinsAsCodeReference
[oleg-nenashev/demo-jenkins-config-as-code]: https://github.com/oleg-nenashev/demo-jenkins-config-as-code
[jenkinsci/configuration-as-code-plugin]: https://github.com/jenkinsci/configuration-as-code-plugin
[gitmoji]: https://gitmoji.carloscuesta.me
