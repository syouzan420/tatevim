function! s:ChangeToTate(bf,x,y,w,h)
  let [nls,pl,px,oln] = s:MakeNewList(a:bf,a:h-2,a:x,a:y)
  let [lst,fin,cy,cx,scrl,msc] = s:ConvertList(nls,pl,px,a:w)
  return [nls,lst,fin,cy,cx,pl,px,scrl,msc,oln]
endfunction

function! s:ConvertList(nls,pl,px,w)
  let lst = s:ChangeList(s:AddSpacesToList(a:nls))
  let mxl = len(a:nls)     " 行数
  let fl = mxl - a:pl -1   " カーソル行と全行数の差（from left position)
  let lim = a:w/2 - 4      " 最大で表示できる行数から4を引いたもの (cursor limit)
  if fl > lim
    let scrl = fl - lim  " 右へスクロールさせる行数
  else
    let scrl = 0
  endif
  let msc = mxl - a:w/2 + 3   " スクロールできる最大数
  if msc < 0
    let msc = 0
  else
    let msc = msc
  endif
  let [fin,cy,cx] = s:ShowTate(lst,a:w,a:pl,a:px,scrl,msc)
  return [lst,fin,cy,cx,scrl,msc]
endfunction

function! s:CursorSet(fin,pl,px,scrl,msc)
  let co = s:GetGyou(a:fin[a:px-1],a:pl-a:msc+a:scrl)
  let cy = a:px + 1
  call cursor(cy,1)
  let cx = col('$') - co
  call cursor(cy,cx)
  return [cy,cx]
endfunction

function! s:ShowTate(lst,w,pl,px,scrl,msc)
  let fin = s:FitToWindow(a:lst,a:w-4,a:scrl)
  call setline(2,fin)
  let [cy,cx] = s:CursorSet(fin,a:pl,a:px,a:scrl,a:msc)
  return [fin,cy,cx]
endfunction

function! s:MoveCursor()
  let fin = s:fin
  let lst = s:lst
  let w = s:w
  let cy = s:cy
  let cx = s:cx
  let pl = s:pl
  let px = s:px
  let scrl = s:scrl
  let msc = s:msc
  let cpos = getcurpos('.')
  let ncy = cpos[1]
  let ncx = cpos[2]
  if cy>ncy
    let px = px - 1
    if ncy==1
      let px = 1
    endif
    let [cy,cx] = s:CursorSet(fin,pl,px,scrl,msc)
  elseif cy<ncy
    let px = px + 1
    if ncy==s:h
      let px = px - 1
    endif
    let [cy,cx] = s:CursorSet(fin,pl,px,scrl,msc) 
  elseif cx>ncx
    if ncx > 2
      let pl = pl + 1
    endif
    if scrl>0 && ncx<10
      let scrl = scrl - 1
      let [fin,cy,cx] = s:ShowTate(lst,w,pl,px,scrl,msc)
    else
      let [cy,cx] = s:CursorSet(fin,pl,px,scrl,msc)
    endif
  elseif cx<ncx
    let pl = pl - 1
    if msc>scrl && ncx>(col('$')-10)
      let scrl = scrl + 1
      let [fin,cy,cx] = s:ShowTate(lst,w,pl,px,scrl,msc)
    else
      let [cy,cx] = s:CursorSet(fin,pl,px,scrl,msc)
    endif
  endif
  return [fin,cy,cx,pl,px,scrl]
endfunction

function! s:GetGyou(str,pl)
  let sl = strchars(a:str)
  let co = 0
  let n = 0
  while n < a:pl
    let ch = slice(a:str,sl-1,sl)
    let n = n + 1
    if ch==' '
      let tch = slice(a:str,sl-2,sl-1)  " スペースの前のキャラクタを得る
      let co = co + 1 + len(tch)        " そのキャラのバイト数に對應して長さを變へる
      let sl = sl - 2
    else
      let co = co + 3       " displaywidth が2のキャラは そのままバイト数を加へる
      let sl = sl - 1
    endif
  endwhile
  return co
