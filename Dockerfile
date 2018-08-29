FROM centos:7

LABEL maintainer "29ygq@sina.com"

ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=

#copy nginx.repo 
COPY nginx.repo /etc/yum.repos.d/

#get all the dependences and nginx
RUN yum install -y git gcc make nginx vim\
  && rm -rf /var/cache/yum/*

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs \
 && mkdir ${FASTDFS_BASE_PATH}

#compile the libfastcommon
WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN git clone --branch V1.0.36 --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/libfastcommon

#compile the fastdfs
WORKDIR ${FASTDFS_PATH}/fastdfs

RUN git clone --branch V5.11 --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs

EXPOSE 22122 23000 8080 8888 80
VOLUME ["$FASTDFS_BASE_PATH", "/etc/fdfs"]   

COPY conf/*.* /etc/fdfs/

RUN mkdir /nginx_conf
COPY nginx_conf/*.conf /nginx_conf/

COPY start.sh /usr/bin/

#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]
