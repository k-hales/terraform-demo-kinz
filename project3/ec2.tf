resource "aws_instance" "main" {
  ami           = data.aws_ssm_parameter.instance_ami.value
  instance_type = "t3.micro"
  key_name = "kinzh-key-2"
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = ["sg-0cfeac59e3a85c8e6"]
  tags = {
    "Name" = "${var.default_tags.env}-EC2"
  }
    user_data = base64encode(file("/Users/kinziehales/Desktop/terraform/user.sh"))
}