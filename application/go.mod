// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.

module github.com/abitofhelp/hybrid_lib_go/application

go 1.23

// Application layer - Use cases and ports
// Depends ONLY on domain layer

require github.com/abitofhelp/hybrid_lib_go/domain v0.0.0

replace github.com/abitofhelp/hybrid_lib_go/domain => ../domain
