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

local custom_golangci_linter = "custom_golangci_linter"

return {
  {
    "mfussenegger/nvim-lint",
    init = function()
      -- Import the existing golangci-lint configuration for extension
      local golangcilint = require("lint.linters.golangcilint")
      for _, arg in ipairs(golangci_always_linters) do
        table.insert(golangcilint.args, #golangcilint.args, "--enable")
        table.insert(golangcilint.args, #golangcilint.args, arg)
      end
      require("lint").linters[custom_golangci_linter] = golangcilint
    end,
    opts = {
      linters_by_ft = {
        go = { custom_golangci_linter },
        ["*"] = { "codespell" },
      },
    },
  },
}
