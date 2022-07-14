scriptencoding utf-8
" AUTHOR: yokoP <teruyokoP@gmail.com>
" MAINTAINER: yokoP
" License: This file is placed in the public domain.

" CHANGE TO TATE -------------------------------------------------
" INPUTS
" x : index of the element of the list (bls)
" y : index of the list (bls)
" USING
" b:h : window height (max line of the window)
function! s:ChangeToTate(x, y)
  call s:MakeNewList(b:h - 2, a:x, a:y)
  call s:ConvertList()
endfunction
" --------------------------------------------------------------------------------

" MAKE NEW LIST ------------------------------------------------------------------
" INPUTS
" hi : limit height which is the limit length of the output list (nls)
" y : index of the list (bls)
" x : index of the element of the list (bls)
" USING
" b:bls : list (bls) that is the original buffer list
function! s:MakeNewList(hi, x, y)
  let c = 0
  let b:pl = a:y
  let plf = b:pl
  let b:px = a:x
  let b:nls = []
  let b:oln = []              " original line number 
  let m = len(b:bls)
  while c < m
    let el = b:bls[c]
    let l = strchars(el)
    while l > a:hi
      if c+1 < plf
        let b:pl = b:pl + 1
      elseif (c+1 == plf) && (b:px > a:hi)
        let b:pl = b:pl + 1
        let b:px = b:px - a:hi
      endif
      let fst = slice(el, 0, a:hi)
      let el = slice(el, a:hi)
      let b:nls = b:nls + [fst]
      let b:oln = b:oln + [c + 1]
      let l = strchars(el)
    endwhile
    let b:nls = b:nls + [el]
    let b:oln = b:oln + [c + 1]
    let c = c + 1
  endwhile
endfunction
" CHANGED 
" b:nls: list which length is limited to (h-2) (max line displayed)
" b:pl : index of the list (nls) corresponds to the cursor position
" b:px : index of the element of the list (nls) corresponds to the cursor position
" b:oln : list of each number (element) is correspons to the line number of the
"           original list (bls) (this list's length is the same as the nls list)
" --------------------------------------------------------------------------------

" CONVERT LIST -------------------------------------------------------------------
" USING
" b:nls: list which length is limited to (h-2) (max line displayed)
" b:pl : index of the list (nls) corresponds to the cursor position
" b:px : index of the element of the list (nls) corresponds to the cursor position
" b:scrl: not-displayed character length of each element of the list (tls)
" b:w : window width (max string display width of the window)
function! s:ConvertList()
  let b:tls = s:ChangeList(s:AddSpacesToList(b:nls))
  let mxl = len(b:nls)     " length of the list (max line numbers) 
  let fl = mxl - b:pl      " number of lines from left to the cursor position
  let lim = b:w / 2 - 4      " the display character length
  let ex = b:pl
  if ex > 5
    let ex = 4
  endif
  if b:scrl == 0
    if fl > lim
      let b:scrl = fl - lim + ex  
    endif
  endif
  let b:msc = mxl - lim 
  if b:msc < 0
    let b:msc = 0
  endif
  call s:ShowTate()
endfunction
" Changed 
" b:tls: list of each element corresponds to the displayable line
" b:fls: list of each element displayed now in Vertical Mode
" b:cy : cursor position y (Vertical Mode)
" b:cx : cursor position x (Vertical Mode)
" b:scrl: not-displayed character length of each element of the list (tls)
" b:msc : the difference between the mxl and lim (when mxl is bigger than lim) 
" --------------------------------------------------------------------------------  

" ADD SPACES TO LIST--------------------------------------------------------------
" INPUT
" ls: list (nls) which elements has different length
function! s:AddSpacesToList(ls)
  let lst = copy(a:ls)
  let lst2 = copy(a:ls)
  call map(lst, "strchars(v:val)")
  let mxl = b:h - 2 
  call map(lst2, "s:AddSpaces(v:val, mxl)")
  return lst2 
endfunction
" OUTPUT
" lst2 : elements has same length (max length of the input list)
" --------------------------------------------------------------------------------

" ADD SPACES ---------------------------------------------------------------------
" INPUTS
" str : string (element of the list (nls))
" mxl : max length of the list (nls)
function! s:AddSpaces(str, mxl)
  let l = strchars(a:str)
  let spn = a:mxl - l
  let sp = repeat(' ', spn)  " space code 32 
  return (a:str . sp)
endfunction
" OUTPUT
" a:str . sp : new element of the list which is the same length with mxl
" --------------------------------------------------------------------------------