endfunction

function! s:CreateField(h)
  enew
  let ls = repeat([' '],a:h-1)
  call append(1,ls)
  bp!
endfunction

function! s:FitToWindow(ls,wi,sc)
  let mcs = len(a:ls[0])
  let res = mapnew(a:ls,"s:FitElmToWindow(v:val,mcs,a:wi,a:sc)")
  call map(res,"'  ' . v:val")
  return res
endfunction

function! s:FitElmToWindow(el,mc,wi,sc)
  if a:mc > a:wi
    let ebl = '' 
    let c = 0
    let n = 0
    while n < a:wi/2-1 + a:sc
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
      if n > a:sc
        let ebl = ebl . ch
      endif
    endwhile
  elseif a:mc < a:wi
    let ebl = repeat(' ',(a:wi-a:mc)) . a:el
  else 
    let ebl = a:el
  endif
  return ebl
endfunction

function! s:MakeNewList(ls,hi,x,y)
  "長さが hi を越える要素は その長さの要素と 残りの要素に分割して
  "リストを置換する
  let c = 0
  let pl = a:y
  let plf = pl
  let px = a:x
  let nls = []
  let oln = []      " original line number 元の行番号をもつリスト
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

function! s:ChangeList(ls)
  let c = 0
  let nls = []
  let m = strchars(a:ls[0])
  while c < m 
    let nls = add(nls,join(reverse(mapnew(a:ls,"s:ChangeChar(strcharpart(v:val,c,1))")),''))
    let c = c + 1
  endwhile
  return nls
endfunction

" キャラクターが表示幅1ならば スペースを追加して 強制的に幅2とする
" さらに 縦に見せるべきキャラクター （括弧など）は 縦書き用に変換する
" ちなみに この時 1バイトのキャラ（イコールや括弧など)が3バイトのキャラに変換されたりする
" しかも その3バイトキャラは表示幅が1なので スペースを後に加へなければならない
" このことをふまへて s:FitElmToWindow関数 s:GetGyou関数の
" 擧動を考へなければならなかった
function! s:ChangeChar(ch)
  let dw = strdisplaywidth(a:ch)
  let cha = a:ch
  if dw == 1
    let cha = cha . ' '
  endif
  if cha =='ー'
    let cha = '｜'
  elseif cha=='( ' || cha=='（'
     let cha = '⏜ '              " 23dc (これらは 挿入モードで Ctrl-v u に續いて入力)
  elseif cha==') ' || cha=='）'
     let cha = '⏝ '              " 23dd
  elseif cha=='= '
     let cha = '꯫ '              " 2225  または a831 abeb 2016 (abebを使用) 
  elseif cha=='。'
    let cha = '︒'              " fe12
  elseif cha=='、'
    let cha = '︑'              " fe11
  endif
  return cha 
endfunction

function! s:AddSpacesToList(ls)
  let cs = mapnew(a:ls,"strchars(v:val)")
  let mxc = max(cs)
  let rsb = mapnew(a:ls,"s:AddSpaces(v:val,mxc)")
  return rsb
endfunction

function! s:AddSpaces(s,m)
  let l = strchars(a:s)
  let spn = a:m - l
  let sp = repeat(' ',spn)  " このスペースは文字コード32 
  return (a:s . sp)
endfunction

