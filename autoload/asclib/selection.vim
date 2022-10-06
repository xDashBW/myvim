" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" selection.vim - 
"
" Created by skywind on 2022/10/06
" Last Modified: 2022/10/06 13:52:09
"
"======================================================================


"----------------------------------------------------------------------
" get selection text
"----------------------------------------------------------------------
function! asclib#selection#get(...) abort
	let mode = get(a:, 1, mode(1))
	" return s:get_selected_text(mode)
	return s:get_visual_selection(mode)
endfunc


"----------------------------------------------------------------------
" internal implementation
"----------------------------------------------------------------------

" Assume the current mode is middle of visual mode.
" @return selected text
function! s:get_selected_text(...) abort
	let mode = get(a:, 1, mode(1))
	let end_col = s:curswant() is s:INT.MAX ? s:INT.MAX : s:get_col_in_visual('.')
	let current_pos = [line('.'), end_col]
	let other_end_pos = [line('v'), s:get_col_in_visual('v')]
	let [begin, end] = s:sort_pos([current_pos, other_end_pos])
	if s:is_exclusive() && begin[1] !=# end[1]
		" Decrement column number for :set selection=exclusive
		let end[1] -= 1
	endif
	if mode !=# 'V' && begin ==# end
		let lines = [s:get_pos_char(begin)]
	elseif mode ==# "\<C-v>"
		let [min_c, max_c] = s:sort_num([begin[1], end[1]])
		let lines = map(range(begin[0], end[0]), '
					\   getline(v:val)[min_c - 1 : max_c - 1]
					\ ')
	elseif mode ==# 'V'
		let lines = getline(begin[0], end[0])
	else
		if begin[0] ==# end[0]
			let lines = [getline(begin[0])[begin[1]-1 : end[1]-1]]
		else
			let lines = [getline(begin[0])[begin[1]-1 :]]
						\         + (end[0] - begin[0] < 2 ? [] : getline(begin[0]+1, end[0]-1))
						\         + [getline(end[0])[: end[1]-1]]
		endif
	endif
	return join(lines, "\n") . (mode ==# 'V' ? "\n" : '')
endfunction


let s:INT = { 'MAX': 2147483647 }


" @return Number: return multibyte aware column number in Visual mode to
" select
function! s:get_col_in_visual(pos) abort
	let [pos, other] = [a:pos, a:pos is# '.' ? 'v' : '.']
	let c = col(pos)
	let d = s:compare_pos(s:getcoord(pos), s:getcoord(other)) > 0
				\   ? len(s:get_pos_char([line(pos), c - (s:is_exclusive() ? 1 : 0)])) - 1
				\   : 0
	return c + d
endfunction

function! s:get_multi_col(pos) abort
	let c = col(a:pos)
	return c + len(s:get_pos_char([line(a:pos), c])) - 1
endfunction

" Helper:

function! s:is_visual(mode) abort
	return a:mode =~# "[vV\<C-v>]"
endfunction

" @return Boolean
function! s:is_exclusive() abort
	return &selection is# 'exclusive'
endfunction

function! s:curswant() abort
	return winsaveview().curswant
endfunction

" @return coordinate: [Number, Number]
function! s:getcoord(expr) abort
	return getpos(a:expr)[1:2]
endfunction

"" Return character at given position with multibyte handling
" @arg [Number, Number] as coordinate or expression for position :h line()
" @return String
function! s:get_pos_char(...) abort
	let pos = get(a:, 1, '.')
	let [line, col] = type(pos) is# type('') ? s:getcoord(pos) : pos
	return matchstr(getline(line), '.', col - 1)
endfunction

" @return int index of cursor in cword
function! s:get_pos_in_cword(cword, ...) abort
	return (s:is_visual(get(a:, 1, mode(1))) || s:get_pos_char() !~# '\k') ? 0
				\   : s:count_char(searchpos(a:cword, 'bcn')[1], s:get_multi_col('.'))
endfunction

" multibyte aware
function! s:count_char(from, to) abort
	let chars = getline('.')[a:from-1:a:to-1]
	return len(split(chars, '\zs')) - 1
endfunction

" 7.4.341
" http://ftp.vim.org/vim/patches/7.4/7.4.341
if v:version > 704 || v:version == 704 && has('patch341')
	function! s:sort_num(xs) abort
		return sort(a:xs, 'n')
	endfunction
else
	function! s:_sort_num_func(x, y) abort
		return a:x - a:y
	endfunction
	function! s:sort_num(xs) abort
		return sort(a:xs, 's:_sort_num_func')
	endfunction
endif

function! s:sort_pos(pos_list) abort
	" pos_list: [ [x1, y1], [x2, y2] ]
	return sort(a:pos_list, 's:compare_pos')
endfunction

function! s:compare_pos(x, y) abort
	return max([-1, min([1,(a:x[0] == a:y[0]) ? a:x[1] - a:y[1] : a:x[0] - a:y[0]])])
endfunction


"----------------------------------------------------------------------
" get visual_selection
"----------------------------------------------------------------------
function! s:get_visual_selection(mode)
	" call with visualmode() as the argument
	let [line_start, column_start] = getpos("'<")[1:2]
	let [line_end, column_end]     = getpos("'>")[1:2]
	let lines = getline(line_start, line_end)
	if a:mode ==# 'v'
		" Must trim the end before the start, the beginning will shift left.
		let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
		let lines[0] = lines[0][column_start - 1:]
	elseif  a:mode ==# 'V'
	" Line mode no need to trim start or end
	elseif  a:mode == "\<c-v>"
		" Block mode, trim every line
		let new_lines = []
		let i = 0
		for line in lines
			let lines[i] = line[column_start - 1: column_end - (&selection == 'inclusive' ? 1 : 2)]
			let i = i + 1
		endfor
	else
		return ''
	endif
	for line in lines
		" echom line
	endfor
	return join(lines, "\n")
endfunction


