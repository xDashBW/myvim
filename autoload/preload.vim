"======================================================================
"
" preload.vim - 
"
" Created by skywind on 2021/12/25
" Last Modified: 2021/12/25 23:29:44
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:script_name = expand('<sfile>:p')
let s:script_home = fnamemodify(s:script_name, ':h')
let s:preload_home = substitute(s:script_home . '/preload', '\\', '/', 'g')
let s:preload_list = []
let s:preload_load = []


"----------------------------------------------------------------------
" inter-preloads
"----------------------------------------------------------------------
let g:preload_plugin = []
let s:preload_loaded = {}


"----------------------------------------------------------------------
" load preload
"----------------------------------------------------------------------
function! preload#load(name)
	let name = a:name
	let script = s:preload_home . '/' . name . '.vim'
	let entry = 'preload#' . name . '#init'
	if !filereadable(script)
		echohl ErrorMsg
		echom 'ERROR: file not readable ' . script
		echohl None
		return -1
	endif
	exec 'source ' . fnameescape(script)
	if exists('*' . entry) == 0
		echohl ErrorMsg
		" echom 'ERROR: entry missing ' . entry . '()'
		echohl None
		return -2
	else
		call call(entry, [])
	endif
	let s:preload_loaded[name] = 1
	return 0
endfunc


"----------------------------------------------------------------------
" ensure loaded
"----------------------------------------------------------------------
function! preload#ensure(name)
	if get(s:preload_loaded, a:name, 0) == 0
		call preload#load(a:name)
	endif
endfunc


"----------------------------------------------------------------------
" check preload existence
"----------------------------------------------------------------------
function! preload#has(name)
	let name = a:name
	let script = s:preload_home . '/' . name . '.vim'
	if !filereadable(script)
		return 0
	endif
	return 1
endfunc


"----------------------------------------------------------------------
" init preload
"----------------------------------------------------------------------
function! preload#init()
	let s:preload_list = []
	let s:preload_load = []
	if has('patch-7.4.1') == 0
		return -1
	endif
	let scripts = globpath(s:preload_home, '*.vim', 1, 1)
	for name in scripts
		if filereadable(name)
			let name = fnamemodify(name, ':p:t:r')
			let s:preload_list += [name]
		endif
	endfor
	if exists('g:preload_load') == 0
		for name in s:preload_list
			if name !~ '^__'
				let s:preload_load += [name]
			endif
		endfor
	else
		let avail = {}
		for name in s:preload_list
			let avail[name] = 1
		endfor
		for name in g:preload_load
			if has_key(avail, name)
				let s:preload_load += [name]
			else
				echohl ErrorMsg
				echom 'ERROR: preload missing: ' . name
				echohl None
			endif
		endfor
	endif
	command! -nargs=1 PreloadLoad call preload#load(<f-args>)
	command! -nargs=1 PreloadEnsure call preload#ensure(<f-args>)
	for name in s:preload_load
		exec 'PreloadLoad ' . fnameescape(name)
	endfor
	let g:PreloadLoaded = 1
	return 0
endfunc



