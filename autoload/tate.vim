scriptencoding utf-8
" AUTHOR: yokoP <teruyokoP@gmail.com>
" MAINTAINER: yokoP
" License: This file is placed in the public domain.

" CHANGE TO TATE -------------------------------------------------
" INPUTS
" bls: original buffer data list
" y : index of the list (bls)
" x : index of the element of the list (bls)
" w : window width (max string display width of the window)
" h : window height (max line of the window)
function! s:ChangeToTate(bls,x,y,scrl,w,h)
  let [nls,pl,px,oln] = s:MakeNewList(a:bls,a:h-2,a:x,a:y)
  let [tls,fls,cy,cx,scrl,msc] = s:ConvertList(nls,pl,px,a:scrl,a:w)
  return [nls,tls,fls,cy,cx,pl,px,scrl,msc,oln]
endfunction
" OUTPUTS
" nls: list which length is limited to (h-2) (max line displayed)
" tls: list of each element corresponds to the displayable line
" fls: list of each element displayed now in Vertical Mode
" cy : cursor position y (Vertical Mode)
" cx : cursor position x (Vertical Mode)
" pl : index of the list (nls) corresponds to the cursor position
" px : index of the element of the list (nls) corresponds to the cursor position
" scrl: not-displayed character length of each element of the list (tls)
" msc : the difference between the max total character length of each line of
"          the list (tln) AND the display character length (when former is bigger than latter) 
" oln : list of each number (element) is correspons to the line number of the
"           original list (bls) (this list's length is the same as the nls list)
" --------------------------------------------------------------------------------

" MAKE NEW LIST ------------------------------------------------------------------
" INPUTS
" ls : list (bls) that is the original buffer list
" hi : limit height which is the limit length of the output list (nls)
" y : index of the list (bls)
" x : index of the element of the list (bls)
function! s:MakeNewList(ls,hi,x,y)
  let c = 0
  let pl = a:y
  let plf = pl
  let px = a:x
  let nls = []
  let oln = []              " original line number 
  let m = len(a:ls)
  while c < m
    let el = a:ls[c]
    let l = strchars(el)
    while l > a:hi
      if c+1 < plf
        let pl = pl + 1
      elseif (c+1 == plf) && (px > a:hi)
        let pl = pl + 1
        let px = px - a:hi
      endif
      let fst = slice(el,0,a:hi)
      let el = slice(el,a:hi)
      let nls = nls + [fst]
      let oln = oln + [c+1]
      let l = strchars(el)
    endwhile
    let nls = nls + [el]
    let oln = oln + [c+1]
    let c = c + 1
  endwhile
  return [nls,pl,px,oln]
endfunction
" OUTPUTS
" nls: list which length is limited to (h-2) (max line displayed)
" pl : index of the list (nls) corresponds to the cursor position
" px : index of the element of the list (nls) corresponds to the cursor position
" oln : list of each number (element) is correspons to the line number of the
"           original list (bls) (this list's length is the same as the nls list)
" --------------------------------------------------------------------------------

" CONVERT LIST -------------------------------------------------------------------
" INPUTS
" nls: list which length is limited to (h-2) (max line displayed)
" pl : index of the list (nls) corresponds to the cursor position
" px : index of the element of the list (nls) corresponds to the cursor position
" w : window width (max string display width of the window)
function! s:ConvertList(nls,pl,px,scrl,w)
  let tls = s:ChangeList(s:AddSpacesToList(a:nls))
  let mxl = len(a:nls)     " length of the list (max line numbers) 
  let fl = mxl - a:pl      " number of lines from left to the cursor position
  let lim = a:w/2 - 4      " the display character length
  if a:scrl == 0
    if fl > lim
      let scrl = fl - lim   
    else
      let scrl = 0
    endif
  else
    let scrl = a:scrl
  endif
  let msc = mxl - lim 
  if msc < 0
    let msc = 0
  else
    let msc = msc
  endif
  let [fls,cy,cx] = s:ShowTate(tls,a:w,a:pl,a:px,scrl,msc)
  return [tls,fls,cy,cx,scrl,msc]
endfunction
" OUTPUTS
" tls: list of each element corresponds to the displayable line
" fls: list of each element displayed now in Vertical Mode
" cy : cursor position y (Vertical Mode)
" cx : cursor position x (Vertical Mode)
" scrl: not-displayed character length of each element of the list (tls)
" msc : the difference between the mxl and lim (when mxl is bigger than lim) 
" --------------------------------------------------------------------------------  