function! s:TateStart()
  let s:h = winheight('%')  " ウインドウの高さ
  let s:w = winwidth('%')   " ウインドウの幅
  augroup Tate 
    nunmap t
    nnoremap q :Tateq
    nnoremap w :Tatec
    write 
    set nofoldenable
    let y = line('.') " 現在のカーソルがある行
    let x = charcol('.') " 現在のカーソルの位置（横方向)までにあるキャラクタ数
    call s:CreateField(s:h) " 新しいバッファを作成し空の行を作って元のバッファにもどる
    let bf = getline(1,line("$"))  " 全行のリストを取得
    let s:bf = mapnew(bf,"(v:val) . ' '")  " リストの最後尾にスペースを追加
    bn!
    let [s:nls,s:lst,s:fin,s:cy,s:cx,s:pl,s:px,s:scrl,s:msc,s:oln] = s:ChangeToTate(s:bf,x,y,s:w,s:h)
    autocmd!
    autocmd InsertLeave * call feedkeys("\<right>",'n')
    autocmd TextChangedI * let [s:bf,s:lst,s:fin,s:pl,s:px,s:cy,s:cx,s:scrl,s:msc,s:oln] = s:UpdateText()
    autocmd CursorMoved * let [s:fin,s:cy,s:cx,s:pl,s:px,s:scrl] = s:MoveCursor()
  augroup END

endfunction

function! s:ConvPos(h,pl,px,oln)
  let ml = a:h - 2  " max length
  let y = s:oln[a:pl-1]
  let i = 1
  let x = a:px  
  while s:oln[a:pl-1-i]==y && (a:pl-i)>0 
    let x = x + ml
    let i = i + 1
    if (a:pl-1-i)<0
      break
    endif
  endwhile
  return [y,x]
endfunction

function! s:UpdateText()
  let fin = s:fin
  let bf = s:bf
  let pl = s:pl
  let px = s:px
  let oln = s:oln
  let w = s:w
  let h = s:h
  let icr = px!=line('.')-1   " 改行が入力されたかどうか
  let [y,x] = s:ConvPos(h,pl,px,oln)
  if icr
    call setline(h," ")
    let tl = bf[y-1]
    let heads = slice(tl,0,x-1)
    let tail = slice(tl,x-1) 
    if y==1
      let bf = [heads,tail] + bf[y:]
    else
      let bf = bf[0:y-2] + [heads,tail] + bf[y:]
    endif
    let x = 1
    let y = y + 1
  else
    let ol = fin[px-1]
    let nl = getline('.')
    let df = strchars(nl)-strchars(ol)  " 挿入された文字の長さ
    let ibs = df < 0    " バックスペースが押されたかどうか
    if ibs
      let tl = bf[y-1]
      if x==1
        if y==1
          let bf = [" "]
        else
          let bf = bf[0:y-2] + bf[y:]
          let x = strchars(bf[y-2]) 
          let y = y - 1
        endif
      else
        let heads = slice(tl,0,x-2)
        let tail = slice(tl,x-1) 
        let tnl = heads . tail
        let bf = bf[0:y-2] + [tnl] + bf[y:]
        let x = x - 1 
      endif
    else
      let str = ""
      let i = 0
      if ol!=nl
        while slice(ol,i,i+1)==slice(nl,i,i+1)
          let i += 1  
        endwhile
        let str = slice(nl,i,i+df)  " 挿入された文字列を得る
      endif
      let tl = bf[y-1]
      let heads = slice(tl,0,x-1)
      let tail = slice(tl,x-1) 
      let tnl = heads . str . tail " 新しい縦の行
      if y==1
        let bf = [tnl] + bf[y:]
      else
        let bf = bf[0:y-2] + [tnl] + bf[y:]
      endif
      let x = x + df
    endif
  endif
  let [nls,lst,fin,cy,cx,pl,px,scrl,msc,oln] = s:ChangeToTate(bf,x,y,w,h)
  call setline(1,"pl=" . pl . " px=" . px . " cy=" . cy . " cx=" . cx . " s=" . scrl . " m=" . msc)
  return [bf,lst,fin,pl,px,cy,cx,scrl,msc,oln]
endfunction

function! s:TateChange()
  augroup Tate 
    autocmd!
  augroup END
  bd!
  normal 1G
  normal dG
  call append(0,s:bf)
  nnoremap t :Tate
endfunction

function! s:TateEnd()
  augroup Tate 
    autocmd!
  augroup END
  bd!
  nnoremap t :Tate
endfunction

command! Tate call s:TateStart()
command! Tateq call s:TateEnd()
command! Tatec call s:TateChange()
nnoremap t :Tate
