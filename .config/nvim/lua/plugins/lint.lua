local golangci_always_linters = {
  "asasalint", -- check for pass []any as any in variadic func(...any)
  "asciicheck", -- checks that all code identifiers does not have non-ASCII symbols in the name
  "bidichk", -- Checks for dangerous unicode character sequences
  "bodyclose", -- checks whether HTTP response body is closed successfully
  "canonicalheader", -- canonicalheader checks whether net/http.Header uses canonical header
  "containedctx", -- containedctx is a linter that detects struct contained context.Context field
  "contextcheck", -- check whether the function uses a non-inherited context
  "copyloopvar", -- copyloopvar is a linter detects places where loop variables are copied
  "cyclop", -- checks function and package cyclomatic complexity
  "decorder", -- check declaration order and count of types, constants, variables and functions
  "dogsled", -- Checks assignments with too many blank identifiers
  "dupl", -- Tool for code clone detection
  "dupword", -- checks for duplicate words in the source code
  "durationcheck", -- check for two durations multiplied together
  "errcheck", -- checks for unchecked errors in Go code
  "errchkjson", -- Checks types passed to the json encoding functions
  "errname", -- Checks that sentinel errors are prefixed with the `Err` and error types are suffixed with the `Error`
  "errorlint", -- finds code that will cause problems with the error wrapping scheme in Go 1.13
  "exhaustive", -- check exhaustiveness of enum switch statements
  -- "exhaustruct", -- Checks if all structure fields are initialized
  "fatcontext", -- detects nested contexts in loops and function literals
  "forbidigo", -- Forbids identifiers
  "forcetypeassert", -- finds forced type assertions
  "funlen", -- Tool for detection of long functions
  "gci", -- Controls Go package import order and makes it always deterministic
  "ginkgolinter", -- enforces standards of using ginkgo and gomega
  "gocheckcompilerdirectives", -- Checks that go compiler directive comments are valid
  "gochecknoglobals", -- Check that no global variables exist
  -- "gochecknoinits", -- Checks that no init functions are present in Go code
  "gochecksumtype", -- Run exhaustiveness checks on Go "sum types"
  "gocognit", -- Computes and checks the cognitive complexity of functions
  "goconst", -- Finds repeated strings that could be replaced by a constant
  "gocritic", -- Provides diagnostics that check for bugs, performance and style issues
  "gocyclo", -- Computes and checks the cyclomatic complexity of functions
  "godot", -- Check if comments end in a period
  -- "godox", -- Tool for detection of FIXME, TODO and other comment keywords
  "gofmt", -- Checks whether code was gofmt-ed
  "gofumpt", -- Checks whether code was gofumpt-ed
  "goheader", -- Checks if file header matches to pattern
  "goimports", -- Check import statements are formatted according to the 'goimport' command
  "gomoddirectives", -- Manage the use of 'replace', 'retract', and 'excludes' directives in go.mod
  "gomodguard", -- Allow and block list linter for direct Go module dependencies
  "goprintffuncname", -- Checks that printf-like functions are named with `f` at the end
  "gosec", -- Inspects source code for security problems
  "gosimple", -- Linter for Go source code that specializes in simplifying code
  "gosmopolitan", -- Report certain i18n/l10n anti-patterns in your Go codebase
  "govet", -- Examines Go source code and reports suspicious constructs
  "grouper", -- Analyze expression groups
  "iface", -- Detect the incorrect use of interfaces
  "importas", -- Enforces consistent import aliases
  "inamedparam", -- reports interfaces with unnamed method parameters
  "ineffassign", -- Detects when assignments to existing variables are not used
  "interfacebloat", -- Checks the number of methods inside an interface
  "intrange", -- finds places where for loops could make use of an integer range
  -- "ireturn", -- Accept Interfaces, Return Concrete Types
  -- "lll", -- Reports long lines
  "loggercheck", -- Checks key value pairs for common logger libraries
  "maintidx", -- measures the maintainability index of each function
  "makezero", -- Finds slice declarations with non-zero initial length
  "mirror", -- reports wrong mirror patterns of bytes/strings usage
  "misspell", -- Finds commonly misspelled English words
  -- "mnd", -- An analyzer to detect magic numbers
  "musttag", -- enforce field tags in (un)marshaled structs
  "nakedret", -- Checks functions with naked returns are not longer than maximum size
  "nestif", -- Reports deeply nested if statements
  "nilerr", -- Finds code that returns nil even if it checks that the error is not nil
  "nilnil", -- Checks for simultaneous return of `nil` error and invalid value
  -- "nlreturn", -- checks for a new line before return and branch statements
  "noctx", -- Finds sending http request without context.Context
  "nolintlint", -- Reports ill-formed or insufficient nolint directives
  -- "nonamedreturns", -- Reports all named returns
  "nosprintfhostport", -- Checks for misuse of Sprintf to construct a host with port in a URL
  "paralleltest", -- Detects missing usage of t.Parallel() method in Go test
  "perfsprint", -- Checks that fmt.Sprintf can be replaced with a faster alternative
  "prealloc", -- Finds slice declarations that could potentially be pre-allocated
  "predeclared", -- find code that shadows one of Go's predeclared identifiers
  "promlinter", -- Check Prometheus metrics naming via promlint
  "protogetter", -- Reports direct reads from proto message fields when getters should be used
  "reassign", -- Checks that package variables are not reassigned
  "recvcheck", -- checks for receiver type consistency
  "revive", -- Fast, configurable, extensible, flexible, and beautiful linter for Go
  "rowserrcheck", -- checks whether Rows.Err of rows is checked successfully
  "sloglint", -- ensure consistent code style when using log/slog
  "spancheck", -- Checks for mistakes with OpenTelemetry/Census spans
  "sqlclosecheck", -- Checks that sql.Rows, sql.Stmt, sqlx.NamedStmt, pgx.Query are closed
  "staticcheck", -- Set of rules from staticcheck
  "stylecheck", -- Stylecheck is a replacement for golint
  "tagalign", -- check that struct tags are well aligned
  "tagliatelle", -- Checks the struct tags
  "tenv", -- detects using os.Setenv instead of t.Setenv since Go1.17
  "testableexamples", -- checks if examples are testable
  "testifylint", -- Checks usage of github.com/stretchr/testify
  -- "testpackage", -- makes you use a separate _test package
  "thelper", -- detects tests helpers which is not start with t.Helper() method
  "tparallel", -- detects inappropriate usage of t.Parallel() method in Go test codes
  "unconvert", -- Remove unnecessary type conversions
  "unparam", -- Reports unused function parameters
  "unused", -- Checks Go code for unused constants, variables, functions and types
  "usestdlibvars", -- detect the possibility to use variables/constants from the Go standard library
  -- "varnamelen", -- checks that the length of a variable's name matches its scope
  "wastedassign", -- Finds wasted assignment statements
  "whitespace", -- checks for unnecessary newlines at the start and end of functions
  "wrapcheck", -- Checks that errors returned from external packages are wrapped
  -- "wsl", -- add or remove empty lines
}

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- Define a custom golangcilint configuration
        golangcilint = {
          -- Ensure the command is explicitly defined here
          cmd = "golangci-lint",
          -- "ireturn", -- Accept Interfaces, Return Concrete Types
          -- "lll", -- Reports long lines
          -- "mnd", -- An analyzer to detect magic numbers
          -- "exhaustruct", -- Checks if all structure fields are initialized
          -- "gochecknoinits", -- Checks that no init functions are present in Go code
          -- "godox", -- Tool for detection of FIXME, TODO and other comment keywords
          -- "nlreturn", -- checks for a new line before return and branch statements
          -- "nonamedreturns", -- Reports all named returns
          -- "testpackage", -- makes you use a separate _test package
          -- "varnamelen", -- checks that the length of a variable's name matches its scope
          args = {
            "run",
            "--output.json.path=stdout",
            "--issues-exit-code=0",
            "--show-stats=false",
            -- "--enable=asasalint", -- check for pass []any as any in variadic func(...any)
            -- "--enable=asciicheck", -- checks that all code identifiers does not have non-ASCII symbols in the name
            -- "--enable=bidichk", -- Checks for dangerous unicode character sequences
            -- "--enable=bodyclose", -- checks whether HTTP response body is closed successfully
            -- "--enable=canonicalheader", -- canonicalheader checks whether net/http.Header uses canonical header
            -- "--enable=containedctx", -- containedctx is a linter that detects struct contained context.Context field
            -- "--enable=contextcheck", -- check whether the function uses a non-inherited context
            -- "--enable=copyloopvar", -- copyloopvar is a linter detects places where loop variables are copied
            -- "--enable=cyclop", -- checks function and package cyclomatic complexity
            -- "--enable=decorder", -- check declaration order and count of types, constants, variables and functions
            -- "--enable=dogsled", -- Checks assignments with too many blank identifiers
            -- "--enable=dupl", -- Tool for code clone detection
            -- "--enable=dupword", -- checks for duplicate words in the source code
            -- "--enable=durationcheck", -- check for two durations multiplied together
            -- "--enable=errcheck", -- checks for unchecked errors in Go code
            -- "--enable=errchkjson", -- Checks types passed to the json encoding functions
            -- "--enable=errname", -- Checks that sentinel errors are prefixed with the `Err` and error types are suffixed with the `Error`
            -- "--enable=errorlint", -- finds code that will cause problems with the error wrapping scheme in Go 1.13
            -- "--enable=exhaustive", -- check exhaustiveness of enum switch statements
            -- "--enable=fatcontext", -- detects nested contexts in loops and function literals
            -- "--enable=forbidigo", -- Forbids identifiers
            -- "--enable=forcetypeassert", -- finds forced type assertions
            -- "--enable=funlen", -- Tool for detection of long functions
            -- "--enable=gci", -- Controls Go package import order and makes it always deterministic
            -- "--enable=ginkgolinter", -- enforces standards of using ginkgo and gomega
            -- "--enable=gocheckcompilerdirectives", -- Checks that go compiler directive comments are valid
            -- "--enable=gochecknoglobals", -- Check that no global variables exist
            -- "--enable=gochecksumtype", -- Run exhaustiveness checks on Go "sum types"
            -- "--enable=gocognit", -- Computes and checks the cognitive complexity of functions
            -- "--enable=goconst", -- Finds repeated strings that could be replaced by a constant
            -- "--enable=gocritic", -- Provides diagnostics that check for bugs, performance and style issues
            -- "--enable=gocyclo", -- Computes and checks the cyclomatic complexity of functions
            -- "--enable=godot", -- Check if comments end in a period
            -- "--enable=gofmt", -- Checks whether code was gofmt-ed
            -- "--enable=gofumpt", -- Checks whether code was gofumpt-ed
            -- "--enable=goheader", -- Checks if file header matches to pattern
            -- "--enable=goimports", -- Check import statements are formatted according to the 'goimport' command
            -- "--enable=gomoddirectives", -- Manage the use of 'replace', 'retract', and 'excludes' directives in go.mod
            -- "--enable=gomodguard", -- Allow and block list linter for direct Go module dependencies
            -- "--enable=goprintffuncname", -- Checks that printf-like functions are named with `f` at the end
            -- "--enable=gosec", -- Inspects source code for security problems
            -- "--enable=gosimple", -- Linter for Go source code that specializes in simplifying code
            -- "--enable=gosmopolitan", -- Report certain i18n/l10n anti-patterns in your Go codebase
            -- "--enable=govet", -- Examines Go source code and reports suspicious constructs
            -- "--enable=grouper", -- Analyze expression groups
            -- "--enable=iface", -- Detect the incorrect use of interfaces
            -- "--enable=importas", -- Enforces consistent import aliases
            -- "--enable=inamedparam", -- reports interfaces with unnamed method parameters
            -- "--enable=ineffassign", -- Detects when assignments to existing variables are not used
            -- "--enable=interfacebloat", -- Checks the number of methods inside an interface
            -- "--enable=intrange", -- finds places where for loops could make use of an integer range
            -- "--enable=loggercheck", -- Checks key value pairs for common logger libraries
            -- "--enable=maintidx", -- measures the maintainability index of each function
            -- "--enable=makezero", -- Finds slice declarations with non-zero initial length
            -- "--enable=mirror", -- reports wrong mirror patterns of bytes/strings usage
            -- "--enable=misspell", -- Finds commonly misspelled English words
            -- "--enable=musttag", -- enforce field tags in (un)marshaled structs
            -- "--enable=nakedret", -- Checks functions with naked returns are not longer than maximum size
            -- "--enable=nestif", -- Reports deeply nested if statements
            -- "--enable=nilerr", -- Finds code that returns nil even if it checks that the error is not nil
            "--enable=nilnil", -- Checks for simultaneous return of `nil` error and invalid value
            "--enable=noctx", -- Finds sending http request without context.Context
            -- "--enable=nolintlint", -- Reports ill-formed or insufficient nolint directives
            -- "--enable=nosprintfhostport", -- Checks for misuse of Sprintf to construct a host with port in a URL
            -- "--enable=paralleltest", -- Detects missing usage of t.Parallel() method in Go test
            -- "--enable=perfsprint", -- Checks that fmt.Sprintf can be replaced with a faster alternative
            -- "--enable=prealloc", -- Finds slice declarations that could potentially be pre-allocated
            -- "--enable=predeclared", -- find code that shadows one of Go's predeclared identifiers
            -- "--enable=promlinter", -- Check Prometheus metrics naming via promlint
            -- "--enable=protogetter", -- Reports direct reads from proto message fields when getters should be used
            -- "--enable=reassign", -- Checks that package variables are not reassigned
            -- "--enable=recvcheck", -- checks for receiver type consistency
            -- "--enable=revive", -- Fast, configurable, extensible, flexible, and beautiful linter for Go
            -- "--enable=rowserrcheck", -- checks whether Rows.Err of rows is checked successfully
            "--enable=sloglint", -- ensure consistent code style when using log/slog
            "--enable=spancheck", -- Checks for mistakes with OpenTelemetry/Census spans
            "--enable=sqlclosecheck", -- Checks that sql.Rows, sql.Stmt, sqlx.NamedStmt, pgx.Query are closed
            "--enable=staticcheck", -- Set of rules from staticcheck
            -- "--enable=stylecheck", -- Stylecheck is a replacement for golint
            -- "--enable=tagalign", -- check that struct tags are well aligned
            -- "--enable=tagliatelle", -- Checks the struct tags
            -- "--enable=tenv", -- detects using os.Setenv instead of t.Setenv since Go1.17
            -- "--enable=testableexamples", -- checks if examples are testable
            "--enable=testifylint", -- Checks usage of github.com/stretchr/testify
            -- "--enable=thelper", -- detects tests helpers which is not start with t.Helper() method
            -- "--enable=tparallel", -- detects inappropriate usage of t.Parallel() method in Go test codes
            -- "--enable=unconvert", -- Remove unnecessary type conversions
            "--enable=unparam", -- Reports unused function parameters
            "--enable=unused", -- Checks Go code for unused constants, variables, functions and types
            "--enable=usestdlibvars", -- detect the possibility to use variables/constants from the Go standard library
            "--enable=wastedassign", -- Finds wasted assignment statements
            "--enable=whitespace", -- checks for unnecessary newlines at the start and end of functions
            "--enable=wrapcheck", -- Checks that errors returned from external packages are wrapped
            function()
              return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
            end,
          },
        },
      },
      linters_by_ft = {
        go = { "golangcilint" },
        ["*"] = { "codespell" },
      },
    },
  },
}
