cd ./devops/ci-image
docker build -t registry.gitlab.com/qak87/qparking/qparking-ci:latest .

if [ "$1" == "--publish" ]; then
  mkdir -p $HOME/.docker/
  echo "${DOCKER_AUTH_CONFIG}" > $HOME/.docker/config.json
  docker login registry.gitlab.com
  docker push registry.gitlab.com/qak87/qparking/qparking-ci:latest
  docker tag registry.gitlab.com/qak87/qparking/qparking-ci:latest registry.gitlab.com/qak87/qparking/qparking-ci:"${CI_PIPELINE_IID}"
  docker push registry.gitlab.com/qak87/qparking/qparking-ci:"${CI_PIPELINE_IID}"
fi