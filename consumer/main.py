import boto3
from secret_keys import Secrets
import json

secrets = Secrets()
sqs_client = boto3.client("sqs", region_name=secrets.REGION_NAME)

ecs_client = boto3.client("ecs", region_name=secrets.REGION_NAME)

def poll_sqs():
    while True:
         response = sqs_client.receive_message(
            QueueUrl=secrets.AWS_SQS_RAWVIDEOS,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=20,
        )
        
         for message in response.get("Messages", []):
              message_body = json.loads(message.get("Body"))

              if (
                   "Service" in message_body
                   and "Event" in message_body
                   and message_body.get("Event") == "s3:TestEvent"
              ):
                   sqs_client.delete_message(
                        QueueUrl=secrets.AWS_SQS_RAWVIDEOS,
                        ReceiptHandle=message["ReceiptHandle"]
                   )
                   continue

              if "Records" in message_body:
                   s3_record = message_body["Records"][0]["s3"]
                   bucket_name = s3_record["bucket"]["name"]
                   s3_key = s3_record["object"]["key"]

                   response = ecs_client.run_task(
                        cluster = "arn:aws:ecs:us-east-1:442042531278:cluster/pahadi-Simba",
                        launchType = "FARGATE",
                        taskDefinition = "arn:aws:ecs:us-east-1:442042531278:task-definition/video-transcoder:2",
                        overrides = {
                             "containerOverrides": [
                                  {"name": "video-transcoder", "environment": [{"name": "S3_BUCKET", "value": bucket_name}, {"name": "S3_KEY", "value": s3_key}]}
                             ]
                        },
                        networkConfiguration = {
                             "awsvpcConfiguration": {
                                  "subnets": [
                                       "subnet-00bc7befcf4ee0fa2"
                                       "subnet-0a0d6e17a47b96d24",
                                       "subnet-0be47a2564c60ea20",
                                       "subnet-06b064343f3a16f20",
                                       "subnet-07904a2c43ff0f479",
                                       "subnet-03acdae4de7b28fc0"

                                  ],
                                  "assignPublicIp": "ENABLED",
                                  "securityGroups": [
                                       "sg-05987f283c0be453c"
                                  ],
                             }
                        }
                   )

                   print(response)
                   sqs_client.delete_message(
                        QueueUrl=secrets.AWS_SQS_RAWVIDEOS,
                        ReceiptHandle=message["ReceiptHandle"]
                   )
                   
poll_sqs()