" ADD SPACES TO LIST--------------------------------------------------------------
" INPUT
" ls: list (nls) which elements has different length
function! s:AddSpacesToList(ls)
  let lst = copy(a:ls)
  call map(lst,"strchars(v:val)")
  let mxl = max(lst)
  call map(a:ls,"s:AddSpaces(v:val,mxl)")
  return a:ls 
endfunction
" OUTPUT
" a:ls : elements has same length (max length of the input list)
" --------------------------------------------------------------------------------

" ADD SPACES ---------------------------------------------------------------------
" INPUTS
" str : string (element of the list (nls))
" mxl : max length of the list (nls)
function! s:AddSpaces(str,mxl)
  let l = strchars(a:str)
  let spn = a:mxl - l
  let sp = repeat(' ',spn)  " space code 32 
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
    let tls = add(tls,join(reverse(map(lst,"s:ChangeChar(strcharpart(v:val,c,1))")),''))
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
  if cha =='ー'
    let cha = '｜'
  elseif cha=='( ' || cha=='（'
     let cha = '⏜ '              " 23dc (in insert mode Ctrl-v u and input this HEX)
  elseif cha==') ' || cha=='）'
     let cha = '⏝ '              " 23dd
  elseif cha=='= '
     let cha = '꯫ '              " 2225 or a831, abeb, 2016 (using abeb) 
  elseif cha=='。'
    let cha = '︒'               " fe12
  elseif cha=='、'
    let cha = '︑'               " fe11
  "elseif cha=='：'
  "  let cha = '‥ '
  "elseif cha=='「'
  "  let cha = '⅂ '
  endif
  return cha 
endfunction
" OUTPUT
" cha : new string for the input character
"       character display width = 1              => add space 
"       character is not for vertical expression => change character
" --------------------------------------------------------------------------------

" SHOW TATE ----------------------------------------------------------------------
" INPUTS
" tls: list of each element corresponds to the displayable line
" w : window width (max string display width of the window)
" pl : index of the list (nls) corresponds to the cursor position
" px : index of the element of the list (nls) corresponds to the cursor position
" scrl: not-displayed character length of each element of the list (tls)
" msc : the difference between the mxl and lim (when mxl is bigger than lim) 
function! s:ShowTate(tls,w,pl,px,scrl,msc)
  let fls = s:FitToWindow(a:tls,a:w-4,a:scrl)
  call setline(2,fls)
  let [cy,cx] = s:CursorSet(fls,a:pl,a:px,a:scrl,a:msc)
  return [fls,cy,cx]
endfunction
" OUTPUTS
" fls: list of each element displayed now in Vertical Mode
" cy : cursor position y (Vertical Mode)
" cx : cursor position x (Vertical Mode)
" --------------------------------------------------------------------------------

" FIT TO WINDOW ------------------------------------------------------------------
" INPUTS
" ls  : list of each element corresponds to the displayable line (tls)
" wi  : displaying line width (string character width)
" scrl: not-displayed character length of each element of the list (tls)
function! s:FitToWindow(ls,wi,scrl)
  let mcs = s:DisplayableLength(a:ls[0]) 
  let lst = copy(a:ls)
  call map(lst,"s:FitElmToWindow(v:val,mcs,a:wi,a:scrl)")
  call map(lst,"'  ' . v:val")  " add 2 spaces at the first of each element of the list
  let lst = lst + [repeat(' ',a:wi-2)]
  return lst
endfunction
" OUTPUT
" lst : list of each element displayed now in Vertical Mode (fls)
" --------------------------------------------------------------------------------

" DISPLAYABLE LENGTH -------------------------------------------------------------
" INPUT
" str : string
function! s:DisplayableLength(str)
  let i = 0
  let l = 0
  let mc = strchars(a:str) 
  while i < mc 
    let ch = slice(a:str,i,i+1)
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
" scrl: not-displayed character length of each element of the list (tls)
function! s:FitElmToWindow(el,mcs,wi,scrl)
  if a:mcs > a:wi
    let nel = '' 
    let c = 0
    let n = 0
    while n < a:wi/2-2 + a:scrl
      let ch = a:el[c+1]
      if ch==' '                      " ここでスペースを得るといふことはバイト数1のキャラが
        let ch = a:el[c:c+1]          " 前にあるといふこと 
        let c = c + 2
      else
        let ch = a:el[c:c+2]          " さうでなければバイト数3のキャラなのだが
        let dw = strdisplaywidth(ch)  " 表示幅が1のものは スペースを加へて
        if dw == 1                    " 表示幅2にしないと 正しく表示されない
          let ch = ch . ' '           " この場合スペース分のバイト数1も加へてやる必要がある
          let c = c + 4
        else
          let c = c + 3
        endif
      endif
      let n = n + 1
      if n > a:scrl
        let nel = nel . ch
      endif
    endwhile
  elseif a:mcs < a:wi
    let nel = repeat(' ',(a:wi-a:mcs-4)) . a:el
  else 
    let nel = a:el
  endif
  return nel 
