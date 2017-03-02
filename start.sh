#!/bin/bash
#set -e

if [ -z "$TRACKER_SERVER" ] ; then  

FASTDFS_MODE=tracker
sed -e "s|/home/yuqing/fastdfs|${FASTDFS_BASE_PATH}|g" /etc/fdfs/tracker.conf.sample > /etc/fdfs/tracker.conf

else   

FASTDFS_MODE=storage
sed -e "s|/home/yuqing/fastdfs|${FASTDFS_BASE_PATH}|g" -e "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf.sample > /etc/fdfs/storage.conf
sed -e "s|/home/yuqing/fastdfs|${FASTDFS_BASE_PATH}|g" -e "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf.sample > /etc/fdfs/client.conf

fi 

FASTDFS_LOG_FILE="${FASTDFS_BASE_PATH}/logs/${FASTDFS_MODE}d.log"
PID_NUMBER="${FASTDFS_BASE_PATH}/data/fdfs_${FASTDFS_MODE}d.pid"

echo "try to start the $FASTDFS_MODE node..."
if [ -f "$FASTDFS_LOG_FILE" ]; then 
	rm "$FASTDFS_LOG_FILE"
fi
# start the fastdfs node.	
fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start

# wait for pid file(important!),the max start time is 5 seconds,if the pid number does not appear in 5 seconds,storage start failed.
TIMES=5
while [ ! -f "$STORAGE_PID_NUMBER" -a $TIMES -gt 0 ]
do
    sleep 1s
	TIMES=`expr $TIMES - 1`
done

# # if the storage node start successfully, print the started time.
# if [ $TIMES -gt 0 ]; then
#     echo "the ${FASTDFS_MODE} node started successfully at $(date +%Y-%m-%d_%H:%M)"
	
# 	# give the detail log address
#     echo "please have a look at the log detail at $FASTDFS_LOG_FILE"

#     # leave balnk lines to differ from next log.
#     echo
#     echo

    
	
# 	# make the container have foreground process(primary commond!)
#     tail -F --pid=`cat $STORAGE_PID_NUMBER` /dev/null
# # else print the error.
# else
#     echo "the ${FASTDFS_MODE} node started failed at $(date +%Y-%m-%d_%H:%M)"
# 	echo "please have a look at the log detail at $FASTDFS_LOG_FILE"
# 	echo
#     echo
# fi

tail -f "$FASTDFS_LOG_FILE"