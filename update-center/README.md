# Update Center

The scripts in this directory are intended to be used in conjuction with the [lanwen/juseppe] docker image.
For those don't necessarily have access to the official Jenkins plugin repository or would prefer to host
their own.
More information can be found on it's GitHub README.md at [jenkinsci/juseppe], but it short it allows
users to quickly spin up their own local or on-prem Jenkins plugin repository.

The `download-plugins.sh` script in here will allow users to download any plugins they pass to the script,
with all dependencies (without needing to specify them), from the official Jenkins' plugin repo. 
With the intention to then expose the downloaded copies as a volume to the [lanwen/juseppe] Docker image.

The [lanwen/juseppe] Docker container can then be used with a Jenkins Master through the `JENKINS_UC`
environment variable, which tells Jenkins where to fetch it's plugins from. (`http://updates.jenkins-ci.org` by default)


### Example
```
cat <<EOF >>plugins.txt
blueocean:1.9.0
configuration-as-code-support:1.3
configuration-as-code:1.3
EOF

./download-plugins.sh -p plugins.txt -d /jenkins/plugins/

docker run -v /jenkins/plugins/:/juseppe/plugins/ -e JUSEPPE_BASE_URI=http://localhost:80 -p 80:8080 lanwen/juseppe
```

[lanwen/juseppe]: https://hub.docker.com/r/lanwen/juseppe/
[jenkinsci/juseppe]: https://github.com/jenkinsci/juseppe
