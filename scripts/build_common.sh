#!/usr/bin/env bash
# Shared card layout and logging policy for kernel payload and direct U-Boot boot.
# Sourced after BSP is set by the caller.
# Stable build identity avoids embedding the local account and hostname.
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-builder}
export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-buildhost}
ROOT_DEV=${ROOT_DEV:-/dev/mmcblk0p2}
BOOT_PART=${BOOT_PART:-0:1}
BOOT_LOG_ARGS=${BOOT_LOG_ARGS:-$(awk 'NF && $1 !~ /^#/ { print; exit }' "$BSP/configs/rg35xxsp.bootargs")}
if [[ ! "$ROOT_DEV" =~ ^[a-zA-Z0-9_./=:-]+$ ]] || [[ ! "$BOOT_PART" =~ ^[0-9]+:[0-9]+$ ]]; then
    echo "无效 ROOT_DEV 或 BOOT_PART" >&2
    exit 1
fi
if [[ ! "$BOOT_LOG_ARGS" =~ ^(ignore_loglevel[[:space:]]+)?drm\.debug=(0|0x[0-9a-fA-F]+)$ ]]; then
    echo "无效 BOOT_LOG_ARGS" >&2
    exit 1
fi
