#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --major)
            export MAJOR="${2}" &&
                shift 2
        ;;
        --minor)
            export MINOR="${2}" &&
                shift 2
        ;;
        --patch)
            export PATCH="${2}" &&
                shift 2
        ;;
        --)
            shift &&
                xhost +local: &&
                cleanup(){
                    xhost -
                } &&
                trap cleanup EXIT &&
                echo LOADING SCRIPT ... &&
                sudo \
                    --preserve-env \
                    /usr/bin/docker \
                    run \
                    --interactive \
                    --rm \
                    --label expiry=$(($(date +%s)+60*60*24*7)) \
                    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
                    --env DISPLAY \
                    rebelplutonium/outer:${MAJOR}.${MINOR}.${PATCH} \
                        "${@}"
        ;;
        *)
            echo Unknown Option &&
                echo ${0} &&
                echo ${@} &&
                exit 64
        ;;
    esac
done