FROM linuxkit/alpine:ace75d0ec6978762d445083d6c8c6336bdb658ed AS build

RUN cat /etc/apk/repositories.upstream >> /etc/apk/repositories \
  && apk update \
  && apk add --update libevent-dev bison \
build-base \
zlib-dev \
fts-dev \
curl \
libressl-dev \
libressl \
libtool \
autoconf automake bison

RUN mkdir /build && cd /build && curl -LO https://github.com/OpenSMTPD/libasr/archive/master.tar.gz && tar xf master.tar.gz && cd libasr-master && ./bootstrap && ./configure && make && make install
RUN mkdir -p /build/opensmtpd && cd /build && curl -LO  http://www.opensmtpd.org/archives/opensmtpd-portable-latest.tar.gz && tar xf opensmtpd-portable-latest.tar.gz -C opensmtpd --strip-components=1 && cd opensmtpd && ./configure && make && make install

FROM scratch
COPY --from=build /usr/local/lib/libasr.so.0.0.3 /usr/lib/
COPY --from=build /usr/local/sbin/smtpctl /usr/sbin/
COPY --from=build /usr/local/sbin/smtpd /usr/sbin/

