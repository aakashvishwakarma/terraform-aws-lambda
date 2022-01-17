data "aws_caller_identity" "current" {}

locals{
    lambda_source_file = "welcome.py"
    lambda_output_file = "outputs/welcome.zip"
}

data "archive_file" "new"{
    type = "zip"
    source_file = "${local.lambda_source_file}"
    output_path = "${local.lambda_output_file}"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${local.lambda_output_file}"
  function_name = var.function-name
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "welcome.handler"

  source_code_hash = "${filebase64sha256(local.lambda_output_file)}"  # we use this to upload new changes to lambda on console.
  runtime = "python3.7"
  environment {
    variables = {
      cred = "${data.aws_kms_ciphertext.client.ciphertext_blob}"
    }
  }
}

### cloudwatch logging
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.function_name}"
  retention_in_days = 14
}


########## To add cloudwatch event trigger(cloudwatch logging)##########
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "test_lambda_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = "test_lambda"
    arn = "${aws_lambda_function.test_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_test_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.test_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}

## KMS key
resource "aws_kms_key" "config" {
  description = "env config"
  is_enabled = true
  policy = <<EOF
  {
    "Version" : "2012-10-17",
    "Id" : "key-consolepolicy-3",
    "Statement" : [ {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    }, {
      "Sid" : "Allow use of the key",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "${aws_iam_role.lambda_role.arn}"
      },
#       "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey" ],
        "Action" : [ "kms:Decrypt","kms:DescribeKey" ],
      "Resource" : "*"
    }, {
      "Sid" : "Allow attachment of persistent resources",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "${aws_iam_role.lambda_role.arn}"
      },
      "Action" : [ "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant" ],
      "Resource" : "*",
      "Condition" : {
        "Bool" : {
          "kms:GrantIsForAWSResource" : "true"
        }
      }
    } ]
  }
EOF
}

data "aws_kms_ciphertext" "client" {
  key_id = "${aws_kms_key.config.key_id}"
  context ={
    LambdaFunctionName =var.function-name
  }
  plaintext = var.client
}
# data "aws_kms_ciphertext" "password" {
#   key_id = "${aws_kms_key.config.key_id}"
#   context ={
#     LambdaFunctionName =var.function-name
#   }
#   plaintext = {
#     "client":"aakash",
#     "user":"abhi",
    
#   }var.password
# }


output "client_output" {
  value = var.client
}
