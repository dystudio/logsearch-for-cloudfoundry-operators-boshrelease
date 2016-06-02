# Log Archiving Docs

## Configuring S3

1. Create S3 bucket
	1. Go to AWS S3
	1. Click on Create Bucket
	1. Create a bucket with a unique name
	
1. Create archiver policy
	1. Go to AWS IAM
	1. Go to Policies
	1. Click on Create Policy
	1. Click on Create your own Policy
	1. Give the policy a name
	1. Copy and paste the following policy code to Policy Document:
	
        ```JSON
	  {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "ServiceBackupPolicy",
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:PutObject"
          ],
          "Resource": [
            "arn:aws:s3:::BUCKET_NAME/*",
            "arn:aws:s3:::BUCKET_NAME"
          ]
        }
      ]
    }
        ```
        
  1. Change BUCKET_NAME to the name of the previously created bucket.
  1. Click on Create policy
	
1. Create archiver user
  1. Go to AWS IAM
  1. Go to Users
  1. Click on Create New Users
  1. Fill in a username in box 1
  1. Click on Create
  1. Click on Download Credentials
  
1. Attach policy to user
  1. Go to AWS IAM
  1. Click on Users
  1. Find the previously created user and click on it
  1. Go to the Permissions tab
  1. Click on Attach Policy
  1. Find the policy created previously
  1. Tick the box of the policy and Click on Attach Policy
  
1. Update the deployment with archiving settings
  1. Edit the deployment manifest stub and add the following properties to the job `parser`
        ```yaml
      properties:
        service-backup:
          destination:
            s3:
              bucket_name: logsearch-backup
              bucket_path: turkish
              access_key_id: AWS_KEY_ID
              secret_access_key: AWS_ACCESS_KEY
              endpoint_url: https://s3-eu-west-1.amazonaws.com
          cron_schedule: 0 * * * *
          source_executable: /var/vcap/packages/logs-backup/before_backup.sh
          source_folder: /var/vcap/store/parser/logs-to-be-archived
          cleanup_executable: rm -rf /var/vcap/store/parser/logs-to-be-archived
        ```
        
  1. Change AWS_KEY_ID and AWS_ACCESS_KEY to `Access Key Id` and `Secret Access Key` respectively from the credentials downloaded in the previous step
  1. Deploy

## Update the Archiver dashboard

1. Create your dashboard
1. Export the required visualisations, searches and dashboards
1. Run `ruby src/dashboards/process.rb /path/to/exported/*.json > src/dashboards/archiver_dashboard.txt`
1. Deploy and run the errand
  ```bash
  $> bosh run errand deploy_logsearch_monitor_dashboards
  ```
