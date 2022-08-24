"======================================================================
"
" main.vim - 
"
" Created by skywind on 2022/08/24
" Last Modified: 2022/08/24 20:24:47
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :

let g:quickui = get(g:, 'quickui', {})


function! quickui#main#cmd(bang, cmdline)
	let [cmdline, opts] = quickui#core#extract_opts(a:cmdline)
	let cmdline = quickui#core#string_strip(cmdline)
	let name = ''
	if cmdline =~# '^\w\+'
		let name = matchstr(cmdline, '^\w\+')
		let cmdline = substitute(cmdline, '^\w\+\s*', '', '')
	endif
	let [cmdline, opt2] = quickui#core#extract_opts(cmdline)
	let opt2.cmdline = cmdline
	let op = deepcopy(opts)
	for k in keys(opt2)
		let op[k] = opt2[k]
	endfor
	let argv = quickui#core#split_argv(cmdline)
	return [opts, name, opt2, cmdline]
endfunc


echo quickui#main#cmd('', '')
echo quickui#main#cmd('', 'hello')
echo quickui#main#cmd('', '-h')
echo quickui#main#cmd('', '-h world')
echo quickui#main#cmd('', '-h world -v')
echo quickui#main#cmd('', '-h world -v -x -y')
echo quickui#main#cmd('', '-h world -v python')
echo quickui#main#cmd('', '-h world -v -x -y python')

echo quickui#core#split_argv('1 2 3')
echo quickui#core#split_argv('1 2 3 hello\ world 4')

