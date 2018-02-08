#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --cloud9-port)
            export CLOUD9_PORT="${2}" &&
                shift 2
        ;;
        --project-name)
            export PROJECT_NAME="${2}" &&
                shift 2
        ;;
        --user-name)
            export USER_NAME="${2}" &&
                shift 2
        ;;
        --user-email)
            export USER_EMAIL="${2}" &&
                shift 2
        ;;
        --gpg-secret-key)
            export GPG_SECRET_KEY="${2}" &&
                shift 2
        ;;
        --gpg2-secret-key)
            export GPG2_SECRET_KEY="${2}" &&
                shift 2
        ;;
        --gpg-user-trust)
            export GPG_USER_TRUST="${2}" &&
                shift 2
        ;;
        --gpg2-user-trust)
            export GPG2_USER_TRUST="${2}" &&
                shift 2
        ;;
        --gpg-key-id)
            export GPG_KEY_ID="${2}" &&
                shift 2
        ;;
        --secrets-organization)
            export SECRETS_ORGANIZATION="${2}" &&
                shift 2
        ;;
        --secrets-repository)
            export SECRETS_REPOSITORY="${2}" &&
                shift 2
        ;;
        *)
            echo Unsupported Option &&
                echo ${0} &&
                echo ${@} &&
                exit 64
        ;;
    esac
done &&
    cleanup(){
        sudo --preserve-env docker stop $(cat docker) $(cat middle) &&
            sudo --preserve-env docker rm -fv $(cat docker) $(cat middle) &&
            sudo --preserve-env docker network rm $(cat network)
    } &&
    sudo \
        --preserve-env \
        docker \
        create \
        --cidfile docker \
        --privileged \
        --volume /:/srv/host:ro \
        --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
        --label expiry=$(date --date "now + 1 month" +%s) \
        docker:${DOCKER_VERSION}-ce-dind \
            --host tcp://0.0.0.0:2376 &&
    sudo \
        --preserve-env \
        docker \
        --cidfile middle \
        --interactive \
        --tty \
        --env DISPLAY \
        --env DOCKER_HOST=tcp://docker:2376 \
        --label expiry=$(date --date "now + 1 month" +%s) \
        middle:${MIDDLE_VERSION} \
            "${@}" &&
    sudo --preserve-env docker network create $(uuidgen) > network &&
    sudo \
        --preserve-env \
        docker \
        network \
        connect \
        --alias docker \
        $(cat main) \
        $(cat docker) &&
    sudo --preserve-env docker network connect $(cat main) $(cat middle) &&
    sudo --preserve-env docker start $(cat docker) &&
    sudo --preserve-env docker start --interactive $(cat middle)
        