#!/usr/bin/env bash
# macOS desired state — edit this file or run "make finder-setup" or "make dock-setup".
# Changes are applied from the interactive menu when you choose "Apply & exit".
#
# Line format: VAR=value  # [type:constraints]  Description
#   type: bool | int:min-max | string:opt1|opt2

# --- Finder -----------------------------------------------------------------
FINDER_SHOW_HIDDEN=true  # [bool]              Show hidden files (dotfiles)
FINDER_SHOW_EXTENSIONS=true  # [bool]              Show all file extensions
FINDER_POSIX_PATH_TITLE=false  # [bool]              Show full POSIX path in title bar
FINDER_SHOW_STATUS_BAR=true    # [bool]              Show status bar (item count, disk space)
FINDER_SHOW_PATH_BAR=true      # [bool]              Show path bar
FINDER_SEARCH_SCOPE="SCcf"  # [string:SCcf|SCev]  Default search scope
FINDER_EXTENSION_WARNING=true  # [bool]              Extension change warning
FINDER_LIBRARY_VISIBLE=true    # [bool]              Unhide ~/Library

# --- Dock -------------------------------------------------------------------
DOCK_TILE_SIZE=45              # [int:16-128]        Icon size in px
DOCK_MAGNIFICATION=true  # [bool]              Magnification on hover
DOCK_LARGE_SIZE=50             # [int:16-128]        Magnification max size in px
