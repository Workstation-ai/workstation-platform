FROM debian:bookworm-slim

LABEL maintainer="Workstation AI <ignacio@workstation.center>"
LABEL description="Workstation Center OS — branded desktop with Firefox, fluxbox, noVNC"

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# ── System packages + Firefox ESR ──────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb x11vnc websockify fluxbox supervisor \
    x11-xserver-utils x11-utils \
    dbus-x11 procps \
    firefox-esr fonts-dejavu-core fonts-liberation \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ── noVNC web client ───────────────────────────────────────────────────
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify.git /usr/share/novnc/utils/websockify && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ── Branding assets ────────────────────────────────────────────────────
# Logo from workstation.center
RUN mkdir -p /usr/share/workstation/branding && \
    curl -fsSL https://workstation.center/logo.png \
      -o /usr/share/workstation/branding/logo.png

# ── Desktop user ───────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash desktop && \
    mkdir -p /home/desktop/.vnc \
             /home/desktop/.workstation \
             /home/desktop/.fluxbox \
             /home/desktop/Desktop

# VNC password (overridden by env at runtime if set)
RUN echo "workstation" | x11vnc -storepasswd /home/desktop/.vnc/passwd && \
    chown -R desktop:desktop /home/desktop

# ── Fluxbox config: custom theme + wallpaper + title ───────────────────
RUN cat > /home/desktop/.fluxbox/init << 'FBINIT'
session.screen0.tabs.usePixmap: false
session.screen0.toolbar.visible: true
session.screen0.toolbar.widthPercent: 100
session.screen0.window.useTitlebar: true
session.screen0.window.defaultDepth: 24
FBINIT

# Right-click menu with useful apps
RUN cat > /home/desktop/.fluxbox/menu << 'FBMENU'
[begin] (Workstation Center OS)
  [submenu] (Applications)
    [exec] (Firefox) {firefox-esr} <>
    [exec] (Terminal) {xterm} <>
  [end]
  [submenu] (System)
    [exec] (Screen Resolution) {xterm -e "echo Set via xrandr"} <>
  [end]
  [restart] (Restart)
  [exit] (Exit)
[end]
FBMENU

RUN chown -R desktop:desktop /home/desktop/.fluxbox

# ── Supervisor config ──────────────────────────────────────────────────
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ── Entrypoint script (sets wallpaper + launches supervisord) ──────────
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5900 6080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
