#!/usr/bin/env bash

# 定义锁文件路径
LOCKFILE="/tmp/wayfreeze_screenshot_script.lock"

# 打开文件描述符 9 并指向锁文件
exec 9>"$LOCKFILE"

# 尝试以非阻塞模式 (-n) 获取排他锁。如果获取失败，说明脚本已经在运行，直接退出。
if ! flock -n 9; then
    # 可选：向系统日志或桌面发送通知提示正在截图中
    notify-send "Screenshot tool is already running."
    exit 0
fi

# 原有的截图逻辑
wayfreeze --after-freeze-cmd 'grim -g "$(slurp)" - | wl-copy; killall wayfreeze'

# 5. 框选完成后，显式释放锁。
# 这样即便下方的 satty 还在运行，下一次按 F1 也能正常触发新的截图。
flock -u 9

wl-paste | satty \
    --filename - \
    --copy-command="wl-copy" \
    --annotation-size-factor 0.5 \
    --output-filename="$(xdg-user-dir PICTURES)/Screenshots/Screenshot from %Y-%m-%d %H:%M:%S.png" \
    --actions-on-enter="save-to-clipboard,exit" \
    --brush-smooth-history-size 2 \
    --disable-notifications &
