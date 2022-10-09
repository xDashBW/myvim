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
" visit tree node
"----------------------------------------------------------------------
function! starter#config#visit(keymap, path) abort
	let keymap = a:keymap
	let path = a:path
	if type(keymap) == v:t_none || type(path) == v:t_none
		return v:none
	endif
	for key in path
		if !has_key(keymap, key)
			return v:none
		endif
		let keymap = keymap[key]
	endfor
	return keymap
endfunc



