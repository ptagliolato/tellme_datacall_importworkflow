FROM geographica/gdal2:2.4.1
ENV LANG C.UTF-8

MAINTAINER ptagliolato

RUN apt-get update \
     && apt-get install -y tree
COPY ./scripts /usr/src/app/
WORKDIR /usr/src/app

CMD ["/bin/bash"]
