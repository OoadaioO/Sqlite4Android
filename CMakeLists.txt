cmake_minimum_required(VERSION 3.10)
project(sqlite3)

# 设置SQLite的编译选项
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_JSON1")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -DNDEBUG")

# 设置动态库输出目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/${ANDROID_ABI})

# 添加sqlite3库
add_library(sqlite3 SHARED sqlite3.c)

# 链接数学库（有些SQLite功能需要）
target_link_libraries(sqlite3 m)

# 安装头文件和库文件
install(FILES sqlite3.h sqlite3ext.h DESTINATION include)
install(TARGETS sqlite3 LIBRARY DESTINATION lib/${ANDROID_ABI}) 