endfunction
" OUTPUT
" nel : new element with length fit to the window column size 
" --------------------------------------------------------------------------------

" CURSOR SET ---------------------------------------------------------------------
" INPUTS
" fls: list of each element displayed now in Vertical Mode
" pl : index of the list (nls) corresponds to the cursor position
" px : index of the element of the list (nls) corresponds to the cursor position
" scrl: not-displayed character length of each element of the list (tls)
" msc : the difference between the mxl and lim (when mxl is bigger than lim) 
function! s:CursorSet(fls,pl,px,scrl,msc)
  let co = s:GetGyou(a:fls[a:px-1],a:pl-a:msc+a:scrl)
  let cy = a:px + 1
  call cursor(cy,1)
  let cx = col('$') - co
  call cursor(cy,cx)
  return [cy,cx]
endfunction
" OUTPUTS
" cy : cursor position y (Vertical Mode)
" cx : cursor position x (Vertical Mode)
" --------------------------------------------------------------------------------

" GET GYOU
" INPUTS
" str : each element of the list (fls) which elements are displayable lines
" dlp : displayed vertical line position (from right)
function! s:GetGyou(str,dlp)
  let sl = strchars(a:str)
  let co = 0
  let n = 0
  while n < a:dlp
    let ch = slice(a:str,sl-1,sl)
    let n = n + 1
    if ch==' '
      let tch = slice(a:str,sl-2,sl-1)  " character in front of the space 
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
  enew
  let ls = repeat([' '],a:h-1)
  call append(1,ls)
  bp!
endfunction
" create a buffer which is empty (with new lines that can change later)
" --------------------------------------------------------------------------------

" CONV POS -----------------------------------------------------------------------
" INPUTS
" h : window height (max line of the window)
" pl : index of the list (nls) corresponds to the cursor position
" px : index of the element of the list (nls) corresponds to the cursor position
" oln : list of line numbers of the original list (bls) 
function! s:ConvPos(h,pl,px,oln)
  let ml = a:h - 2  " max length
  let y = a:oln[a:pl-1]
  let i = 1
  let x = a:px  
  while a:oln[a:pl-1-i]==y && (a:pl-i)>0 
    let x = x + ml
    let i = i + 1
    if (a:pl-1-i)<0
      break
    endif
  endwhile
  return [y,x]
endfunction
" OUTPUTS
" y : index of the list (bls) 
" x : index of the element of the list (bls)
" --------------------------------------------------------------------------------

function! s:UpdateText(fls,bls,pl,px,scrl,oln,w,h)
  let fls = a:fls
  let bls = a:bls
  let pl = a:pl
  let px = a:px
  let scrl = a:scrl
  let oln = a:oln
  let icr = px!=line('.')-1             " whether <CR> is entered or not
  let [y,x] = s:ConvPos(a:h,pl,px,oln)
  if icr
    call setline(len(fls)+2," ")
    let tl = bls[y-1]
    let heads = slice(tl,0,x-1)
    let tail = slice(tl,x-1) 
    if y==1
      let bls = [heads,tail] + bls[y:]
    else
      let bls = bls[0:y-2] + [heads,tail] + bls[y:]
    endif
    let x = 1
    let y = y + 1
  else
    let ol = fls[px-1]
    let nl = getline('.')
    let df = strchars(nl)-strchars(ol)  " character length of the input
    let ibs = df < 0                    " whether <BS> is entered or not 
    if ibs
      let tl = bls[y-1]
      if x==1
        if y==1
          let bls = [" "]
        else
          let bls = bls[0:y-2] + bls[y:]
          let x = strchars(bls[y-2]) + 1 
          let y = y - 1
        endif
      else
        let heads = slice(tl,0,x-2)
        let tail = slice(tl,x-1) 
        let tnl = heads . tail
        if y==1
          if x==2
            let bls = [" "] + bls[y:]
          else
            let bls = [tnl] + bls[y:]
          endif
        else
          let bls = bls[0:y-2] + [tnl] + bls[y:]
        endif
        let x = x - 1 
      endif
    else
      let str = ""
      let i = 0
      if ol!=nl
        while slice(ol,i,i+1)==slice(nl,i,i+1)
          let i += 1  
        endwhile
        let str = slice(nl,i,i+df)      " input string 
      endif
      let tl = bls[y-1]
      let heads = slice(tl,0,x-1)
      let tail = slice(tl,x-1) 
      let tnl = heads . str . tail      " new vertical line 
      if y==1
        let bls = [tnl] + bls[y:]
      else
        let bls = bls[0:y-2] + [tnl] + bls[y:]
      endif
      let x = x + df
    endif
  endif
  let [nls,tls,fls,cy,cx,pl,px,scrl,msc,oln] = s:ChangeToTate(bls,x,y,scrl,a:w,a:h)
  let status = "pl=".pl." px=".px." cy=".cy." cx=".cx." s=".scrl." m=".msc
  call setline(1,status)
  return [bls,tls,fls,pl,px,cy,cx,scrl,msc,oln]
