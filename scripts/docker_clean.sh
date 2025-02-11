#!/bin/bash
docker system df
echo y | docker image prune
echo y | docker container prune
echo y | docker volume prune 
echo y | docker builder prune 
echo y | docker system prune 
docker system df

