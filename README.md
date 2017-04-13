# This repo has been made available to the OSS Logsearch community as a reference. No pull requests or issues will be accepted or reviewed.

# Logsearch for Cloud Foundry Operators

Log parsing rules and other components useful for running LogSearch with the main purpose of monitoring Cloud Foundry deployments. 
LogSearch for Cloud Foundry Operators is an "extension" on top of [logsearch-boshrelease](https://github.com/logsearch/logsearch-boshrelease)
meaning a properly configured LogSearch deployment is required in order to use this release.

## Configuring the deployment

### Configure and upload Logsearch

In this step you are uploading the core logsearch-boshrelease, and preparing a base logsearch deploy manifest
```sh
$ git clone https://github.com/logsearch/logsearch-boshrelease --recursive
$ cd logsearch-boshrelease
$ vim templates/stub.$infrastructure.example.yml
$ scripts/generate_deployment_manifest $infrastructure stub.$infrastructure.example.yml > ~/workspace/logsearch.yml

$ bosh upload release https://bosh.io/d/github.com/logsearch/logsearch-boshrelease
```

### Configure and upload Logsearch for Cloud Foundry Operators

In this step you are uploading the logsearch-for-cloudfoundry-operators-boshrelease extension

```sh
$ git clone https://github.com/pivotal-cf/logsearch-for-cloudfoundry-operators-boshrelease.git --recursive
$ cd logsearch-for-cloudfoundry-operators-boshrelease
$ bosh create release --force
$ bosh upload release
```

#### Generate the final deployment manifest

In this step you are extending the base logsearch manifest with the logsearch-for-cloudfoundry-operators-boshrelease extensions

```sh
$ vim templates/example-with-basic-auth.yml
$ scripts/generate_deployment_manifest ~/workspace/logsearch.yml templates/example-with-basic-auth.yml > ~/workspace/logsearch-for-cf-ops.yml
```

### Deploy

```sh
$ bosh deployment ~/workspace/logsearch-for-cf-ops.yml
$ bosh deploy
```

Tested to work with stemcell 3363
