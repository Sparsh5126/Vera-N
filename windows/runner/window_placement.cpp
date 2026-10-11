#include "window_placement.h"

namespace window_placement {

namespace {

constexpr const wchar_t kKey[] = L"Software\\Vera N\\Window";
constexpr const wchar_t kValue[] = L"Placement";

bool WasMaximized(const WINDOWPLACEMENT& placement) {
  if (placement.showCmd == SW_SHOWMAXIMIZED) {
    return true;
  }
  // Closed while minimized: what it was before minimizing.
  return placement.showCmd == SW_SHOWMINIMIZED &&
         (placement.flags & WPF_RESTORETOMAXIMIZED) != 0;
}

}  // namespace

void Save(HWND window) {
  WINDOWPLACEMENT placement = {};
  placement.length = sizeof(placement);
  if (!GetWindowPlacement(window, &placement)) {
    return;
  }
  placement.showCmd = WasMaximized(placement) ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;
  placement.flags = 0;
  RegSetKeyValue(HKEY_CURRENT_USER, kKey, kValue, REG_BINARY, &placement,
                 sizeof(placement));
}

int Restore(HWND window) {
  WINDOWPLACEMENT placement = {};
  DWORD size = sizeof(placement);
  const LSTATUS result =
      RegGetValue(HKEY_CURRENT_USER, kKey, kValue, RRF_RT_REG_BINARY, nullptr,
                  &placement, &size);
  if (result != ERROR_SUCCESS || size != sizeof(placement) ||
      placement.length != sizeof(placement)) {
    return SW_SHOWNORMAL;
  }
  // A monitor that has since been unplugged: keep the default spot.
  if (MonitorFromRect(&placement.rcNormalPosition, MONITOR_DEFAULTTONULL) ==
      nullptr) {
    return SW_SHOWNORMAL;
  }
  const int show = WasMaximized(placement) ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;
  // Move it while it is still hidden; Show() reveals it later.
  placement.showCmd = SW_HIDE;
  placement.flags = 0;
  SetWindowPlacement(window, &placement);
  return show;
}

}  // namespace window_placement
