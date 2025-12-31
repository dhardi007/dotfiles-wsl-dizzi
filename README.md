# 💤 Arch Linux en WSL - Guía Completa

> **Configuración de Linux WSL en Windows** | Actualizado: 26/08/2025 🔮 🔥 🚀

<div align="center">

```
                  -`                       root@classmate
                 .o+`
                `ooo/                        Arch Linux x86_64
               `+oooo:                       Linux 5.15.167.4-microsoft-standard-WSL2
              `+oooooo:                      188 (pacman)
              -+oooooo+:                     zsh 5.9
            `/:-:++oooo+:                    Windows Terminal
           `/++++/+++++++:                   WSLg 1.0.65 (Wayland)
          `/++++++++++++++:                  6 hours, 56 mins
         `/+++ooooooooooooo/`              CPU  Intel(R) Celeron(R) N4000 (2) @ 1.09 GHz
        ./ooosssso++osssssso+`             󰍛  538.21 MiB / 1.84 GiB (29%)
       .oossssso-````/ossssss+`            󰋊  1.80 GiB / 1006.85 GiB (0%) - ext4
      -osssssso.      :ssssssso.           󰋊  70.77 GiB / 73.73 GiB (96%) - 9p
     :osssssss/        osssso+++.          󰛿  192.168.21.211/20
    /ossssssss/        +ssssooo/-          󰁹  100% [AC Connected]
```
https://private-user-images.githubusercontent.com/127579140/481942769-ae102d70-576c-405f-908d-03725f59476f.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NjcxNjQzMDUsIm5iZiI6MTc2NzE2NDAwNSwicGF0aCI6Ii8xMjc1NzkxNDAvNDgxOTQyNzY5LWFlMTAyZDcwLTU3NmMtNDA1Zi05MDhkLTAzNzI1ZjU5NDc2Zi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUxMjMxJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MTIzMVQwNjUzMjVaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT01ODJkN2UwNGYyZjk2NzY2ZTE1NzEzYWRhOGQzMDk2ZTIyNmI4MmFiMmQ5MmE5MWMxMmRmMzc0NGQ0NTU3MjNhJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.VjF7x79Ym4xB_F4kNWAW3pqwcdwFaeNh4JS_G1JOb7M
</div>

---

## 📋 Tabla de Contenidos

