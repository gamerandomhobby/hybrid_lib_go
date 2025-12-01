# Library with Hexagonal Architecture

[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE) [![Go](https://img.shields.io/badge/Go-1.23+-00ADD8.svg)](https://go.dev)

**Version:** 1.0.0<br>
**Date:** 2025-11-29<br>
**SPDX-License-Identifier:** BSD-3-Clause<br>
**License File:** See the LICENSE file in the project root<br>
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.<br>
**Status:** Released

## Overview

A **professional Go library** demonstrating **hybrid DDD/Clean/Hexagonal architecture** with **strict module boundaries** enforced via Go workspaces and **functional programming** principles using custom **domain-level Result monads** (ZERO external dependencies in domain layer).

> **Library Template:** This project serves as a **template for enterprise Go library development**. Use the included `scripts/python/brand_project/brand_project.py` script to generate a new project from this template with your own project name, module paths, and branding.

This is a **reusable library** showcasing:
- **4-Layer Hexagonal Architecture** (Domain, Application, Infrastructure, API)
- **Strict Module Boundaries** via go.work and separate go.mod per layer
- **Static Dispatch via Generics** (zero-overhead dependency injection)
- **Railway-Oriented Programming** with Result monads (no panics across boundaries)
- **API Facade Pattern** for clean public interface
- **Multi-Module Workspace** (compiler-enforced boundaries)

## Features

- ✅ 4-layer hexagonal architecture (Domain, Application, Infrastructure, API)
- ✅ Custom domain Result monads (ZERO external dependencies)
- ✅ Static dispatch via generics (zero-overhead DI)
- ✅ API facade pattern for clean public interface
- ✅ Module boundary enforcement via go.mod
- ✅ Composition root pattern (`api/adapter/desktop`)
- ✅ Custom writer support for testing
- ✅ Comprehensive Makefile automation

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Desktop** | ✅ Full | Console I/O via `api/adapter/desktop` |
| **Custom** | 🔧 Custom | Requires Writer interface implementation |

### Custom Platform Support

This library uses a **composition root pattern** with dependency injection for platform portability:

| Package | Purpose |
|---------|---------|
| `api/` | Public facade, re-exports types (no infrastructure imports) |
| `api/adapter/desktop/` | Composition root for desktop (ConsoleWriter) |
| `application/port/` | Port interfaces (Writer) |

**Default**: Desktop platforms use console I/O via `api/adapter/desktop`.

**For custom platforms**, create your own composition root:

```go
// 1. Implement the Writer interface for your platform
type UARTWriter struct{}

func (w *UARTWriter) Write(message string) result.Result[result.Unit] {
    // Write to UART...
    return result.Ok(result.UnitValue)
}

// 2. Create operations with your writer
ops := operations.New(&UARTWriter{})

// 3. Use operations directly
res := ops.Greet(cmd)
```

See **[All About Our API](docs/guides/all_about_our_api.md)** for detailed architecture and implementation guidance.

## Architecture

### Module Structure

**Strict boundaries enforced by Go modules:**

```
hybrid_lib_go/
├── go.work                          # Workspace definition (manages all modules)
├── domain/                          # Module: Pure business logic (ZERO external dependencies)
│   └── go.mod                       # ZERO external dependencies - custom Result types
├── application/                     # Module: Use cases and ports
│   └── go.mod                       # Depends ONLY on domain
├── infrastructure/                  # Module: Driven adapters
│   └── go.mod                       # Depends on application + domain
├── api/                             # Module: Public facade (re-exports types)
│   ├── go.mod                       # Depends on application + domain (NOT infrastructure)
│   └── adapter/
│       └── desktop/                 # Sub-module: Composition root
│           └── go.mod               # Depends on ALL modules (wires infrastructure)
└── test/
    └── integration/                 # Integration tests for API usage
```

### Key Architectural Rules

**4-Layer Library Architecture:**

| Layer | Dependencies | Purpose |
|-------|-------------|---------|
| `domain/` | NONE | Pure business logic, value objects, Result monad |
| `application/` | domain | Use cases, ports, commands |
| `infrastructure/` | application, domain | Adapters (ConsoleWriter, etc.) |
| `api/` | application, domain | Public facade, re-exports types |
| `api/adapter/desktop/` | ALL | Composition root, wires infrastructure |

**Critical Boundary Rules:**
- **api/** re-exports types but does NOT import infrastructure
- **api/adapter/desktop/** (composition root) CAN import infrastructure
- **Domain** has ZERO external dependencies
- All dependencies flow INWARD toward Domain

## Quick Start

### Prerequisites

- **Go 1.23+** (for workspace and generics support)
- **Make** (for build automation)
- **Python 3** (optional, for architecture validation)

### Building

```bash
# Build all library modules
make build

# Clean artifacts
make clean
```

### Running

**Basic Usage (with convenience component):**

```go
import (
    "context"
    "github.com/abitofhelp/hybrid_lib_go/api"
    "github.com/abitofhelp/hybrid_lib_go/api/adapter/desktop"
)

func main() {
    // Create ready-to-use greeter
    greeter := desktop.NewGreeter()

    // Execute greeting
    ctx := context.Background()
    result := greeter.Execute(ctx, api.NewGreetCommand("Alice"))

    if result.IsOk() {
        // Greeting was written to console
    } else {
        errInfo := result.ErrorInfo()
        switch errInfo.Kind {
        case api.ValidationError:
            // Handle validation error
        case api.InfrastructureError:
            // Handle infrastructure error
        }
    }
}
```

## Usage

**Custom Writer (for testing or different output):**

```go
import (
    "context"
    "github.com/abitofhelp/hybrid_lib_go/api"
    "github.com/abitofhelp/hybrid_lib_go/api/adapter/desktop"
)

// Implement WriterPort interface
type MyWriter struct { /* ... */ }

func (w *MyWriter) Write(ctx context.Context, msg string) api.Result[api.Unit] {
    // Custom write logic
    return api.Ok(api.Unit{})
}

func main() {
    writer := &MyWriter{}
    greeter := desktop.GreeterWithWriter(writer)
    result := greeter.Execute(ctx, api.NewGreetCommand("Bob"))
}
```

### API Reference

**Types (via `api` package):**

| Type | Description |
|------|-------------|
| `Result[T]` | Result monad (Ok or Error) |
| `ErrorType` | Error information struct |
| `ErrorKind` | Error category (Validation, Infrastructure) |
| `Person` | Domain value object |
| `GreetCommand` | Input command |
| `WriterPort` | Output port interface |
| `Unit` | Void return type |

**Functions:**

| Function | Description |
|----------|-------------|
| `api.NewGreetCommand(name)` | Create a greet command |
| `api.CreatePerson(name)` | Create a Person value object |
| `api.Ok[T](value)` | Create successful Result |
| `api.Err[T](error)` | Create error Result |
| `desktop.NewGreeter()` | Create ready-to-use greeter |
| `desktop.GreeterWithWriter(w)` | Create greeter with custom writer |

## Testing

```bash
# Run all tests (unit + integration)
make test

# Run unit tests only
make test-unit

# Run integration tests
make test-integration

# Run with coverage
make test-coverage

# Validate architecture boundaries
make check-arch
```

**Test Structure:**
- **Unit tests**: Co-located with code (`*_test.go`)
- **Integration tests**: `test/integration/` with `//go:build integration` tag

## Documentation

- 📚 **[Quick Start Guide](docs/quick_start.md)** - Get up and running
- 📖 **[Documentation Index](docs/index.md)** - All documentation links
- 🏗️ **[Software Design Specification](docs/formal/software_design_specification.md)** - Architecture details
- 🎨 **[Architecture Diagrams](docs/diagrams/)** - Visual documentation

## Code Standards

This project follows:
- **Go Language Standards** (`~/.claude/agents/go.md`)
- **Architecture Standards** (`~/.claude/agents/architecture.md`)
- **Functional Programming Standards** (`~/.claude/agents/functional.md`)

### Key Standards Applied

1. **SPDX Headers:** All `.go` files have SPDX license headers
2. **Result Monads:** All fallible operations return `Result[T]`
3. **No Panics:** Errors are values, recovery patterns at boundaries
4. **Module Boundaries:** Compiler-enforced via go.mod
5. **Static Dispatch:** Generic types with interface constraints
6. **API Facade:** Clean public interface via api/ package

## Creating a New Project

Use the `brand_project.py` script to create a new library from this template:

```bash
cd scripts
python3 -m brand_project \
    --old-project hybrid_lib_go \
    --new-project my_library \
    --old-org abitofhelp \
    --new-org mycompany \
    --source /path/to/hybrid_lib_go \
    --target /path/to/my_library
```

**What gets updated:**
- Project name throughout all files
- GitHub organization/username in module paths
- Copyright holder information
- All `go.mod` module paths
- Import statements in Go source files

## Submodule Management

This project uses git submodules for shared Python tooling:

- `scripts/python` - Build, release, and architecture scripts
- `test/python` - Shared test fixtures and configuration

### Workflow

```
hybrid_python_scripts (source repo)
         │
         │ git push (manual)
         ▼
      GitHub
         │
         │ make submodule-update (in each consuming repo)
         ▼
┌─────────────────────────────────┐
│  1. Pull new submodule commit   │
│  2. Stage reference change      │
│  3. Commit locally              │
│  4. Push to remote              │
└─────────────────────────────────┘
```

### Commands

```bash
# After fresh clone
make submodule-init

# Pull latest from submodule repos
make submodule-update

# Check current submodule commits
make submodule-status
```

### Bulk Update (all repositories)

```bash
python3 ~/Python/src/github.com/abitofhelp/git/update_submodules.py

# Options:
#   --dry-run   Show what would happen without changes
#   --no-push   Update locally but do not push to remote
```

## Contributing

This project is not open to external contributions at this time.

## AI Assistance & Authorship

This project — including its source code, tests, documentation, and other deliverables — is designed, implemented, and maintained by human developers, with Michael Gardner as the Principal Software Engineer and project lead.

We use AI coding assistants (such as OpenAI GPT models and Anthropic Claude Code) as part of the development workflow to help with:

- drafting and refactoring code and tests,
- exploring design and implementation alternatives,
- generating or refining documentation and examples,
- and performing tedious and error-prone chores.

AI systems are treated as tools, not authors. All changes are reviewed, adapted, and integrated by the human maintainers, who remain fully responsible for the architecture, correctness, and licensing of this project.

## License

Copyright © 2025 Michael Gardner, A Bit of Help, Inc.

Licensed under the BSD-3-Clause License. See [LICENSE](LICENSE) for details.

## Author

Michael Gardner
A Bit of Help, Inc.
https://github.com/abitofhelp

## Project Status

**Status**: Production Ready (v1.0.0)

- ✅ 4-layer hexagonal architecture
- ✅ Custom domain Result monads (ZERO external dependencies)
- ✅ Static dispatch via generics (zero-overhead DI)
- ✅ API facade pattern for clean public interface
- ✅ Module boundary enforcement via go.mod
- ✅ Composition root pattern
- ✅ Custom writer support for testing
- ✅ Comprehensive Makefile automation
