#!/bin/bash

echo "Архивирую /home/container..."
tar -czf /tmp/server_backup.tar.gz -C /home/container . 2>/dev/null

if [ ! -f /tmp/server_backup.tar.gz ]; then
    echo "Ошибка: архив не создан!"
    exit 1
fi

echo "Создаю папку на Gofile..."
FOLDER=$(curl -s -X POST "https://api.gofile.io/contents" \
    -H "Content-Type: application/json" \
    -d '{"name": "Minecraft_Backup"}' | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$FOLDER" ]; then
    echo "Ошибка: не удалось создать папку, пробую загрузить без неё"
    curl -s -F "file=@/tmp/server_backup.tar.gz" "https://gofile.io/upload" > /tmp/upload_result.txt
else
    curl -s -X POST "https://api.gofile.io/contents/$FOLDER/upload" \
        -F "file=@/tmp/server_backup.tar.gz" > /tmp/upload_result.txt
    echo ""
    echo "========================================="
    echo "Ссылка на скачивание:"
    echo "https://gofile.io/d/$FOLDER"
    echo "========================================="
fi

rm -f /tmp/server_backup.tar.gz /tmp/upload_result.txt
rm -f "$0"
echo "Готово!"
