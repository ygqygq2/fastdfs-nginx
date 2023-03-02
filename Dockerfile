## Dockerfile
FROM centos:7

LABEL maintainer "29ygq@sina.com"

ENV FASTDFS_PATH=/opt/fdfs \
  FASTDFS_BASE_PATH=/var/fdfs \
  LIBFASTCOMMON_VERSION="V1.0.66" \
  LIBSERVERFRAME_VERSION="V1.1.25" \
  FASTDFS_NGINX_MODULE_VERSION="V1.23" \
  FASTDFS_VERSION="V6.9.4" \
  NGINX_VERSION="1.23.3" \
  TENGINE_VERSION="2.3.3" \
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

## compile the libserverframe
RUN git clone -b $LIBSERVERFRAME_VERSION https://github.com/happyfish100/libserverframe.git libserverframe \
  && cd libserverframe \
  && ./make.sh \
  && ./make.sh install \
  && rm -rf ${FASTDFS_PATH}/libserverframe

## compile the fastdfs
RUN git clone -b $FASTDFS_VERSION https://github.com/happyfish100/fastdfs.git fastdfs \
  && cd fastdfs \
  && ./make.sh \
  && ./make.sh install \
  && rm -rf ${FASTDFS_PATH}/fastdfs

## comile nginx
# nginx url: https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
# tengine url: http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz
# RUN git clone -b $FASTDFS_NGINX_MODULE_VERSION https://github.com/happyfish100/fastdfs-nginx-module.git fastdfs-nginx-module \
#   && wget http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz \
#   && tar -zxf tengine-${NGINX_VERSION}.tar.gz \
#   && cd tengine-${TENGINE_VERSION} \
#   && ./configure --prefix=/usr/local/nginx \
#       --add-module=${FASTDFS_PATH}/fastdfs-nginx-module/src/ \
#       --add-module=./modules/ngx_http_upstream_dynamic_module \
#       --add-module=./modules/ngx_http_upstream_check_module \
#   && make \
#   && make install \
#   && ln -s /usr/local/nginx/sbin/nginx /usr/bin/ \
#   && rm -rf ${FASTDFS_PATH}/tengine-* \
#   && rm -rf ${FASTDFS_PATH}/fastdfs-nginx-module 

RUN git clone -b $FASTDFS_NGINX_MODULE_VERSION https://github.com/happyfish100/fastdfs-nginx-module.git fastdfs-nginx-module \
  && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar -zxf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION} \
  && ./configure --prefix=/usr/local/nginx \
      --add-module=${FASTDFS_PATH}/fastdfs-nginx-module/src/ \
      --with-stream=dynamic \
  && make \
  && make install \
  && ln -s /usr/local/nginx/sbin/nginx /usr/bin/ \
  && rm -rf ${FASTDFS_PATH}/nginx-* \
  && rm -rf ${FASTDFS_PATH}/fastdfs-nginx-module

EXPOSE 22122 23000 8080 8888 80
VOLUME ["$FASTDFS_BASE_PATH","/etc/fdfs","/usr/local/nginx/conf/conf.d"]   

COPY conf/*.* /etc/fdfs/
COPY nginx_conf/ /nginx_conf/
COPY nginx_conf/nginx.conf /usr/local/nginx/conf/

COPY entrypoint.sh /usr/bin/

#make the entrypoint.sh executable 
RUN chmod a+x /usr/bin/entrypoint.sh

WORKDIR ${FASTDFS_PATH}

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["tracker"]
