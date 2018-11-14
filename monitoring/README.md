# Monitoring

TODO: Finish off writing this.

### Run
```shell
docker run --rm --name prometheus -v $(pwd)/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml -p 9090:9090  -p 8080 quay.io/prometheus/prometheus

docker run --rm --name=grafana -p 3000:3000 -p 9090 -v $(pwd)/monitoring/grafana/:/etc/grafana/provisioning/ grafana/grafana
```

Open [http://localhost:9090/config](http://localhost:9090/config) to confirm the
config is as expected, then you should be able to run queries like:
`javamelody_http_hits_count`.
