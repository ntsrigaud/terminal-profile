" VIM Configuration Profile

" Use the first installed Powerline Vim binding across Python versions.
let s:powerline_bindings = globpath($HOME . '/.local/lib', 'python*/site-packages/powerline/bindings/vim', 0, 1)
if len(s:powerline_bindings) > 0
	execute 'set rtp+=' . fnameescape(s:powerline_bindings[0])
endif

" Always show statusline
set laststatus=2

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" Always show the command as it is being typed.
set showcmd

