module github.com/abitofhelp/hybrid_lib_go/api

go 1.23.0

require (
	github.com/abitofhelp/hybrid_lib_go/application v0.0.0
	github.com/abitofhelp/hybrid_lib_go/domain v0.0.0
)

replace (
	github.com/abitofhelp/hybrid_lib_go/application => ../application
	github.com/abitofhelp/hybrid_lib_go/domain => ../domain
)
