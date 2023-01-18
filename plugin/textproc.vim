"======================================================================
"
" textproc.vim - 
"
" Created by skywind on 2022/01/21
" Last Modified: 2022/08/30 02:58
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


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
	let fn = s:script_home . '/site/text'
	let fn = substitute(fn, '\\', '\/', 'g')
	let candidate += [fn]
	let location = get(g:, 'textproc_root', '')
	if location != ''
		if isdirectory(location)
			let candidate += [location]
			let t = location . '/' . &ft
			if isdirectory(t)
				let candidate += [t]
			endif
		endif
	endif
	let rtp_name = get(g:, 'textproc_home', 'text')
	for rtp in split(&rtp, ',')
		if rtp != ''
			let path = rtp . '/' . rtp_name
			if isdirectory(path)
				let candidate += [path]
				let t = path . '/' . &ft
				if isdirectory(t)
					let candidate += [t]
				endif
			endif
		endif
	endfor
	return candidate
endfunc


"----------------------------------------------------------------------
" list script
"----------------------------------------------------------------------
function! s:script_list() abort
	let select = {}
	let check = {}
	let marks = ['py', 'lua', 'pl', 'php', 'js', 'ts', 'rb']
	let marks += ['gawk', 'awk']
	if s:windows == 0
		let marks += ['sh', 'zsh', 'bash', 'fish']
	else
		let marks += ['cmd', 'bat', 'exe', 'ps1']
	endif
	for mark in marks
		let check[mark] = 1
	endfor
	let roots = s:script_roots()
	for root in roots
		if isdirectory(root) == 0
			continue
		endif
		let candidate = [root]
		let test = root . '/' . (&filetype)
		if isdirectory(test)
			let candidate += [test]
		endif
		for location in candidate
			let filelist = globpath(location, '*', 1, 1)
			call sort(filelist)
			for fn in filelist
				let name = fnamemodify(fn, ':t')
				let main = fnamemodify(fn, ':t:r')
				let ext = fnamemodify(name, ':e')
				let ext = (s:windows == 0)? ext : tolower(ext)
				if s:windows
					let fn = substitute(fn, '\/', '\\', 'g')
				endif
				if has_key(check, ext)
					let select[main] = fn
				endif
			endfor
		endfor
	endfor
	let methods = {}
	if exists('g:textproc')
		for key in keys(g:textproc)
			let methods[key] = g:textproc[key]
		endfor
	endif
	if exists('b:textproc')
		for key in keys(b:textproc)
			let methods[key] = b:textproc[key]
		endfor
	endif
	for key in keys(methods)
		if type(methods[key]) == v:t_string
			let value = methods[key]
			if value =~ '^:'
				let value = strpart(value, 1)
			endif
			let select[key] = function(value)
		else
			let select[key] = function(methods[key])
		endif
	endfor
	return select
endfunc

" echo s:script_list()

" echo function(funcref(function('s:script_list')))()


"----------------------------------------------------------------------
" returns shebang
"----------------------------------------------------------------------
function! s:script_shebang(script)
	let script = a:script
	if type(script) != v:t_string
		return ''
	elseif !filereadable(script)
		return ''
	endif
	let textlist = readfile(script, '', 20)
	let shebang = ''
	for text in textlist
		let text = s:string_strip(text)
		if text =~ '^#'
			let text = s:string_strip(strpart(text, 1))
			if text =~ '^!'
				let shebang = s:string_strip(strpart(text, 1))
				break
			endif
		endif
	endfor
	return shebang
endfunc