- [Diferencias Arch vs Debian](#-diferencias-arch-vs-debian)
- [Instalación Base](#-instalación-base)
- [Configuración Root y Sudo](#-configuración-root-y-sudo)
- [Oh My Zsh + Plugins](#-oh-my-zsh--plugins)
- [Paquetes Esenciales](#-paquetes-esenciales)
- [Gestión de Usuarios](#-gestión-de-usuarios)
- [Neovim Nativo](#-neovim-nativo)
- [YAY (AUR)](#-yay-aur-opcional)

---

## ⚔️ Diferencias Arch vs Debian

### Comandos Básicos

| Acción | Arch (pacman) | Debian/Ubuntu (apt) |
|--------|---------------|---------------------|
| Actualizar sistema | `pacman -Sy` | `apt update && apt upgrade` |
| Instalar paquetes | `pacman -S paquete` | `apt install paquete` |
| Buscar paquetes | `pacman -Ss paquete` | `apt search paquete` |

### Gestores de Paquetes

<table>
<tr>
<th>🔷 Arch Linux</th>
<th>🔶 Debian/Ubuntu</th>
</tr>
<tr>
<td>

- **pacman** → Gestor oficial (repos Arch)
- **yay/paru** → Ayudantes AUR (comunidad)
- **pamac** → Interfaz GTK/CLI (opcional)
- **makepkg** → Compilar PKGBUILD manual

</td>
<td>

- **apt** → Gestor principal (repos oficiales)
- **dpkg** → Bajo nivel (instalar .deb)

</td>
</tr>
</table>

**Gestores Universales** (ambas distros):
- `snap` → Paquetes sandbox de Canonical
- `flatpak` → Paquetes sandbox independientes
- `pip/pipx` → Gestores Python (user-space)

---

## 🚀 Instalación Base

### 1️⃣ Listar e Instalar Distros

Desde **PowerShell en Windows**:

```powershell
# Ver distros disponibles
wsl --list --online

# Instalar Arch Linux
wsl --install --distribution Arch

# O si prefieres Debian
wsl --install --distribution Debian

# Remover una distro
wsl --unregister Debian

# Iniciar distro por primera vez
wsl.exe -d archlinux
```

---

## 🔐 Configuración Root y Sudo

### 2️⃣ Actualizar Sistema y Cambiar a Zsh

<table>
<tr>
<th>🔷 Arch Linux</th>
<th>🔶 Debian</th>
</tr>
<tr>
<td>

```bash
pacman -Sy
pacman -S git base-devel zsh sudo
```

</td>
<td>

```bash
apt update && apt upgrade
apt install git build-essential zsh sudo
```

</td>
</tr>
</table>

### Cambiar shell a Zsh

```bash
chsh -s /usr/bin/zsh
```

### Configurar sudoers

```bash
# Editar permisos
visudo

# O con nano
nano /etc/sudoers
```

Agregar estas líneas:

```bash
root ALL=(ALL) ALL
%wheel ALL=(ALL:ALL) ALL
```

---

## 🎨 Oh My Zsh + Plugins

### 3️⃣ Instalar Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Instalar Oh My Posh (con yay)

```bash
yay -S oh-my-posh

# Agregar al final de ~/.zshrc:
nano ~/.zshrc
```

```bash
# HABILITAR OH MY POSH
# Temas: https://ohmyposh.dev/docs/themes
eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
```

### Plugins Zsh Esenciales

```bash
# Powerlevel10k
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Syntax Highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Completions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions

# History Substring Search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Autocomplete
git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/zsh-autocomplete

# FZF Tab
git clone https://github.com/Aloxaf/fzf-tab.git ~/.zsh/fzf-tab
```

---

## 📦 Paquetes Esenciales

### 4️⃣ Instalar Dotfiles + Paquetes Base

```bash
# Clonar dotfiles
git clone https://github.com/dizzi1222/dotfiles-wsl-dizzi
cd dotfiles-wsl-dizzi
stow .

# Si hay conflictos, elimínalos manualmente (NO uses --adopt)
```

<table>
<tr>
<th>🔷 Arch Linux</th>
<th>🔶 Debian</th>
</tr>
<tr>
<td>

```bash
sudo pacman -S git github-cli eza fastfetch \
nano stow yazi nodejs fzf ripgrep tmux \
python-pipx fd neovim rsync gcc
```

</td>
<td>

```bash
sudo apt install git gh eza fastfetch nano \
stow yazi nodejs npm fzf ripgrep tmux pipx \
man-db locales apt-transport-https \
ca-certificates curl gnupg lsb-release fd-find
```

</td>
</tr>
</table>

> **📌 Notas Importantes:**
> - NO instales Neovim innecesariamente. Los alias enlazan programas de Windows con WSL
> - Asegúrate de adaptar los paths de `\user [diego]` en `.zshrc` para que funcionen los alias
> - Puedes copiar dotfiles a `.config` pero **Stow es mejor**
> - `code` abre archivos Stow correctamente gracias a WSL, pero `nvim .zshrc` no lee symlinks
> - **Solución:** Usa path completo → `nvim ~/dotfiles-wsl-dizzi/zsh/.zshrc`

---

## 👤 Gestión de Usuarios

### 5️⃣ Crear Usuario

<table>
<tr>
<th>🔷 Arch Linux</th>
<th>🔶 Debian</th>
</tr>
<tr>
<td>

```bash
useradd -m -g users -G wheel diego
passwd diego
```

</td>
<td>

```bash
adduser diego
usermod -aG sudo diego
```

</td>
</tr>
</table>

### Cambiar entre usuarios

```bash
# Entrar al usuario
su diego

# Salir
exit
```

---

## ⚡ Neovim Nativo

### 6️⃣ Configuración para Máxima Velocidad 🚀

Para evitar el **lag extremo** de WSL al leer desde `/mnt/c/`, **NO uses enlaces simbólicos** (`ln -s`). Los archivos deben ser nativos.

```bash
# Instalar Neovim y rsync
sudo pacman -S neovim rsync

# Ejecutar sincronización
~/sync-nvim.sh
```

El script copiará tu config de Windows:
- **Origen:** `C:\Users\Diego\AppData\Local\nvim`
- **Destino:** `~/.config/nvim`

---

## 🎯 YAY (AUR) [Opcional]

### 7️⃣ Instalar YAY (~200MB)

> ⚠️ **Solo disponible en Arch Linux**

```bash
# Como root
cd ~
git clone https://aur.archlinux.org/yay.git
sudo cp -r /root/yay /home/diego

# Dar permisos al usuario
chown -R diego:users /home/diego/yay

# Arreglar caché (si falla compilación)
mkdir -p /home/diego/.cache
chmod 755 /home/diego/.cache
chown -R diego:users /home/diego/.cache

# Cambiar a usuario diego
su diego

# Compilar e instalar yay
cd ~/yay
makepkg -si
```

---

## 🦥 Debian vs Arch

<div align="center">

![Debian vs Arch](https://github.com/user-attachments/assets/ac37b985-489d-4801-a8ce-1fde7ef7446d)

[**Ver video comparativo**](https://youtu.be/H7RQYREJO98)

![I use Arch btw](https://github.com/user-attachments/assets/df6ecb56-d359-474d-8be1-bf68c48172ff)

</div>

---

## 📌 Paquetes Instalados

```bash
❯ pacman -Qet | tail -n 20

base 3-2
eza 0.23.0-1
fastfetch 2.50.2-1
github-cli 2.78.0-1
nano 8.6-1
stow 2.4.1-1
yazi 25.5.31-2
zsh-autosuggestions 0.7.1-1
zsh-syntax-highlighting 0.8.0-1
```

---

<div align="center">

**💤 zsh > bashzzz btw~ 🔮**

*I use Arch, btw.*

</div>

