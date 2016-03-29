# Logsearch for Cloud Foundry Operators

Log parsing rules and other components useful for running LogSearch with the main purpose of monitoring Cloud Foundry deployments. LogSearch for Cloud Foundry Operators is an "extension" on top of **logsearch-boshrelease**, meaning a properly configured LogSearch deployment is required in order to use this release.

## Configuring the deployment

### 1. Configure and upload LogSearch

```sh
$ git clone https://github.com/logsearch/logsearch-boshrelease --recursive
$ cd logsearch-boshrelease
$ vim templates/stub.$env.example.yml
$ scripts/generate_deployment_manifest $env stub.$env.example.yml > ~/workspace/logsearch.yml

$ bosh upload release https://bosh.io/d/github.com/logsearch/logsearch-boshrelease
```

### 2. Configure LogSearch for Cloud Foundry Operators

```sh
$ git clone https://github.com/logsearch/logsearch-for-cloudfoundry-operators-boshrelease --recursive
$ cd logsearch-for-cloudfoundry-operators-boshrelease
$ vim templates/example-with-basic-auth.yml
```


### 3. Generate the final deployment manifest

```sh
$ scripts/generate_deployment_manifest ~/workspace/logsearch.yml templates/example-with-basic-auth.yml > ~/workspace/logsearch-for-cf-ops.yml
```

### 4. Upload LogSearch for Cloud Foundry Operators release to your BOSH director

```sh
$ bosh create release --force
$ bosh upload release
```

### 5. Deploy

```sh
$ bosh deployment ~/workspace/logsearch-for-cf-ops.yml
$ bosh deploy
```
