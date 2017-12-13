#!/bin/bash
mUser='<%= input("username") %>'

if [ ! -d /home/OLD_account ]; then
   mkdir -p /home/OLD_account
fi


lock_user()
{
  echo $user
  
  id ${user} > /dev/null 2>&1
  user_exist=$?

  if [ ${user_exist} == 0 ]; then
    # lock user
    passwd -l $user
    # archive and remove user's home directory
    cp -rp /home/$user /home/OLD_account/
    tar -cpzf /home/OLD_account/$user-$(date +"%d-%m-%Y").tar.gz -P /home/OLD_account/$user
    arch_status=$?
    if [ ${arch_status} == 0 ]; then
      rm -rf /home/$user
      rm -rf /home/OLD_account/$user
    fi
  fi
}

for user in ${mUser}
  do
    echo "Locking user $user"
    lock_user ${user}
  done
