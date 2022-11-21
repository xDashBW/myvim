" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" config.vim - 
"
" Created by skywind on 2022/09/07
" Last Modified: 2022/09/07 16:42:08
"
"======================================================================


"----------------------------------------------------------------------
" default config
"----------------------------------------------------------------------
let s:default_config = {
			\ 'icon_separator': '=>',
			\ 'icon_group': '+',
			\ 'icon_breadcrumb': '>',
			\ 'max_height': 20,
			\ 'min_height': 5,
			\ 'padding': [2, 0, 2, 0],
			\ 'spacing': 3,
			\ 'position': 'bottom',
			\ 'splitmod': '',
			\ }


"----------------------------------------------------------------------
" get config
"----------------------------------------------------------------------
function! starter#config#get(opts, key) abort
	if type(a:opts) == v:t_dict
		let opts = a:opts
	elseif type(a:opts) == v:t_none
		let opts = get(g:, 'quickui_starter', {})
	endif
	return get(opts, a:key, s:default_config[a:key])
endfunc


"----------------------------------------------------------------------
" evaluate keymap dict
"----------------------------------------------------------------------
function! s:keymap_eval(keymap)
	let keymap = a:keymap
	if type(keymap) == v:t_func
		let keymap = call(keymap, [])
	elseif type(keymap) == v:t_string
		let keymap = quickui#core#string_strip(keymap)
		if keymap =~ '\v^\$\{(.*)\}$'
			let t = strpart(keymap, 2, strlen(keymap) - 3)
			unlet keymap
			let keymap = eval(t)
		endif
	endif
	return keymap
endfunc


"----------------------------------------------------------------------
" visit tree node
"----------------------------------------------------------------------
function! starter#config#visit(keymap, path) abort
	let keymap = a:keymap
	let path = a:path
	if type(keymap) == v:t_none || type(path) == v:t_none
		return v:none
	endif
	let index = 0
	while 1
		let keymap = s:keymap_eval(keymap)
		if index >= len(path)
			break
		endif
		let key = path[index]
		if !has_key(keymap, key)
			return v:none
		endif
		let keymap = keymap[key]
		let index += 1
	endwhile
	return keymap
endfunc


"----------------------------------------------------------------------
" compile keymap into ctx
"----------------------------------------------------------------------
function! starter#config#compile(keymap, opts) abort
	let keymap = a:keymap
	let opts = a:opts
	let ctx = {}
	let ctx.items = {}
	let ctx.keys = []
	let ctx.strlen_key = 1
	let ctx.strlen_txt = 8
	for key in keys(keymap)
		if key == '' || key == 'name'
			continue
		endif
		let key_code = starter#charname#get_key_code(key)
		if type(key_code) == v:t_none
			continue
		endif
		let ctx.keys += [key]
		let item = {}
		let item.key = key
		let item.code = key_code
		let item.label = starter#charname#get_key_label(key)
		let item.cmd = ''
		let item.text = ''
		let item.child = 0
		let ctx.items[key] = item
		let value = keymap[key]
		if type(value) == v:t_func
			unlet value
			let value = call(value, [])
		elseif type(value) == v:t_string
			let value = quickui#core#string_strip(value)
			if value =~ '\v^\$\{(.*)\}$'
				let t = strpart(value, 2, strlen(value) - 3)
				unlet value
				let value = eval(t)
			endif
		endif
		if type(value) == v:t_string
			let item.cmd = value
			let item.text = value
		elseif type(value) == v:t_list
			let item.cmd = (len(value) > 0)? value[0] : ''
			let item.text = (len(value) > 1)? value[1] : ''
		elseif type(value) == v:t_dict
			let item.child = 1
			let item.text = get(value, 'name', '...')
		endif
		if len(item.label) > ctx.strlen_key
			let ctx.strlen_key = len(item.label)
		endif
		if len(item.text) > ctx.strlen_txt
			let ctx.strlen_txt = len(item.text)
		endif
	endfor
	let ctx.keys = starter#charname#sort(ctx.keys)
	return ctx
endfunc


