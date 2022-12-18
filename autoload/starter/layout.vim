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
" horizon
"----------------------------------------------------------------------
function! s:layout_horizon(ctx, opts) abort
	let ctx = a.ctx
	let padding = starter#config#get(a:opts, 'pedding')
	let spacing = starter#config#get(a:opts, 'spacing')
	let ctx.cx = a:ctx.wincx - (padding[0] + padding[2])
	if ctx.cx <= ctx.stride
		let ctx.ncols = 1
	else
		" Ax + B(x-1) = y  -->  (A+B)x = y+B  --> x = (y+B)/(A+B)
		let ctx.ncols = (ctx.cx + spacing) / (spacing + ctx.stride)
	endif
	if type(ctx.ncols) == 5
		let ctx.ncols = float2nr(ctx.ncols)
	endif
	let ctx.ncols = (ctx.ncols < 1)? 1 : ctx.ncols
	let nitems = len(ctx.items)
	let ctx.nrows = (nitems + ctx.ncols - 1) / ctx.ncols
	if type(ctx.nrows) == 5
		let ctx.nrows = float2nr(ctx.nrows)
	endif
endfunc


"----------------------------------------------------------------------
" vertical
"----------------------------------------------------------------------
function! s:layout_vertical(ctx, opts) abort
	let a:ctx.wincy = winheight(0)
endfunc


"----------------------------------------------------------------------
" layout init
"----------------------------------------------------------------------
function! starter#layout#init(ctx, opts, hspace, vspace) abort
	let a:ctx.wincx = a:hspace
	let a:ctx.wincy = a:vspace
	if a:ctx.vertical == 0
		call s:layout_horizon(a:ctx, a:opts)
	else
		call s:layout_vertical(a:ctx, a:opts)
	endif
endfunc



