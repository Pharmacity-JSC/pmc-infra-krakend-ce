FROM alpine:3.14.0

LABEL maintainer="phat.dangthanh@pharmacity.vn"
ENV GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
ENV GLIBC_VERSION=2.30-r0

RUN set -ex && \
    apk --update add --no-cache libstdc++ curl ca-certificates openssl openjdk11 && \
    mkdir /data && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION}; \
        do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    &&  rm -rf /var/cache/apk/*

WORKDIR /etc/krakend

ADD krakend /usr/bin/krakend
ADD key-bank /data

RUN openssl pkcs12 -export -in client.cer -inkey scb-apibanking-client-cert-private-key.pem -out scb-apibanking.keystore.p12 -name pharmacity -password pass:hkcG2xZcheLTs1v9
RUN keytool -importkeystore -deststorepass hkcG2xZcheLTs1v9 -destkeypass hkcG2xZcheLTs1v9 -destkeystore scb-api-banking.jks -srckeystore scb-apibanking.keystore.p12 -srcstoretype PKCS12 -srcstorepass hkcG2xZcheLTs1v9 -alias pharmacity
RUN keytool -list -keystore scb-api-banking.jks -storepass hkcG2xZcheLTs1v9

VOLUME [ "/etc/krakend" ]

ENTRYPOINT [ "/usr/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend/krakend.json" ]

EXPOSE 8000 8090 9091