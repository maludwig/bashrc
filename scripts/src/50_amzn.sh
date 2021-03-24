#!/bin/bash
# Network name


# Detect EC2 Environment
is_ec2_instance () {
  commands_exist curl aws && uname -a | grep -qE "(amzn|aws.*Ubuntu)"
}

if is_ec2_instance; then
  PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4 2> /dev/null`
  INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null`
  EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
  EC2_REGION=`echo "$EC2_AVAIL_ZONE" | sed -E 's%([0-9][0-9]*)[a-z]*$%\1%'`

  INSTANCE_JSON=`aws ec2 describe-tags --region="${EC2_REGION}" --filters "Name=resource-id,Values=$INSTANCE_ID" 2> /dev/null`

  if [[ "$INSTANCE_JSON" != "" ]]; then
    if commands_exist jq; then
      #Better, works with ASGs
      INSTANCE_NAME=`echo "$INSTANCE_JSON" | jq --raw-output '.Tags[] | select(.Key == "Name") | .Value'`
    else
      INSTANCE_NAME=`echo "$INSTANCE_JSON" | sed -r 's/.*Value": "([^"]*)", "Key": "Name".*/\1/'`
    fi
    HOST_ALIAS="${INSTANCE_NAME}"
  fi

  export PUBLIC_IP
  export INSTANCE_ID
  export EC2_AVAIL_ZONE
  export EC2_REGION
  export INSTANCE_NAME
  export HOST_ALIAS
fi