" CHANGE LIST --------------------------------------------------------------------
" INPUT
" ls : list of the same length elements version of the nls
function! s:ChangeList(ls)
  let c = 0
  let tls = []
  let m = strchars(a:ls[0])
  while c < m 
    let lst = copy(a:ls)
    let tls = add(tls, join(reverse(map(lst, "s:ChangeChar(strcharpart(v:val, c, 1))")), ''))
    let c = c + 1
  endwhile
  return tls
endfunction
" OUTPUT
" tls: list of each element corresponds to the displayable line
" -------------------------------------------------------------------------------- 

" CHANGE CHAR --------------------------------------------------------------------
" INPUT
" ch : character of the element of the list (tls)
function! s:ChangeChar(ch)
  let dw = strdisplaywidth(a:ch) " display width of the character
  let cha = a:ch
  if dw == 1
    let cha = cha . ' '
  endif
  if cha == 'ー'
    let cha = '｜'
  elseif cha == '( ' || cha == '（'
     let cha = '⏜ '              " 23dc (in insert mode Ctrl-v u and input this HEX)
  elseif cha == ') ' || cha == '）'
     let cha = '⏝ '              " 23dd
  elseif cha == '= '
     let cha = '꯫ '              " 2225 or a831, abeb, 2016 (using abeb) 
  elseif cha == '。'
    let cha = '︒'               " fe12
  elseif cha == '、'
    let cha = '︑'               " fe11
  endif
  return cha 
endfunction
" OUTPUT
" cha : new string for the input character
"       character display width = 1              => add space 
"       character is not for vertical expression => change character
" --------------------------------------------------------------------------------

" SHOW TATE ----------------------------------------------------------------------
" Using 
" b:w : window width (max string display width of the window)
function! s:ShowTate()
  call s:FitToWindow(b:w - 4)
  call setline(2, b:fls)
  call s:CursorSet()
endfunction
" CHANGED 
" b:fls: list of each element displayed now in Vertical Mode
" cy : cursor position y (Vertical Mode)
" cx : cursor position x (Vertical Mode)
" --------------------------------------------------------------------------------

" FIT TO WINDOW ------------------------------------------------------------------
" INPUT
" wi  : displaying line width (string character width)
" USING
" b:tls : list of each element corresponds to the displayable line (tls)
" b:scrl: not-displayed character length of each element of the list (tls)
function! s:FitToWindow(wi)
  let l:mcs = s:DisplayableLength(b:tls[0]) 
  let lst = copy(b:tls)
  call map(lst, "s:FitElmToWindow(v:val, l:mcs, a:wi)")
  call map(lst, "'  ' . v:val")  " add 2 spaces at the first of each element of the list
  let b:fls = lst + [repeat(' ', a:wi - 2)]
endfunction
" CHANGED
" b:fls : list of each element displayed now in Vertical Mode (fls)
" --------------------------------------------------------------------------------

" DISPLAYABLE LENGTH -------------------------------------------------------------
" INPUT
" str : string
function! s:DisplayableLength(str)
  let i = 0
  let l = 0
  let mc = strchars(a:str) 
  while i < mc 
    let ch = slice(a:str, i, i + 1)
    let dw = strdisplaywidth(ch)
    let l = l + dw
    let i += 1
  endwhile
  return l
endfunction
" OUTPUT
" l : sum of the display width
" --------------------------------------------------------------------------------

" FIT ELM TO WINOW ---------------------------------------------------------------
" INPUTS
" el : element of the list (tls)
" wi  : displaying line width (string character width)
" USING
" b:scrl: not-displayed character length of each element of the list (tls)
function! s:FitElmToWindow(el, mcs, wi)
  if a:mcs > a:wi
    let nel = '' 
    let c = 0
    let n = 0
    while n < a:wi / 2 - 2 + b:scrl
      let ch = a:el[c + 1]
      if ch == ' '                      " ここでスペースを得るといふことはバイト数1のキャラが
        let ch = a:el[c : c + 1]          " 前にあるといふこと 
        let c = c + 2
      else
        let ch = a:el[c : c + 2]          " さうでなければバイト数3のキャラなのだが
        let dw = strdisplaywidth(ch)  " 表示幅が1のものは スペースを加へて
        if dw == 1                    " 表示幅2にしないと 正しく表示されない
          let ch = ch . ' '           " この場合スペース分のバイト数1も加へてやる必要がある
          let c = c + 4
        else
          let c = c + 3
        endif
      endif
      let n = n + 1
      if n > b:scrl
        let nel = nel . ch
      endif
    endwhile
  elseif a:mcs < a:wi
    let nel = repeat(' ', (a:wi - a:mcs - 4)) . a:el
  else 
    let nel = a:el
  endif
  return nel 
