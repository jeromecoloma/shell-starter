#!/bin/bash
# Test timeout detection logic

echo "Testing timeout detection..."

# Save original PATH
ORIG_PATH="$PATH"

# Test with timeout available
echo ""
echo "=== With timeout available ==="
if command -v timeout >/dev/null 2>&1; then
    echo "✅ timeout command found"
else
    echo "❌ timeout command not found"
fi

# Test without timeout in PATH
echo ""
echo "=== Without timeout in PATH ==="
export PATH="/tmp"
if command -v timeout >/dev/null 2>&1; then
    echo "❌ timeout command should not be found"
else
    echo "✅ timeout command correctly not found"
fi

# Restore PATH
export PATH="$ORIG_PATH"
echo ""
echo "PATH restored"