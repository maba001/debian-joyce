FROM debian:bookworm as builder

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl libreadline8 libreadline8 readline-common \
 && apt-get install -y build-essential libpng-dev libxml2-dev \
 && apt-get install -y libsdl1.2-dev libsdl1.2debian \
 && apt-get clean

WORKDIR /tmp
# RUN curl -s -o joyce.tar.gz https://www.seasip.info/Unix/Joyce/joyce-2.4.2.tar.gz
RUN curl -s -o joyce.tar.gz https://www.seasip.info/Unix/Joyce/joyce-2.5.2.tar.gz
RUN tar xzf joyce.tar.gz

RUN mkdir -p /opt/joyce \
 && cd /tmp/joyce* \
 && pwd \
 && ./configure --prefix=/opt/joyce \
 && make \
 && make check

RUN cd /tmp/joyce* \
 && make install

FROM debian:bookworm-slim

COPY --from=builder /opt/joyce /opt/joyce

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y telnet \
 && apt-get install -y libsdl1.2debian libxml2 \
 && apt-get install -y tigervnc-standalone-server xfonts-base xterm x11-apps \
 && apt-get install -y procps dbus-x11 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


COPY /src/root/ /root/
COPY /src/etc/profile /etc/
COPY /src/etc/tigervnc /etc/tigervnc/
COPY /src/etc/bash.bashrc /etc/
COPY /src/usr/ /usr/

RUN mkdir -p /opt/floppies \
 && mkdir -p /opt/external-mount
COPY /src/opt/floppies/ /opt/floppies/

ENV SHELL=/bin/bash
ENV USER=root
ENV DISPLAY=:1

WORKDIR /root
RUN chmod 600 /root/.vnc/passwd

CMD [ "/usr/local/bin/startup" ]
