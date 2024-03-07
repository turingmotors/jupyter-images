#!/bin/bash

set -e

tag=$1

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 767397804933.dkr.ecr.us-west-2.amazonaws.com
docker build --build-arg TAG_FOR_BASE_SAGEMAKER_IMAGE=$tag -t turing-distribution:$tag .
docker tag turing-distribution:$tag 767397804933.dkr.ecr.us-west-2.amazonaws.com/turing-distribution:$tag
docker push 767397804933.dkr.ecr.us-west-2.amazonaws.com/turing-distribution:$tag
