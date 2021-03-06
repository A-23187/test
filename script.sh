#!/usr/bin/env bash

LOCAL_USER=${LOCAL_USER:-debugger}
LOCAL_USER_PWD=${LOCAL_USER_PWD:-123456}
PORT=${PORT:-23187}

echo "Adding a new local user: $LOCAL_USER ..."
sudo useradd -G sudo -s /bin/bash -m $LOCAL_USER

echo "Setting $LOCAL_USER's password ..."
echo -e "$LOCAL_USER_PWD\n$LOCAL_USER_PWD" | sudo passwd $LOCAL_USER

echo "Connecting to $REMOTE_USER@$REMOTE_HOST ..."
if [ "$SSH_KEY" != "" ]; then
    # connect using private key
    echo "$SSH_KEY" > ssh_key # fxxk, echo $SSH_KEY (without quotes) will convert LF to space !
    chmod 600 ssh_key
    ssh -i ssh_key -o StrictHostKeyChecking=accept-new \
        -fNR $PORT:localhost:22 $REMOTE_USER@$REMOTE_HOST
    rm ssh_key
else
    # connect using password
    sshpass -p $SSH_PWD ssh -o StrictHostKeyChecking=accept-new \
        -fNR $PORT:localhost:22 $REMOTE_USER@$REMOTE_HOST
fi

echo "To connect back by running 'ssh $LOCAL_USER@localhost -p $PORT'"
if [[ $TIME =~ ^0[smhd]?$ ]]; then
    echo "  and 'touch /home/$LOCAL_USER/.exit' to exit after connecting."
    while : ; do
        sleep 1
        [ -f /home/$LOCAL_USER/.exit ] && break
    done
else
    echo "  and the connection will be closed after $TIME."
    sleep $TIME
fi
echo -e "Bye \u2764"
