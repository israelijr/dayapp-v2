#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC_FILE="$ROOT_DIR/pubspec.yaml"
BUILD_GRADLE_FILE="$ROOT_DIR/android/app/build.gradle.kts"
KEY_PROPERTIES_FILE="$ROOT_DIR/android/key.properties"

failures=0
warnings=0
min_version_code=""
device_serial=""
skip_device_check=false

print_usage() {
  cat <<'EOF'
Uso:
  ./scripts/check_release_readiness.sh [opcoes]

Opcoes:
  --min-version-code N  Define o menor versionCode ja publicado.
                        O script falha se a versao atual for <= N.
  --device-serial ID    Forca o uso de um dispositivo Android especifico via adb.
  --skip-device-check   Nao consulta a versao instalada no celular.
  -h, --help            Exibe esta ajuda.

Objetivo:
  Validar se o app esta pronto para sair como atualizacao sem exigir
  desinstalacao, reduzindo risco de perda de dados locais.
EOF
}

pass() {
  printf 'PASS %s\n' "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf 'WARN %s\n' "$1"
}

fail() {
  failures=$((failures + 1))
  printf 'FAIL %s\n' "$1"
}

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

read_property() {
  local file_path="$1"
  local key="$2"
  local line

  line="$(grep -E "^${key}=" "$file_path" | tail -n 1 | tr -d '\r' || true)"
  if [[ -z "$line" ]]; then
    printf ''
    return
  fi

  trim "${line#*=}"
}

is_placeholder_value() {
  local value="$1"

  case "$value" in
    *SUA_SENHA*|*SUBSTITUA*|'<'*'>')
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

build_adb_command() {
  if [[ -n "$device_serial" ]]; then
    printf 'adb\n-s\n%s\n' "$device_serial"
  else
    printf 'adb\n'
  fi
}

