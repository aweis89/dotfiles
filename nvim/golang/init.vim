function! GoTestFunc()
  let func_regex = cfi#format("^(Test_?)?%s$", "")
  execute "T go test -json -v -run '" . func_regex . "' ./... 2>&1" . '|gotestfmt'
endfunction

map tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tf :vsplit \| call GoTestFunc()<cr>
map tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tf :vsplit \| call GoTestFunc()<cr>

if !executable('gotests')
	!go get -u github.com/cweill/gotests/...
endif
