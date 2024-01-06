# Docker for fastdfs-nginx

[fastdfs](https://github.com/happyfish100/fastdfs)

[![Build Status](https://github.com/ygqygq2/fastdfs-nginx/workflows/Publish%20Docker%20image/badge.svg)](https://github.com/ygqygq2/fastdfs-nginx/actions) ![Docker Stars](https://img.shields.io/docker/stars/ygqygq2/fastdfs-nginx.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/ygqygq2/fastdfs-nginx.svg)

## Supported tags and respective `Dockerfile` links

- [`latest` (*Dockerfile*)](https://github.com/ygqygq2/fastdfs-nginx/blob/master/Dockerfile) [![](https://images.microbadger.com/badges/image/ygqygq2/fastdfs-nginx.svg)](http://microbadger.com/images/ygqygq2/fastdfs-nginx "Get your own image badge on microbadger.com")

## Simplest docker run example

```
docker network create fastdfs-net
docker run -dit --network=fastdfs-net --name tracker -v /var/fdfs/tracker:/var/fdfs ygqygq2/fastdfs-nginx:latest tracker
docker run -dit --network=fastdfs-net --name storage0 -e TRACKER_SERVER=tracker:22122 -p18080:8080 -v /var/fdfs/storage0:/var/fdfs ygqygq2/fastdfs-nginx:latest storage
docker run -dit --network=fastdfs-net --name storage1 -e TRACKER_SERVER=tracker:22122 -p28080:8080 -v /var/fdfs/storage1:/var/fdfs ygqygq2/fastdfs-nginx:latest storage

# 进入 storage 0 测试
docker exec -it storage0 /bin/bash
date > /tmp/test.html
fdfs_upload_file /etc/fdfs/client.conf /tmp/test.html
# 出现类似 group1/M00/00/00/rBMAA2RJ5XaAby7aAAAAHZb6r-461.html
# 可以使用 curl 127.0.0.1:8080/group1/M00/00/00/rBMAA2RJ5XaAby7aAAAAHZb6r-461.html 访问

# 外部使用浏览器打开 127.0.0.1:18080/group1/M00/00/00/rBMAA2RJ5XaAby7aAAAAHZb6r-461.html 访问
```

## Env vars
```
|Env var name       |Effect                      |Default    |
|-------------------|----------------------------|-----------|
|PORT               |tracker/storage port        |22122/23000|
|GROUP_NAME         |group name                  |`group1`   |
|TRACKER_SERVER     |tracker server and port     |``         |
|GET_TRACKER_SERVER |get tracker server command  |``         |
|CUSTOM_CONFIG      |use your custom config file |`false`    |
```

## Use docker-compose

```
docker-compose up -d
```

# Fastdfs-nginx in kubernetes
```
helm repo add ygqygq2 https://ygqygq2.github.io/charts/
helm repo update
helm install f-n ygqygq2/fastdfs-nginx
```
