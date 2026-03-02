#!/usr/bin/env bash

LOCKFILE="/tmp/wayfreeze_screenshot_script.lock"
exec 9>"$LOCKFILE"

if ! flock -n 9; then
    notify-send "Screenshot tool is already running."
    exit 0
fi

# 1. 记录当前剪贴板状态（指纹）
# 如果剪贴板当前不是图片，md5sum 会失败，所以加个判断
PREV_HASH=$(wl-paste -t image/png 2>/dev/null | md5sum)

# 2. 触发截图
niri msg action screenshot

# 3. 等待剪贴板更新
# 设置超时时间防止死循环（例如 10 秒）
MAX_ATTEMPTS=10
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    CURRENT_HASH=$(wl-paste -t image/png 2>/dev/null | md5sum)
    
    # 如果哈希值改变，说明新截图已存入
    if [ "$CURRENT_HASH" != "$PREV_HASH" ] && [ -n "$CURRENT_HASH" ]; then
        break
    fi
    
    sleep 0.1
    ATTEMPT=$((ATTEMPT + 1))
done

# 4. 释放锁
# 既然已经拿到剪贴板数据，可以释放锁让下一次截图进程进入
flock -u 9

# 5. 调用 satty 处理新内容
wl-paste -t image/png | satty \
    --filename - \
    --copy-command="wl-copy" \
    --annotation-size-factor 0.5 \
    --output-filename="$(xdg-user-dir PICTURES)/Screenshots/Screenshot from %Y-%m-%d %H:%M:%S.png" \
    --actions-on-enter="save-to-clipboard,exit" \
    --brush-smooth-history-size 2 \
    --disable-notifications &
