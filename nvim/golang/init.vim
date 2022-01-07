function! GoTestFunc()
  let func_regex = cfi#format("^(Test_?)?%s$", "")
  execute "T go test -json -v -run '" . func_regex . "' ./... 2>&1" . '|gotestfmt'
endfunction

map <C-k> :GoDeclsDir<cr>
" nmap gf :GoFillStruct<cr>
" map ga :GoAlternate<cr>
nmap <leader>i :GoInfo<cr>
nmap <C-i> :GoInfo<cr>

let g:delve_sign_priority = 10000
" let g:go_addtags_transform = "camelcase"
" Set custom templates for tests
let g:gotests_template_dir = stdpath('config') . '/golang/gotests-templates'

map <leader>dd :DlvToggleBreakpoint<cr>
map <leader>dt :DlvTest<cr>
map tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tf :vsplit \| call GoTestFunc()<cr>

if !executable('gotests')
	!go get -u github.com/cweill/gotests/...
endif
