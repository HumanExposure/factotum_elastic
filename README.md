# Factotum Elasticsearch

## Docker

`docker build . -t factotum-elastic` will build from the Dockerfile in the current working directory and label the built image as `factotum-elastic:latest`
`docker-compose build factotum-elastic` will build the Dockerfile in `https://github.com/HumanExposure/factotum_elastic` in the branch as specified in the environment variable and label the built image as `factotum-elastic:latest`
