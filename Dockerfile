FROM amazon/aws-cli:2.16.8

RUN yum update -y
RUN yum install -y unzip jq tar gzip curl
RUN curl  -OL https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
RUN unzip terraform_1.8.5_linux_amd64.zip -d /bin
RUN curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.59.3/terragrunt_linux_amd64" -o /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt
ENV HISTFILE=/terraform/.bash_history
ENTRYPOINT ["/bin/bash"]

