###  This line of code is use to add inline policy to role.

# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "lambda_policy"
#   role = aws_iam_role.lambda_role.id

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = "${file("iam/lambda-policy.json")}"
# }
##------------------------------------------------------

## This one is creating role with trust policy
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = "${file("iam/trust-policy.json")}"
}
##-----------------------------------------------------------

## These below two are attaching AWS manageed permissions to our role
resource "aws_iam_role_policy_attachment" "Lambda_AmazonEC2ReadOnlyAccess" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "Lambda_AmazonSSMReadOnlyAccess" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
##---------------------------------------------------------------

## This block is creating role with customer managed policy using our policy docs.
resource "aws_iam_policy" "cutomer_managed_policy" {
  name        = "customer-mnaged"
  description = "A test policy"

  policy = "${file("iam/lambda-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "customer_managed_role_attach" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = aws_iam_policy.cutomer_managed_policy.arn
}