resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.toptal-access-key.key_name

  user_data = <<-EOF
              #cloud-config
              
              apt:
                sources:
                  docker.list:
                    source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
                    keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

              packages:
                - docker-ce
                - docker-ce-cli
                - apt-transport-https
                - ca-certificates
                - curl
                - gnupg-agent
                - software-properties-common
                - docker-compose-plugin
                - jq
                - curl 
                - npm


              # create the docker group
              groups:
                - docker

              # Add default auto created user to docker group
              system_info:
                default_user:
                  groups: [docker]

              runcmd:
                - /usr/bin/sleep 10
                - /usr/bin/docker pull tutum/hello-world
                - /usr/bin/docker run -d -p 80:80 --restart=always -e SOME_VAR="SOME VALUE" tutum/hello-world
                - /usr/bin/docker compose version

             EOF
}



resource "aws_key_pair" "toptal-access-key" {
  key_name   = "toptal_access_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl59hcXNOkns62o34FH1JkqRAUojia659PsOcj52Ofv debian@Ahmed-Laptop"
}

