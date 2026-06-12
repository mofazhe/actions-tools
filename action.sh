#!/bin/sh

# Clean up any existing directory and initialize a new git repository
rm -rf "$CLONE_PATH"
mkdir "$CLONE_PATH" && cd "$CLONE_PATH"
git init
git remote add origin "$REPOSITORY"

echo "Analyzing target version: $REF ..."

# 1. Check if the target is a remote branch
if git ls-remote --heads origin "$REF" | grep -q "$REF"; then
    echo "Detected: [Branch]. Performing shallow fetch..."
    git fetch --depth 1 origin "$REF"
    git checkout FETCH_HEAD

    # 2. Check if the target is a remote tag
elif git ls-remote --tags origin "$REF" | grep -q "$REF"; then
    echo "Detected: [Tag]. Performing shallow fetch..."
    git fetch --depth 1 "origin refs/tags/$REF:refs/tags/$REF"
    git checkout "$REF"

    # 3. If it's neither a branch nor a tag, treat it as a Commit ID
else
    echo "No matching branch or tag found. Treating as [Commit ID]..."

    # Try to fetch the specific commit directly (efficient if supported by server)
    if git fetch --depth 1 origin "$REF" 2> /dev/null; then
        git checkout FETCH_HEAD
    else
        echo "Shallow fetch for commit failed. Falling back to full fetch..."
        # Fallback: Fetch all references if the server disallows fetching unadvertised commits
        git fetch origin
        git checkout "$REF"
    fi
fi

echo "Repository successfully cloned! Current commit info:"
git --no-pager log -1 --oneline
