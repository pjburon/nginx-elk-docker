FROM nginx

EXPOSE 80
EXPOSE 443

# Do this apt/pip stuff all in one RUN command to avoid creating large
# intermediate layers on non-squashable docker installs
RUN apt update && \
    apt install -y python python-dev libffi6 libffi-dev libssl-dev curl build-essential apache2-utils && \
    curl -L 'https://bootstrap.pypa.io/get-pip.py' | python && \
    pip install -U cffi certbot && \
    apt remove --purge -y python-dev build-essential libffi-dev libssl-dev curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy in scripts for certbot
COPY ./scripts/ /scripts
RUN chmod +x /scripts/*.sh

RUN mkdir /etc/nginx/stream.d/
COPY ./stream.d/ /etc/nginx/stream.d/
COPY ./conf.d/ /etc/nginx/conf.d/
COPY *.conf /etc/nginx/

ENTRYPOINT []
CMD ["/bin/bash", "/scripts/entrypoint.sh"]
