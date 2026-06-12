#!/bin/bash

if [[ "$PATCH_DIR" = /* ]]; then
    # 如果用户输入的是绝对路径，直接使用，不需要拼接
    ABS_PATCH_DIR="$PATCH_DIR"
else
    # 如果用户输入的是相对路径，则拼上 GitHub 的项目根目录变量，将其强制转换为绝对路径
    ABS_PATCH_DIR="$GITHUB_WORKSPACE/$PATCH_DIR"
fi

echo "Found patch dir: $ABS_PATCH_DIR"

# 确保文件夹存在
if [ ! -d "$ABS_PATCH_DIR" ]; then
    echo "Error: Directory '$ABS_PATCH_DIR' does not exist!"
    exit 1
fi

# 检查文件夹内是否有符合条件的文件（排除空文件夹导致循环报错）
shopt -s nullglob
export LC_ALL=C
PATCH_FILES=("$ABS_PATCH_DIR"/*.patch)
if [ ${#PATCH_FILES[@]} -eq 0 ]; then
    echo "Warning: No .patch files found in '$ABS_PATCH_DIR'. Skipping..."
    exit 0
fi
shopt -u nullglob

cd "$APPLY_DIR"
for patch in "${PATCH_FILES[@]}"; do
    # echo "Checking $patch ..."
    # # 应用补丁前检查
    # if ! git apply --check "$patch"; then
    #     echo "Error: Patch '$patch' cannot be applied cleanly due to conflicts!"
    #     exit 1
    # fi
    # # 应用补丁
    # echo "Applying $patch ..."
    # git apply "$patch"

    echo "Applying $patch ..."
    # --ignore-space-change: 兼容 Windows/Linux 换行符和空格差异
    # --whitespace=fix: 自动修复行尾多余空格
    if git apply --ignore-space-change --whitespace=fix "$patch"; then
        echo "SUCCESS: Patch $(basename "$patch") applied successfully."
    else
        echo "CRITICAL ERROR: Failed to apply patch $(basename "$patch")."
        exit 1
    fi
done

echo "All patches verified successfully (No conflicts found)."
echo "Reviewing cumulative git diff:"
git --no-pager diff
