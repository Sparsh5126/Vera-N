#ifndef RUNNER_WINDOW_PLACEMENT_H_
#define RUNNER_WINDOW_PLACEMENT_H_

#include <windows.h>

// Vera N: the window opens where it was last closed (docs/LAPTOP_PLAN.md,
// L5). The placement is per-computer window state, so it lives in the
// user's registry, never in the synced notes folder.
namespace window_placement {

// Remembers |window|'s size and position, and whether it was maximized.
void Save(HWND window);

// Puts the still-hidden |window| where it was last closed, if that spot is
// still on a monitor. Returns the show command to use: SW_SHOWMAXIMIZED if
// it was closed maximized, otherwise SW_SHOWNORMAL.
int Restore(HWND window);

}  // namespace window_placement

#endif  // RUNNER_WINDOW_PLACEMENT_H_
