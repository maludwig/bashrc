
_amzn_test () {
  msg-info '
    Install this repo onto an Amazon Linux EC2 instance, and an Ubuntu EC2 instance,
      then make sure these variables are populated:

    Type:

      echo "
        PUBLIC_IP=$PUBLIC_IP
        INSTANCE_ID=$INSTANCE_ID
        EC2_AVAIL_ZONE=$EC2_AVAIL_ZONE
        EC2_REGION=$EC2_REGION
      "

    If the instance has EC2 Read access, they should populate with values.
  '
  ask-yes "Did it work?" && [[ "$ASK" == "y" ]]
}

TESTS=(_amzn_test)
