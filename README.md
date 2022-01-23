# Docker for fastdfs-nginx

[fastdfs](https://github.com/happyfish100/fastdfs)

[![Build Status](https://github.com/ygqygq2/fastdfs-nginx/workflows/Publish%20Docker%20image/badge.svg)](https://github.com/ygqygq2/fastdfs-nginx/actions) ![Docker Stars](https://img.shields.io/docker/stars/ygqygq2/fastdfs-nginx.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/ygqygq2/fastdfs-nginx.svg)

# Supported tags and respective `Dockerfile` links

- [`latest` (*Dockerfile*)](https://github.com/ygqygq2/fastdfs-nginx/blob/master/Dockerfile) [![](https://images.microbadger.com/badges/image/ygqygq2/fastdfs-nginx.svg)](http://microbadger.com/images/ygqygq2/fastdfs-nginx "Get your own image badge on microbadger.com")

## Simplest docker run example

```
docker network create fastdfs-net
docker run -dit --network=fastdfs-net --name tracker -v /var/fdfs/tracker:/var/fdfs ygqygq2/fastdfs-nginx:latest tracker
docker run -dit --network=fastdfs-net --name storage0 -e TRACKER_SERVER=tracker:22122 -v /var/fdfs/storage0:/var/fdfs ygqygq2/fastdfs-nginx:latest storage
docker run -dit --network=fastdfs-net --name storage1 -e TRACKER_SERVER=tracker:22122 -v /var/fdfs/storage1:/var/fdfs ygqygq2/fastdfs-nginx:latest storage
```

