scriptencoding utf-8
if exists('g:loaded_swindle')
  finish
endif
let g:loaded_swindle = 1

let s:save_cpo = &cpo
set cpo&vim


command! -nargs=0 SwindleJumpNext call swindle#jump_next()
command! -nargs=0 SwindleJumpPrev call swindle#jump_prev()
command! -nargs=0 SwindleCloseBuffer call swindle#close_buffer()

nnoremap <silent> <Plug>(swindle-jump-next) :<C-u>SwindleJumpNext<CR>
nnoremap <silent> <Plug>(swindle-jump-prev) :<C-u>SwindleJumpPrev<CR>
nnoremap <silent> <Plug>(swindle-close-buffer) :<C-u>SwindleCloseBuffer<CR>

augroup swindle
	autocmd!
	autocmd BufWinEnter * call swindle#on_BufWinEnter()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
