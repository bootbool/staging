command  -nargs=* MyProject call s:MyProject(<f-args>)
command  -nargs=* MyProjectLoad call s:MyProjectLoad(<f-args>)
command  -nargs=* MyConfig call s:MyConfig(<f-args>)
command  -nargs=* MPL call s:MyProjectLoad(<f-args>)
command  -nargs=* MPC call s:MyProjectCreat(<f-args>)
command  -nargs=* MyCountMatch call s:MyCountMatch(<f-args>)

function s:MyProjectLoad(...)
    set tags=tags
    cs kill -1
    if a:0 != 0
        if a:1 == 'ignorecase'
            cs a cscope.out . -C
        else
            echo "ignorecase ?"
        endif
    else
        if filereadable("cscope.out")
            echo "cscope.out exists! Add now!"
            cs a cscope.out
        endif
    endif
    call s:MyConfig()
endfunction

function s:MyProjectCreat(...)
    echo "Generating tag file..."
    call s:MyProjectCreatTag()
    echo "Generating cscope file..."
    silent !cscope -Rbkq
    redraw
endfunction

function s:MyProjectCreatTag(...)
    silent !ctags -R --langmap=c:.c.h.C.H --c-kinds=-p --c++-kinds=-p --fields=+iamS --extra=+q .
    silent !ctags -R --langmap=c:.c.h.C.H --c-kinds=p --c++-kinds=p --fields=+iamS --extra=+q  -f tags1  . 
    silent !grep -v ^\!_TAG_ tags1 >>tags
    silent !rm tags1
endfunction

function! s:UpdateTags()
    if !filereadable("tags")
        return 
    endif
    let f = expand("%:.")
    let cwd = getcwd()
    let cmd = "awk \'$2!=\"" . expand("%") . "\"\' tags > tags1"
    let resp = system(cmd)
    call delete("tags")
    call rename("tags1", "tags")
    let tagfilename1 = cwd . "/tags1"
    let tagfilename2 = cwd . "/tags2"
    let cmd1 = 'ctags  -f ' . tagfilename1 . ' --langmap=c:.c.h.C.H --c-kinds=-p --c++-kinds=-p --fields=+iaS --extra=+q ' . '"' . f . '"'
    let cmd2 = 'ctags  -f ' . tagfilename2 . ' --langmap=c:.c.h.C.H --c-kinds=p --c++-kinds=p --fields=+iaS --extra=+q ' . '"' . f . '"'
    redraw
    echo "Updating tags..."
    let resp = system(cmd1)
    let resp = system(cmd2)
    silent !grep -v ^\!_TAG_ tags1 >>tags
    silent !grep -v ^\!_TAG_ tags2 >>tags
    call delete("tags1")
    call delete("tags2")
    redraw
    echo "Updating cscope..."
    silent !cscope -Rbkq
    cs reset
    redraw
    echo "Updating done!"
    redraw
endfunction

function! s:MyProject( ... )
    if a:0 == 0
        call s:MyProjectCreat()
        call s:MyProjectLoad()
        return
    endif
    if a:1 == 'create'
        call s:MyProjectCreat()
    elseif a:1 == "load"
        call s:MyProjectLoad()
    else
        echo "load, create ?"
    endif
endfunction

function s:MyConfig(...)
    " Mapping cursor for cscope  
    map <S-up>  <ESC>:cprevious<CR>
    map <S-down> <ESC>:cnext<CR>
    map <S-left>  <ESC>:col<CR>:cc<CR>
    map <S-right> <ESC>:cnew<CR>:cc<CR>
    
    " Mapping cursor for ctags
    map <A-up>  <ESC>:tp<CR>
    map <A-down> <ESC>:tn<CR>
    map <A-left>  <ESC>:po<CR>
    map <A-right> <ESC>:ta<CR>

    set foldmethod=syntax
    set foldlevel=99
    "au BufRead * normal zR
endfunction