endfunction

function! s:MoveCursor(fls,tls,w,h,cy,cx,pl,px,scrl,msc)
  let fls = a:fls
  let cpos = getcurpos('.')
  let cy = a:cy
  let cx = a:cx
  let pl = a:pl
  let px = a:px
  let scrl = a:scrl
  let ncy = cpos[1]
  let ncx = cpos[2]
  if cy > ncy                   " cursor move up
    let px = px - 1
    if ncy==1
      let px = 1
    endif
    let [cy,cx] = s:CursorSet(fls,pl,px,scrl,a:msc)
  elseif cy < ncy               " cursor move down
    let px = px + 1
    if ncy==a:h
      let px = px - 1
    endif
    let [cy,cx] = s:CursorSet(fls,pl,px,scrl,a:msc) 
  elseif cx > ncx               " cursor move left
    if ncx > 2
      let pl = pl + 1
    endif
    if scrl > 0 && ncx < 10
      let scrl = scrl - 1
      let [fls,cy,cx] = s:ShowTate(a:tls,a:w,pl,px,scrl,a:msc)
    else
      let [cy,cx] = s:CursorSet(fls,pl,px,scrl,a:msc)
    endif
  elseif cx < ncx               " cursor move right
    let pl = pl - 1
    if a:msc > scrl && ncx > (col('$')-10)
      let scrl +=  1
      let [fls,cy,cx] = s:ShowTate(a:tls,a:w,pl,px,scrl,a:msc)
    else
      let [cy,cx] = s:CursorSet(fls,pl,px,scrl,a:msc)
    endif
  endif
  let status = "pl=".pl." px=".px." cy=".cy." cx=".cx." s=".scrl." m=".a:msc
  call setline(1,status)
  return [fls,cy,cx,pl,px,scrl]
endfunction

function! tate#TateStart()
  let s:h = winheight('%')  " height of the window 
  let s:w = winwidth('%')   " width of the window 
  " define q key and w key for command :Tateq and :Tatec
  command! Tateq call TateEnd()
  command! Tatec call TateChange()
  write                   " write the current buffer to the file 
  set nofoldenable        " set off the script fold
  let l:y = line('.')       " the current line which is on the cursor 
  let l:x = charcol('.')    " character index of the line where the cursor is exist 
  " create new buffer, make empty lines and return to the original buffer 
  call s:CreateField(s:h) 
  let s:bls = getline(1,line("$"))  " set all lines of the original buffer to a list 
  call map(s:bls,"(v:val) . ' '")   " add space to all elements of the list 
  bn!                               " move to the buffer created for vertical input
  nnoremap <buffer> q :Tateq
  nnoremap <buffer> w :Tatec
  let [b:nls,b:tls,b:fls,b:cy,b:cx,b:pl,b:px,b:scrl,b:msc,b:oln] = s:ChangeToTate(s:bls,l:x,l:y,0,s:w,s:h)
  augroup Tate 
    autocmd!
    autocmd InsertLeave * call feedkeys("\<right>",'n')
    autocmd TextChangedI * let [s:bls,b:tls,b:fls,b:pl,b:px,b:cy,b:cx,b:scrl,b:msc,b:oln] = s:UpdateText(b:fls,s:bls,b:pl,b:px,b:scrl,b:oln,s:w,s:h)
    autocmd CursorMoved * let [b:fls,b:cy,b:cx,b:pl,b:px,b:scrl] = s:MoveCursor(b:fls,b:tls,s:w,s:h,b:cy,b:cx,b:pl,b:px,b:scrl,b:msc)
  augroup END
endfunction

function! TateChange()
  augroup Tate 
    autocmd!
  augroup END
  bd!                     " return the original buffer
  " clear the buffer
  normal 1G
  normal dG 
  call append(0,s:bls)     " append new data
  delcommand Tateq
  delcommand Tatec
  unlet s:bls
  unlet s:w
  unlet s:h
endfunction

function! TateEnd()
  augroup Tate 
    autocmd!
  augroup END
  bd!
  delcommand Tateq
  delcommand Tatec
  unlet s:bls
  unlet s:w
  unlet s:h
  mapclear
endfunction
