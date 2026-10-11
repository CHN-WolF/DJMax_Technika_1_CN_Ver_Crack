#!/bin/bash
# build_all.sh — one-shot build for every crack component and tool in sources/.
#
#   deliverables (deploy names; copy to game root / crack_work\tools as-is):
#     RC_GrandLocal.dll   <- rclocal_diag.c + thunks_gas.S + rclocal_diag.def
#                            + rclocal_replay.rc (embeds RC_GrandLocal_official.dll)
#     RCGrandDogW32.dll   <- rcreplay.c + rclogger.def   (replay SDK)
#     modewatch.exe       <- modewatch.c                 (display-mode watchdog)
#   sweep: every other sources/*.c with main()/DllMain -> <name>.exe / <name>.dll.
#   skipped on purpose (legacy variants, superseded by rclocal_diag.c):
#     rclocal_replay / rclocal_logger / rclocal_nopatch / rclogger
#   products land next to this script; intermediates (.o) go to a temp dir.
#   toolchain lookup: $W64DEVKIT -> ./toolchain -> up-N crack_work/tools/toolchain -> PATH.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$DIR/sources"
[ -d "$SRC" ] || { echo "sources/ not found next to $0"; exit 1; }

find_tc() {
    if [ -n "${W64DEVKIT:-}" ] && [ -x "${W64DEVKIT:-}/bin/gcc.exe" ]; then echo "$W64DEVKIT/bin"; return 0; fi
    local cand
    for cand in "$DIR/toolchain/w64devkit_x/w64devkit/bin" \
                "$DIR/../toolchain/w64devkit_x/w64devkit/bin" \
                "$DIR/../../tools/toolchain/w64devkit_x/w64devkit/bin" \
                "$DIR/../../../tools/toolchain/w64devkit_x/w64devkit/bin" \
                "$DIR/../../../../tools/toolchain/w64devkit_x/w64devkit/bin"; do
        if [ -x "$cand/gcc.exe" ]; then echo "$cand"; return 0; fi
    done
    if command -v gcc >/dev/null 2>&1 && command -v windres >/dev/null 2>&1; then echo ""; return 0; fi
    return 1
}
TC="$(find_tc)" || { echo "toolchain not found: set W64DEVKIT or put w64devkit_x under crack_work/tools/toolchain"; exit 1; }
GCC="${TC:+$TC/}gcc"; GCC="${GCC}.exe"
WINDRES="${TC:+$TC/}windres"; WINDRES="${WINDRES}.exe"
command -v "$GCC" >/dev/null || GCC="${GCC%.exe}"       # PATH mode: drop .exe
command -v "$WINDRES" >/dev/null || WINDRES="${WINDRES%.exe}"
echo "using: GCC=$GCC WINDRES=$WINDRES"

LOG="$DIR/build_all.log"
: > "$LOG"
pass=0; failed=""
ok() { pass=$((pass+1)); }
no() { failed="$failed $1"; echo "FAIL $1" >> "$LOG"; }

TMP="$DIR/.build.$$"
rm -rf "$TMP"; mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

# ---- deliverable 1: RC_GrandLocal.dll (local layer v13) ----
if [ -f "$SRC/rclocal_diag.c" ]; then
    echo "== RC_GrandLocal.dll" | tee -a "$LOG"
    if [ ! -f "$SRC/RC_GrandLocal_official.dll" ]; then
        echo "FAIL RC_GrandLocal.dll (sources/RC_GrandLocal_official.dll missing)" >> "$LOG"
        no RC_GrandLocal.dll
    elif ( cd "$SRC" && "$WINDRES" -F pe-i386 -i rclocal_replay.rc -o "$TMP/rclocal_diag_res.o" ) >> "$LOG" 2>&1 \
      && "$GCC" -m32 -O1 -mpreferred-stack-boundary=2 -Wall -Wno-unused -c "$SRC/rclocal_diag.c" -o "$TMP/rclocal_diag_c.o" >> "$LOG" 2>&1 \
      && "$GCC" -m32 -c "$SRC/thunks_gas.S" -o "$TMP/thunks_gas.o" >> "$LOG" 2>&1 \
      && "$GCC" -m32 -shared -static-libgcc -mpreferred-stack-boundary=2 \
             -o "$DIR/RC_GrandLocal.dll" \
             "$TMP/rclocal_diag_c.o" "$TMP/thunks_gas.o" "$TMP/rclocal_diag_res.o" "$SRC/rclocal_diag.def" \
             -lwinmm -Wl,--disable-auto-import >> "$LOG" 2>&1; then
        ok
    else
        no RC_GrandLocal.dll
    fi
fi

# ---- deliverable 2: RCGrandDogW32.dll (replay SDK) ----
if [ -f "$SRC/rcreplay.c" ]; then
    echo "== RCGrandDogW32.dll" | tee -a "$LOG"
    if "$GCC" -m32 -O2 -shared -static-libgcc -o "$DIR/RCGrandDogW32.dll" "$SRC/rcreplay.c" "$SRC/rclogger.def" >> "$LOG" 2>&1; then
        ok
    else
        no RCGrandDogW32.dll
    fi
fi

# ---- deliverable 3: modewatch.exe ----
if [ -f "$SRC/modewatch.c" ]; then
    echo "== modewatch.exe" | tee -a "$LOG"
    if "$GCC" -m32 -O2 -o "$DIR/modewatch.exe" "$SRC/modewatch.c" >> "$LOG" 2>&1; then
        ok
    else
        no modewatch.exe
    fi
fi

# ---- generic sweep: every other source with an entry point ----
SKIP=" rclocal_diag rcreplay modewatch rclocal_replay rclocal_logger rclocal_nopatch rclogger "
LIBS="-luser32 -lwinmm -liphlpapi -lsetupapi -lws2_32 -lole32 -lavrt -lpsapi"
for src in "$SRC"/*.c; do
    name="$(basename "${src%.c}")"
    case "$SKIP" in *" $name "*) continue;; esac
    if ! grep -q "DllMain\|int main\|WinMain" "$src"; then
        echo "SKIP $name (no main/DllMain)" >> "$LOG"
        continue
    fi
    if grep -q "DllMain" "$src"; then
        out="$DIR/$name.dll"; kind="-shared -static-libgcc"
    else
        out="$DIR/$name.exe"; kind=""
    fi
    if "$GCC" -m32 -O2 $kind -o "$out" "$src" >> "$LOG" 2>&1 \
       || "$GCC" -m32 -O2 $kind -o "$out" "$src" $LIBS >> "$LOG" 2>&1; then
        ok
    else
        echo "FAIL $name" >> "$LOG"
        no "$name"
    fi
done

echo
echo "built OK: $pass"
if [ -n "$failed" ]; then
    echo "FAILED/SKIPPED:$failed"
    echo "(details in build_all.log — legacy/MSVC-specific sources are expected there)"
fi