function! MySearch(...)
    if a:0 == 0
        return
    endif
    if a:1 == 'file'
        if exists("a:2")
            let l:s = input('File: ', a:2)
        else
            let l:s = input('File: ')
        endif
        if l:s == '' || l:s == '/'
            redraw
            let l:result = inputlist(['Goto main()?:', 'Press Num key(Yes)', 'Press Enter/Esc(No)'])
            if l:result == '0'
                return
            else
                call feedkeys("\<ESC>:MPL\<CR>\<ESC>:cs f g main\<CR>", "t")
            endif
            return
        endif
        let l:s = substitute(l:s, " ", "*", "g")
        call feedkeys("\<ESC>:e **/*" . l:s . "*\<TAB>", "t")
        return
    endif
    if a:1 == 'tag'
        if exists("a:2")
            let l:s = '/' . input('ltag /', a:2)
        else
            let l:s = '/' . input('ltag /')
        endif
        if l:s == '' || l:s == '/'
            echo "Cancel search!"
            return
        endif
        let l:s = substitute(l:s, " ", ".*", "g")
        execute 'ltag ' . l:s
        redraw
        echo "ltag " . l:s
        return
    endif
    if a:1 == 'cscope-f'
        if exists("a:2")
            let l:s = input('cs f f :', '.*' . a:2 . '.*' )
        else
            let l:s = input('cs f f <.*xxx.*>:')
        endif
        if l:s == ''
            echo "Cancel find!"
            return
        endif
        let l:s = substitute(l:s, " ", ".*", "g")
        if exists("a:2")
            execute 'cs f f ' . l:s
        else
            execute 'cs f f .*' . l:s . '.*'
        endif
        return
    endif
    if a:1 == 'cscope-g'
        if exists("a:2")
            let l:s = input('cs f g :', '.*' . a:2 . '.*' )
        else
            let l:s = input('cs f g <.*xxx.*>:')
        endif
        if l:s == ''
            echo "Cancel search!"
            return
        endif
        let l:s = substitute(l:s, " ", ".*", "g")
        if exists("a:2")
            execute 'cs f g ' . l:s
        else
            execute 'cs f g .*' . l:s . '.*'
        endif
        return
    endif
    if a:1 == 'cscope-e'
        if exists("a:2")
            let l:s = input('cs f e :', a:2)
        else
            let l:s = input('cs f e :')
        endif
        if l:s == ''
            echo "Cancel search!"
            return
        endif
        execute 'cs f e ' . l:s
        return
    endif
    if a:1 == 'vimgrep'
        if exists("a:2")
            let l:s = input('vimgrep :', a:2)
        else
            let l:s = input('vimgrep :')
        endif
        if l:s == ''
            echo "Cancel search!"
            return
        endif
        execute 'vimgrep /' . l:s . '/g **/*.[Cc]** **/*.[Hh]**'
        return
    endif
endfunction

function! MyHighlight(...)
    if a:0 == 0
        return
    endif
    redraw
    if a:1 == '1'
        if exists("a:2")
            let l:s = a:2
        else
            let l:s = input('1 Highlight pattern:')
            if l:s == ''
                echo "Cancel highlight!"
                return
            endif
        endif
        execute 'match MyHighlight1 /\c' . l:s . '/'
    endif
    if a:1 == '2'
        if exists("a:2")
            let l:s = a:2
        else
            let l:s = input('2 Highlight pattern:')
            if l:s == ''
                echo "Cancel highlight!"
                return
            endif
        endif
        execute '2match MyHighlight2 /\c' . l:s . '/'
    endif
    if a:1 == '3'
        if exists("a:2")
            let l:s = a:2
        else
            let l:s = input('3 Highlight pattern:')
            if l:s == ''
                echo "Cancel highlight!"
                return
            endif
        endif
        execute '3match MyHighlight3 /\c' . l:s . '/'
    endif
endfunction

