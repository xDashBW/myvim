" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" layout.vim - window layout
"
" Created by skywind on 2022/11/25
" Last Modified: 2022/11/25 20:02:09
"
"======================================================================


"----------------------------------------------------------------------
" layout init
"----------------------------------------------------------------------
function! starter#layout#init(ctx, opts) abort
	if a:ctx.vertical == 0
		call s:layout_horizon(a:ctx, a:opts)
	else
		call s:layout_vertical(a:ctx, a:opts)
	endif
endfunc


"----------------------------------------------------------------------
" horizon
"----------------------------------------------------------------------
function! s:layout_horizon(ctx, opts) abort
	let a:ctx.wincx = &columns
endfunc


"----------------------------------------------------------------------
" vertical
"----------------------------------------------------------------------
function! s:layout_vertical(ctx, opts) abort
	let a:ctx.wincy = winheight(0)
endfunc



