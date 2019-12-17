## Dockerfile
FROM centos:7

LABEL maintainer "29ygq@sina.com"

ENV FASTDFS_PATH=/opt/fdfs \
  FASTDFS_BASE_PATH=/var/fdfs \
  LIBFASTCOMMON_VERSION=V1.0.42 \
  FASTDFS_NGINX_MODULE_VERSION=V1.22 \
  FASTDFS_VERSION=V6.04 \
  NGINX_VERSION="1.17.3" \
  TENGINE_VERSION="2.3.2" \
  PORT= \
  GROUP_NAME= \
  TRACKER_SERVER=

#get all the dependences and nginx
RUN yum install -y git gcc make wget pcre pcre-devel openssl openssl-devel \
  && rm -rf /var/cache/yum/*

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
  && mkdir -p ${FASTDFS_PATH}/fastdfs \
  && mkdir -p ${FASTDFS_PATH}/fastdfs-nginx-module \
  && mkdir ${FASTDFS_BASE_PATH} \
  && mkdir /nginx_conf && mkdir -p /usr/local/nginx/conf/conf.d

WORKDIR ${FASTDFS_PATH}

## compile the libfastcommon
RUN git clone -b $LIBFASTCOMMON_VERSION https://github.com/happyfish100/libfastcommon.git libfastcommon \
  && cd libfastcommon \
  && ./make.sh \
  && ./make.sh install \
  && rm -rf ${FASTDFS_PATH}/libfastcommon

## compile the fastdfs
RUN git clone -b $FASTDFS_VERSION https://github.com/happyfish100/fastdfs.git fastdfs \
  && cd fastdfs \
  && ./make.sh \
  && ./make.sh install \
  && rm -rf ${FASTDFS_PATH}/fastdfs

## comile nginx
# nginx url: https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
# tengine url: http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz
RUN git clone -b $FASTDFS_NGINX_MODULE_VERSION https://github.com/happyfish100/fastdfs-nginx-module.git fastdfs-nginx-module \
  && wget http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz \
  && tar -zxf tengine-${TENGINE_VERSION}.tar.gz \
  && cd tengine-${TENGINE_VERSION} \
  && ./configure --prefix=/usr/local/nginx --add-module=${FASTDFS_PATH}/fastdfs-nginx-module/src/ \
  && make \
  && make install \
  && ln -s /usr/local/nginx/sbin/nginx /usr/bin/ \
  && rm -rf ${FASTDFS_PATH}/fastdfs-nginx-module 

EXPOSE 22122 23000 8080 8888 80
VOLUME ["$FASTDFS_BASE_PATH","/etc/fdfs","/usr/local/nginx/conf/conf.d"]   

COPY conf/*.* /etc/fdfs/
COPY nginx_conf/ /nginx_conf/
COPY nginx_conf/nginx.conf /usr/local/nginx/conf/

COPY start.sh /usr/bin/

#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh

WORKDIR ${FASTDFS_PATH}

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]
