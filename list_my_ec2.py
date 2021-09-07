# Author: Chetan Hireholi

import boto3
import pandas as pd

AWS_REGION = "us-east-1"
EC2_RESOURCE = boto3.resource('ec2', region_name=AWS_REGION)

instances = EC2_RESOURCE.instances.all()

for instance in instances:
    print("EC2 instance {instance.id} information:")
    print("Instance type: {instance.instance_type}")