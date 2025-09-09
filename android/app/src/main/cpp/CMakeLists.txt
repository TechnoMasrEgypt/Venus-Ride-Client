cmake_minimum_required(VERSION 3.18.1)

project(tiny_elf C)

set(CMAKE_C_STANDARD 11)

# Optimize for size
add_compile_options(-Os -fdata-sections -ffunction-sections)
add_link_options(-Wl,--gc-sections -Wl,-s)

add_executable(tiny_elf main.c)