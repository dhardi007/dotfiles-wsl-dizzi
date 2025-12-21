# Editar locale.gen
sudo nano /etc/locale.gen

# Descomenta esta línea (quita el # al principio):
# en_US.UTF-8 UTF-8

# Guarda (Ctrl+X, luego Y, luego Enter)

# Generar los locales
sudo locale-gen

# Establecer locale
echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf
echo 'LC_ALL=en_US.UTF-8' | sudo tee -a /etc/locale.conf

# Para la sesión actual
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Agregar a .zshrc permanentemente
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc

# Recargar
source ~/.zshrc