endfunction
" OUTPUT
" nel : new element with length fit to the window column size 
" --------------------------------------------------------------------------------

" CURSOR SET ---------------------------------------------------------------------
" USING
" b:fls: list of each element displayed now in Vertical Mode
" b:pl : index of the list (nls) corresponds to the cursor position
" b:px : index of the element of the list (nls) corresponds to the cursor position
" b:scrl: not-displayed character length of each element of the list (tls)
" b:msc : the difference between the mxl and lim (when mxl is bigger than lim) 
function! s:CursorSet()
  let co = s:GetGyou(b:fls[b:px - 1], b:pl - b:msc + b:scrl)
  let b:cy = b:px + 1
  call cursor(b:cy, 1)
  let b:cx = col('$') - co
  call cursor(b:cy, b:cx)
endfunction
" CHANGED 
" b:cy : cursor position y (Vertical Mode)
" b:cx : cursor position x (Vertical Mode)
" --------------------------------------------------------------------------------

" GET GYOU
" INPUTS
" str : each element of the list (fls) which elements are displayable lines
" dlp : displayed vertical line position (from right)
function! s:GetGyou(str, dlp)
  let sl = strchars(a:str)
  let co = 0
  let n = 0
  while n < a:dlp
    let ch = slice(a:str, sl - 1, sl)
    let n = n + 1
    if ch==' '
      let tch = slice(a:str, sl - 2,sl - 1)  " character in front of the space 
      let co = co + 1 + len(tch)        " add character bytes and the byte of the space 
      let sl = sl - 2
    else
      let co = co + 3       " add 3 bytes when displaywidth is 2 
      let sl = sl - 1
    endif
  endwhile
  return co
endfunction
" OUTPUT
" co : column length from the right limit to the cursor position  
" --------------------------------------------------------------------------------

" CREATE FIELD ------------------------------------------------------------------
" INPUT
" h : window height (max line of the window)
function! s:CreateField(h)
  enew!
  set nofoldenable        " set off the script fold
  set nonumber
  set scrolloff=0
  let ls = repeat([' '], a:h - 1)
  call append(1, ls)
  bp!
endfunction
" create a buffer which is empty (with new lines that can change later)
" --------------------------------------------------------------------------------

" CONV POS -----------------------------------------------------------------------
" USING
" b:h : window height (max line of the window)
" b:pl : index of the list (nls) corresponds to the cursor position
" b:px : index of the element of the list (nls) corresponds to the cursor position
" b:oln : list of line numbers of the original list (bls) 
function! s:ConvPos()
  let ml = b:h - 2  " max length
  let y = b:oln[b:pl - 1]
  let i = 1
  let x = b:px  
  while b:oln[b:pl - 1 - i] == y && (b:pl - i) > 0 
    let x = x + ml
    let i = i + 1
    if (b:pl - 1 - i) < 0
      break
    endif
  endwhile
  return [y, x]
endfunction
" OUTPUTS
" y : index of the list (bls) 
" x : index of the element of the list (bls)
" --------------------------------------------------------------------------------

function! s:UpdateText(bli)
  let icr = b:px != line('.') - 1             " whether <CR> is entered or not
  let [y, x] = s:ConvPos()
  if icr
    let s:bcr = 1 
    call setline(len(b:fls) + 2, " ")
    let tl = b:bls[y - 1]
    let heads = slice(tl, 0, x - 1)
    let tail = slice(tl, x - 1) 
    if y == 1
      let b:bls = [heads, tail] + b:bls[y :]
    else
      let b:bls = b:bls[0 : y - 2] + [heads, tail] + b:bls[y :]
    endif
    let x = 1
    let y = y + 1
  else
    if a:bli == 0
    let ol = b:fls[b:px - 1]
    let nl = getline('.')
    let df = strchars(nl) - strchars(ol)  " character length of the input
    let ibs = df < 0                    " whether <BS> is entered or not 
    if ibs
      let tl = b:bls[y - 1]
      if x == 1
        if y == 1
          let b:bls = [" "]
        else
          let b:bls = b:bls[0 : y - 2] + b:bls[y :]
          let x = strchars(b:bls[y - 2]) + 1 
          let y = y - 1
        endif
      else
        let heads = slice(tl, 0, x - 2)
        let tail = slice(tl, x - 1) 
        let tnl = heads . tail
        if y == 1
          if x == 2
            let b:bls = [" "] + b:bls[y :]
          else
            let b:bls = [tnl] + b:bls[y :]
          endif
        else
          let b:bls = b:bls[0 : y - 2] + [tnl] + b:bls[y :]
        endif
        let x = x - 1 
      endif
    else
      let str = ""
      let i = 0
      if ol != nl
        while slice(ol, i, i + 1)==slice(nl, i, i + 1)
          let i += 1  
        endwhile
        let str = slice(nl, i, i + df)      " input string 
      endif
      let tl = b:bls[y - 1]
      let heads = slice(tl, 0, x - 1)
      let lnl = strchars(tl)
      if lnl < x
        let str = repeat(' ', x - lnl - 1) . str
      endif
      let tail = slice(tl, x - 1) 
      let tnl = heads . str . tail      " new vertical line 
      if y == 1
        let b:bls = [tnl] + b:bls[y :]
      else
        let b:bls = b:bls[0 : y - 2] + [tnl] + b:bls[y :]
      endif
      let x = x + df
    endif
  endif
    let s:bcr = 0 
  endif
  call s:ChangeToTate(x, y)
  let status = "pl=" . b:pl . " px=" . b:px . " cy=" . b:cy . " cx=" . b:cx . " s=" . b:scrl . " m=" . b:msc
  call setline(1, status)
