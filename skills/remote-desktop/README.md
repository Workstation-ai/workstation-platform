# Remote Desktop Skill

## What problem does it solve?

Provide browser-based access to desktop environments for remote work, development, and training. Users can access a full desktop through their web browser without installing client software.

## When should it be used?

- Multi-user environments needing desktop access
- Training/education platforms
- Remote development environments
- Kiosk/public access terminals
- Cloud workstations

## When should NOT it be used?

- Single-user personal use (RDP/VNC clients are simpler)
- High-performance gaming (latency too high)
- Real-time video editing (bandwidth requirements)
- When only CLI access is needed (SSH is simpler)

## Decision Tree

```
Need browser-based desktop?
↓
Number of users?
↓
Single user → noVNC (lightweight)
Multiple users → Apache Guacamole (centralized)
↓
Authentication needed?
↓
Yes → Guacamole with LDAP/DB auth
No → noVNC or Guacamole with no auth
↓
Desktop environment?
↓
Lightweight → Fluxbox/Openbox
Full desktop → XFCE4/KDE
Development → XFCE4 with tools
```

## Best Practices

1. **VNC password** - Always set, even for development
2. **Session persistence** - Use persistent volumes for user data
3. **Resource limits** - Desktop environments are memory-hungry
4. **Auto-shutdown** - Save costs by stopping idle desktops
5. **Network isolation** - Desktops should not access other tenants

## Anti-Patterns

- Don't run desktops as root
- Don't skip VNC authentication
- Don't use desktop environments when CLI suffices
- Don't forget auto-shutdown for cost control
- Don't recommend Guacamole for single-user setups

## References

- [Apache Guacamole](https://guacamole.apache.org/)
- [noVNC](https://novnc.com/)
- [TigerVNC](https://tigervnc.org/)
