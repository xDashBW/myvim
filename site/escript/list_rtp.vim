tabnew
for name in split(&rtp, ',')
	call append('$', [name])
endfor
exec "normal ggdd"
set nomodified

