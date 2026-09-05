> ⚠️ **Under Active Development**  
> Syntax, directory structures, and core utility behavior are undergoing rapid iteration and may change between commits. Comprehensive documentation is currently **not a priority** while core features, internal dispatching, and framework utilities are being built and refined.

# windk

Windk (Windows Development Kit) scaffolds native Windows batch CLIs with a consistent, memory-efficient architecture: isolated executable proxies, INI-driven subcommand routing, ANSI formatting, zero runtime deps.


## Why Batch?

Writing custom command-line utilities in native `cmd.exe` usually turns into a mess of monolithic, hard-to-read batch files with variable collisions and fragile string parsing. `windk` fixes this while preserving the single biggest advantage of Batch: **zero external dependencies**.

* **Zero Setup**: Runs natively on any stock Windows machine straight out of the box.
* **Instant Cold-Start**: No runtime boot times (unlike Node.js, Python, or heavy PowerShell startup times).
* **Clean Terminal Scope**: Uses `setlocal`/`endlocal` memory guards in the entry wrapper so custom script variables never pollute your open terminal window.
* **Native Path Normalization**: Automatically converts relative paths (`..\lib\...`) into clean, absolute Windows file paths.

## Execution Flow

1. **Invocation & Entry Proxy**:
   * User invokes `windk` from the command line, resolving through the Windows `PATH` environment variable to `bin/windk.bat`.
   * **`bin/windk.bat`** establishes a `setlocal` boundary, captures raw CLI arguments via `%*`, and delegates execution down to the core engine dispatcher inside `tools/windk/cli.bat`.
2. **Environment & Subsystem Initialization**:
   * **`tools/windk/cli.bat`** receives the proxied call and initializes core framework utilities:
   * **`core/path_resolver.bat`** (Path Normalization Engine):
     * Converts relative paths into absolute Win32 target paths.
     * Normalizes trailing backslashes and resolves parent directory traversals (`..\`).
   * **`core/config_manager.bat`** (INI Parser & State Registry):
     * Iterates dynamically over `.cfg/.ini` section headers to register configuration keys into the framework's execution scope.
     * Evaluates `@:` alias pointers (e.g., `h=@:help`), resolving shortcut keys directly to their primary script target without duplicating target strings.
     * Uses the path resolver to expand relative script locations into fully qualified paths.
   * **`core/ansi_codes.bat`** (VT100 Terminal Styling Subsystem):
     * Generates fast VT100 ANSI escape sequences via internal `cmd.exe` prompt expansion.
     * Queries Windows version information (`ver` build numbers) to verify native virtual terminal processing support (Windows 10 Build 10586+).
     * Honors the industry-standard `NO_COLOR` environment variable, safely degrading to plain text when requested or unsupported.
3. **Argument Parsing & Routing**:
   * **Flag Intercept**: If a standalone flag (e.g., `-h`, `--help`) is detected before a positional argument, its mapped script (or resolved `@:` alias) executes immediately and terminates the pipeline.
   * **Subcommand Routing**: If a positional command (e.g., `windk create test`) is provided, `tool/toolname/cli.bat` locates the corresponding script handler, resolves any alias redirects, and forwards remaining flags and arguments down to the target executable batch script.
4. **Environment Block Cleanup**:
   * Upon completion, control returns to `bin/windk.bat`, which fires its `endlocal` boundary. This immediately purges all temporary runtime variables and aliases from memory, returning a clean shell state to the caller with the appropriate exit code (`ERRORLEVEL`).

## Configuration

In Windk's architecture, each tool's configuration files live inside its own folder — `tool/toolname/` — rather than in a shared location.

```ini
[main]
name=windk
version=0.1.0

[flag]
help=..\lib\__help\windk-help.bat
h=@:help

[command]
create=..\lib\commands\create.bat
c=@:create
```

## License

MIT License

Copyright (c) Michael Arakilian.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
