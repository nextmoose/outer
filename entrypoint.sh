#!/bin/sh

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
        --label expiry=$(date --date "now + 1 month") \
        docker:18.01.0-ce-dind \
            --host tcp://0.0.0.0:2376 &&
    sudo \
        --preserve-env \
        docker \
        --cidfile middle \
        --interactive \
        --tty \
        --env DISPLAY \
        --env DOCKER_HOST=tcp://docker:2376 \
        --label expiry=$(date --date "now + 1 month") \
        middle:0.0.0 &&
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
        