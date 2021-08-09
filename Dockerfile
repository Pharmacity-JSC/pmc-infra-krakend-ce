FROM alpine:3.14.0

LABEL maintainer="phat.dangthanh@pharmacity.vn"

RUN apk update && apk add --no-cache \
	  curl \
    &&  rm -rf /var/cache/apk/*

ADD krakend /usr/bin/krakend

VOLUME [ "/etc/krakend" ]

WORKDIR /etc/krakend

ENTRYPOINT [ "/usr/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend/krakend.json" ]

EXPOSE 8000 8090