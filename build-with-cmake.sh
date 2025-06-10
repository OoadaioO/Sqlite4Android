#!/bin/bash

# 检查NDK路径
if [ -z "$ANDROID_NDK" ]; then
  echo "请设置ANDROID_NDK环境变量指向NDK根目录"
  echo "例如: export ANDROID_NDK=/path/to/android-ndk"
  exit 1
fi

echo "正在使用NDK: $ANDROID_NDK"

# 检查CMakeLists.txt文件
if [ ! -f "CMakeLists.txt" ]; then
  echo "错误: 找不到CMakeLists.txt文件"
  exit 1
fi

# 创建构建目录
mkdir -p build

# 设置编译的ABI和API级别
ABIS=("armeabi-v7a" "arm64-v8a" "x86")
API_LEVEL=21

# 编译各个架构
for ABI in "${ABIS[@]}"; do
  echo "编译 $ABI 版本..."
  
  # 创建特定架构的构建目录
  mkdir -p "build/$ABI"
  cd "build/$ABI"
  
  # 使用CMake配置项目
  cmake ../.. \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$ABI \
    -DANDROID_PLATFORM=android-$API_LEVEL \
    -DCMAKE_BUILD_TYPE=Release
  
  # 编译项目
  cmake --build . -- -j4
  
  # 返回原目录
  cd ../..
done

# 创建最终输出目录
mkdir -p output/lib
mkdir -p output/include

# 复制编译结果
for ABI in "${ABIS[@]}"; do
  mkdir -p "output/lib/$ABI"
  cp "build/$ABI/lib/$ABI/libsqlite3.so" "output/lib/$ABI/"
done

# 复制头文件
cp sqlite3.h output/include/
cp sqlite3ext.h output/include/

# 检查编译结果
if [ -f output/lib/armeabi-v7a/libsqlite3.so ] && \
   [ -f output/lib/arm64-v8a/libsqlite3.so ] && \
   [ -f output/lib/x86/libsqlite3.so ]; then
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