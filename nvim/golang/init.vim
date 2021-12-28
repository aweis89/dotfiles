function! GoTestFunc()
  let func_regex = cfi#format("^(Test_?)?%s$", "")
  execute "T go test -json -v -run '" . func_regex . "' ./... 2>&1" . '|gotestfmt'
endfunction

map <C-k> :GoDeclsDir<cr>
nmap gf :GoFillStruct<cr>
map ga :GoAlternate<cr>
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
nmap <leader>i :GoInfo<cr>
nmap <C-i> :GoInfo<cr>
let g:go_metalinter_autosave = 0
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:delve_sign_priority = 10000
" let g:go_addtags_transform = "camelcase"
" Set custom templates for tests
let g:gotests_template_dir = stdpath('config') . '/golang/gotests-templates'

map <leader>dd :DlvToggleBreakpoint<cr>
map <leader>dt :DlvTest<cr>
map tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
map <leader>tf :vsplit \| call GoTestFunc()<cr>
