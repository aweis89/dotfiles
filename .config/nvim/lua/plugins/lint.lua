return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- Define a custom golangcilint configuration
        golangcilint = {
          -- cmd = "golangci-lint",
          cmd = "/opt/homebrew/bin/golangci-lint",
          args = {
            "run",
            "--output.json.path=stdout",
            "--issues-exit-code=0",
            "--show-stats=false",

            "--enable=asasalint", -- check for pass []any as any in variadic func(...any)
            "--enable=asciicheck", -- checks that all code identifiers does not have non-ASCII symbols in the name
            "--enable=bidichk", -- Checks for dangerous unicode character sequences
            "--enable=bodyclose", -- checks whether HTTP response body is closed successfully
            "--enable=canonicalheader", -- canonicalheader checks whether net/http.Header uses canonical header
            "--enable=containedctx", -- containedctx is a linter that detects struct contained context.Context field
            "--enable=contextcheck", -- check whether the function uses a non-inherited context
            "--enable=copyloopvar", -- copyloopvar is a linter detects places where loop variables are copied
            "--enable=cyclop", -- checks function and package cyclomatic complexity
            "--enable=decorder", -- check declaration order and count of types, constants, variables and functions
            "--enable=dogsled", -- Checks assignments with too many blank identifiers
            "--enable=dupl", -- Tool for code clone detection
            "--enable=dupword", -- checks for duplicate words in the source code
            "--enable=durationcheck", -- check for two durations multiplied together
            "--enable=errcheck", -- checks for unchecked errors in Go code
            "--enable=errchkjson", -- Checks types passed to the json encoding functions
            "--enable=errname", -- Checks that sentinel errors are prefixed with the `Err` and error types are suffixed with the `Error`
            "--enable=errorlint", -- finds code that will cause problems with the error wrapping scheme in Go 1.13
            "--enable=exhaustive", -- check exhaustiveness of enum switch statements
            "--enable=fatcontext", -- detects nested contexts in loops and function literals
            "--enable=forbidigo", -- Forbids identifiers
            "--enable=forcetypeassert", -- finds forced type assertions
            "--enable=funlen", -- Tool for detection of long functions
            "--enable=ginkgolinter", -- enforces standards of using ginkgo and gomega
            "--enable=gochecksumtype", -- Run exhaustiveness checks on Go "sum types"
            "--enable=gocognit", -- Computes and checks the cognitive complexity of functions
            "--enable=goconst", -- Finds repeated strings that could be replaced by a constant
            "--enable=gocritic", -- Provides diagnostics that check for bugs, performance and style issues
            "--enable=gocyclo", -- Computes and checks the cyclomatic complexity of functions
            "--enable=godot", -- Check if comments end in a period
            "--enable=goheader", -- Checks if file header matches to pattern
            "--enable=gomoddirectives", -- Manage the use of 'replace', 'retract', and 'excludes' directives in go.mod
            "--enable=gomodguard", -- Allow and block list linter for direct Go module dependencies
            "--enable=goprintffuncname", -- Checks that printf-like functions are named with `f` at the end
            "--enable=gosec", -- Inspects source code for security problems
            "--enable=gosmopolitan", -- Report certain i18n/l10n anti-patterns in your Go codebase
            "--enable=govet", -- Examines Go source code and reports suspicious constructs
            "--enable=grouper", -- Analyze expression groups
            "--enable=iface", -- Detect the incorrect use of interfaces
            "--enable=importas", -- Enforces consistent import aliases
            "--enable=inamedparam", -- reports interfaces with unnamed method parameters
            "--enable=ineffassign", -- Detects when assignments to existing variables are not used
            "--enable=interfacebloat", -- Checks the number of methods inside an interface
            "--enable=intrange", -- finds places where for loops could make use of an integer range
            "--enable=loggercheck", -- Checks key value pairs for common logger libraries
            "--enable=maintidx", -- measures the maintainability index of each function
            "--enable=makezero", -- Finds slice declarations with non-zero initial length
            "--enable=mirror", -- reports wrong mirror patterns of bytes/strings usage
            "--enable=misspell", -- Finds commonly misspelled English words
            "--enable=musttag", -- enforce field tags in (un)marshaled structs
            "--enable=nakedret", -- Checks functions with naked returns are not longer than maximum size
            "--enable=nestif", -- Reports deeply nested if statements
            "--enable=nilerr", -- Finds code that returns nil even if it checks that the error is not nil
            "--enable=nilnil", -- Checks for simultaneous return of `nil` error and invalid value
            "--enable=nilnesserr", -- Checks for simultaneous return of `nil` error and invalid value
            "--enable=noctx", -- Finds sending http request without context.Context
            "--enable=nolintlint", -- Reports ill-formed or insufficient nolint directives
            "--enable=nosprintfhostport", -- Checks for misuse of Sprintf to construct a host with port in a URL
            "--enable=paralleltest", -- Detects missing usage of t.Parallel() method in Go test
            "--enable=perfsprint", -- Checks that fmt.Sprintf can be replaced with a faster alternative
            "--enable=prealloc", -- Finds slice declarations that could potentially be pre-allocated
            "--enable=predeclared", -- find code that shadows one of Go's predeclared identifiers
            "--enable=promlinter", -- Check Prometheus metrics naming via promlint
            "--enable=protogetter", -- Reports direct reads from proto message fields when getters should be used
            "--enable=reassign", -- Checks that package variables are not reassigned
            "--enable=recvcheck", -- checks for receiver type consistency
            "--enable=revive", -- Fast, configurable, extensible, flexible, and beautiful linter for Go
            "--enable=rowserrcheck", -- checks whether Rows.Err of rows is checked successfully
            "--enable=sloglint", -- ensure consistent code style when using log/slog
            "--enable=spancheck", -- Checks for mistakes with OpenTelemetry/Census spans
            "--enable=sqlclosecheck", -- Checks that sql.Rows, sql.Stmt, sqlx.NamedStmt, pgx.Query are closed
            "--enable=staticcheck", -- Set of rules from staticcheck
            "--enable=tagalign", -- check that struct tags are well aligned
            "--enable=tagliatelle", -- Checks the struct tags
            "--enable=testableexamples", -- checks if examples are testable
            "--enable=testifylint", -- Checks usage of github.com/stretchr/testify
            "--enable=thelper", -- detects tests helpers which is not start with t.Helper() method
            "--enable=tparallel", -- detects inappropriate usage of t.Parallel() method in Go test codes
            "--enable=unconvert", -- Remove unnecessary type conversions
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