function! SwitchSourceHeader()
  "update!
  if (expand ("%:e") == "c")
    find %:t:r.h
  else
    find %:t:r.c
  endif
endfunction

function s:MyCountMatch(...)
    if a:0 == 0
        let pats=input('Search Pattern: ')
    elseif a:0 != 0
        let pats=a:1
    endif
    if pats==''
        echo "Cancel count match!"
        return
    endif
    execute 'let i=1 | g/' . pats . '\zs/s//\=i/ | let i=i+1'
    execute '%s/' . pats . '/& /'
    return
endfunction

" Mapping key for move cursor around windows
nmap <C-j><C-j> <C-W>j
nmap <C-k><C-k> <C-W>k
nmap <C-l><C-l> <C-W>l
nmap <C-h><C-h> <C-W>h
nmap <C-left> <C-W>h
nmap <C-right> <C-W>l
nmap <C-up> <C-W>k
nmap <C-down> <C-W>j
imap <A-j> <down>
imap <A-k> <up>
imap <A-l> <Right>
imap <A-h> <Left>

" Mapping movement key to go through wrapped line
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
inoremap <expr> <down> ((pumvisible())?("\<C-n>"):("\<down>"))
inoremap <expr> <up> ((pumvisible())?("\<C-p>"):("\<up>"))
nnoremap B ^
nnoremap E $

" Copy/Paste
vmap <C-c> "+y
imap <C-v> <ESC>"+gp
cmap <C-v> <C-r>+
xnoremap p "_dP
nnoremap <leader>p "0p
nnoremap <leader>P "0P

nmap K a_<Esc>r
nmap gdd :let @/='\<'.expand("<cword>").'\>'<CR>:set hls<CR>:echo @/<CR>

command! -nargs=+ CSf :cs f f <args>
command! -nargs=+ CSe :cs f e <args>
command! -nargs=+ CSg :cs f g <args>
command! -nargs=+ CSt :cs f t <args>
command! -nargs=+ CSc :cs f c <args>

nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nnoremap <silent> <MiddleMouse> <ESC><LeftMouse>:exe 'echo "2match"<bar>3match MyHighlight3 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>
map <2-MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>
map <3-MiddleMouse> <Nop>
imap <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>
imap <4-MiddleMouse> <Nop>
nnoremap <silent> <S-MiddleMouse> <ESC><LeftMouse>:exe 'echo "2match"<bar>2match MyHighlight2 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>viw
nnoremap <silent> <C-MiddleMouse> <ESC><LeftMouse>:exe 'echo "2match"<bar>2match MyHighlight2 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>

map <S-LeftMouse> <ESC><C-o>
map <S-RightMouse> <ESC><C-i>
imap <S-LeftMouse> <ESC><C-o>
imap <S-RightMouse> <ESC><C-i>

map #1 <ESC>:help<SPACE>
vmap #1 <ESC>:help <C-R>*<CR>
map <C-F1> <ESC>:help <C-R>=expand("<cword>")<CR><CR>
map <S-F1> <ESC>:help <C-R>=expand("<cword>")<CR><CR>

nmap #2 <ESC>:call MySearch('file')<CR>
nmap <S-F2> :call SwitchSourceHeader()<CR>
nmap <C-F2> <ESC>:call MySearch('cscope-f')<CR>
vmap <C-F2> <ESC>:call MySearch('cscope-f', '<C-R>*')<CR>

nmap #3 <ESC>:call MySearch('tag')<CR>
vmap #3 <ESC>:call MySearch('tag', '<C-R>*')<CR>
nmap <C-F3> <ESC>:call MySearch('cscope-g')<CR>
nmap <S-F3> <ESC>:call MySearch('cscope-g')<CR>
vmap <C-F3> <ESC>:call MySearch('cscope-g', '<C-R>*')<CR>
vmap <S-F3> <ESC>:call MySearch('cscope-g', '<C-R>*')<CR>

