// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.

module github.com/abitofhelp/hybrid_lib_go/cmd/greeter

go 1.23

// Main entry point - depends only on bootstrap

require github.com/abitofhelp/hybrid_lib_go/bootstrap v0.0.0

replace github.com/abitofhelp/hybrid_lib_go/bootstrap => ../../bootstrap
