"======================================================================
"
" main.vim - 
"
" Created by skywind on 2022/08/24
" Last Modified: 2022/08/24 20:24:47
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" extension map
"----------------------------------------------------------------------
let g:quickui = get(g:, 'quickui', {})
let s:quickui = {}


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:private = {}
let s:private.quickui = {}


"----------------------------------------------------------------------
" help
"----------------------------------------------------------------------
function! s:sub_help(opts, argv)
endfunc


"----------------------------------------------------------------------
" list extension
"----------------------------------------------------------------------
function! s:sub_list(opts, argv)
endfunc


"----------------------------------------------------------------------
" main cmd
"----------------------------------------------------------------------
function! quickui#main#cmd(bang, cmdline) abort
	let [cmdline, op1] = quickui#core#extract_opts(a:cmdline)
	let cmdline = quickui#core#string_strip(cmdline)
	let name = ''
	if cmdline =~# '^\w\+'
		let name = matchstr(cmdline, '^\w\+')
		let cmdline = substitute(cmdline, '^\w\+\s*', '', '')
	endif
	let name = quickui#core#string_strip(name)
	let [cmdline, op2] = quickui#core#extract_opts(cmdline)
	let op2.cmdline = quickui#core#string_strip(cmdline)
	let opts = deepcopy(op1)
	for k in keys(op2)
		let opts[k] = op2[k]
	endfor
	let argv = quickui#core#split_argv(cmdline)
	let quickui = {}
	for key in keys(s:quickui)
		let quickui[key] = s:quickui[key]
	endfor
	for key in keys(g:quickui)
		let quickui[key] = g:quickui[key]
	endfor
	let names = keys(quickui)
	call sort(names)
	let s:private.quickui = quickui
	let s:private.names = names
	if name == ''
		if has_key(op1, 'h')
			call s:sub_help(opts, argv)
		elseif has_key(op1, 'l')
			call s:sub_list(opts, argv)
		endif
		return 0
	endif
	if has_key(s:private.quickui, name) == 0
		call quickui#utils#errmsg('invalid extension name: ' . name)
		return -1
	endif
	let obj = s:private.quickui[name]
	if has_key(obj, 'run') == 0
		call quickui#utils#errmsg('not find "run" funcref in extension: ' . name)
		return -2
	endif
	let hr = call(obj.run, [opts, argv])
	return hr
endfunc





