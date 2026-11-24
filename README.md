# 🐺 Husky Linux

Vlastní obraz operačního systému postavený na oficiální šabloně frameworku **BlueBuild**.

* **Základní obraz:** Fedora 45 Kinoite (KDE Plasma) s otevřenými ovladači NVIDIA (`ghcr.io/blue-build/base-images/fedora-kinoite-nvidia-open:45`).
* **RGB hardware:** `ckb-next` (s automaticky aktivovanou systémovou službou `ckb-next-daemon.service`) a `openrgb`.
* **Gaming & Steam:** `steam-devices` (udev pravidla pro gamepady), `gamemode`, `mangohud`, `gamescope`.
* **Vývoj:** `git`.
* **Aplikace:** Uživatelské aplikace a hry (např. Steam) si instaluje uživatel sám přes grafické rozhraní **KDE Discover** (Flathub).

---

## 🚀 Instalace a přechod na obraz (Rebase)

Pro přechod na tento obraz ze stávající instalace Fedory Atomic spusťte:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/<vaše-github-jméno>/husky-linux:latest
```

nebo pomocí moderního nástroje `bootc`:

```bash
sudo bootc switch ghcr.io/<vaše-github-jméno>/husky-linux:latest
```

---

## 🔒 Secure Boot

Ovladače NVIDIA jsou podepsané upstreamem Universal Blue. Pokud máte v UEFI zapnutý Secure Boot, po prvním nabootování zadejte:

```bash
ujust enroll-secure-boot-key
```

a při restartu na modré obrazovce *MOK Management* potvrďte import klíče (výchozí heslo: `universalblue`).
