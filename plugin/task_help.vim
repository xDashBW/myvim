"======================================================================
"
" task_extension.vim - 
"
" Created by skywind on 2021/12/14
" Last Modified: 2021/12/14 17:19:47
"
"======================================================================


"----------------------------------------------------------------------
" api hook
"----------------------------------------------------------------------
let g:asynctasks_api_hook = get(g:, 'asynctasks_api_hook', {})


"----------------------------------------------------------------------
" utils
"----------------------------------------------------------------------
function! s:errmsg(msg)
	redraw
	echohl ErrorMsg
	echom 'ERROR: ' . a:msg
	echohl NONE
	return 0
endfunction

function! s:strip(text)
	return substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:require_check()
	if get(g:, 'quickui_version', '') == ''
		call s:errmsg('skywind3000/vim-quickui 1.4.3+ is required')
		return v:false
	endif
	let c1 = g:quickui#core#has_popup
	let c2 = g:quickui#core#has_floating
	if has('nvim') == 0
		if c1 == 0
			call s:errmsg('Vim 8.2 or above is required')
			return v:false
		endif
	elseif c2 == 0
		call s:errmsg('NeoVim 0.5.0 or above is required')
		return v:false
	endif
	return v:true
endfunc



"----------------------------------------------------------------------
" api input
"----------------------------------------------------------------------
function! s:api_input(msg, text, history)
	if s:require_check() == 0
		return ''
	endif
	let msg = a:msg
	let msg = a:msg . "\n(Enter to confirm, ESC to cancel)" 
	return quickui#input#open(msg, a:text, a:history)
endfunc


"----------------------------------------------------------------------
" api confirm
"----------------------------------------------------------------------
function! s:api_confirm(msg, choices, index)
	if s:require_check() == 0
		return 0
	endif
	let index = (a:index == 0)? 1 : a:index
	return quickui#confirm#open(a:msg, a:choices, index)
endfunc


"----------------------------------------------------------------------
" play file
"----------------------------------------------------------------------
function! PlaySound22(wav)
	if get(g:, 'asynctasks_sound', 1) == 0
		return -1
	elseif !filereadable(a:wav)
		return -1
	elseif exists('*sound_playfile')
		return sound_playfile(a:wav)
	elseif executable('afplay')
		let cmd = 'afplay %s'
	elseif executable('aplay')
		let cmd = 'aplay %s'
	elseif executable('powershell') && (has('win32') || has('win64'))
		let cmd = 'powershell -c (New-Object Media.SoundPlayer %s).PlaySync()'
	elseif executable('sndrec32')
		let cmd = 'sndrec32 /embedding /play /close %s'
	else
		return -1
	endif
	let name = fnamemodify(a:wav, ':p')
	let cmd = printf(cmd, shellescape(name))
	call asyncrun#run('', {'mode': 'hide'}, cmd)
	return 0
endfunc


"----------------------------------------------------------------------
" detect project type
"----------------------------------------------------------------------
function! s:api_detect(path, templates)
	return ''
endfunc


"----------------------------------------------------------------------
" select template
"----------------------------------------------------------------------
function! s:api_template(templates, preset)
	return '!'
endfunc


"----------------------------------------------------------------------
" init hook
"----------------------------------------------------------------------
function! g:asynctasks_api_hook.init()
	let ui = get(g:, 'asynctasks_use_quickui', 1)
	if ui == 0
		return -1
	endif
	if get(g:, 'quickui_version', '') != ''
		let c1 = g:quickui#core#has_popup
		let c2 = g:quickui#core#has_floating
		if c1 || c2
			let g:asynctasks_api_hook.input = function('s:api_input')
			let g:asynctasks_api_hook.confirm = function('s:api_confirm')
		endif
	endif
	let g:asynctasks_api_hook.sound_play = function('PlaySound22')
	let g:asynctasks_api_hook.detect = function('s:api_detect')
	" let g:asynctasks_api_hook.template = function('s:api_template')
	return 0
endfunc


