FROM alpine:latest

# Instalaciones necesarias
RUN apk add --no-cache \
  bash \
  python3 \
  py3-pip \
  supervisor \
  fluxbox \
  xvfb \
  tigervnc \
  wget \
  curl \
  git \
  nodejs \
  npm \
  chromium \
  chromium-chromedriver \
  ttf-freefont \
  && python3 -m ensurepip \
  && pip3 install --no-cache-dir websockify

# Crear usuario no-root
RUN adduser -D chrome
USER chrome
WORKDIR /home/chrome

# Instalar noVNC
RUN mkdir -p /opt/novnc && \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.tar.gz | tar xz --strip 1 -C /opt/novnc && \
    ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# Crear xstartup para VNC
RUN mkdir -p /home/chrome/.vnc && \
    echo '#!/bin/sh\nxrdb $HOME/.Xresources\nstartfluxbox &' > /home/chrome/.vnc/xstartup && \
    chmod +x /home/chrome/.vnc/xstartup

# Supervisord y configuración
USER root
COPY supervisord.conf /etc/supervisord.conf
COPY local.conf /etc/supervisord.d/local.conf

# Exponer puertos VNC y websockify
EXPOSE 5900 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
