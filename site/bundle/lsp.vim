" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" lsp.vim - LSP config
"
" Created by skywind on 2022/12/05
" Last Modified: 2022/12/05 13:53:14
"
"======================================================================


"----------------------------------------------------------------------
" completion keymaps
"----------------------------------------------------------------------
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() . "\<cr>" : "\<cr>"

function! s:refresh_dot()
	let hr = asyncomplete#force_refresh()
	return '.'
endfunc

" inoremap <expr> . ("." . asyncomplete#force_refresh())


"----------------------------------------------------------------------
" turning lsp
"----------------------------------------------------------------------
let g:lsp_diagnostics_enabled = 0


"----------------------------------------------------------------------
" turning completion
"----------------------------------------------------------------------
let g:asyncomplete_min_chars = 0
let g:asyncomplete_auto_completeopt = 0

set shortmess+=c

