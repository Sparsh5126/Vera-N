# Vera N patch to local_auth_windows 2.0.2

Visual Studio 2026 no longer accepts the legacy `/await` coroutine switch
this plugin passed, and the plugin's code relied on it (a plain `return`
inside a coroutine). Two changes, nothing else:

1. `windows/CMakeLists.txt`: the `/await` option on the plugin target is
   removed; the plugin already builds as C++20, which has coroutines.
2. `windows/local_auth_plugin.cpp` line 75: `return consent_result;` became
   `co_return consent_result;`.

The `example/`, `test/` and `pigeons/` (code-generator input) folders were left out. Used through
`dependency_overrides` in pubspec.yaml; drop this copy once an upstream
release builds with Visual Studio 2026.
