FROM alpine:3.20

LABEL maintainer="Workstation AI <ignacio@workstation.center>"
LABEL description="Workstation Center OS — branded desktop with Firefox, fluxbox, noVNC, HTTPS redirect"

ENV DISPLAY=:99

# ── System packages + Firefox ESR + nginx ──────────────────────────────
RUN apk update && apk add --no-cache \
    xvfb x11vnc websockify fluxbox supervisor nginx \
    firefox-esr font-dejavu xterm \
    xprintidle xdotool \
    bash curl git

# ── noVNC web client ───────────────────────────────────────────────────
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify.git /usr/share/novnc/utils/websockify && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ── Branding assets ────────────────────────────────────────────────────
RUN mkdir -p /usr/share/workstation/branding && \
    curl -fsSL https://workstation.center/logo.png \
      -o /usr/share/workstation/branding/logo.png

# ── Nginx config: HTTP→HTTPS redirect + WebSocket proxy ────────────────
COPY nginx/workstation.conf /etc/nginx/http.d/default.conf

# ── Desktop user ───────────────────────────────────────────────────────
RUN adduser -D -s /bin/bash desktop && \
    mkdir -p /home/desktop/.vnc /home/desktop/.workstation /home/desktop/.fluxbox /home/desktop/Desktop && \
    chown -R desktop:desktop /home/desktop

# ── Fluxbox config ─────────────────────────────────────────────────────
RUN cat > /home/desktop/.fluxbox/init << 'FBINIT'
session.screen0.tabs.usePixmap: false
session.screen0.toolbar.visible: true
session.screen0.toolbar.widthPercent: 100
FBINIT

RUN cat > /home/desktop/.fluxbox/menu << 'FBMENU'
[begin] (Workstation Center OS)
  [submenu] (Applications)
    [exec] (Firefox) {firefox-esr} <>
    [exec] (Terminal) {xterm} <>
  [end]
  [restart] (Restart)
  [exit] (Exit)
[end]
FBMENU

RUN chown -R desktop:desktop /home/desktop/.fluxbox

# ── Supervisor config ──────────────────────────────────────────────────
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ── Inactivity monitor ──────────────────────────────────────────────────
COPY inactivity-monitor.sh /usr/local/bin/inactivity-monitor.sh
RUN chmod +x /usr/local/bin/inactivity-monitor.sh

# ── Entrypoint ─────────────────────────────────────────────────────────
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5900 6080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
