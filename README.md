# bsp-rg35xxsp

Anbernic RG35XX-SP（Allwinner H700）主线 Linux BSP 构建仓库。

基于 Linux **7.2.9**、U-Boot **2026.04** 和 TF-A **lts-v2.14.2**，
通过公开上游 submodule 与设备适配 patch 管理源码。

本次同步包含 LCD/DE33 适配、RTC 开机校时、TF2 与启动告警修复，以及正常启动日志配置。
7.2.9 已包含 LCD TCON TOP 路由修复；开发阶段已完成重启及 LCD 视觉验收。

## 获取源码

```bash
git clone --recurse-submodules https://github.com/hsyysy/bsp-rg35xxsp.git
cd bsp-rg35xxsp
```

已有克隆更新后，运行 `git submodule update --init --recursive`。

## 目录结构

```text
├── linux/          # gregkh/linux v7.2.9
├── u-boot/         # u-boot/u-boot v2026.04
├── arm-tf-a/       # ARM-software/arm-trusted-firmware lts-v2.14.2
├── patches/linux/  # 相对 vanilla 7.2.9 的设备适配补丁
├── configs/        # 内核 fragment 和启动日志参数
├── scripts/        # 编译脚本
└── out/            # 构建产物（忽略提交）
```

## 编译

Debian/Ubuntu 依赖（TF-A 需要 GCC 11 或更新版本）：

```bash
sudo apt-get install gcc-aarch64-linux-gnu bc bison flex libssl-dev libelf-dev \
    libgnutls28-dev python3-dev python3-setuptools swig

./scripts/build_tfa.sh
./scripts/build_uboot.sh
./scripts/build_kernel.sh          # 增量编译
./scripts/build_kernel.sh release  # distclean 后全量编译
```

内核可独立构建；仅 U-Boot 依赖 `out/bl31.bin`。内核脚本会校验源码版本，
应用补丁并合并配置。重复构建会检查补丁实际状态，不依赖历史标记文件。
release 模式会清除内核构建配置；请先保存需要保留的自定义配置。

默认使用双分区布局：p1 为启动分区，p2 为根分区。旧五分区卡的构建示例：

```bash
BOOT_PART=0:2 ROOT_DEV=/dev/mmcblk0p5 ./scripts/build_uboot.sh
BOOT_PART=0:2 ROOT_DEV=/dev/mmcblk0p5 ./scripts/build_kernel.sh
```

脚本只构建 BSP；需自行准备 rootfs、固件并按实际卡布局部署。

## 产物

| `out/` 下文件 | 说明 |
|---|---|
| `bl31.bin` | TF-A BL31 |
| `u-boot-sunxi-with-spl.bin` | U-Boot SPL + BL31 |
| `Image.gz` | 内核镜像 |
| `sun50i-h700-anbernic-rg35xx-sp.dtb` | 设备树 |
| `modules.tar.gz` | 模块；在根文件系统解包，去除构建机路径软链 |
| `p2-payload/` | 启动分区内容：Image.gz、DTB、extlinux.conf；目录名兼容旧布局 |
| `SHA256SUMS` | 构建产物校验值 |

## 补丁与 CI

`patches/linux/0001-rg35xxsp-linux-7.2.9.patch` 包含相对 vanilla 的源码改动；
配置独立维护在 `configs/`。

推送到 `main` / `master` 或提交 PR 时运行 GitHub Actions 构建；
推送 `v*` tag 时创建 Release 并上传产物。

## 许可证

内核、U-Boot、TF-A 各自遵循其上游许可证。本仓库的构建脚本和补丁见 [LICENSE](LICENSE)。