nmap #4 <ESC>:call MySearch('vimgrep')<CR>
vmap #4 <ESC>:call MySearch('vimgrep', '<C-R>*')<CR>
nmap <C-F4> <ESC>:call MySearch('cscope-e')<CR>
nmap <S-F4> <ESC>:call MySearch('cscope-e')<CR>
vmap <C-F4> <ESC>:call MySearch('cscope-e', '<C-R>*')<CR>
vmap <S-F4> <ESC>:call MySearch('cscope-e', '<C-R>*')<CR>


"map <C-F5> <ESC>mA:echo "'A Mark line:" . <C-R>=line('.')<CR><CR>
nmap #5 <ESC>:echo "Goto mark 'A'"<CR>`A
nmap <C-F5> <ESC>:echo "Goto mark 'B'"<CR>`B
nmap <S-F5> <ESC>:echo "Goto mark 'B'"<CR>`B
nmap <A-F5> <ESC>:echo "Goto mark 'B'"<CR>`B

map #7 <ESC>:call MyHighlight('1')<CR>
nmap <S-F7> <ESC>:call MyHighlight('2')<CR>
nmap <C-F7> <ESC>:call MyHighlight('3')<CR>
nmap <A-F7> <ESC>:call MyHighlight('2')<CR>
vmap #7 <ESC>:call MyHighlight('1', '<C-R>*')<CR>
vmap <S-F7> <ESC>:call MyHighlight('2', '<C-R>*')<CR>
vmap <C-F7> <ESC>:call MyHighlight('3', '<C-R>*')<CR>
vmap <A-F7> <ESC>:call MyHighlight('2', '<C-R>*')<CR>

map <F10> <ESC>:silent make<CR><ESC>:copen<CR>/error<CR>

"Plugins setting
let Tlist_Use_Right_Window = 1

set fileformat=unix
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set fileencodings=utf-8,gbk,ucs-bom,cp936,latin1
set nobackup
set nocp
set hlsearch
set incsearch
set ignorecase
filetype plugin on 
set cscopequickfix=s-,c-,d-,i-,t-,e-,g-,f- 
set completeopt-=preview
set complete-=i
set history=700
set nu
set numberwidth=1
set scrolloff=3
set showmatch
set matchtime=10
set smartcase
set smarttab
set smartindent
syntax enable
syntax on

cd %:p:h
set path=./**
if has('unix')
    set backupdir=/tmp
    set directory=/tmp
endif

set wildmenu
set wildmode=full
set wildignore=*.o
if exists("&wildignorecase")
    set wildignorecase
endif

colorscheme koehler
hi Visual  guifg=#000000 guibg=#FFFFFF gui=none
highlight MyHighlight1 guibg=green guifg=yellow term=bold gui=bold,undercurl
highlight MyHighlight2 guibg=blue guifg=white term=bold gui=bold,undercurl
highlight MyHighlight3 guibg=DarkCyan guifg=lightgrey term=bold gui=bold,undercurl

"set lines=40 columns=70

au VimEnter [Mm]akefile,*.[HhCc]** call s:MyProjectLoad()
autocmd BufWritePost *.[HhCc]** call s:UpdateTags()
autocmd Filetype gitcommit setlocal spell textwidth=72

" GUI setting
"Toggle Menu and Toolbar
set guifont=Monospace\ 12
set guioptions+=c
set guioptions-=m
set guioptions-=T
set guioptions-=r
set guioptions-=L
nmap  <F12> :call MyToggle()<CR>

function! MyToggle(...)
    if &guioptions =~# 'T'
        set guioptions-=m
        set guioptions-=T
        set guioptions-=r
        set guioptions-=L
        imap <C-v> <ESC>"+gp
        cmap <C-v> <C-r>+
    else
        set guioptions+=m
        set guioptions+=T
        set guioptions+=r
        set guioptions+=L
        cunmap <C-v>
        iunmap <C-v>
    endif
endfunction
