# bsp-rg35xxsp

Anbernic RG35XX-SP 主线 Linux BSP 构建仓库。

基于 mainline Linux 7.2.3 + U-Boot 2026.04 + TF-A lts-v2.14.2，通过 submodule + patch 管理。

## 目录结构

```
├── linux/          # submodule: gregkh/linux v7.2.3
├── u-boot/         # submodule: u-boot/u-boot v2026.04
├── arm-tf-a/       # submodule: ARM-software/arm-trusted-firmware lts-v2.14.2
├── patches/
│   └── linux/      # 设备相关内核补丁（DTS、DRM、驱动等）
├── configs/        # 内核 config fragment
├── scripts/        # 编译脚本
└── out/            # 构建产物（gitignore）
```

## 编译

### 依赖

```bash
# Debian/Ubuntu
sudo apt-get install gcc-aarch64-linux-gnu bc bison flex libssl-dev libgnutls28-dev
```

### 构建顺序

```bash
# 1. TF-A (BL31)
./scripts/build_tfa.sh

# 2. U-Boot（依赖 bl31.bin）
./scripts/build_uboot.sh

# 3. Kernel（使用 linux 子模块 v7.2.3）
./scripts/build_kernel.sh          # dev 模式，增量编译
./scripts/build_kernel.sh release  # release 模式，distclean 后全量编译
```

### 产物

构建产物在 `out/` 目录：

| 文件 | 说明 |
|------|------|
| `bl31.bin` | TF-A BL31 |
| `u-boot-sunxi-with-spl.bin` | U-Boot SPL + BL31 |
| `Image.gz` | 内核镜像 |
| `sun50i-h700-anbernic-rg35xx-sp.dtb` | 设备树 |
| `modules.tar.gz` | 内核模块 |
| `p2-payload/` | FAT 分区部署内容（Image + DTB + extlinux.conf） |

## 补丁说明

| Patch | 内容 |
|-------|------|
| `0001-rg35xxsp-linux-7.2.3.patch` | RG35XX-SP 内核改动（DTS、DRM、驱动、配置及构建修复） |

## CI

推送到 `master` 分支自动触发 GitHub Actions 构建。推送 tag 时自动创建 Release 并上传产物。

## 许可证

内核、U-Boot、TF-A 各自遵循其上游许可证。本仓库的构建脚本和补丁见 [LICENSE](LICENSE)。
