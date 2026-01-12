#!/bin/bash

# Розширений скрипт підрахунку файлів

TARGET_DIR="/etc"

# Функція для підрахунку
count_items() {
    local dir=$1
    local type=$2
    find "$dir" -maxdepth 1 -type "$type" 2>/dev/null | wc -l
}

# Підрахунок різних типів
files=$(count_items "$TARGET_DIR" "f")
dirs=$(count_items "$TARGET_DIR" "d")
links=$(count_items "$TARGET_DIR" "l")

# Виведення результатів
echo "Статистика директорії $TARGET_DIR:"
echo "  Звичайні файли: $files"
echo "  Директорії: $((dirs - 1))"  # Віднімаємо саму директорію
echo "  Символічні посилання: $links"
echo "  -------------------------"
echo "  Разом (тільки файли): $files"

