#!/bin/bash
#set -e

function fdfs_set () {
    if [ "$1" = "monitor" ] ; then
        if [ -n "$TRACKER_SERVER" ] ; then  
          sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
        fi
        fdfs_monitor /etc/fdfs/client.conf
        exit 0
    elif [ "$1" = "storage" ] ; then
        FASTDFS_MODE="storage"
    else 
        FASTDFS_MODE="tracker"
    fi
    
    if [ -n "$PORT" ] ; then  
        sed -i "s|^port=.*$|port=${PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
    fi
    
    if [ -n "$TRACKER_SERVER" ] ; then  
        sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
        sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
    fi
    
    if [ -n "$GROUP_NAME" ] ; then  
        sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/storage.conf
    fi 
    
    FASTDFS_LOG_FILE="${FASTDFS_BASE_PATH}/logs/${FASTDFS_MODE}d.log"
    PID_NUMBER="${FASTDFS_BASE_PATH}/data/fdfs_${FASTDFS_MODE}d.pid"
    
    echo "try to start the $FASTDFS_MODE node..."
    if [ -f "$FASTDFS_LOG_FILE" ]; then 
        rm "$FASTDFS_LOG_FILE"
    fi
    # start the fastdfs node.	
    fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start
}

function nginx_set () {
    # start nginx.
    cp /nginx_conf/${FASTDFS_MODE}.conf /etc/nginx/conf.d/
    nginx
}

fdfs_set
nginx_set

# wait for pid file(important!),the max start time is 5 seconds,if the pid number does not appear in 5 seconds,start failed.
TIMES=5
while [ ! -f "$PID_NUMBER" -a $TIMES -gt 0 ]
do
    sleep 1s
    TIMES=`expr $TIMES - 1`
done

tail -f "$FASTDFS_LOG_FILE"
