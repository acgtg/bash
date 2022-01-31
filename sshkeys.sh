#!/usr/bin/env bash
id="$1"
users=(user1 user2 user3)
validkeys=""
url="http://10.10.10.10/user/$id/.ssh"
if [ "$id" = "pdu" ]; then
    hostname=`hostname -s`
    keys=`curl -sf $url/authorized_keys.$hostname`
elif [ "$id" = "ops" ]; then
  for(( i=0;i<${#users[@]};i++))
    do
        subid=${users[i]}
        suburl="http://10.10.10.10/user/$subid/.ssh"
        tmpkeys=`curl -sf $suburl/id_rsa.pub`
        validkeys="$validkeys\n$tmpkeys"
    done
    keys=`echo -e $validkeys`
else
    keys=`curl -sf $url/id_rsa.pub`
fi
printf "%s\n" "$keys"
