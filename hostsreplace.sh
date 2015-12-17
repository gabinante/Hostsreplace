#!/bin/bash

#this script is designed to circumvent cloudfront by continually refreshing your hosts file with the dynamic IP of the cloudfront host.

hash=$(dig your-server-here.us-east-1.elb.amazonaws.com a | grep -A 1 "ANSWER SECTION" | grep "IN" | awk '{print$5}');
HOST=$(cat /etc/hosts | grep cloudfrontdns.com | awk '{print$2}');
 
if [ -z "$hash" ];
  then echo "Nope, it's fucked. Sorry."
  exit
fi
 
if [ -z "$HOST" ];
  then echo $hash "  cloudfrontdns.com" >> /etc/hosts
  killall -HUP mDNSResponder
  sudo discoveryutil mdnsflushcache 
elif [ ! -z "$hash" -a ! -z "$HOST" ];
  then
  echo $hash $HOST
    sed -i '.bak' 'cloudfrontdns.com/d' /etc/hosts
    echo "$hash    cloudfrontdns.com" >> /etc/hosts
    rm /etc/hosts.bak
    killall -HUP mDNSResponder
    sudo discoveryutil mdnsflushcache 
fi
