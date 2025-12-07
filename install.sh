#!/bin/bash
# Install Claude Code AUv3 development configuration

set -e

REPO_URL="https://github.com/hagenkaiser/claude-code-auv3.git"
TEMP_DIR=$(mktemp -d)
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Code AUv3 config..."

# Clone repo
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null

# Create directories if needed
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/agents"

# Copy files
cp "$TEMP_DIR/skills/"*.md "$CLAUDE_DIR/skills/" 2>/dev/null || true
cp "$TEMP_DIR/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
cp "$TEMP_DIR/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true

# Cleanup
rm -rf "$TEMP_DIR"

echo "Done! Installed to $CLAUDE_DIR"
echo ""
echo "Files installed:"
echo "  - skills/audiokit-dsp.md"
echo "  - commands/create-auv3.md"
echo "  - agents/auv3-coordinator.md"
echo "  - agents/auv3-architect.md"
echo "  - agents/auv3-dsp-engineer.md"
echo "  - agents/auv3-ui-designer.md"
echo "  - agents/auv3-integrator.md"
