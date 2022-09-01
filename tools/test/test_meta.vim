
for i in range(12)
	let n = i + 1
	let fn = 'F' . (i + 1)
	exec printf("noremap <s-%s> :echo 'shift+%s'<cr>", fn, fn)
	exec printf("noremap <c-%s> :echo 'ctrl+%s'<cr>", fn, fn)
	exec printf("noremap <m-%s> :echo 'meta+%s'<cr>", fn, fn)
endfor

for t in ['up', 'down', 'left', 'right']
	exec printf("noremap <s-%s> :echo 'shift+%s'<cr>", t, t)
	exec printf("noremap <c-%s> :echo 'ctrl+%s'<cr>", t, t)
	exec printf("noremap <m-%s> :echo 'meta+%s'<cr>", t, t)
endfor


