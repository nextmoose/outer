#!/bin/sh

source public.env &&
    export GPG_SECRET_KEY="$(cat private/gpg.secret.key)" &&
    export GPG2_SECRET_KEY="$(cat private/gpg2.secret.key)" &&
    export GPG_OWNER_TRUST="$(cat public/gpg.owner.trust)" &&
    export GPG2_OWNER_TRUST="$(cat public/gpg2.owner.trust)" &&
            --secrets-organization)
                export SECRETS_ORGANIZATION="${2}" &&
                    shift 2
            ;;
            --secrets-repository)
                export SECRETS_REPOSITORY="${2}" &&
                    shift 2
            ;;
            --docker-semver)
                export DOCKER_SEMVER="${2}" &&
                    shift 2
            ;;
            --browser-semver)
                export BROWSER_SEMVER="${2}" &&
                    shift 2
            ;;
            --middle-semver)
                export MIDDLE_SEMVER="${2}" &&
                    shift 2
            ;;
            --inner-semver)
                export INNER_SEMVER="${2}" &&
                    shift 2
            ;;
            --target-uid)
                export TARGET_UID="${2}" &&
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
    if [ -z "${CLOUD9_PORT}" ]
    then
        echo Unspecified CLOUD9_PORT &&
            exit 65
    fi &&
    if [ -z "${PROJECT_NAME}" ]
    then
        echo Unspecified PROJECT_NAME &&
            exit 66
    fi &&
    if [ -z "${USER_NAME}" ]
    then
        echo Unspecified USER_NAME &&
            exit 67
    fi &&
    if [ -z "${USER_EMAIL}" ]
    then
        echo Unspecified USER_EMAIL &&
            exit 68
    fi &&
    if [ -z "${GPG_SECRET_KEY}" ]
    then
        echo Unspecified GPG_SECRET_KEY &&
            exit 69
    fi &&
    if [ -z "${GPG2_SECRET_KEY}" ]
    then
        echo Unspecified GPG2_SECRET_KEY &&
            exit 70
    fi &&
    if [ -z "${GPG_OWNER_TRUST}" ]
    then
        echo Unspecified GPG_OWNER_TRUST &&
            exit 71
    fi &&
    if [ -z "${GPG2_OWNER_TRUST}" ]
    then
        echo Unspecified GPG2_OWNER_TRUST &&
            exit 72
    fi &&
    if [ -z "${SECRETS_ORGANIZATION}" ]
    then
        echo Unspecified SECRETS_ORGANIZATION &&
            exit 73
    fi &&
    if [ -z "${SECRETS_REPOSITORY}" ]
    then
        echo Unspecified SECRETS_REPOSITORY &&
            exit 74
    fi &&
    if [ -z "${DOCKER_SEMVER}" ]
    then
        echo Unspecified DOCKER_SEMVER &&
            exit 75
    fi &&
    if [ -z "${BROWSER_SEMVER}" ]
    then
        echo Unspecified BROWSER_SEMVER &&
            exit 76
    fi &&
    if [ -z "${MIDDLE_SEMVER}" ]
    then
        echo Unspecified MIDDLE_SEMVER &&
            exit 77
    fi &&
    if [ -z "${TARGET_UID}" ]
    then
        echo Unspecified TARGET_UID &&
            exit 78
    fi &&
    cleanup(){
        sudo --preserve-env docker stop $(cat docker) $(cat middle) &&
            sudo --preserve-env docker rm -fv $(cat docker) $(cat middle)
    } &&
    trap cleanup EXIT &&
    IMAGE_VOLUME=$(sudo --preserve-env docker volume ls --quiet | while read VOLUME
    do
            if [ "$(sudo --preserve-env docker volume inspect --format \"{{.Labels.moniker}}\" ${VOLUME})" == "\"${MONIKER}-image\"" ]
            then    
                echo ${VOLUME}
            fi
    done | head -n 1) &&
    if [ -z "${IMAGE_VOLUME}" ]
    then
        IMAGE_VOLUME=$(sudo docker volume create --label moniker=${MONIKER}-image --label expiry=$(($(date +%s)+60*60*24*7)))
    fi &&
    echo IMAGE_VOLUME=${IMAGE_VOLUME} &&
    sudo \
        --preserve-env \
        docker \
        create \
        --cidfile docker \
        --privileged \
        --volume /:/srv/host:ro \
        --volume ${IMAGE_VOLUME}:/var/lib/docker \
        --volume /run/user/${TARGET_UID}/pulse:/srv/pulse \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        docker:${DOCKER_SEMVER}-ce-dind \
            --host tcp://0.0.0.0:2376 &&
    sudo --preserve-env docker start $(cat docker) &&
    sudo --preserve-env docker exec --interactive $(cat docker) adduser -D user -u ${TARGET_UID} -g ${TARGET_UID} &&
    sudo --preserve-env docker exec --interactive $(cat docker) mkdir /opt &&
    sudo --preserve-env docker exec --interactive $(cat docker) mkdir /opt/cloud9 &&
    sudo --preserve-env docker exec --interactive $(cat docker) mkdir /opt/cloud9/workspace &&
    sudo --preserve-env docker exec --interactive $(cat docker) chown user:user /opt/cloud9/workspace &&
    sudo \
        --preserve-env \
        docker \
        create \
        --cidfile middle \
        --interactive \
        --env DISPLAY \
        --env DOCKER_HOST \
        --env CLOUD9_PORT \
        --env PROJECT_NAME \
        --env USER_NAME \
        --env USER_EMAIL \
        --env GPG_SECRET_KEY \
        --env GPG2_SECRET_KEY \
        --env GPG_OWNER_TRUST \
        --env GPG2_OWNER_TRUST \
        --env GPG_KEY_ID \
        --env SECRETS_ORGANIZATION \
        --env SECRETS_REPOSITORY \
        --env DOCKER_SEMVER \
        --env BROWSER_SEMVER \
        --env MIDDLE_SEMVER \
        --env INNER_SEMVER \
        --env TARGET_UID \
        --env DOCKER_HOST=$(sudo --preserve-env docker inspect --format "tcp://{{ .NetworkSettings.Networks.bridge.IPAddress }}:2376" $(cat docker)) \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        rebelplutonium/middle:${MIDDLE_SEMVER} \
            "${@}" &&
    sudo --preserve-env docker exec --interactive $(cat docker) docker ps --all --quiet | while read CONTAINER
    do
        sudo --preserve-env docker exec --interactive $(cat docker) docker rm --force --volumes ${CONTAINER}
    done &&
    sudo --preserve-env docker start --interactive $(cat middle)