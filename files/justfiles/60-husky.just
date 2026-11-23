# Dokončení uživatelského nastavení Husky Linuxu (Razer plugdev, OpenRGB i2c, MangoHud pro Steam)
husky-setup:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Husky Linux: Dokončení uživatelského nastavení ==="
    if ! grep -q "^plugdev:" /etc/group && grep -q "^plugdev:" /usr/lib/group; then
        sudo bash -c 'grep "^plugdev:" /usr/lib/group >> /etc/group'
    fi
    if grep -q "^plugdev:" /etc/group; then
        sudo usermod -aG plugdev "$USER"
        echo "[OK] Uživatel $USER přidán do skupiny plugdev (OpenRazer / Razer)."
    fi
    if ! grep -q "^i2c:" /etc/group && grep -q "^i2c:" /usr/lib/group; then
        sudo bash -c 'grep "^i2c:" /usr/lib/group >> /etc/group'
    fi
    if grep -q "^i2c:" /etc/group; then
        sudo usermod -aG i2c "$USER"
        echo "[OK] Uživatel $USER přidán do skupiny i2c (OpenRGB)."
    fi
    mkdir -p "$HOME/.config/MangoHud"
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam
    echo "[OK] Steam (Flatpak) propojen s konfigurací MangoHud / GOverlay."
    systemctl --user enable --now openrazer-daemon.service || true
    echo "[OK] Služba openrazer-daemon aktivována."
    echo ""
    echo "Hotovo! Odhlaste se a znovu přihlaste (nebo restartujte PC), aby se projevily nové skupiny."

# Povolení portů ve firewallu pro bezdrátové zrcadlení na TV (Miracast / GNOME Network Displays)
husky-miracast-firewall:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Povolení portů Miracast (7236 TCP/UDP) ve firewalld ==="
    sudo firewall-cmd --permanent --add-port=7236/tcp
    sudo firewall-cmd --permanent --add-port=7236/udp
    sudo firewall-cmd --reload
    echo "[OK] Porty pro Miracast povoleny."
