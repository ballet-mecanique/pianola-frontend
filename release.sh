#!/usr/bin/env bash

set -e

# Ensure clean working tree
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ Working tree is dirty. Commit or stash first."
  exit 1
fi

# Get latest tag
LATEST_TAG=$(git describe --tags --abbrev=0)

if [[ ! "$LATEST_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "❌ Latest tag '$LATEST_TAG' does not match vX.Y.Z"
  exit 1
fi

echo "Latest tag: $LATEST_TAG"

# Strip "v" and split
VERSION=${LATEST_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# Bump patch
PATCH=$((PATCH + 1))
NEW_TAG="v$MAJOR.$MINOR.$PATCH"

echo "New tag: $NEW_TAG"

# Create tag
git tag "$NEW_TAG"

# Push tag
git push origin "$NEW_TAG"

# Create GitHub release
gh release create "$NEW_TAG" \
  --title "$NEW_TAG" \
  --generate-notes

echo "✅ Release $NEW_TAG published"
