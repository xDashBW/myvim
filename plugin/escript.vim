" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" escript.vim - execute script
"
" Created by skywind on 2022/09/16
" Last Modified: 2022/09/16 11:03:30
"
"======================================================================

"----------------------------------------------------------------------
" script home
"----------------------------------------------------------------------
let s:script_home = fnamemodify(expand('<sfile>:p'), ':h:h')
let s:windows = has('win32') || has('win64') || has('win16') || has('win95')
let s:scripts = {}


"----------------------------------------------------------------------
" string strip
"----------------------------------------------------------------------
function! s:string_strip(text)
	return substitute(a:text, '^\s*\(.\{-}\)[\s\r\n]*$', '\1', '')
endfunc


"----------------------------------------------------------------------
" script root
"----------------------------------------------------------------------
function! s:script_roots() abort
	let candidate = []
	let fn = s:script_home . '/site/escript'
	let fn = substitute(fn, '\\', '\/', 'g')
	let candidate += [fn]
	let location = get(g:, 'escript_root', '')
	if location != ''
		if isdirectory(location)
			let candidate += [location]
		endif
	endif
	let rtp_name = get(g:, 'escript_home', 'escript')
	for rtp in split(&rtp, ',')
		if rtp != ''
			let path = rtp . '/' . rtp_name
			if isdirectory(path)
				let candidate += [path]
			endif
		endif
	endfor
	return candidate
endfunc


"----------------------------------------------------------------------
" list script
"----------------------------------------------------------------------
function! s:script_list() abort
	let roots = s:script_roots()
	echo roots
endfunc

echo s:script_list()

