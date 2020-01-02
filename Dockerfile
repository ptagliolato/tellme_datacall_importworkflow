FROM geographica/gdal2:2.4.1
ENV LANG C.UTF-8

MAINTAINER ptagliolato

RUN apt-get update \
     && apt-get install -y tree
COPY ./scripts /usr/src/app/
RUN chmod +x /usr/src/app *.sh
WORKDIR /usr/src/app

CMD ["/bin/bash"]
