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
" turning lsp
"----------------------------------------------------------------------
let g:lsp_use_lua = has('nvim-0.4.0') || (has('lua') && has('patch-8.2.0775'))
let g:lsp_completion_documentation_enabled = 0
let g:lsp_diagnostics_enabled = 0
let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0

let g:lsp_signature_help_enabled = 0
let g:lsp_document_highlight_enabled = 0


"----------------------------------------------------------------------
" turning completion
"----------------------------------------------------------------------
let g:asyncomplete_min_chars = 0
let g:asyncomplete_auto_completeopt = 0

set shortmess+=c


"----------------------------------------------------------------------
" keymaps
"----------------------------------------------------------------------
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() . "\<cr>" : "\<cr>"

function! s:refresh_dot()
	let hr = asyncomplete#force_refresh()
	return '.'
endfunc

" inoremap <expr> . ("." . asyncomplete#force_refresh())
