# Windk Tool Directory (`/tool`)

This directory contains the isolated implementations for all standalone tools, utilities, and CLI entry points.

---

## Architecture Rules

Because the utilities housed here are independent, **strict isolation must be maintained**:

1. **Self-Contained Isolation**
   * Every tool gets its own subfolder (e.g., `tool/c_nav/`, `tool/sysinfo/`).
   * A tool must **never** directly depend on or call scripts inside another tool's directory (e.g., `c_nav` must never call scripts in `sysinfo`).

2. **Launcher Proxy Pattern**
   * Code in `tool/toolname/` should not be executed directly by end-users.
   * Every executable tool must expose a lightweight proxy runner inside the root `bin/` directory (e.g., `bin/c.bat`), which delegates execution to `tools/toolname/cli.bat %*`.

3. **Core Dependencies (`/lib`)**
   * If your tool requires shared infrastructure—such as the JIT Configuration Engine (`config_manager.bat`) or ANSI color utilities—reference them relative to the top-level `/lib` directory.
   * Do not duplicate shared framework utilities inside individual tool folders.

---

## Creating a New Tool

To add a new utility to the suite:

1. Create a dedicated folder: `tool/toolname/`
2. Define the main entry script: `tool/toolname/cli.bat`
3. Add any private helpers or local configuration files inside `tool/toolname/`
4. Add a proxy launcher script to `bin/toolname.bat`:

```cmd
@echo off
:: Entry Proxy & Scope Guard
setlocal EnableExtensions EnableDelayedExpansion

:: Forward all arguments to the tool dispatcher
call "%~dp0..\tool\windk\cli.bat" %*

:: Store return code from dispatcher
set "EXIT_CODE=%ERRORLEVEL%"

:: Destroy all windk variables and restore user's previous environment
endlocal & exit /b %EXIT_CODE%
```
