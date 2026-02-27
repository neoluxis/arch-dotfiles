#!/bin/bash

# 设置最大快照数量
MAX_SNAPSHOTS=2

# 获取当前快照列表并按创建时间排序（从最旧到最新）
SNAPSHOT_LIST=$(timeshift --list | grep "Sysupgrade" | awk '{print $3}')

# 计算当前快照数量
CURRENT_SNAPSHOTS=$(echo "$SNAPSHOT_LIST" | wc -l)

# 如果当前快照数量超过最大值，进行清理
if [ "$CURRENT_SNAPSHOTS" -gt "$MAX_SNAPSHOTS" ]; then
    # 需要删除的快照数量
    DELETE_COUNT=$((CURRENT_SNAPSHOTS - MAX_SNAPSHOTS))

    # 获取需要删除的最旧快照
    DELETE_SNAPSHOTS=$(echo "$SNAPSHOT_LIST" | tail -n "$DELETE_COUNT")

    # 删除最旧的快照
    for SNAPSHOT in $DELETE_SNAPSHOTS; do
        echo "Deleting snapshot: $SNAPSHOT"
        timeshift --delete --snapshot "$SNAPSHOT" --yes
    done
else
    echo "No snapshots to delete. Current snapshots are within the limit."
fi

cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
grub-mkconfig -o /boot/grub/grub.cfg
