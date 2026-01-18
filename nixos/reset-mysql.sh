#!/usr/bin/env bash
# MySQL 重置脚本 - 清理损坏的数据目录并重新初始化

set -e

echo "停止 MySQL 服务..."
sudo systemctl stop mysql

echo "备份现有数据目录（如果存在）..."
if [ -d /var/lib/mysql ]; then
    sudo mv /var/lib/mysql /var/lib/mysql.backup.$(date +%Y%m%d_%H%M%S)
fi

echo "创建新的数据目录..."
sudo mkdir -p /var/lib/mysql
sudo chown mysql:mysql /var/lib/mysql
sudo chmod 700 /var/lib/mysql

echo "启动 MySQL 服务（将自动初始化）..."
sudo systemctl start mysql

echo "等待 MySQL 完全启动..."
sleep 5

echo "检查服务状态..."
sudo systemctl status mysql

echo ""
echo "完成！MySQL 应该已经成功初始化并启动。"
echo "你可以使用以下命令连接："
echo "  sudo mysql -u root"
