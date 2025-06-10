#!/bin/bash

# 请确保已经设置了NDK路径
if [ -z "$ANDROID_NDK" ]; then
  echo "请设置ANDROID_NDK环境变量指向NDK根目录"
  echo "例如: export ANDROID_NDK=/path/to/android-ndk"
  exit 1
fi

echo "正在使用NDK: $ANDROID_NDK"

# 创建目录结构
mkdir -p jni
mkdir -p libs

# 检查Android.mk和Application.mk是否存在
if [ ! -f jni/Android.mk ] || [ ! -f jni/Application.mk ]; then
  echo "错误: 无法找到jni/Android.mk或jni/Application.mk文件"
  exit 1
fi

# 设置环境变量以修复M1/M2芯片的问题
export TERM=xterm-256color
export SHELL=/bin/bash
export ANDROID_NDK_TOOLCHAIN_VERSION=clang
export NDK_TOOLCHAIN_VERSION=clang

# 使用特定的ndk-build命令
echo "开始编译SQLite for Android..."
$ANDROID_NDK/ndk-build NDK_HOST_64BIT=1

# 检查编译结果
if [ $? -eq 0 ]; then
  echo "编译成功！生成的库文件位于libs目录:"
  ls -la libs/*
else
  echo "编译失败！"
  exit 1
fi

echo "编译完成。" 