" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" utils.vim - utils
"
" Created by skywind on 2022/12/24
" Last Modified: 2022/12/24 03:38:40
"
"======================================================================


"----------------------------------------------------------------------
" internal save view
"----------------------------------------------------------------------
function! s:save_view(mode)
	if a:mode == 0
		let w:starter_save = winsaveview()
	else
		if exists('w:starter_save')
			if get(b:, 'starter_keep', 0) == 0
				call winrestview(w:starter_save)
			endif
			unlet w:starter_save
		endif
	endif
endfunc


"----------------------------------------------------------------------
" save view
"----------------------------------------------------------------------
function! starter#utils#save_view() abort
	let winid = winnr()
	keepalt noautocmd windo call s:save_view(0)
	keepalt noautocmd silent! exec printf('%dwincmd w', winid)
endfunc


"----------------------------------------------------------------------
" restore view
"----------------------------------------------------------------------
function! starter#utils#restore_view() abort
	let winid = winnr()
	keepalt noautocmd windo call s:save_view(1)
	keepalt noautocmd silent! exec printf('%dwincmd w', winid)
endfunc

