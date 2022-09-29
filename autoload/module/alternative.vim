" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" alternative.vim - locate alternative file
"
" Created by skywind on 2022/09/09
" Last Modified: 2022/09/09 22:25:45
"
"======================================================================


"----------------------------------------------------------------------
" alternative config
"----------------------------------------------------------------------
if !exists('g:alternative')
	let g:alternative = [
				\ "h:c",
				\ "h:m",
				\ "h,hpp,hh:cpp,cc,cxx,mm",
				\ "H:C,M",
				\ "H,HPP,HH:CPP,CC,CXX,MM",
				\ "vim:vim",
				\ "aspx.cs:aspx",
				\ "aspx.vb:aspx",
				\ ]
endif


"----------------------------------------------------------------------
" find alternative
"----------------------------------------------------------------------
function! module#alternative#alter_extname(extname) abort
	let hr = []
	let extname = a:extname
	for text in g:alternative
		let text = asclib#string#replace(text, ' ', '')
		let parts = split(text, ':')
		if len(parts) < 2
			continue
		endif
		let p1 = split(parts[0], ',')
		let p2 = split(parts[1], ',')
		if index(p1, extname) >= 0
			let hr += p2
		elseif index(p2, extname) >= 0
			let hr += p1
		endif
	endfor
	return hr
endfunc


"----------------------------------------------------------------------
" detect certain path
"----------------------------------------------------------------------
function! module#alternative#detect_path(path, main, altext)

endfunc


"----------------------------------------------------------------------
" search alternative
"----------------------------------------------------------------------
function! module#alternative#search_alter(fullname, ...) abort
	let fullname = (a:fullname == '')? expand('%:p') : a:fullname
	let fullname = (a:fullname == '%')? expand('%:p') : fullname
	let fullname = asclib#path#abspath(fullname)
	let mainname = fnamemodify(fullname, ':t:r')
	let extname = fnamemodify(fullname, ':e')
	let dirname = asclib#path#dirname(fullname)
	let root = asclib#path#get_root(fullname)
	if extname == ''
		return ''
	elseif !filereadable(fullname)
		return ''
	endif
	let alter_exts = module#alternative#alter_extname(extname)
	let alter_dict = {}
	for name in alter_exts
		let alter_dict[name] = 1
	endfor
	let level = 0
	let maxlevel = (a:0 > 0)? (a:1) : -1
	while 1
		let pattern = dirname . '/**/' . mainname . '.*'
		echo pattern
		for name in split(glob(pattern), '\n')
			if name != ''
				let test = fnamemodify(name, ':e')
				echo "  - " . name
				if test != extname
					if has_key(alter_dict, test)
						return name
					endif
				endif
			endif
		endfor
		let level += 1
		if asclib#path#equal(dirname, root)
			break
		elseif maxlevel > 0
			if level >= maxlevel
				break
			endif
		endif
		let t = fnamemodify(dirname, ':h')
		if t == dirname
			break
		endif
		let dirname = t
	endwhile
	return ''
endfunc


