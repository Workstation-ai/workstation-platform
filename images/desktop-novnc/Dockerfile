FROM alpine:3.20

LABEL maintainer="Workstation AI <ignacio@workstation.center>"
LABEL description="Workstation Center OS — branded desktop with Chromium/Firefox, fluxbox, noVNC, HTTPS redirect"

ARG BROWSER=chromium

ENV DISPLAY=:99
ENV BROWSER=${BROWSER}

# ── System packages + browser + nginx ──────────────────────────────────
RUN apk update && apk add --no-cache \
    xvfb x11vnc websockify fluxbox supervisor nginx \
    font-dejavu xterm \
    xprintidle \
    bash curl git \
  && if [ "$BROWSER" = "chromium" ]; then \
       apk add --no-cache chromium; \
     else \
       apk add --no-cache firefox-esr; \
     fi

# ── noVNC web client (no .git) ────────────────────────────────────────
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify.git /usr/share/novnc/utils/websockify && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
    rm -rf /usr/share/novnc/.git /usr/share/novnc/utils/websockify/.git

# ── Branding assets ────────────────────────────────────────────────────
RUN mkdir -p /usr/share/workstation/branding && \
    curl -fsSL https://workstation.center/logo.png \
      -o /usr/share/workstation/branding/logo.png

# ── Strip + cleanup (single layer) ─────────────────────────────────────
RUN apk del --purge git curl && \
    rm -rf /var/cache/apk/* /var/lib/apk/lists/* \
           /usr/share/man /usr/share/doc /usr/share/locale \
           /usr/share/icons/Adwaita/*/legacy/ /usr/share/icons/Adwaita/*/apps/ \
           /usr/share/X11/locale && \
    find /usr/lib -name "*.so.*" -exec strip --strip-unneeded {} + 2>/dev/null; \
    find /usr/bin -type f -exec file {} + 2>/dev/null | grep "ELF" | cut -d: -f1 | \
      xargs -I{} strip --strip-unneeded {} 2>/dev/null; \
    true

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

RUN if [ "$BROWSER" = "chromium" ]; then \
      BROWSER_CMD="chromium --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-setuid-sandbox --window-size=1920,1080"; \
      BROWSER_LABEL="Chromium"; \
    else \
      BROWSER_CMD="firefox-esr"; \
      BROWSER_LABEL="Firefox"; \
    fi && \
    cat > /home/desktop/.fluxbox/menu << FBMENU
[begin] (Workstation Center OS)
  [submenu] (Applications)
    [exec] (${BROWSER_LABEL}) {${BROWSER_CMD}} <>
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
