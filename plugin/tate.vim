" AUTHOR: yokoP
" MAINTAINER: yokoP
" License: This file is placed in the public domain.

if exists('g:loaded_tate') && g:loaded_tate
  finish
endif

command! Tate call tate#TateStart()
command! Tateq call tate#TateEnd()
command! Tatec call tate#TateChange()
nnoremap t :Tate
