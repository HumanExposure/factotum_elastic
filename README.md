# Factotum Elastic

The "logstash" and "elasticsearch" folders contain files that will be copied to their respective Docker containers.

## Docker

### Builing locally

```bash
cd /path/to/checked_out/factotum_elastic
docker build elasticsearch -t factotum-elasticsearch
docker build logstash -t factotum-logstash
```

This will build both images and tag them as `factotum-elasticsearch:latest` and `factotum-logstash:latest`, respectively.

### Building via `docker-compose`

```bash
cd /path/to/checked_out/factotum/docker
docker-compose build factotum-elasticsearch factotum-logstash
```

This will build both images by fetching the state of this repository directly from GitHub at the branch/tag/commit specified by `FACTOTUM_ELASTIC_BRANCH` and tag them as `factotum-elasticsearch:latest` and `factotum-logstash:latest`, respectively.

### Running the images

```bash
cd /path/to/checked_out/factotum/docker
docker-compose up -d factotum-elasticsearch factotum-logstash
```

This will run the images tagged `factotum-elasticsearch:latest` and `factotum-logstash:latest`. They will be made via GitHub if they do not exist.
