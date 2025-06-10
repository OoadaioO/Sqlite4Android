#!/bin/bash

# 检查NDK路径
if [ -z "$ANDROID_NDK" ]; then
  echo "请设置ANDROID_NDK环境变量指向NDK根目录"
  echo "例如: export ANDROID_NDK=/path/to/android-ndk"
  exit 1
fi

echo "正在使用NDK: $ANDROID_NDK"

# 创建输出目录
mkdir -p output/lib/armeabi-v7a
mkdir -p output/lib/arm64-v8a
mkdir -p output/lib/x86
mkdir -p output/include

# 复制头文件
cp sqlite3.h output/include/
cp sqlite3ext.h output/include/

# 设置编译参数 (-fPIC 解决 relocation 错误，-fvisibility=hidden 解决符号可见性问题)
CFLAGS="-O3 -DNDEBUG -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_JSON1 -fPIC -fvisibility=hidden"

# 设置API级别
API_LEVEL=21

# 确定正确的 toolchain 位置
TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64"
if [ ! -d "$TOOLCHAIN" ]; then
  echo "找不到工具链: $TOOLCHAIN"
  echo "请检查NDK目录结构"
  exit 1
fi

# 编译ARM 32位版本 (armeabi-v7a)
echo "编译 armeabi-v7a (ARM 32位) 版本..."
ARM_CC="$TOOLCHAIN/bin/armv7a-linux-androideabi$API_LEVEL-clang"
if [ ! -f "$ARM_CC" ]; then
  echo "找不到: $ARM_CC"
  echo "尝试查找可用的编译器:"
  ls -la $TOOLCHAIN/bin/armv7a-linux-*
  exit 1
fi
$ARM_CC $CFLAGS -shared -o output/lib/armeabi-v7a/libsqlite3.so sqlite3.c -lm

# 编译ARM 64位版本 (arm64-v8a)
echo "编译 arm64-v8a (ARM 64位) 版本..."
ARM64_CC="$TOOLCHAIN/bin/aarch64-linux-android$API_LEVEL-clang"
if [ ! -f "$ARM64_CC" ]; then
  echo "找不到: $ARM64_CC"
  echo "尝试查找可用的编译器:"
  ls -la $TOOLCHAIN/bin/aarch64-linux-*
  exit 1
fi
$ARM64_CC $CFLAGS -shared -o output/lib/arm64-v8a/libsqlite3.so sqlite3.c -lm

# 编译X86版本
echo "编译 x86 版本..."
X86_CC="$TOOLCHAIN/bin/i686-linux-android$API_LEVEL-clang"
if [ ! -f "$X86_CC" ]; then
  echo "找不到: $X86_CC"
  echo "尝试查找可用的编译器:"
  ls -la $TOOLCHAIN/bin/i686-linux-*
  exit 1
fi
$X86_CC $CFLAGS -shared -o output/lib/x86/libsqlite3.so sqlite3.c -lm

# 检查编译结果
if [ -f output/lib/armeabi-v7a/libsqlite3.so ] && [ -f output/lib/arm64-v8a/libsqlite3.so ] && [ -f output/lib/x86/libsqlite3.so ]; then
  echo "编译成功！生成的库文件位于output/lib目录:"
  ls -la output/lib/*/*.so
  echo ""
  echo "文件大小:"
  du -h output/lib/*/*.so
else
  echo "编译失败！"
  exit 1
fi

echo "编译完成。" 