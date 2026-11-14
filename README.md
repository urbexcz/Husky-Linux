# 🐺 Husky Linux

Vlastní deklarativní atomická distribuce založená na **Fedora Kinoite (KDE Plasma)** a frameworku **BlueBuild**, optimalizovaná pro:
* **Grafickou kartu:** NVIDIA GeForce RTX 4060 (architektura Ada Lovelace) s moderními otevřenými moduly jádra (`nvidia-open`).
* **Denní použití (Daily Driver):** Stabilní systém typu *„nainstaluj a zapomeň“* – root souborového systému je pouze pro čtení (read-only, immutable).
* **Gaming:** Steam, MangoHud, Goverlay, ProtonUp-Qt.
* **Hardware & periferie:** Ovladače pro Corsair (`ckb-next`), Razer (`openrazer` + `polychromatic`), univerzální RGB (`OpenRGB`).
* **NVIDIA Suite:** Monitorování a správa ventilátorů (`GreenWithEnvy`), hardwarový záznam her s NVENC (`GPU Screen Recorder` – náhrada za NVIDIA ShadowPlay).
* **Multimédia & TV:** Zrcadlení obrazu na TV přes **Sunshine** (NVENC streamování do aplikace Moonlight na TV) i **Gnome Network Displays** (Miracast).
* **Vývoj (Vibe coding):** Distrobox & Podman pro čistá vývojová prostředí (např. Antigravity IDE) bez zásahu do hostitelského systému.

---

## 🏗️ Architektura systému

* **Základní OCI obraz:** `ghcr.io/blue-build/base-images/fedora-kinoite-nvidia-open:latest`
* **Desktopové prostředí:** KDE Plasma 6 (Wayland s nativní podporou NVIDIA Explicit Sync)
* **Balíčkovací strategie:**
  * **Základ OS (RPM-ostree / Akmods):** Pouze hardware ovladače, daemony a systémové utility (`ckb-next`, `openrazer`, `sunshine`, `distrobox`, `nvtop`, `btop`).
  * **Aplikace (Flatpak / Flathub):** Veškeré uživatelské programy a herní stack (Steam, VLC, Flatseal, GWE) běží v izolovaných kontejnerech. Díky tomu zůstává jádro distribuce 100% čisté a nezpomaluje se 32bitovými knihovnami.

---

## 🚀 Jak poprvé zprovoznit repozitář na GitHubu

### 1. Vytvoření repozitáře na GitHubu
1. Otevřete [github.com/new](https://github.com/new).
2. Pojmenujte repozitář: `Husky-Linux`.
3. Nastavte jej jako **Public** (aby GitHub Actions mohl publikovat kontejner do GitHub Container Registry).
4. **Nezaklikávejte** „Add a README file“ ani šablony (repozitář nechte prázdný).
5. Klikněte na **Create repository**.

### 2. Odeslání (Push) souborů z vašeho PC
V terminálu (PowerShell) v této složce spusťte:
```powershell
git init -b main
git add .
git commit -m "feat: initial Husky Linux configuration"
git remote add origin https://github.com/urbexcz/Husky-Linux.git
git push -u origin main
```

### 3. Nastavení podpisových klíčů (Cosign) – jedním kliknutím
Pro podepisování vašeho kontejneru je v repozitáři připravený automatický workflow:
1. Na GitHubu jděte do záložky **Actions**.
2. V levém menu klikněte na **generate-cosign-keys**.
3. Klikněte na **Run workflow** -> **Run workflow**.
4. Po dokončení:
   * Workflow automaticky commitne veřejný klíč `cosign.pub` do vašeho repozitáře.
   * V detailu běhu (záložka **Summary**) se vám zobrazí privátní klíč.
5. Zkopírujte privátní klíč a uložte jej do:
   **Settings -> Secrets and variables -> Actions -> New repository secret**
   * Name: `SIGNING_SECRET`
   * Secret: *(vložte obsah privátního klíče)*

---

## 💿 Sestavení obrazu a instalačního ISO

1. **Stavba obrazu OS:**
   * Po uložení `SIGNING_SECRET` se v záložce **Actions** automaticky spustí workflow **build-husky-linux** (případně ho můžete spustit ručně tlačítkem *Run workflow*).
   * Obraz se zkompiluje a nahraje do vašeho GitHub Container Registry pod adresou:
     `ghcr.io/urbexcz/husky-linux:latest`

2. **Generování instalačního ISO:**
   * Jakmile je obraz zkompilován, v záložce **Actions** vyberte **build-husky-iso** a klikněte na **Run workflow**.
   * Během cca 10–15 minut se vytvoří bootovatelné ISO.
   * Výsledný soubor `husky-linux-latest.iso` si stáhnete přímo ze sekce **Artifacts** na stránce daného běhu.

3. **Nahrání na USB flashdisk:**
   * Použijte **Fedora Media Writer**, **BalenaEtcher** nebo **Rufus** (režim DD) a nahrajte stažené `.iso` na flashku.

---

## 🛠️ Důležité kroky po první instalaci

### 1. Přístup k myši Razer (skupina plugdev)
Aby aplikace Polychromatic nebo OpenRGB mohly komunikovat s hardwarem myši Razer, přidejte svůj uživatelský účet do systémové skupiny `plugdev`:
```bash
sudo gpasswd -a $USER plugdev
```
Poté se odhlašte a znovu přihlaste (nebo restartujte PC).

### 2. Steam a dodatečné disky (SSD/HDD)
Protože Steam běží jako bezpečný Flatpak, přístup k dalším interním diskům můžete povolit jedním kliknutím:
1. Otevřete aplikaci **Flatseal**.
2. Vlevo vyberte **Steam**.
3. V sekci **Filesystem** (Souborový systém) přidejte cestu k vašemu disku (např. `/mnt/games` nebo `/run/media/...`).

### 3. Zrcadlení na TV (Sunshine & Moonlight)
V systému je předinstalován server **Sunshine**:
* Webová administrace běží na: `https://localhost:47990`
* Na televizi (Android TV, Apple TV, LG webOS, Samsung Tizen) si nainstalujte klienta **Moonlight**.
* Spárujte zadáním PINu – díky grafice RTX 4060 získáte streamování plochy a her v 4K s bleskovou odezvou a kódováním NVENC.
