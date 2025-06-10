# SQLite Android 编译指南

本指南介绍如何编译支持 x86、ARM 32位(armeabi-v7a)和ARM 64位(arm64-v8a)架构的SQLite库。

## 前提条件

1. 安装Android NDK
   - 可以从[Android开发者网站](https://developer.android.com/ndk/downloads)下载
   - 推荐使用r21或更高版本的NDK

2. 设置环境变量
   ```bash
   export ANDROID_NDK=/path/to/android-ndk
   ```

3. 将[sqlite源码 sqlite-autoconf-xxx.tar.gz](https://www.sqlite.org/download.html)，解压到当前目录下，或者将当前目录下的所有代码拷贝到sqlite源码目录下 

## 编译方法1：使用NDK-Build

如果您想使用传统的ndk-build：

1. 文件:
   - `jni/Android.mk`: NDK编译配置文件
   - `jni/Application.mk`: 指定要支持的架构
   - `build-android.sh`: 编译脚本

2. 运行编译脚本:
   ```bash
   ./build-android.sh
   ```

## 编译方法2：直接使用NDK工具链（修复版）

这个方法使用NDK提供的Clang编译器直接编译SQLite：

1. 使用修复过的直接编译脚本:
   ```bash
   ./android-build.sh
   ```

2. 该脚本解决了以下问题：
   - 添加了`-fPIC`解决ARM relocation错误
   - 添加了`-fvisibility=hidden`解决符号可见性问题
   - 提高了API级别到21（解决某些兼容性问题）
   - 增加了错误检查和路径验证
   - 链接数学库(-lm)，解决某些数学函数依赖

## 编译方法3：使用CMake（推荐）

这是最现代化和稳定的方法：

1. 使用CMake构建系统：
   ```bash
   ./build-with-cmake.sh
   ```

2. 优势：
   - 更好的跨平台兼容性
   - 更现代的构建系统
   - 自动处理许多常见问题
   - 适用于所有主流NDK版本

## 编译输出

所有方法都会在`output/lib`目录生成：
- x86架构: `output/lib/x86/libsqlite3.so`
- ARM 32位架构: `output/lib/armeabi-v7a/libsqlite3.so`
- ARM 64位架构: `output/lib/arm64-v8a/libsqlite3.so`

头文件位于`output/include`目录。

## 自定义编译选项

各方法中，SQLite编译选项可以通过以下方式自定义：

1. NDK-Build方法：修改`jni/Android.mk`中的`LOCAL_CFLAGS`
2. 直接编译方法：修改`android-build.sh`中的`CFLAGS`变量
3. CMake方法：修改`CMakeLists.txt`中的`CMAKE_C_FLAGS`

常用的编译选项包括:
- `-DSQLITE_THREADSAFE=1`: 启用线程安全
- `-DSQLITE_ENABLE_FTS3`: 启用全文搜索
- `-DSQLITE_ENABLE_JSON1`: 启用JSON扩展
- `-DSQLITE_ENABLE_RTREE`: 启用R树索引
- `-DSQLITE_ENABLE_COLUMN_METADATA`: 启用列元数据

## 在Android项目中使用

1. 将生成的`libsqlite3.so`文件复制到Android项目的`src/main/jniLibs/<架构>/`目录下

2. 在代码中使用:
   ```java
   static {
       System.loadLibrary("sqlite3");
   }
   ```

3. 使用JNI接口调用SQLite API，或者使用Android内置的SQLite接口

## 常见问题解决

### 遇到 "Unknown host CPU architecture: arm64" 错误
这通常发生在使用Mac M1/M2芯片的电脑上。解决方法：
1. 使用方法2（直接使用NDK工具链）或方法3（CMake）编译
2. 或者在`build-android.sh`中添加`NDK_HOST_64BIT=1`参数

### 遇到 "requires unsupported dynamic reloc R_ARM_REL32" 错误
需要添加`-fPIC`选项。我们的修复版脚本已添加此选项。

### 遇到 "relocation R_386_GOTOFF against preemptible symbol" 错误
这是x86架构编译时的符号可见性问题，使用`-fvisibility=hidden`选项可以解决。

### 找不到编译器 (如 "aarch64-linux-android16-clang")
原因是API级别与NDK版本不匹配。我们的修复版脚本使用API级别21，并添加了错误检查。

### 编译过程中遇到其他错误
- 检查NDK版本是否兼容（推荐r21或更高版本）
- 确保SQLite源文件(`sqlite3.c`和`sqlite3.h`)存在
- 尝试使用CMake方法，它通常最可靠 