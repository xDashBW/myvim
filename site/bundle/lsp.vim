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


