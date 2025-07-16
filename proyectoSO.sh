#!/usr/bin/env bash
# primero instalar el repo con las modificaciones
#install_poketerm.sh, este archivo convierte mlterm en tu terminal por defecto
# y aplica el fondo Pokémon persistente.

set -e

########################################
# 1. Instalar paquetes necesarios
########################################
echo "Instalando mlterm, libsixel-bin y jq (dependencias)..."
sudo apt update -qq
sudo apt install -y mlterm libsixel-bin jq

# Detectar pokeshell; si no existe, intentar instalarlo con pipx (o git clone).
if ! command -v pokeshell &>/dev/null; then
  echo "→ pokeshell no encontrado. Instalando vía pipx..."
  if ! command -v pipx &>/dev/null; then
    sudo apt install -y pipx python3-venv
    pipx ensurepath
  fi
  pipx install pokeshell
fi

########################################
# 2. Hacer mlterm la terminal por defecto
########################################
echo "→ Registrando mlterm como x-terminal-emulator por defecto..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
  x-terminal-emulator /usr/bin/mlterm 60
sudo update-alternatives --set x-terminal-emulator /usr/bin/mlterm

########################################
# 3. Insertar / actualizar bloque en ~/.bashrc
########################################
BASHRC="$HOME/.bashrc"
TAG_BEGIN="# >>> Poketerm BEGIN >>>"
TAG_END="# <<< Poketerm END <<<"

pokeblock=$(cat <<'EOF'
# >>> Poketerm BEGIN >>>
# Fondo Pokémon (mlterm / foot+sixel): un sprite por sesión, persiste tras clear,
# ocupa ~25 % del ancho y se dibuja sobre fondo negro con texto blanco.
if [[ $TERM == mlterm* || $TERM == foot* ]]; then
  printf '\033]11;#000000\007'     # fondo negro (OSC 11)
  printf '\033]10;#ffffff\007'     # texto blanco (OSC 10)

  if [[ -z "$POKE_SPRITE_FILE" || ! -f "$POKE_SPRITE_FILE" ]]; then
    POKE_SPRITE_FILE=$(mktemp --suffix=.sixel)
    pokeshell random | img2sixel -g 25%x > "$POKE_SPRITE_FILE"
    export POKE_SPRITE_FILE
  fi

  _poke_redraw () { cat "$POKE_SPRITE_FILE"; printf '\033[H'; }

  _poke_redraw
  alias clear='printf "\033[2J\033[H" && _poke_redraw'
  alias pokerefresh='rm -f "$POKE_SPRITE_FILE"; unset POKE_SPRITE_FILE; clear'
fi
# <<< Poketerm END <<<
EOF
)

# Elimina bloque antiguo si existe y añade el nuevo al final.
echo "→ Actualizando $BASHRC ..."
grep -q "$TAG_BEGIN" "$BASHRC" && \
  sed -i "/$TAG_BEGIN/,/$TAG_END/d" "$BASHRC"
printf "\n%s\n" "$pokeblock" >> "$BASHRC"

########################################
# 4. Mensaje final
########################################
echo -e "\n Instalación completada."
echo "→ Abre una nueva ventana de terminal o ejecuta 'mlterm' para probar."
echo "   Usa 'clear' para limpiar (el Pokémon reaparecerá) y 'pokerefresh' para cambiarlo."
