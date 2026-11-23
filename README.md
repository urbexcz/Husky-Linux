# 🐺 Husky Linux

Vlastní deklarativní atomická distribuce založená na **Fedora 44 Kinoite (KDE Plasma 6)** a frameworku **BlueBuild**, optimalizovaná pro maximální stabilitu (*nainstaluj a zapomeň*):

* **Stabilní větev (Fedora 44 / GTS):** Připnuto na prověřenou Fedoru 44 (žádné nečekané noční přeskoky na čerstvě vydané verze, ale pravidelné denní bezpečnostní a ovladačové aktualizace).
* **Grafická karta:** NVIDIA GeForce RTX 4060 (Ada Lovelace) s otevřenými jadernými moduly (`nvidia-open`), multimediálními kodeky (`negativo17`) a vyladěným režimem spánku (`NVreg_PreserveVideoMemoryAllocations=1`).
* **Správa GPU a záznam obrazu nativně v OS (RPM):**
  * **LACT** (`lact` + `lactd.service`) – křivky ventilátorů, limity spotřeby, takty a monitoring nativně na Waylandu.
  * **GPU Screen Recorder** (`gpu-screen-recorder` + `gpu-screen-recorder-gtk` z Terra F44) – nativní RPM s oprávněním `cap_sys_admin` pro přímý KMS záznam bez dialogů a plný **AV1 NVENC** na RTX 4060.
  * `nvtop` – rychlý terminálový monitoring GPU.
* **Gaming:** Steam (Flatpak) s přesně sladěnými Flatpak Vulkan vrstvami **MangoHud** a **Gamescope** (`//26.08` + auto-sync v `blujust husky-setup`), hostitelský **GameMode**, `steam-devices`, **GOverlay** a **ProtonUp-Qt**.
* **Hardware & periferie (0 RGB konfliktů):**
  * **Corsair:** `ckb-next` + automaticky aktivovaná služba `ckb-next-daemon.service`.
  * **Razer (DeathAdder V2 Pro):** Jaderné moduly `kmod-openrazer` zkompilované přímo proti přesné verzi jádra a **podepsané vlastním MOK klíčem pro Secure Boot** + `openrazer-daemon` + grafické centrum **Polychromatic**.
* **Vývoj a kontejnery:** `distrobox`, `git`, `zsh`, `btop`, `fastfetch` + příkaz `blujust husky-dev`.
* **Multimédia:** **GNOME Network Displays** (nativní Fedora 44 RPM pro Miracast), VLC, Flatseal, Warehouse.

---

## 🏗️ Architektura systému

* **Základní OCI obraz:** `ghcr.io/blue-build/base-images/fedora-kinoite-nvidia-open:44`
* **Desktopové prostředí:** KDE Plasma 6 (Wayland)
* **Aktualizace:** Automatické na pozadí (`bootc-fetch-apply-updates.timer` + `flatpak-system-updates.timer`), ručně přes `sudo bootc upgrade` (nebo `rpm-ostree upgrade`) a `flatpak update`.
* **Podepisování:** Kontejner podepsán klíčem **Cosign** (`cosign.pub`); jaderné moduly podepsány klíči **BlueBuild MOK** (NVIDIA) a **Husky Linux MOK** (OpenRazer).

---

## 🛠️ Krok po první instalaci

Po prvním přihlášení do systému otevřete terminál a spusťte:

```bash
blujust husky-setup
```

Tento jediný příkaz automaticky:
1. Přidá váš účet do skupiny `plugdev` (oprávnění pro myš Razer / OpenRazer).
2. Propojí Steam (Flatpak) s konfigurací `~/.config/MangoHud` z programu **GOverlay**.
3. Automaticky ověří aktuální runtime Steamu a sladí k němu vrstvy **MangoHud** a **Gamescope**.
4. Aktivuje uživatelskou službu `openrazer-daemon.service`.

Poté se odhlaste a znovu přihlaste (nebo restartujte PC).

### Secure Boot (pokud jej máte zapnutý kvůli Windows 11 – funguje NVIDIA i OpenRazer)
Oba jaderné ovladače (**NVIDIA** i **OpenRazer**) jsou kryptograficky podepsané pro Secure Boot. Pro jejich jednorázové zapsání do UEFI spusťte jediný příkaz:

```bash
blujust husky-secureboot
```

Po restartu PC se zobrazí modrá obrazovka *MokManager*:
1. Zvolte **Enroll MOK** → **Continue** → **Yes**.
2. Zadejte heslo **`bluebuild`** *(stejné na české i anglické klávesnici – neobsahuje Y ani Z)*.
3. Zvolte **Reboot**.

### Další pomocné příkazy `blujust`
* **Přidání dalšího SSD do Steamu:** `blujust husky-steam-disk /cesta/k/disku` (nebo graficky ve Flatsealu).
* **Vývojový kontejner s NVIDIA akcelerací:** `blujust husky-dev`.
* **Miracast firewall (GNOME Network Displays):** `blujust husky-miracast-firewall`.
* **Ruční synchronizace Flatpaků po aktualizaci:** `bluebuild-flatpak-manager`.

---

## 💿 Generování instalačního ISO

1. Po úpravě `recipes/recipe.yml` vždy **nejprve vyčkejte na dokončení** akce `build-husky-linux` na GitHub Actions (zelená fajfka).
2. Teprve poté v záložce **Actions** spusťte workflow **build-husky-iso** (*Run workflow*, výchozí `fedora_version: 44`).
3. Hotový obraz `husky-linux-latest.iso` stáhnete v sekci **Artifacts** na stránce daného běhu.
