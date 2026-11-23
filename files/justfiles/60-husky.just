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

# Zaevidování MOK klíčů pro Secure Boot (NVIDIA + OpenRazer najednou) - heslo v MokManageru: bluebuild
husky-secureboot:
    #!/usr/bin/bash
    set -euo pipefail
    ENROLLMENT_PASSWORD="bluebuild"
    BLUEBUILD_KEY="/etc/pki/akmods/certs/akmods-blue-build.der"
    HUSKY_KEY="/etc/pki/akmods/certs/husky-mok.der"
    echo "=== Husky Linux: Příprava MOK klíčů pro Secure Boot (NVIDIA + OpenRazer) ==="
    sudo mokutil --timeout -1
    printf '%s\n%s\n' "${ENROLLMENT_PASSWORD}" "${ENROLLMENT_PASSWORD}" | sudo mokutil --import "${BLUEBUILD_KEY}" "${HUSKY_KEY}"
    echo ""
    echo "[OK] Oba certifikáty (BlueBuild NVIDIA + Husky Linux OpenRazer) jsou připraveny k zápisu."
    echo "Po restartu PC se zobrazí modrá obrazovka MokManager:"
    echo "  1. Zvolte 'Enroll MOK' -> 'Continue' -> 'Yes'"
    echo "  2. Zadejte heslo: bluebuild"
    echo "  3. Zvolte 'Reboot'"

# Povolení portů ve firewallu pro bezdrátové zrcadlení na TV (Miracast / GNOME Network Displays)
husky-miracast-firewall:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Povolení portů Miracast (7236 TCP/UDP) ve firewalld ==="
    sudo firewall-cmd --permanent --add-port=7236/tcp
    sudo firewall-cmd --permanent --add-port=7236/udp
    sudo firewall-cmd --reload
    echo "[OK] Porty pro Miracast povoleny."
