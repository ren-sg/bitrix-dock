#!/bin/bash

# Скрипт для настройки локального SSL с помощью mkcert

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Пути
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
CERTS_DIR="${SCRIPT_DIR}/certs"

echo -e "${YELLOW}Начинаем настройку локального SSL...${NC}"

# 1. Проверка наличия mkcert
if ! command -v mkcert &> /dev/null; then
    echo -e "${RED}Ошибка: утилита 'mkcert' не установлена.${NC}"
    echo "Пожалуйста, установите её:"
    echo "  Ubuntu/Debian: sudo apt install libnss3-tools && wget -O mkcert https://dl.filippo.io/mkcert/latest?for=linux/amd64 && chmod +x mkcert && sudo mv mkcert /usr/local/bin/"
    echo "  macOS: brew install mkcert"
    echo "После установки выполните один раз: mkcert -install"
    exit 1
fi

# Установка корневого сертификата в систему (безопасно запускать несколько раз)
mkcert -install

# 2. Чтение домена из .env
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Ошибка: Файл $ENV_FILE не найден.${NC}"
    exit 1
fi

# Извлекаем значение PROJECT_DOMAIN, убирая возможные пробелы, кавычки и комментарии
PROJECT_DOMAIN=$(grep -E '^[[:space:]]*PROJECT_DOMAIN=' "$ENV_FILE" | cut -d '=' -f 2- | tr -d '"' | tr -d "'" | awk '{print $1}')

if [ -z "$PROJECT_DOMAIN" ]; then
    echo -e "${RED}Ошибка: PROJECT_DOMAIN не найден в $ENV_FILE.${NC}"
    exit 1
fi

echo -e "Найден домен: ${GREEN}${PROJECT_DOMAIN}${NC}"

# 3. Создание директории для сертификатов
mkdir -p "$CERTS_DIR"

# 4. Генерация сертификатов
echo "Генерация сертификата для $PROJECT_DOMAIN..."
mkcert -cert-file "$CERTS_DIR/cert.crt" -key-file "$CERTS_DIR/cert.key" "$PROJECT_DOMAIN" "*.${PROJECT_DOMAIN}"

echo -e "${GREEN}✅ Сертификаты успешно сгенерированы!${NC}"
echo -e "Файлы сертификатов сохранены в: ${CERTS_DIR}"
echo -e "${YELLOW}Готово! Теперь пересоберите Nginx и перезапустите контейнеры (docker-compose up -d --build nginx).${NC}"