detect_installed_version_code() {
  local application_id="$1"
  local -a adb_command=()
  local device_count
  local package_path
  local version_line
  local detected_version

  if [[ "$skip_device_check" == true ]]; then
    warn 'Consulta ao dispositivo foi ignorada por --skip-device-check.'
    return
  fi

  if ! has_command adb; then
    warn 'adb nao encontrado. Sem --min-version-code, a comparacao com versao instalada fica indisponivel.'
    return
  fi

  if [[ -z "$device_serial" ]]; then
    device_count="$(adb devices | awk 'NR > 1 && $2 == "device" { count++ } END { print count + 0 }')"
    if [[ "$device_count" == "0" ]]; then
      warn 'Nenhum dispositivo Android conectado. Conecte o celular ou informe --min-version-code.'
      return
    fi

    if [[ "$device_count" != "1" ]]; then
      warn 'Mais de um dispositivo conectado. Use --device-serial ou informe --min-version-code.'
      return
    fi
  fi

  mapfile -t adb_command < <(build_adb_command)

  if [[ -n "$device_serial" ]]; then
    pass "Usando dispositivo adb ${device_serial}."
  else
    pass 'Usando o unico dispositivo adb conectado para validar upgrade local.'
  fi

  package_path="$("${adb_command[@]}" shell pm path "$application_id" 2>/dev/null | tr -d '\r' || true)"
  if [[ "$package_path" != package:* ]]; then
    warn "Pacote ${application_id} nao esta instalado no dispositivo. Sem versao instalada para comparar."
    return
  fi

  pass "Pacote ${application_id} encontrado no dispositivo."

  version_line="$("${adb_command[@]}" shell dumpsys package "$application_id" 2>/dev/null | grep -m 1 'versionCode=' | tr -d '\r' || true)"
  detected_version="$(printf '%s' "$version_line" | sed -E 's/.*versionCode=([0-9]+).*/\1/' | xargs || true)"

  if [[ "$detected_version" =~ ^[0-9]+$ ]]; then
    min_version_code="$detected_version"
    pass "versionCode instalado no celular: ${min_version_code}."
  else
    warn 'Nao foi possivel ler o versionCode instalado no dispositivo.'
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min-version-code)
      if [[ $# -lt 2 ]]; then
        printf 'Parametro ausente para --min-version-code.\n' >&2
        exit 1
      fi
      min_version_code="$2"
      shift 2
      ;;
    --device-serial)
      if [[ $# -lt 2 ]]; then
        printf 'Parametro ausente para --device-serial.\n' >&2
        exit 1
      fi
      device_serial="$2"
      shift 2
      ;;
    --skip-device-check)
      skip_device_check=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      printf 'Opcao invalida: %s\n' "$1" >&2
      print_usage >&2
      exit 1
      ;;
  esac
done

printf 'Validando release do DayApp...\n\n'

if [[ ! -f "$PUBSPEC_FILE" ]]; then
  printf 'Arquivo pubspec.yaml nao encontrado em %s\n' "$PUBSPEC_FILE" >&2
  exit 1
fi

if [[ ! -f "$BUILD_GRADLE_FILE" ]]; then
  printf 'Arquivo build.gradle.kts nao encontrado em %s\n' "$BUILD_GRADLE_FILE" >&2
  exit 1
fi

version_line="$(grep -E '^version:' "$PUBSPEC_FILE" | head -n 1 | tr -d '\r' | cut -d ':' -f 2- | xargs || true)"
if [[ -z "$version_line" ]]; then
  fail 'pubspec.yaml sem campo version.'
else
  if [[ "$version_line" == *+* ]]; then
    version_name="${version_line%%+*}"
    version_code="${version_line##*+}"

    if [[ -n "$version_name" && "$version_code" =~ ^[0-9]+$ ]]; then
      pass "Versao encontrada no pubspec: ${version_name}+${version_code}."
    else
      fail "Formato de versao invalido no pubspec: ${version_line}. Use algo como 1.0.1+2."
    fi
  else
    fail "Formato de versao invalido no pubspec: ${version_line}. Use algo como 1.0.1+2."
  fi
fi

application_id="$(grep -E 'applicationId\s*=' "$BUILD_GRADLE_FILE" | head -n 1 | sed -E 's/.*=\s*"([^"]+)".*/\1/' || true)"
if [[ -z "$application_id" ]]; then
  fail 'Nao foi possivel identificar o applicationId no build.gradle.kts.'
else
  pass "applicationId configurado: ${application_id}."
fi

if [[ -z "$min_version_code" && -n "$application_id" ]]; then
  detect_installed_version_code "$application_id"
fi

if [[ -n "${version_code:-}" && -n "$min_version_code" ]]; then
  if [[ ! "$min_version_code" =~ ^[0-9]+$ ]]; then
    fail "--min-version-code precisa ser numerico. Valor recebido: ${min_version_code}."
  elif (( version_code > min_version_code )); then
    pass "versionCode atual (${version_code}) e maior que a referencia anterior (${min_version_code})."
  else
    fail "versionCode atual (${version_code}) precisa ser maior que a referencia anterior (${min_version_code}) para atualizar sem desinstalar."
  fi
elif [[ -n "${version_code:-}" ]]; then
  warn 'Nao foi possivel confirmar se esta versao supera a instalada/publicada. Use adb, --device-serial ou --min-version-code.'
fi

if grep -q 'create("release")' "$BUILD_GRADLE_FILE"; then
  pass 'Signing config de release encontrada.'
else
  fail 'Signing config de release nao encontrada.'
fi

if grep -Eq 'signingConfig\s*=\s*signingConfigs\.getByName\("release"\)' "$BUILD_GRADLE_FILE" \
  || grep -Eq 'signingConfig\s*=\s*if\s*\(keystorePropertiesFile\.exists\(\)\)' "$BUILD_GRADLE_FILE"; then
  pass 'Build de release usa a assinatura configurada.'
else
  fail 'Build de release nao esta vinculada a signingConfigs.release.'
fi

if [[ ! -f "$KEY_PROPERTIES_FILE" ]]; then
  fail 'Arquivo android/key.properties nao encontrado.'
else
  pass 'Arquivo android/key.properties encontrado.'

  store_password="$(read_property "$KEY_PROPERTIES_FILE" 'storePassword')"
  key_password="$(read_property "$KEY_PROPERTIES_FILE" 'keyPassword')"
  key_alias="$(read_property "$KEY_PROPERTIES_FILE" 'keyAlias')"
  store_file_value="$(read_property "$KEY_PROPERTIES_FILE" 'storeFile')"

  if [[ -z "$store_password" || -z "$key_password" || -z "$key_alias" || -z "$store_file_value" ]]; then
    fail 'android/key.properties precisa ter storePassword, keyPassword, keyAlias e storeFile preenchidos.'
  else
    pass 'android/key.properties possui os campos obrigatorios.'
  fi

  if is_placeholder_value "$store_password" || is_placeholder_value "$key_password"; then
    fail 'android/key.properties ainda contem placeholders de senha.'
  else
    pass 'android/key.properties nao aparenta conter placeholders de senha.'
  fi

  if [[ -n "$store_file_value" ]]; then
    if [[ "$store_file_value" = /* ]]; then
      keystore_path="$store_file_value"
    else
      keystore_path="$ROOT_DIR/android/$store_file_value"
    fi

    if [[ -f "$keystore_path" ]]; then
      pass "Keystore localizada em ${keystore_path}."
    else
      fail "Arquivo da keystore nao encontrado em ${keystore_path}."
    fi
  fi
fi

if grep -q '^\s*version:' "$PUBSPEC_FILE"; then
  pass 'Flutter controlara versionName/versionCode a partir do pubspec.'
fi

printf '\nResumo:\n'
printf '  Falhas: %s\n' "$failures"
printf '  Avisos: %s\n' "$warnings"

if (( failures > 0 )); then
  printf '\nStatus final: AJUSTES NECESSARIOS antes de publicar como atualizacao.\n'
  exit 1
fi

if (( warnings > 0 )); then
  printf '\nStatus final: VALIDACAO PARCIAL. Revise os avisos acima.\n'
  exit 0
fi

printf '\nStatus final: OK para seguir com a geracao de release.\n'