"----------------------------------------------------------------------
" detect script runner
"----------------------------------------------------------------------
function! s:script_runner(script) abort
	let script = a:script
	let ext = fnamemodify(script, ':e')
	let ext = (s:windows == 0)? ext : tolower(ext)
	let runner = ''
	if type(script) != v:t_string
		return ''
	elseif script == ''
		return ''
	elseif script =~ '^:'
		return ''
	elseif executable(script) 
		return ''
	elseif exists('g:textproc_runner')
		let runners = g:textproc_runner
		let runner = get(runners, ext, '')
		if runner != ''
			return runner
		endif
	endif
	if s:windows
		if index(['cmd', 'bat', 'exe'], ext) >= 0
			return ''
		elseif ext == 'ps1'
			return 'powershell -file'
		endif
	else
		let shebang = s:script_shebang(script)
		if shebang != ''
			return shebang
		endif
	endif
	if index(['py', 'pyw', 'pyc', 'pyo'], ext) >= 0
		if s:windows
			for name in ['python', 'python3', 'python2']
				if executable(name)
					return name
				endif
			endfor
		else
			for name in ['python3', 'python', 'python2']
				if executable(name)
					return name
				endif
			endfor
		endif
	elseif ext == 'lua'
		let t = ['lua', 'lua5.4', 'lua5.3', 'lua5.2', 'lua5.1', 'luajit']
		for name in t
			if executable(name)
				return name
			endif
		endfor
	elseif ext == 'sh'
		for name in ['sh', 'bash', 'zsh', 'dash']
			if executable(name)
				return name
			endif
		endfor
		if executable('busybox')
			return 'busybox sh'
		endif
	elseif ext == 'gawk'
		if executable('gawk')
			return 'gawk -f'
		endif
	elseif ext == 'awk'
		for name in ['gawk', 'awk', 'mawk', 'nawk']
			if executable(name)
				return name . ' -f'
			endif
		endfor
	endif
	let ext_runners = {
				\ 'pl' : 'perl',
				\ 'php' : 'php',
				\ 'rb' : 'ruby',
				\ 'zsh' : 'zsh',
				\ 'bash' : 'bash',
				\ 'sh' : 'sh',
				\ 'fish' : 'fish',
				\ }
	if has_key(ext_runners, ext) 
		let runner = ext_runners[ext]
		if type(runner) == type('')
			if executable(runner)
				return runner
			endif
		elseif type(runner) == type([])
			for name in runner
				if executable(runner)
					return runner
				endif
			endfor
		endif
	endif
	return ''
endfunc

" echo s:script_runner('c:/share/vim/lib/ascmini.awk')


"----------------------------------------------------------------------
" run script
"----------------------------------------------------------------------
function! s:script_run(name, args, lnum, count, debug) abort
	if a:count <= 0
		return 0
	endif
	let scripts = s:script_list()
	if has_key(scripts, a:name) == 0
		echohl ErrorMsg
		echo 'ERROR: runner not find: ' . a:name
		echohl None
		return 0
	endif
	if type(scripts[a:name]) == v:t_string
		let script = scripts[a:name]
		let runner = s:script_runner(script)
		let runner = (runner != '')? (runner . ' ') : ''
		let runner = (runner != '' || s:windows == 0)? runner : 'call '
		let cmd = runner . shellescape(script)
		if a:args != ''
			let cmd = cmd . ' ' . (a:args)
		endif
		let line1 = a:lnum
		let line2 = line1 + a:count - 1
		let cmd = printf('%s,%s!%s', line1, line2, cmd)
		let $VIM_ENCODING = &encoding
		let $VIM_FILEPATH = expand('%:p')
		let $VIM_FILENAME = expand('%:t')
		let $VIM_FILEDIR = expand('%:p:h')
		let $VIM_CWD = getcwd()
		let $VIM_SCRIPT = script
		let $VIM_SCRIPTNAME = a:name
		let $VIM_SCRIPTDIR = fnamemodify(script, ':p:h')
		let $VIM_FILETYPE = &ft
		execute cmd
	elseif type(scripts[a:name]) == v:t_func
		let bid = bufnr('%')
		let text = getbufline(bid, a:lnum, a:lnum + a:count - 1)
		let hr = call(scripts[a:name], [text])
		if len(text) < len(hr)
			call appendbufline(bid, a:lnum, repeat([''], len(hr) - len(text)))
		elseif len(text) > len(hr)
			call deletebufline(bid, a:lnum, a:lnum + len(text) - len(hr) - 1)
		endif
		call setbufline(bid, a:lnum, hr)
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" run in a split
"----------------------------------------------------------------------
function! s:run_in_split(name, args, lnum, count, debug) abort
	if a:count <= 0
		return 0
	endif
	let scripts = s:script_list()
	if has_key(scripts, a:name) == 0
		echohl ErrorMsg
		echo 'ERROR: runner not find: ' . a:name
		echohl None
		return 0
	endif
	let bid = bufnr('%')
	let input = getbufline(bid, a:lnum, a:lnum + a:count - 1)
	if type(scripts[a:name]) == v:t_string
		let script = scripts[a:name]
		let runner = s:script_runner(script)
		let runner = (runner != '')? (runner . ' ') : ''
		let runner = (runner != '' || s:windows == 0)? runner : 'call '
		let cmd = runner . shellescape(script)
		if a:args != ''
			let cmd = cmd . ' ' . (a:args)
		endif
		let line1 = a:lnum
		let line2 = line1 + a:count - 1
		let $VIM_ENCODING = &encoding
		let $VIM_FILEPATH = expand('%:p')
		let $VIM_FILENAME = expand('%:t')
		let $VIM_FILEDIR = expand('%:p:h')
		let $VIM_CWD = getcwd()
		let $VIM_SCRIPT = script
		let $VIM_SCRIPTNAME = a:name
		let $VIM_SCRIPTDIR = fnamemodify(script, ':p:h')
		let $VIM_FILETYPE = &ft
		let text = system(cmd, input)
		let output = split(text, '\n', 1)
	elseif type(scripts[a:name]) == v:t_func
		let output = call(scripts[a:name], [input])
	endif
	let bid = get(t:, '_textproc_buffer', -1)
	if bid < 0
		if has('nvim') == 0
			let bid = bufadd('')
			call bufload(bid)
			call setbufvar(bid, '&buflisted', 0)
			call setbufvar(bid, '&bufhidden', 'hide')
			call setbufvar(bid, '&buftype', 'nofile')
			call setbufvar(bid, 'noswapfile', 1)
		else
			let bid = nvim_create_buffer(v:false, v:true)
		endif
		let t:_textproc_buffer = bid
	endif
	call setbufvar(bid, '_textproc_buffer', bid)
	call setbufvar(bid, '&modifiable', 1)
	call deletebufline(bid, 1, '$')
	call setbufline(bid, 1, output)
	call setbufvar(bid, '&modified', 0)
	return bid
