FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb x11vnc websockify fluxbox \
    x11-xserver-utils x11-utils \
    dbus-x11 procps \
    git curl \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify.git /usr/share/novnc/utils/websockify

# Create user
RUN useradd -m -s /bin/bash user && \
    mkdir -p /home/user/.vnc /home/user/.workstation && \
    chown -R user:user /home/user

# Default VNC password
RUN echo "bux2026" | x11vnc -storepasswd /home/user/.vnc/passwd && \
    chown user:user /home/user/.vnc/passwd && \
    chmod 600 /home/user/.vnc/passwd

# Startup script
COPY src/start.sh /home/user/.workstation/start.sh
RUN chmod +x /home/user/.workstation/start.sh && chown user:user /home/user/.workstation/start.sh

USER user
WORKDIR /home/user

EXPOSE 5900 6080

CMD ["/home/user/.workstation/start.sh"]
