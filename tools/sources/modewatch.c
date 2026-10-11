// modewatch.exe <origW> <origH> <origHz> — restore the desktop display mode once
// no game process (Client.exe / client_unpacked.exe) remains. Spawned by
// RC_GrandLocal.dll after it switches the desktop to 1280x768 for fullscreen=true.
// Retries/launcher restarts are covered: we wait until NO game process has
// existed for ~4s straight. Single instance via a named mutex.
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <tlhelp32.h>

static int game_alive(void) {
    HANDLE s = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (s == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32 pe; pe.dwSize = sizeof pe;
    int found = 0;
    if (Process32First(s, &pe)) {
        do {
            // case-insensitive: INT ships Client.exe, China ships client.exe
            if (!stricmp(pe.szExeFile, "Client.exe") || !stricmp(pe.szExeFile, "client_unpacked.exe")) { found = 1; break; }
        } while (Process32Next(s, &pe));
    }
    CloseHandle(s);
    return found;
}

int main(int argc, char** argv) {
    if (argc < 4) { printf("usage: modewatch <origW> <origH> <origHz>\n"); return 1; }
    int w = atoi(argv[1]), h = atoi(argv[2]), hz = atoi(argv[3]);
    HANDLE mtx = CreateMutexA(NULL, FALSE, "Global\\DJMaxTechnikaModeWatch");
    if (!mtx || GetLastError() == ERROR_ALREADY_EXISTS) return 0;   // another watcher owns the restore
    int quiet = 0;
    for (;;) {
        if (game_alive()) { quiet = 0; Sleep(2000); continue; }
        if (++quiet >= 2) break;    // ~4s with no game process
        Sleep(2000);
    }
    DEVMODEA dm; memset(&dm, 0, sizeof dm); dm.dmSize = sizeof dm;
    if (EnumDisplaySettingsA(NULL, ENUM_CURRENT_SETTINGS, &dm) &&
        ((int)dm.dmPelsWidth != w || (int)dm.dmPelsHeight != h)) {
        memset(&dm, 0, sizeof dm); dm.dmSize = sizeof dm;
        dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL;
        dm.dmPelsWidth = w; dm.dmPelsHeight = h; dm.dmBitsPerPel = 32;
        if (hz > 0) { dm.dmFields |= DM_DISPLAYFREQUENCY; dm.dmDisplayFrequency = hz; }
        int r = ChangeDisplaySettingsA(&dm, 0);   // dynamic, session-scoped
        FILE* f = fopen("modewatch.log", "a");
        if (f) { fprintf(f, "restored %dx%d@%d -> %d\n", w, h, hz, r); fclose(f); }
    }
    CloseHandle(mtx);
    return 0;
}
