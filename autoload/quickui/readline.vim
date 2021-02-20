"======================================================================
"
" readline.vim - 
"
" Created by skywind on 2021/02/20
" Last Modified: 2021/02/20 12:58:24
"
"======================================================================


"----------------------------------------------------------------------
" readline class
"----------------------------------------------------------------------
let s:readline = {}
let s:readline.cursor = 0       " cursur position in character
let s:readline.code = []        " buffer character in int list
let s:readline.wide = []        " char display width
let s:readline.size = 0         " buffer size in character
let s:readline.text = ''        " text buffer
let s:readline.dirty = 0        " dirty
let s:readline.select = -1      " visual selection start pos
let s:readline.history = []     " history text
let s:readline.index = 0        " history pointer, 0 for current


"----------------------------------------------------------------------
" move pos
"----------------------------------------------------------------------
function! s:readline.move(pos) abort
	let pos = a:pos
	let pos = (pos < 0)? 0 : pos
	let pos = (pos > self.size)? self.size : pos
	let self.cursor = pos
	return pos
endfunc


"----------------------------------------------------------------------
" set text
"----------------------------------------------------------------------
function! s:readline.set(text)
	let code = list2str(text)
	let wide = []
	for cc in code
		let ch = nr2char(cc)
		let wide += [strdisplaywidth(cc)]
	endfor
	let self.code = code
	let self.wide = wide
	let self.size = len(code)
	let self.dirty = 1
	call self.move(self.cursor)
endfunc


"----------------------------------------------------------------------
" internal: update text parts
"----------------------------------------------------------------------
function! s:readline.update() abort
	let self.text = list2str(self.code)
	let self.dirty = 0
	return self.text
endfunc


"----------------------------------------------------------------------
" extract text: -1/0/1 for text before/on/after cursor
"----------------------------------------------------------------------
function! s:readline.extract(locate)
	let cc = self.cursor
	if a:locate < 0
		let p = slice(self.code, 0, cc)
	elseif a:locate == 0
		let p = slice(self.code, cc, cc + 1)
	else
		let p = slice(self.code, cc + 1)
	endif
	return list2str(p)
endfunc


"----------------------------------------------------------------------
" insert text in current cursor position
"----------------------------------------------------------------------
function! s:readline.insert(text) abort
	let code = str2list(text)
	let wide = []
	let cursor = self.cursor
	for cc in code
		let ch = nr2char(cc)
		let wide += [strdisplaywidth(cc)]
	endfor
	call insert(self.code, code, cursor)
	call insert(self.wide, wide, cursor)
	let self.size = len(self.code)
	let self.cursor += len(code)
	let self.dirty = 1
endfunc


"----------------------------------------------------------------------
" internal function: delete n characters on and after cursor
"----------------------------------------------------------------------
function! s:readline.delete(size) abort
	let avail = self.size - cursor
	if avail > 0
		let size = a:size
		let size = (size > avail)? avail : size
		let cursor = self.cursor
		call remove(self.code, cursor, cursor + size - 1)
		call remove(self.wide, cursor, cursor + size - 1)
		let self.size = len(self.code)
		let self.dirty = 1
	endif
endfunc


"----------------------------------------------------------------------
" backspace
"----------------------------------------------------------------------
function! s:readline.backspace(size) abort
	let avail = self.cursor
	let size = a:size
	let size = (size > avail)? avail : size
	if size > 0
		let self.cursor -= size
		call self.delete(size)
		let self.dirty = 1
	endif
endfunc


"----------------------------------------------------------------------
" replace
"----------------------------------------------------------------------
function! s:readline.replace(text) abort
	let length = strchars(a:text)
	if length > 0
		call self.delete(length)
		call self.insert(a:text)
		let self.dirty = 1
	endif
endfunc


"----------------------------------------------------------------------
" save history in current position
"----------------------------------------------------------------------
function! s:readline.history_save() abort
	let size = len(self.history)
	if size > 0
		let self.index = (self.index < 0)? 0 : self.index
		let self.index = (self.index >= size)? (size - 1) : self.index
		if self.dirty
			call self.update()
		endif
		let self.history[self.index] = self.text
	endif
endfunc


"----------------------------------------------------------------------
" previous history
"----------------------------------------------------------------------
function! s:readline.history_prev() abort
	let size = len(self.history)
	if size > 0
		call self.history_save()
		let self.index = (self.index < size - 1)? (self.index + 1) : 0
		call self.set(self.history[self.index])
	endif
endfunc


"----------------------------------------------------------------------
" next history
"----------------------------------------------------------------------
function! s:readline.history_next() abort
	let size = len(self.history)
	if size > 0
		call self.history_save()
		let self.index = (self.index <= 0)? (size - 1) : (self.index - 1)
		call self.set(self.history[self.index])
	endif
endfunc


"----------------------------------------------------------------------
" init history
"----------------------------------------------------------------------
function! s:readline.history_init(history) abort
	if len(a:history) == 0
		let self.history = []
		let self.index = 0
	else
		let history = deepcopy(a:history) + ['']
		call reverse(history)
		let self.history = history
		let self.index = 0
	endif
endfunc


"----------------------------------------------------------------------
" feed character
"----------------------------------------------------------------------
function! s:readline.feed(char) abort
	let char = a:char
	let code = str2list(char)
	let head = len(code)? code[0] : 0
	if head < 0x20 || head == 0x80
		if char == "\<BS>"
			call self.backspace(1)
		elseif char == "\<DELETE>"
			call self.delete(1)
		elseif char == "\<LEFT>"
			call self.move(self.cursor - 1)
		elseif char == "\<RIGHT>"
			call self.move(self.cursor + 1)
		elseif char == "\<UP>"
			call self.history_prev()
		elseif char == "\<DOWN>"
			call self.history_next()
		elseif char == "\<c-d>"
			call self.delete(1)
		elseif char == "\<c-k>"
			if self.size > self.cursor
				call self.delete(self.size - self.cursor)
			endif
		elseif char == "\<home>"
			call self.move(0)
		elseif char == "\<end>"
			call self.move(self.size)
		elseif char == "\<C-Insert>"
		elseif char == "\<S-Insert>"
		elseif char == "\<c-w>"
		else
			return -1
		endif
		return 0
	else
		call self.insert(char)
	endif
	return 0
endfunc


