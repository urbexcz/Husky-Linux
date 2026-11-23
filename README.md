# 🐺 Husky Linux

Vlastní deklarativní atomická distribuce založená na **Fedora 44 Kinoite (KDE Plasma 6)** a frameworku **BlueBuild**, optimalizovaná pro maximální stabilitu (*nainstaluj a zapomeň*):

* **Stabilní větev (Fedora 44 / GTS):** Připnuto na prověřenou Fedoru 44 (žádné nečekané noční přeskoky na čerstvě vydané verze, ale pravidelné denní bezpečnostní a ovladačové aktualizace).
* **Grafická karta:** NVIDIA GeForce RTX 4060 (Ada Lovelace) s otevřenými jadernými moduly (`nvidia-open`), multimediálními kodeky a vyladěným režimem spánku (`NVreg_PreserveVideoMemoryAllocations=1`).
* **Správa GPU na Waylandu:** **LACT** (moderní náhrada za ukončené GreenWithEnvy – křivky ventilátorů, limity napájení, takty, teploty nativně na Waylandu) + `nvtop` + **GPU Screen Recorder** (NVENC).
* **Gaming:** Steam (Flatpak) s odpovídajícími Flatpak Vulkan vrstvami **MangoHud** a **Gamescope** (`//26.08`), hostitelský **GameMode**, `steam-devices`, **GOverlay** a **ProtonUp-Qt**.
* **Hardware & periferie:**
  * **Corsair:** `ckb-next` + automaticky aktivovaná služba `ckb-next-daemon.service`.
  * **Razer (DeathAdder V2 Pro):** Jaderné moduly `kmod-openrazer` zkompilované přímo proti přesné verzi jádra + `openrazer-daemon` + grafické centrum **Polychromatic**.
  * **Univerzální RGB:** **OpenRGB** + systémová `openrgb-udev-rules` (v základu obrazu).
* **Vývoj a kontejnery:** `distrobox`, `git`, `zsh`, `btop`, `fastfetch`.
* **Multimédia:** VLC, GNOME Network Displays (Miracast), Flatseal, Warehouse.

---

## 🏗️ Architektura systému

* **Základní OCI obraz:** `ghcr.io/blue-build/base-images/fedora-kinoite-nvidia-open:44`
* **Desktopové prostředí:** KDE Plasma 6 (Wayland)
* **Aktualizace:** Automatické na pozadí (`bootc-fetch-apply-updates.timer` + `flatpak-system-updates.timer`), ručně přes `sudo bootc upgrade` (nebo `rpm-ostree upgrade`) a `flatpak update`.
* **Podepisování:** Každý obraz je kryptograficky podepsán klíčem **Cosign** (`cosign.pub`).

---

## 🛠️ Krok po první instalaci (jediný příkaz)

Po prvním přihlášení do systému otevřete terminál a spusťte připravený pomocný příkaz:

```bash
blujust husky-setup
```

Tento jediný příkaz automaticky:
1. Přidá váš účet do skupiny `plugdev` (oprávnění pro myš Razer / OpenRazer) a `i2c` (OpenRGB).
2. Propojí Steam (Flatpak) s konfigurací `~/.config/MangoHud` z programu **GOverlay**.
3. Spustí uživatelskou službu `openrazer-daemon.service`.

Poté se odhlaste a znovu přihlaste (nebo restartujte PC).

### Poznámka k Secure Bootu (pokud jej máte zapnutý kvůli Windows 11)
* Pro zavedení podepsaného ovladače **NVIDIA** spusťte jednou `blujust enroll-secure-boot-key` a po restartu v modrém menu *MokManager* zadejte heslo **`bluebuild`**.
* **Upozornění k OpenRazeru:** Lokálně zkompilovaný jaderný modul `kmod-openrazer` není podepsaný klíčem BlueBuild. Se **vypnutým Secure Bootem** funguje vše ihned bez omezení; se zapnutým Secure Bootem jádro nepodepsaný modul OpenRazeru odmítne zavést (myš funguje jako standardní USB HID, ale Polychromatic ji neuvidí).

### Další volitelné příkazy
* **Miracast (GNOME Network Displays):** Pokud používáte bezdrátové zrcadlení na TV přes Wi-Fi Direct, povolte jednorázově porty ve firewallu:
  ```bash
  blujust husky-miracast-firewall
  ```
* **Další disky pro Steam:** Otevřete aplikaci **Flatseal** → **Steam** → **Filesystem** a přidejte cestu k vašemu hernímu SSD.
* **Kdyby se po aktualizaci nenačetl nový Flatpak:** Spusťte `bluebuild-flatpak-manager` (systém nově zobrazuje desktopová oznámení při automatické instalaci Flatpaků).

---

## 💿 Generování instalačního ISO

1. Po úpravě `recipes/recipe.yml` vždy **nejprve vyčkejte na dokončení** akce `build-husky-linux` na GitHub Actions (zelená fajfka).
2. Teprve poté v záložce **Actions** spusťte workflow **build-husky-iso** (*Run workflow*, výchozí `fedora_version: 44`).
3. Hotový obraz `husky-linux-latest.iso` stáhnete v sekci **Artifacts** na stránce daného běhu.
