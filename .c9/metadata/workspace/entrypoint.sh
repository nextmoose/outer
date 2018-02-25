{"changed":true,"filter":false,"title":"entrypoint.sh","tooltip":"/entrypoint.sh","value":"#!/bin/sh\n\nMONIKER=d1523b1c-85a1-40fb-8b55-6bf6d9ae0a0a &&\n    while [ ${#} -gt 0 ]\n    do\n        case ${1} in\n            --moniker)\n                MONIKER=\"${2}\" &&\n                    shift 2\n            ;;\n            --cloud9-port)\n                export CLOUD9_PORT=\"${2}\" &&\n                    shift 2\n            ;;\n            --project-name)\n                export PROJECT_NAME=\"${2}\" &&\n                    shift 2\n            ;;\n            --user-name)\n                export USER_NAME=\"${2}\" &&\n                    shift 2\n            ;;\n            --user-email)\n                export USER_EMAIL=\"${2}\" &&\n                    shift 2\n            ;;\n            --gpg-secret-key)\n                export GPG_SECRET_KEY=\"${2}\" &&\n                    shift 2\n            ;;\n            --gpg2-secret-key)\n                export GPG2_SECRET_KEY=\"${2}\" &&\n                    shift 2\n            ;;\n            --gpg-owner-trust)\n                export GPG_OWNER_TRUST=\"${2}\" &&\n                    shift 2\n            ;;\n            --gpg2-owner-trust)\n                export GPG2_OWNER_TRUST=\"${2}\" &&\n                    shift 2\n            ;;\n            --gpg-key-id)\n                export GPG_KEY_ID=\"${2}\" &&\n                    shift 2\n            ;;\n            --secrets-organization)\n                export SECRETS_ORGANIZATION=\"${2}\" &&\n                    shift 2\n            ;;\n            --secrets-repository)\n                export SECRETS_REPOSITORY=\"${2}\" &&\n                    shift 2\n            ;;\n            --docker-semver)\n                export DOCKER_SEMVER=\"${2}\" &&\n                    shift 2\n            ;;\n            --browser-semver)\n                export BROWSER_SEMVER=\"${2}\" &&\n                    shift 2\n            ;;\n            --middle-semver)\n                export MIDDLE_SEMVER=\"${2}\" &&\n                    shift 2\n            ;;\n            --inner-semver)\n                export INNER_SEMVER=\"${2}\" &&\n                    shift 2\n            ;;\n            *)\n                echo Unsupported Option &&\n                    echo ${0} &&\n                    echo ${@} &&\n                    exit 64\n            ;;\n        esac\n    done &&\n    if [ -z \"${CLOUD9_PORT}\" ]\n    then\n        echo Unspecified CLOUD9_PORT &&\n            exit 65\n    fi &&\n    if [ -z \"${PROJECT_NAME}\" ]\n    then\n        echo Unspecified PROJECT_NAME &&\n            exit 66\n    fi &&\n    if [ -z \"${USER_NAME}\" ]\n    then\n        echo Unspecified USER_NAME &&\n            exit 67\n    fi &&\n    if [ -z \"${USER_EMAIL}\" ]\n    then\n        echo Unspecified USER_EMAIL &&\n            exit 68\n    fi &&\n    if [ -z \"${GPG_SECRET_KEY}\" ]\n    then\n        echo Unspecified GPG_SECRET_KEY &&\n            exit 69\n    fi &&\n    if [ -z \"${GPG2_SECRET_KEY}\" ]\n    then\n        echo Unspecified GPG2_SECRET_KEY &&\n            exit 70\n    fi &&\n    if [ -z \"${GPG_OWNER_TRUST}\" ]\n    then\n        echo Unspecified GPG_OWNER_TRUST &&\n            exit 71\n    fi &&\n    if [ -z \"${GPG2_OWNER_TRUST}\" ]\n    then\n        echo Unspecified GPG2_OWNER_TRUST &&\n            exit 72\n    fi &&\n    if [ -z \"${SECRETS_ORGANIZATION}\" ]\n    then\n        echo Unspecified SECRETS_ORGANIZATION &&\n            exit 73\n    fi &&\n    if [ -z \"${SECRETS_REPOSITORY}\" ]\n    then\n        echo Unspecified SECRETS_REPOSITORY &&\n            exit 74\n    fi &&\n    if [ -z \"${DOCKER_SEMVER}\" ]\n    then\n        echo Unspecified DOCKER_SEMVER &&\n            exit 75\n    fi &&\n    if [ -z \"${BROWSER_SEMVER}\" ]\n    then\n        echo Unspecified BROWSER_SEMVER &&\n            exit 76\n    fi &&\n    if [ -z \"${MIDDLE_SEMVER}\" ]\n    then\n        echo Unspecified MIDDLE_SEMVER &&\n            exit 77\n    fi &&\n    cleanup(){\n        sudo --preserve-env docker stop $(cat registry) $(cat docker) $(cat middle) &&\n            sudo --preserve-env docker rm -fv $(cat registry) $(cat docker) $(cat middle) &&\n            sudo --preserve-env docker ps --quiet --all --filter label=expiry | while read ID\n            do\n                echo LOG A 1 &&\n                    if [ $(sudo --preserve-env docker inspect --format \"{{ .Config.Labels.expiry }}\" ${ID}) -lt $(date +%s) ]\n                    then\n                        sudo --preserve-env docker rm -v ${ID}\n                    fi &&\n                    echo LOG B1\n            done &&\n            sudo --preserve-env docker volume ls --quiet | while read VOLUME\n            do\n                echo LOG A 3 &&\n                    if [ \"$(sudo --preserve-env docker volume inspect --format \\\"{{.Labels.expiry}}\\\" ${VOLUME})\" != \"\\\"<no value>\\\"\" ] && [ $(sudo --preserve-env docker volume inspect --format \"{{.Labels.expiry}}\" ${VOLUME}) -lt $(date +%s) ]\n                    then\n                        sudo --preserve-env docker volume rm ${VOLUME}\n                    fi &&\n                    echo LOG B 3\n            done\n    } &&\n    trap cleanup EXIT &&\n    IMAGE_VOLUME=$(sudo --preserve-env docker volume ls --quiet | while read VOLUME\n    do\n            if [ \"$(sudo --preserve-env docker volume inspect --format \\\"{{.Labels.moniker}}\\\" ${VOLUME})\" == \"\\\"${MONIKER}\\\"\" ]\n            then    \n                echo ${VOLUME}\n            fi\n    done | head -n 1) &&\n    if [ -z \"${IMAGE_VOLUME}\" ]\n    then\n        echo CREATING A NEW DOCKER VOLUME &&\n            IMAGE_VOLUME=$(sudo docker volume create --label moniker=${MONIKER} --label expiry=$(($(date +%s)+60*60*24*7)))\n    else\n        echo USING A CACHED DOCKER VOLUME\n    fi &&\n    # sudo --preserve-env docker create --cidfile registry --volume ${REGISTRY_VOLUME}:/var/lib/registry registry:2.6.2 &&\n    sudo \\\n        --preserve-env \\\n        docker \\\n        create \\\n        --cidfile docker \\\n        --privileged \\\n        --volume /:/srv/host:ro \\\n        --volume ${IMAGE_VOLUME}:/var/lib/docker/image \\\n        --label expiry=$(($(date +%s)+60*60*24*7)) \\\n        docker:${DOCKER_SEMVER}-ce-dind \\\n            --host tcp://0.0.0.0:2376 &&\n    sudo --preserve-env docker start $(cat docker) $(cat registry) &&\n    sudo --preserve-env docker start $(cat docker) $(cat registry) &&\n    # sleep 5s &&\n    sudo --preserve-env docker exec --interactive $(cat docker) adduser -D user &&\n    sudo --preserve-env docker exec --interactive $(cat docker) mkdir /home/user/workspace &&\n    sudo --preserve-env docker exec --interactive $(cat docker) chown user:user /home/user/workspace &&\n#     echo LOG A 5 &&\n#     sudo --preserve-env docker inspect --format \"{{.NetworkSettings.Networks.bridge.IPAddress}}\" | sudo --preserve-env docker exec --interactive $(cat docker) tee -a /etc/hosts &&\n#     echo LOG B 5 &&\n#     (cat > ${TFILE} <<EOF\n# {\n#     \"insecure-registries\": [\"registry:5000\"]\n# }\n# EOF\n#     ) | sudo --preserve-env docker exec --interactive $(cat docker) tee /etc/docker/daemon.json &&\n#     sudo --preserve-env docker restart $(cat docker) $(cat registry) &&\n#     sleep 5s &&\n    echo LOG A 6 &&\n    sudo \\\n        --preserve-env \\\n        docker \\\n        create \\\n        --cidfile middle \\\n        --interactive \\\n        --env DISPLAY \\\n        --env DOCKER_HOST \\\n        --env CLOUD9_PORT \\\n        --env PROJECT_NAME \\\n        --env USER_NAME \\\n        --env USER_EMAIL \\\n        --env GPG_SECRET_KEY \\\n        --env GPG2_SECRET_KEY \\\n        --env GPG_OWNER_TRUST \\\n        --env GPG2_OWNER_TRUST \\\n        --env GPG_KEY_ID \\\n        --env SECRETS_ORGANIZATION \\\n        --env SECRETS_REPOSITORY \\\n        --env DOCKER_SEMVER \\\n        --env BROWSER_SEMVER \\\n        --env MIDDLE_SEMVER \\\n        --env INNER_SEMVER \\\n        --env DOCKER_HOST=$(sudo --preserve-env docker inspect --format \"tcp://{{ .NetworkSettings.Networks.bridge.IPAddress }}:2376\" $(cat docker)) \\\n        --label expiry=$(($(date +%s)+60*60*24*7)) \\\n        rebelplutonium/middle:${MIDDLE_SEMVER} \\\n            \"${@}\" &&\n    echo LOG B 6 &&\n    sudo --preserve-env docker start --interactive $(cat middle)","undoManager":{"mark":11,"position":13,"stack":[[{"start":{"row":168,"column":1},"end":{"row":169,"column":1},"action":"remove","lines":["       echo LOG A 4 &&"," "],"id":2}],[{"start":{"row":172,"column":0},"end":{"row":173,"column":0},"action":"remove","lines":["            echo LOG B 4",""],"id":3}],[{"start":{"row":171,"column":16},"end":{"row":171,"column":17},"action":"remove","lines":["&"],"id":4}],[{"start":{"row":171,"column":15},"end":{"row":171,"column":16},"action":"remove","lines":["&"],"id":5}],[{"start":{"row":171,"column":14},"end":{"row":171,"column":15},"action":"remove","lines":[" "],"id":6}],[{"start":{"row":180,"column":4},"end":{"row":180,"column":6},"action":"insert","lines":["# "],"id":7}],[{"start":{"row":192,"column":4},"end":{"row":192,"column":6},"action":"insert","lines":["# "],"id":8},{"start":{"row":193,"column":4},"end":{"row":193,"column":6},"action":"insert","lines":["# "]}],[{"start":{"row":197,"column":0},"end":{"row":197,"column":2},"action":"insert","lines":["# "],"id":9},{"start":{"row":198,"column":0},"end":{"row":198,"column":2},"action":"insert","lines":["# "]},{"start":{"row":199,"column":0},"end":{"row":199,"column":2},"action":"insert","lines":["# "]},{"start":{"row":200,"column":0},"end":{"row":200,"column":2},"action":"insert","lines":["# "]},{"start":{"row":201,"column":0},"end":{"row":201,"column":2},"action":"insert","lines":["# "]},{"start":{"row":202,"column":0},"end":{"row":202,"column":2},"action":"insert","lines":["# "]},{"start":{"row":203,"column":0},"end":{"row":203,"column":2},"action":"insert","lines":["# "]},{"start":{"row":204,"column":0},"end":{"row":204,"column":2},"action":"insert","lines":["# "]},{"start":{"row":205,"column":0},"end":{"row":205,"column":2},"action":"insert","lines":["# "]},{"start":{"row":206,"column":0},"end":{"row":206,"column":2},"action":"insert","lines":["# "]},{"start":{"row":207,"column":0},"end":{"row":207,"column":2},"action":"insert","lines":["# "]}],[{"start":{"row":192,"column":4},"end":{"row":192,"column":5},"action":"remove","lines":["#"],"id":10}],[{"start":{"row":192,"column":0},"end":{"row":192,"column":4},"action":"remove","lines":["    "],"id":11}],[{"start":{"row":192,"column":0},"end":{"row":192,"column":1},"action":"remove","lines":[" "],"id":12}],[{"start":{"row":192,"column":0},"end":{"row":192,"column":4},"action":"insert","lines":["    "],"id":13}],[{"start":{"row":192,"column":0},"end":{"row":193,"column":0},"action":"remove","lines":["    sudo --preserve-env docker start $(cat docker) $(cat registry) &&",""],"id":14},{"start":{"row":192,"column":0},"end":{"row":193,"column":0},"action":"insert","lines":["    sudo --preserve-env docker start $(cat docker) $(cat registry) &&",""]}],[{"start":{"row":193,"column":0},"end":{"row":194,"column":0},"action":"insert","lines":["    sudo --preserve-env docker start $(cat docker) $(cat registry) &&",""],"id":15}]]},"ace":{"folds":[],"scrolltop":2349,"scrollleft":0,"selection":{"start":{"row":192,"column":0},"end":{"row":193,"column":0},"isBackwards":false},"options":{"guessTabSize":true,"useWrapMode":false,"wrapToView":true},"firstLineState":{"row":166,"state":"start","mode":"ace/mode/sh"}},"timestamp":1519594644963}