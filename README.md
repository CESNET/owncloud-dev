# owncloud-dev
Docker image for ownCloud development envrionment.
It sets up a development instance of ownCloud from
current GitHub sources. It could be used for running
tests on ownCloud and optionally on 3rd party Git[Hub] apps.

# Build it:

```
sudo docker build . -t ocdev
```

# Use it:

```
sudo docker run -it ocdev [<app_url> <app_name>]
```
*If an app is provided, it will be cloned and enabled in ownCloud*.
