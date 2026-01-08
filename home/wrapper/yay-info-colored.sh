#!/bin/bash
#/006   yay-info-colored.sh
# Wrapper para colorear salida de yay -Siia

yay -Siia "$1" | sed -E \
  -e 's/^(Repositorio|Repository)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;33m\3\x1b[0m/' \
  -e 's/^(Nombre|Name)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;32m\3\x1b[0m/' \
  -e 's/^(Versión|Version)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;35m\3\x1b[0m/' \
  -e 's/^(Descripción|Description)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;37m\3\x1b[0m/' \
  -e 's/^(URL)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;34m\3\x1b[0m/' \
  -e 's/^(Licencias|Licenses)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;33m\3\x1b[0m/' \
  -e 's/^(Depende de|Depends On)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;32m\3\x1b[0m/' \
  -e 's/^(Tamaño|Size|Download Size)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;31m\3\x1b[0m/' \
  -e 's/^(AUR URL|AUR Out-of-date)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;34m\3\x1b[0m/' \
  -e 's/^([A-Za-z ]+)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\3/' \
  -e 's/^(Architecture)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;35m\3\x1b[0m/' \
  -e 's/^(Groups)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;36m\3\x1b[0m/' \
  -e 's/^(Provides)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;32m\3\x1b[0m/' \
  -e 's/^(Depends On)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;32m\3\x1b[0m/' \
  -e 's/^(Make Deps)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;33m\3\x1b[0m/' \
  -e 's/^(Check Deps)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;33m\3\x1b[0m/' \
  -e 's/^(Optional Deps)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;33m\3\x1b[0m/' \
  -e 's/^(Conflicts With)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;31m\3\x1b[0m/' \
  -e 's/^(Replaces)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;35m\3\x1b[0m/' \
  -e 's/^(Maintainer)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;34m\3\x1b[0m/' \
  -e 's/^(Votes)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;35m\3\x1b[0m/' \
  -e 's/^(Popularity)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;35m\3\x1b[0m/' \
  -e 's/^(First Submitted)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;34m\3\x1b[0m/' \
  -e 's/^(Last Modified)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;34m\3\x1b[0m/' \
  -e 's/^(Out-of-date)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;31m\3\x1b[0m/' \
  -e 's/^(ID)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;35m\3\x1b[0m/' \
  -e 's/^(Package Base ID)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;35m\3\x1b[0m/' \
  -e 's/^(Keywords)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[0;33m\3\x1b[0m/' \
  -e 's/^(Snapshot URL)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\x1b[1;34m\3\x1b[0m/' \
  -e 's/^([A-Za-z ]+)(\s*):(.*)$/\x1b[1;36m\1\2\x1b[0m:\3/'
