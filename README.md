# crystal-helloworld

This simple web server, replies with a "Hello world"
message, along with the HTTP parameter string.

Click on the below button to:
1. Launch a Cloud Shell machine
2. Download this GitHub repository
3. Build a container using Docker
4. Push the container into Google Container Regsitry
5. Launch Cloud Run

All automatically...

[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run)

If you are not familiar with Crystal, it is very similar
to the Ruby language, but it is compiled.  The following
docker image is only a few MB in size.

I have added a Makefile to simply building and deploying
the executable.

## Test
``` bash
curl http:<Cloud Run URL>/hi/nick
Hello world, got /hi/nick
```

## Clean up
``` bash
gcloud run services delete crystal-webserver
```

Don't forget to delete the GCR repo as well.

## Available make commands
``` bash
$ make
Available targets:

  build/cloud                         Build docker container in Cloud
  build/docker                        Build docker container locally
  build/local                         Compiles source using shards command
  clean/cloud                         Delete Cloud Run service and container
  deploy                              Deploy container to Cloud Run
  docker/login                        Configures Docker to authenticate to GCR
  help                                This help screen
  logs                                Examine the logs from the Cloud container
  logs/stream                         Stream Cloud Run logs
  watch                               Locally run program with dynamic recompile
```

# Resources
## Cloud Run
1. https://github.com/GoogleCloudPlatform/cloud-run-button

## GNU Make
1. [GNU make](https://www.gnu.org/software/make/manual/make.html)
2. [The Art of Makefiles](https://levelup.gitconnected.com/the-art-of-makefiles-a-technical-guide-to-automated-building-6bb43fefe1ed)
3. [Makefile Best Practices](https://docs.cloudposse.com/reference/best-practices/make-best-practices/)
4. [Learn Makefiles](https://makefiletutorial.com/)

# Notes
Send authorization token, if unauthenticated is not allowed
``` bash
curl --header "Authorization: Bearer $(gcloud auth print-identity-token)" [URL]
```

It is now possible to send requests via a local proxy, even if the service is authenticated.

``` bash
gcloud beta run services proxy
```
