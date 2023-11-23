# tate.vim
virtical insert in vim

for VIM version 8.2.2434 later

start virtical mode with ':Tate' and Enter in normal mode  

end virtical mode with 'q' and Enter in normal mode  

write the virtical text to the buffer, press 'w' and Enter in normal mode  

in Nihongo from here  

縦書きを實現したプラグインです  
まだ改良すべき箇所は多いですが 一應動きます  
:Tate に續いて Enter で 縦書きモードに移行し  
通常どおり iなどを押して 挿入モードで文字を挿入できます  
挿入中のEnterや BSも機能するはずです  
保存したい場合は ノーマルモードで wに續き Enterを押し 横書きモードに戻してから 通常通り保存します  
最新のVIMでないと charcol関数がないことによりエラーが出ます  
このプラグインを使ふ場合は VIMを最新にすることをお勧めします  
プラグインを入れるには   
autoloadフォルダ および pluginフォルダ にある tate.vim ファイルを それぞれ  
ローカルにある .vim フォルダ内の autoloadフォルダ および pluginフォルダに入れるか  
[Dein.vim](https://kaworu.jpn.org/vim/Vim%E3%81%A8NeoVim%E3%81%AE%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E3%83%9E%E3%83%8D%E3%83%BC%E3%82%B8%E3%83%A3Dein.vim) などの プラグイン管理を使用し インストールしてください
![Screenshot from 2022-02-13 13-57-06](https://user-images.githubusercontent.com/12661196/153739536-d664fd0b-9aa9-4e8b-950c-cec34119c189.png)

vim9スクリプトで書いた [VerticalVim](https://github.com/syouzan420/VerticalVim/tree/main) は ぼちぼち更新もしてゐます  
スクロールも こちらの方が快適なので おすすめです