endfunc


"----------------------------------------------------------------------
" display buffer in a split 
"----------------------------------------------------------------------
function! s:display_buffer(bid)
	function! s:WindowCheck(mode)
		if a:mode == 0
			let w:textproc_save = winsaveview()
		else
			if exists('w:textproc_save')
				call winrestview(w:textproc_save)
				unlet w:textproc_save
			endif
		endif
	endfunc
	if a:bid > 0
		for i in range(winnr('$'))
			let nr = winbufnr(i + 1)
			if nr == a:bid
				return 0
			endif
		endfor
		let open_mode = get(g:, 'textproc_split', '<auto>')
		if open_mode == '<auto>' || 'auto'
			let open_mode = (winwidth(0) >= 160)? 'vert' : ''
		endif
		let l:winnr = winnr()
		let savebid = bufnr('')
		keepalt noautocmd windo call s:WindowCheck(0)
		keepalt noautocmd silent! exec ''.l:winnr.'wincmd w'
		exec open_mode . ' ' . 'split'
		exec 'b ' . a:bid
		keepalt noautocmd exec 'wincmd p'
		let l:winnr = winnr()
		keepalt noautocmd windo call s:WindowCheck(1)
		keepalt noautocmd silent! exec ''.l:winnr.'wincmd w'
	else
		let bid = -(a:bid)
		if bid == 0
			return 0
		endif
		for i in range(winnr('$'))
			let nr = winbufnr(i + 1)
			if nr == bid
				let avail = i + 1
				let l:winnr = winnr()
				let savebid = bufnr('')
				keepalt noautocmd windo call s:WindowCheck(0)
				keepalt noautocmd silent! exec ''.l:winnr.'wincmd w'
				keepalt noautocmd exec ''.avail.'close'
				keepalt noautocmd windo call s:WindowCheck(1)
				break
			endif
		endfor
	endif
	return 0
endfunc

" hello world

"----------------------------------------------------------------------
" function
"----------------------------------------------------------------------
function! s:TextProcess(bang, args, line1, line2, count) abort
	let cmdline = s:string_strip(a:args)
	let name = ''
	let args = ''
	if cmdline =~# '^\w\+'
		let name = matchstr(cmdline, '^\w\+')
		let args = substitute(cmdline, '^\w\+\s*', '', '')
	elseif cmdline == '-close'
		let bid = get(t:, '_textproc_buffer', 0)
		call s:display_buffer(-bid)
		return 0
	endif
	if a:count == 0
		if a:bang == ''
			echohl WarningMsg
			" echo 'Warning: no range specified !'
			echohl None
		endif
		return 0
	endif
	if name == ''
		if a:bang == ''
			echohl ErrorMsg
			echo 'ERROR: script name required'
			echohl None
		endif
		return 0
	endif
	let cc = a:line2 - a:line1 + 1
	if a:bang == ''
		call s:script_run(name, args, a:line1, cc, 0)
	else
		let bid = s:run_in_split(name, args, a:line1, cc, 0)
		call s:display_buffer(bid)
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" command complete
"----------------------------------------------------------------------
function! s:complete(ArgLead, CmdLine, CursorPos)
	let candidate = []
	let scripts = s:script_list()
	let names = keys(scripts)
	call sort(names)
	for name in names
		if stridx(name, a:ArgLead) == 0
			let candidate += [name]
		endif
	endfor
	return candidate
endfunc


"----------------------------------------------------------------------
" command defintion
"----------------------------------------------------------------------
command! -bang -nargs=+ -range=0 -complete=customlist,s:complete TP
		\ call s:TextProcess('<bang>', <q-args>, <line1>, <line2>, <count>)

" test