endfunction

function! s:MoveCursor()
  let cpos = getcurpos('.')
  let ncy = cpos[1]
  let ncx = cpos[2]
  if b:cy > ncy                   " cursor move up
    let b:px = b:px - 1
    if ncy == 1
      let b:px = 1
    endif
    call s:CursorSet()
  elseif b:cy < ncy               " cursor move down
    let b:px = b:px + 1
    if ncy == b:h
      let b:px = b:px - 1
    endif
    call s:CursorSet() 
  elseif b:cx > ncx               " cursor move left
    if ncx > 2
      let b:pl = b:pl + 1
    endif
    if b:scrl > 0 && ncx < 10
      let b:scrl = b:scrl - 1
      call s:ShowTate()
    else
      call s:CursorSet()
    endif
  elseif b:cx < ncx               " cursor move right
    let b:pl = b:pl - 1
    if b:msc > b:scrl && ncx > (col('$') - 10)
      let b:scrl +=  1
      call s:ShowTate()
    else
      if b:pl == 0
        let b:pl = b:pl + 1
        let b:cx = b:cx + 1
      endif
      call s:CursorSet()
    endif
  endif
  let status = "pl=" . b:pl . " px=" . b:px . " cy=" . b:cy . " cx=" . b:cx . " s=" . b:scrl . " m=" . b:msc
  call setline(1,status)
endfunction

function! tate#TateStart()
  let l:h = winheight('%')  " height of the window 
  let l:w = winwidth('%')   " width of the window 
  let l:y = line('.')       " the current line which is on the cursor 
  let l:x = charcol('.')    " character index of the line where the cursor is exist 
  " create new buffer, make empty lines and return to the original buffer 
  call s:CreateField(l:h) 
  let l:bls = getline(1, line("$"))  " set all lines of the original buffer to a list 
  " call map(l:bls, "(v:val) . ' '")   " add space to all elements of the list 
  bn!                               " move to the buffer created for vertical input
  let [b:bls, b:nls, b:tls, b:fls, b:oln, b:cy, b:cx, b:pl, b:px, b:scrl, b:msc, b:h, b:w, s:bcr] = [l:bls, [], [], [], [], 0, 0, 0, 0, 0, 0, l:h, l:w, 0] 
  call s:ChangeToTate(l:x, l:y)
  command! Tateq call TateEnd()
  command! Tatec call TateChange(b:bls)
  nnoremap <buffer> q :Tateq
  nnoremap <buffer> w :Tatec
  augroup Tate 
    autocmd!
    autocmd InsertLeave <buffer> call s:UpdateText(1) 
    autocmd TextChangedI <buffer> call s:UpdateText(0)
    autocmd CursorMoved <buffer> call s:MoveCursor()
  augroup END
endfunction

function! TateChange(bls)
  augroup Tate 
    autocmd!
  augroup END
  let [y, x] = s:ConvPos()
  bd!                     " return the original buffer
  " clear the buffer
  normal 1G
  normal dG 
  call append(0, a:bls)     " append new data
  normal G
  normal dd                 " delete the last line
  call cursor(y, x)
  delcommand Tateq
  delcommand Tatec
endfunction

function! TateEnd()
  augroup Tate 
    autocmd!
  augroup END
  bd!
  delcommand Tateq
  delcommand Tatec
  mapclear
endfunction
