#!/usr/bin/env bash
set -euo pipefail

# Lab Claude Skills Installer
# Creates symlinks from ~/.claude/skills/ to this repo's skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 [OPTIONS] [SKILL_NAME ...]"
    echo ""
    echo "Install lab Claude Code skills by creating symlinks in ~/.claude/skills/"
    echo ""
    echo "Options:"
    echo "  --list       List all available skills"
    echo "  --status     Show installation status of all skills"
    echo "  --update     Pull latest changes and install any new skills"
    echo "  --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Install all skills"
    echo "  $0 data-handling r-renv     # Install specific skills only"
    echo "  $0 --status                 # Check what's installed"
    echo "  $0 --update                 # Pull latest + install new skills"
}

list_skills() {
    echo -e "${BLUE}Available skills:${NC}"
    echo ""
    for skill_dir in "$SKILLS_SRC"/*/; do
        skill_name=$(basename "$skill_dir")
        # Extract description from SKILL.md frontmatter
        desc=$(sed -n 's/^description: *//p' "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/|$//' | xargs)
        if [ -n "$desc" ]; then
            printf "  %-30s %s\n" "$skill_name" "$desc"
        else
            printf "  %-30s %s\n" "$skill_name" "(no description)"
        fi
    done
}

show_status() {
    echo -e "${BLUE}Skill installation status:${NC}"
    echo ""
    local linked=0 local_copy=0 absent=0
    for skill_dir in "$SKILLS_SRC"/*/; do
        skill_name=$(basename "$skill_dir")
        dst="$SKILLS_DST/$skill_name"

        if [ -L "$dst" ]; then
            link_target=$(readlink "$dst")
            if [ "$link_target" = "$skill_dir" ] || [ "$link_target" = "${skill_dir%/}" ]; then
                echo -e "  ${GREEN}[linked]${NC}  $skill_name"
                ((linked++)) || true
            else
                echo -e "  ${YELLOW}[other]${NC}   $skill_name -> $link_target"
            fi
        elif [ -d "$dst" ]; then
            # Check if local copy differs from repo version
            if diff -q "$dst/SKILL.md" "$skill_dir/SKILL.md" &>/dev/null; then
                echo -e "  ${YELLOW}[local]${NC}   $skill_name (local copy, matches repo)"
            else
                echo -e "  ${YELLOW}[local]${NC}   $skill_name (local copy, ${RED}differs from repo${NC})"
            fi
            ((local_copy++)) || true
        else
            echo -e "  ${RED}[absent]${NC}  $skill_name"
            ((absent++)) || true
        fi
    done
    echo ""
    echo -e "  ${GREEN}$linked linked${NC}, ${YELLOW}$local_copy local${NC}, ${RED}$absent not installed${NC}"
    if [ "$absent" -gt 0 ]; then
        echo -e "  Run ${BLUE}$0${NC} to install missing skills"
    fi
}

do_update() {
    echo -e "${BLUE}Updating lab skills...${NC}"
    echo ""

    # Pull latest changes
    echo "  Pulling latest from git..."
    if git -C "$SCRIPT_DIR" pull --ff-only 2>&1 | sed 's/^/    /'; then
        echo -e "  ${GREEN}[ok]${NC}  Repository updated"
    else
        echo -e "  ${YELLOW}[warn]${NC}  git pull failed — you may have local changes or need to merge"
        echo "          Try: cd $SCRIPT_DIR && git status"
        return 1
    fi
    echo ""

    # Install any new skills that aren't linked yet
    echo "  Checking for new skills..."
    local new_count=0
    mkdir -p "$SKILLS_DST"
    for skill_dir in "$SKILLS_SRC"/*/; do
        skill_name=$(basename "$skill_dir")
        dst="$SKILLS_DST/$skill_name"
        if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
            install_skill "$skill_name"
            ((new_count++)) || true
        fi
    done

    if [ "$new_count" -eq 0 ]; then
        echo -e "  ${GREEN}[ok]${NC}  No new skills to install"
    fi

    # Report any local copies that now differ
    echo ""
    echo "  Checking for outdated local copies..."
    local outdated=0
    for skill_dir in "$SKILLS_SRC"/*/; do
        skill_name=$(basename "$skill_dir")
        dst="$SKILLS_DST/$skill_name"
        if [ -d "$dst" ] && [ ! -L "$dst" ]; then
            if ! diff -q "$dst/SKILL.md" "$skill_dir/SKILL.md" &>/dev/null; then
                echo -e "  ${YELLOW}[outdated]${NC} $skill_name — local copy differs from updated repo"
                ((outdated++)) || true
            fi
        fi
    done

    if [ "$outdated" -eq 0 ]; then
        echo -e "  ${GREEN}[ok]${NC}  All local copies up to date"
    else
        echo ""
        echo -e "  ${YELLOW}$outdated local copy/copies differ from repo.${NC}"
        echo "  To see what changed:  diff ~/.claude/skills/SKILL_NAME/SKILL.md $SKILLS_SRC/SKILL_NAME/SKILL.md"
        echo "  To accept repo version: rm -r ~/.claude/skills/SKILL_NAME && $0 SKILL_NAME"
    fi

    echo ""
    echo -e "${GREEN}Update complete!${NC}"
}

install_skill() {
    local skill_name="$1"
    local src="$SKILLS_SRC/$skill_name"
    local dst="$SKILLS_DST/$skill_name"

    if [ ! -d "$src" ]; then
        echo -e "  ${RED}[error]${NC}   $skill_name — not found in repo"
        return 1
    fi

    # If destination is already a symlink to us, skip
    if [ -L "$dst" ]; then
        link_target=$(readlink "$dst")
        if [ "$link_target" = "$src" ] || [ "$link_target" = "${src%/}" ]; then
            echo -e "  ${GREEN}[ok]${NC}      $skill_name (already linked)"
            return 0
        else
            echo -e "  ${YELLOW}[skip]${NC}    $skill_name — symlink exists pointing to: $link_target"
            echo "            Remove it first if you want to relink: rm $dst"
            return 0
        fi
    fi

    # If destination exists as a directory, warn and skip
    if [ -d "$dst" ]; then
        echo -e "  ${YELLOW}[skip]${NC}    $skill_name — local copy exists at $dst"
        echo "            Remove or rename it first if you want to link: mv $dst ${dst}.bak"
        return 0
    fi

    # Create symlink
    ln -s "$src" "$dst"
    echo -e "  ${GREEN}[linked]${NC}  $skill_name"
}

# Parse arguments
if [ $# -eq 0 ]; then
    # Install all skills
    echo -e "${BLUE}Installing all lab skills...${NC}"
    echo ""

    # Ensure destination directory exists
    mkdir -p "$SKILLS_DST"

    for skill_dir in "$SKILLS_SRC"/*/; do
        skill_name=$(basename "$skill_dir")
        install_skill "$skill_name"
    done

    echo ""
    echo -e "${GREEN}Done!${NC} Skills are symlinked from $SKILLS_DST"
    echo "To update later: $0 --update"
    exit 0
fi

case "$1" in
    --list)
        list_skills
        exit 0
        ;;
    --status)
        show_status
        exit 0
        ;;
    --update)
        do_update
        exit 0
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    --*)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    *)
        # Install specific skills
        echo -e "${BLUE}Installing selected skills...${NC}"
        echo ""

        mkdir -p "$SKILLS_DST"

        for skill_name in "$@"; do
            install_skill "$skill_name"
        done

        echo ""
        echo -e "${GREEN}Done!${NC}"
        exit 0
        ;;
esac