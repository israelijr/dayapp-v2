#!/bin/bash

# Navega até o diretório do projeto
cd /home/israel/Dev/DayApp || exit

# Executa os comandos de limpeza e build
flutter clean
rm -rf android/.gradle
rm -rf build
rm -rf .dart_tool
flutter pub get
flutter build appbundle --release

# Mantém o terminal aberto para você ver o resultado ou possíveis erros
echo ""
echo "Processo concluído! Pressione qualquer tecla para fechar."
read -n 1 -s
