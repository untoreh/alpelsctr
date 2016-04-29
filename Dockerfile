FROM java:jre-alpine
#
RUN \
 apk --update --no-cache upgrade && apk add curl wget \
 && cd /tmp \
 && wget `curl -s https://api.github.com/repos/tianon/gosu/releases | grep browser_download_url | grep amd64 | head -n 1 | cut -d '"' -f 4` -O /usr/local/bin/gosu \
 && chmod +x /usr/local/bin/gosu \
 && ELSv=`curl -s https://api.github.com/repos/elastic/elasticsearch/tags | grep zipball_url | grep -v "-" | head -n 1 | cut -d '/' -f 8 | grep -ohE [0-9]+\.[0-9]+\.[0-9]+` \
 && wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/${ELSv}/elasticsearch-${ELSv}.zip -O els.zip \
 && unzip els.zip \
 && mv elasticsearch-${ELSv} /els \
 && rm els.zip 


VOLUME ["/srv/els/config","/srv/els/data","/srv/els/plugins","/srv/els/logs"]

RUN gosu nobody true \
 && chmod +s /usr/local/bin/gosu \
 && adduser elasticsearch -D
COPY entry.sh /

EXPOSE 9000 9200 9300
ENTRYPOINT ["/entry.sh"]
CMD ["/els/bin/elasticsearch"]
