# https://github.com/elastic/logstash-docker
FROM docker.elastic.co/logstash/logstash-oss:6.2.4

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json

RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install logstash-input-tcp
RUN logstash-plugin install logstash-input-udp

EXPOSE 5000
