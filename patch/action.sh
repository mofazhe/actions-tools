#!/bin/bash

cd "$APPLY_DIR"
echo "Found patch dir: $PATCHES_DIR"

# 确保文件夹存在
if [ ! -d "$PATCHES_DIR" ]; then
    echo "Error: Directory '$PATCHES_DIR' does not exist!"
    exit 1
fi

# 检查文件夹内是否有符合条件的文件（排除空文件夹导致循环报错）
shopt -s nullglob
export LC_ALL=C
PATCH_FILES=($PATCHES_DIR/*.patch)
if [ ${#PATCH_FILES[@]} -eq 0 ]; then
    echo "Warning: No .patch files found in '$PATCHES_DIR'. Skipping..."
    exit 0
fi

for patch in "${PATCH_FILES[@]}"; do
    echo "Checking $patch ..."
    # 应用补丁前检查
    if ! git apply --check "$patch"; then
        echo "Error: Patch '$patch' cannot be applied cleanly due to conflicts!"
        exit 1
    fi
    # 应用补丁
    echo "Applying $patch ..."
    git apply "$patch"
done

echo "All patches verified successfully (No conflicts found)."
echo "Reviewing cumulative git diff:"
git --no-pager diff
