#!/bin/bash

# Настройки удаленных серверов (УКАЖИТЕ СВОИ IP И ПУТИ)
LOBBY_IP="2.26.52.10"
LOBBY_PATH="/home/container/plugins"

GRIEF_IP="2.26.52.10"
GRIEF_PATH="/home/container/plugins"

# Локальные папки на этом сервере, куда всё скачается
LOCAL_DEST="/root/network_backups"
mkdir -p "$LOCAL_DEST/lobby" "$LOCAL_DEST/grief"

echo "=== СКАЧИВАНИЕ СЕРВЕРА ЛОББИ ==="
# rsync копирует только измененные файлы, что экономит трафик и время
rsync -avz -e ssh root@$LOBBY_IP:$LOBBY_PATH/ "$LOCAL_DEST/lobby/"

echo "=== СКАЧИВАНИЕ СЕРВЕРА ГРИФ ==="
rsync -avz -e ssh root@$GRIEF_IP:$GRIEF_PATH/ "$LOCAL_DEST/grief/"

echo "=== КОПИРОВАНИЕ ЗАВЕРШЕНО ==="
echo "Все серверы теперь собраны локально в папке: $LOCAL_DEST"
