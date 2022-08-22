FROM maven:3.8-jdk-11
RUN apt-get update
RUN apt-get -y install curl gnupg jq wget zip unzip software-properties-common

#Install AWS Cli 2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get -y install nodejs
RUN npm install -g @angular/cli
RUN npm install ytoj -g
RUN npm install -g eslint
RUN npm list -g  @openapitools/openapi-generator-cli || npm install @openapitools/openapi-generator-cli@2.1.15 -g


#Install Sonnar scanner
COPY ./sonar-scanner /root/sonnar-scanner
#Install Headless chrome for FE tests
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome*.deb;
RUN export CHROME_BIN=/usr/bin/google-chrome
#Intstall terraform
RUN wget --quiet https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip \
  && unzip terraform_1.1.4_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_1.1.4_linux_amd64.zip
#Python
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt -y install python3.9
RUN apt install -y python3-pip
#Install Docker compose for tests
RUN pip3 install --no-cache-dir docker-compose
RUN pip3 install pylint
RUN pip3 install boto3
RUN pip3 install black
RUN pip3 install datamodel-code-generator
RUN pip3 install poetry


#Versions

RUN terraform -version
RUN eslint -v
RUN node --version
RUN npm --version
RUN pip3 --version
RUN aws --version
RUN docker-compose -v


