#!/bin/sh

xhost +local: &&
    cleanup(){
        xhost -
    } &&
    trap cleanup EXIT &&
    sudo         /usr/bin/docker         run         --interactive         --rm         --label expiry=1520681595         --volume /var/run/docker.sock:/var/run/docker.sock:ro         --env DISPLAY         rebelplutonium/outer:0.0.3             ""    
