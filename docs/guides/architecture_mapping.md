# Architecture Mapping: Go ↔ Ada (Library)

**Version:** 1.0.0
**Date:** November 26, 2025
**SPDX-License-Identifier:** BSD-3-Clause
**License File:** See the LICENSE file in the project root.
**Copyright:** (c) 2025 Michael Gardner, A Bit of Help, Inc.
**Status:** Released


**Purpose**: Educational tool showing how the same hexagonal architecture is implemented in Go and Ada libraries using each language's idioms.

## Core Principle

Both implementations follow **identical architecture** (Hybrid DDD/Clean/Hexagonal) but use **language-specific idioms** for implementation.

**Library vs Application Architecture**:
- **Application** (5 layers): domain → application → infrastructure, presentation → bootstrap
- **Library** (4 layers): domain → application → infrastructure → api

The library architecture removes presentation and bootstrap (app-only concerns) and adds an API layer as the public facade.

---

## Layer Dependency Rules (Library)

```
┌─────────────────────────────────────────────────────────────────┐
│                      PUBLIC API FACADE                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  api/                                                     │   │
│  │  - Re-exports domain and application types               │   │
│  │  - Does NOT import infrastructure                        │   │
│  │  - Public entry point for library consumers              │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  api/desktop/                                             │   │
│  │  - Platform-specific instantiation                        │   │
│  │  - Wires infrastructure adapters to application           │   │
│  │  - CAN import infrastructure                              │   │
│  └────────────────────────┬─────────────────────────────────┘   │
└───────────────────────────┼─────────────────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────────────────┐
│                    INTERNAL LAYERS                               │
│                           ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  infrastructure/                                          │   │
│  │  - Implements output ports                                │   │
│  │  - Imports: application, domain                           │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  application/                                             │   │
│  │  - Use cases, ports, commands                             │   │
│  │  - Imports: domain only                                   │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  domain/                                                  │   │
│  │  - Pure business logic                                    │   │
│  │  - ZERO external module dependencies                      │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Dependency Rules Summary

| Layer          | Can Import                          | Cannot Import            |
|----------------|-------------------------------------|--------------------------|
| domain         | (nothing)                           | all other layers         |
| application    | domain                              | infrastructure, api      |
| infrastructure | application, domain                 | api                      |
| api            | application, domain                 | infrastructure           |
| api/desktop    | api, application, domain, infrastructure | (composition root) |

**CRITICAL**: The `api` package does NOT import infrastructure. Infrastructure is wired inside platform-specific sub-packages like `api/desktop`.

---

## File-by-File Mapping

### Domain Layer (Pure Business Logic - ZERO external module dependencies)

| Go | Ada | Notes |
|----|-----|-------|
| `domain/valueobject/person.go` | `domain/domain-person.ads/adb` | Person value object |
| `domain/error/result.go` | `domain/domain-result.ads/adb` | Result monad type |

**Key Points**:
- **Go**: Result monad defined in domain (no external dependencies)
- **Ada**: Generic_Result defined in domain
- **Both**: Pure value objects, immutable, with validation

---

### Application Layer (Use Cases + Ports)

| Go | Ada | Notes |
|----|-----|-------|
| `application/model/unit.go` | `application/application-unit_type.ads` | Unit type for void returns |
| `application/port/outbound/writer.go` | `application/application-console_port.ads` | Output port interface |
| `application/port/inbound/greet.go` | N/A (generic param) | Input port interface |
| `application/command/greet.go` | N/A | Command DTO |
| `application/usecase/greet.go` | `application/usecase/application-usecase-greet.ads/adb` | Use case with static dispatch |

**Static Dispatch Pattern**:

**Go**:
```go
type GreetUseCase[W WriterPort] struct {
    writer W  // Compile-time binding via generics
}
```

**Ada**:
```ada
generic
   with function Console_Write(...) return Result;
package Use_Case is
   -- Compile-time binding via generic instantiation
end Use_Case;
```

---

### Infrastructure Layer (Adapters)

| Go | Ada | Notes |
|----|-----|-------|
| `infrastructure/adapter/consolewriter.go` | `infrastructure/adapter/infrastructure-adapter-console_writer.ads/adb` | Console output adapter |

**Pattern**: Implements WriterPort interface, converts I/O errors to Result types.

---

### API Layer (Public Facade) - LIBRARY SPECIFIC

| Go | Ada | Notes |
|----|-----|-------|
| `api/api.go` | `api/api.ads` | Re-exports domain and application types |
| `api/desktop/desktop.go` | `api/desktop/desktop.ads/adb` | Platform-specific wiring |

**Key Insight**: The API layer provides a clean public interface:
- **api/**: Re-exports types (Result, Person, GreetCommand, etc.)
- **api/desktop/**: Creates ready-to-use greeter with infrastructure wired

**Usage Example**:
```go
import "github.com/abitofhelp/hybrid_lib_go/api"
import "github.com/abitofhelp/hybrid_lib_go/api/desktop"

greeter := desktop.NewGreeter()
result := greeter.Execute(ctx, api.NewGreetCommand("Alice"))
```

---

## Comparison: App vs Library Architecture

| App Layer | Lib Layer | Purpose |
|-----------|-----------|---------|
| domain | domain | Pure business logic |
| application | application | Use cases and ports |
| infrastructure | infrastructure | Adapter implementations |
| presentation | ❌ (removed) | CLI/UI (app-only) |
| bootstrap | ❌ (removed) | Composition root (app-only) |
| ❌ (none) | api | Public facade (lib-only) |
| ❌ (none) | api/desktop | Platform wiring (lib-only) |

---

## Summary

### Direct Mappings:
1. Person value object
2. Unit type
3. Console Writer adapter
4. Use Case (Greet)
5. Result monad pattern
6. API facade pattern

### Same Concept, Different Idiom:
1. **Ports**: Go uses interfaces, Ada uses generic formal parameters
2. **Context**: Go passes explicitly, Ada uses built-in task features
3. **Static Dispatch**: Go uses interface+generics, Ada uses pure generics

### Library-Specific Patterns:
1. **API Facade**: Public entry point re-exporting internal types
2. **Platform Sub-packages**: api/desktop wires infrastructure
3. **No presentation/bootstrap**: These are application concerns

### Educational Value:
- Students learn **library architecture** patterns
- Shows how **same architecture** works for libraries vs applications
- Demonstrates **facade pattern** for clean public APIs
