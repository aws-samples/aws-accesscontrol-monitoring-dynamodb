## Enable fine-grained access control and observability for API operations in your Amazon DynamoDB

Data sovereignty requires businesses to comply with data protection regulations, which can be complex and vary from country to country. Good data governance requires businesses to keep productivity high while securing the privacy and integrity of the data. In particular, with Amazon DynamoDB based solutions, you need to ensure the security and compliance of your AWS resources. Being proactive, you will use AWS Identity and Access Management (IAM) roles and policies to implement least privilege access. This preventive posture is key in reducing the security risk and the subsequent impact. Being reactive, you will continuously monitor DynamoDB API activities to enhance the visibility for the security and operations engineering teams.

In this blog, you will learn;
1.	Access Control in DynamoDB: Configure fine grained access control with condition based IAM polices on your Amazon DynamoDB. We will provide you sample AWS IAM Identity Center (successor to AWS Single Sign-On) permission sets for fine grained access control to Amazon DynamoDB based on attributes like AWS Regions and tags.

2.	Monitor DynamoDB control and data plane activity: Integrate DynamoDB with AWS CloudTrail, log DynamoDB control and data plane API actions (example `DeleteItem’) as events in CloudTrail logs, create CloudWatch metric filter, and create a CloudWatch alarm. We will provide you with a HashiCorp Terraform IaC template that automates creation of all of the above. 

To read further, check the  blog <need to update>

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

