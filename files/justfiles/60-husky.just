# Dokončení uživatelského nastavení Husky Linuxu (Razer plugdev, MangoHud/Gamescope sync pro Steam)
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
    mkdir -p "$HOME/.config/MangoHud"
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam
    echo "[OK] Steam (Flatpak) propojen s konfigurací MangoHud / GOverlay."
    if flatpak info com.valvesoftware.Steam >/dev/null 2>&1; then
        STEAM_RT="$(flatpak info --show-runtime com.valvesoftware.Steam | awk -F'/' '{print $NF}')"
        if [[ -n "${STEAM_RT}" ]]; then
            echo "[INFO] Detekovaný runtime Steamu: ${STEAM_RT} – ověřuji MangoHud a Gamescope vrstvy..."
            flatpak install --system -y --noninteractive flathub \
                "org.freedesktop.Platform.VulkanLayer.MangoHud//${STEAM_RT}" \
                "org.freedesktop.Platform.VulkanLayer.gamescope//${STEAM_RT}" || true
        fi
    fi
    systemctl --user enable --now openrazer-daemon.service || true
    echo "[OK] Služba openrazer-daemon aktivována."
    echo ""
    echo "Hotovo! Odhlaste se a znovu přihlaste (nebo restartujte PC), aby se projevila skupina plugdev."

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

# Povolení přístupu k dalšímu SSD/HDD disku pro Steam (příklad: blujust husky-steam-disk /mnt/games)
husky-steam-disk PATH:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ ! -d "{{ PATH }}" ]]; then
        echo "CHYBA: Adresář '{{ PATH }}' neexistuje."
        exit 1
    fi
    flatpak override --user --filesystem="{{ PATH }}" com.valvesoftware.Steam
    echo "[OK] Steam (Flatpak) má nyní přístup k adresáři: {{ PATH }}"

# Vytvoření vývojového Distrobox kontejneru s akcelerací NVIDIA GPU (volitelně přepne výchozí shell na zsh)
husky-dev:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Vytvářím vývojový Distrobox kontejner 'dev' s podporou NVIDIA GPU ==="
    distrobox create --name dev --image registry.fedoraproject.org/fedora-toolbox:44 --nvidia --yes
    echo "[OK] Kontejner připraven. Vstoupíte do něj příkazem: distrobox enter dev"
    if command -v zsh >/dev/null 2>&1 && [[ "${SHELL}" != *"zsh" ]]; then
        echo "[TIP] Pokud chcete přepnout výchozí shell na zsh, spusťte: chsh -s $(command -v zsh)"
    fi

# Povolení portů ve firewallu pro bezdrátové zrcadlení na TV (Miracast / GNOME Network Displays)
husky-miracast-firewall:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Povolení portů Miracast (7236 TCP/UDP) ve firewalld ==="
    sudo firewall-cmd --permanent --add-port=7236/tcp
    sudo firewall-cmd --permanent --add-port=7236/udp
    sudo firewall-cmd --reload
    echo "[OK] Porty pro Miracast povoleny."
