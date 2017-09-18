command  -nargs=* MyProject call s:MyProject(<f-args>)
command  -nargs=* MyProjectLoad call s:MyProjectLoad(<f-args>)
command  -nargs=* MyConfig call s:MyConfig(<f-args>)
command  -nargs=* MPL call s:MyProjectLoad(<f-args>)
command  -nargs=* MPC call s:MyProjectCreat(<f-args>)
command  -nargs=* MyCountMatch call s:MyCountMatch(<f-args>)
let g:MySearchList = []
let g:MySearchListPointer = 0
let g:MyModifyList = []
let g:MyFileList = []
let g:MyFileListPointer = 0
if !exists('g:My_Update_Tags')
    let g:My_Update_Tags = 0
endif

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
"   silent !cscope -Rbkq
    silent !cscope -Rbk
    redraw
endfunction

function s:MyProjectCreatTag(...)
    silent !ctags -R --langmap=c:+.c.h.C.H --c-kinds=+p --c++-kinds=+p --fields=+iamS --extra=+q .
endfunction

function! s:UpdateTags()
    if !filereadable("tags")
        return 
    endif
    if g:My_Update_Tags != 1
        call add(g:MyModifyList, expand('%'))
        call uniq(sort(g:MyModifyList))
        echo "Record to MyModifyList!"
        redraw
        return
    endif
    echo "Updating tags..."
    silent !ctags --langmap=c:+.c.h.C.H --c-kinds=+p --c++-kinds=+p --fields=+iamS --extra=+q -a %
    redraw
    echo "Updating cscope..."
    silent !cscope -Rbk
    cs reset
    redraw
    echo "Updating done!"
    redraw
endfunction

function! s:UpdateTagsLeave()
    if !filereadable("tags")
        return 
    endif
    if g:My_Update_Tags != 1
        if len(g:MyModifyList) == 0
            return
        endif
        let filelists = join(g:MyModifyList, ' ')
        echo "Updating tags..."
        silent exe '!ctags  --langmap=c:+.c.h.C.H --c-kinds=+p --c++-kinds=+p --fields=+iamS --extra=+q -a ' . filelists
        redraw
        echo "Updating cscope..."
        silent !cscope -Rbk
        redraw
        echo "Updating done!"
        redraw
        return
    endif
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
    map <S-up>  <ESC>:cprevious<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <S-down> <ESC>:cnext<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <S-left>  <ESC>:col<CR>:cc<CR>:let @h=MyListManage('g:MySearchList', 'g:MySearchListPointer', "back")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <S-right> <ESC>:cnew<CR>:cc<CR>:let @h=MyListManage('g:MySearchList', 'g:MySearchListPointer',"forward")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <S-LeftMouse>  <ESC>:col<CR>:cc<CR>:let @h=MyListManage('g:MySearchList','g:MySearchListPointer',"back")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>'azz
    map <S-RightMouse> <ESC>:cnew<CR>:cc<CR>:let @h=MyListManage('g:MySearchList', 'g:MySearchListPointer',"forward")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>'bzz

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :let @h="<C-R>=expand("<cword>")<CR>"<CR>:call MyListManage('g:MySearchList', 'g:MySearchListPointer',"add", @h)<CR>:cs find g <C-R>h<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>
    nmap <silent> <C-RightMouse> <LeftMouse>ma:let @h ="<C-R>=expand("<cword>")<CR>"<CR>:cs find g <C-R>h<CR>:call MyListManage('g:MySearchList', 'g:MySearchListPointer',"add", @h)<CR>mb:exe '2match MyHighlight2 /' . @h . '/'<CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :let @h="<C-R>=expand("<cword>")<CR>"<CR>:cs find e <C-R>h<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
    
    " Mapping cursor for ctags
    map <A-up>  <ESC>:tp<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <A-down> <ESC>:tn<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <A-left>  <ESC>:po<CR>:let @h=MyListManage('g:MySearchList', 'g:MySearchListPointer',"back")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    map <A-right> <ESC>:ta<CR>:let @h=MyListManage('g:MySearchList', 'g:MySearchListPointer',"forward")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz

    map <S-ScrollWheelUp> <S-Up>
    map <S-ScrollWheelDown> <S-Down>
    map <A-ScrollWheelUp> <A-Up>
    map <A-ScrollWheelDown> <A-Down>
    map <S-MouseDown> <S-up>
    map <S-MouseUp> <S-Down>
    map <A-MouseDown> <A-up>
    map <A-MouseUp> <A-Down>

    nmap <silent> <C-LeftMouse> <LeftMouse>:let @h ="<C-R>=expand("<cword>")<CR>"<CR><C-]>:call MyListManage('g:MySearchList', 'g:MySearchListPointer', "add", @h)<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz
    nmap <silent> <C-t> <ESC>:po<CR>:let @h=MyListManage('g:MySearchList', 'g:MySearchListPointer', "back")<CR>:exe '2match MyHighlight2 /' . @h . '/'<CR>zz

    set foldmethod=syntax
    set foldlevel=99
    "au BufRead * normal zR
endfunction

function! MyShourtcut(...)
    echo '1/j/a: file search, <tab>'
    echo '2/k/s: function search, ltag'
    echo '3/l/d: regular experession, vimgrep'
    let l:result = getchar()
    let c=nr2char(l:result)
    if c == '1' || c == 'j' || c == 'a'
        redraw
        call MySearch('file')
    elseif c == '2' || c == 'k' || c == 's'
        redraw
        call MySearch('tag')
    elseif c == '3' || c == 'l' || c == 'd'
        redraw
        call MySearch('vimgrep')
    else
        redraw
        return
    endif
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
            echo 'Not Press A-z, go to main()'
            echo 'Press A-z, abort! ...'
            "let l:result = inputlist(['Goto main()?:', 'Press any key(Yes)', 'Press Enter/Esc(No)'])
            let l:result = getchar()
            let l:result =nr2char(l:result) 
            if ( l:result < 'A' || l:result > 'z' )
                call feedkeys("\<ESC>:MPL\<CR>\<ESC>:cs f g main\<CR>", "t")
                call MyListManage('g:MySearchList', 'g:MySearchListPointer', "add", "main" )
            endif
            redraw
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
        let @h = substitute(l:s, "/", "", "")
        execute 'ltag ' . l:s
        redraw
        echo "ltag " . l:s
        execute '2match MyHighlight2 /\c' . @h . '/'
        call MyListManage('g:MySearchList', 'g:MySearchListPointer', "add", @h )
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
        execute 'cs f g ' . l:s
        let @h=l:s
        execute '2match MyHighlight2 /\c' . l:s . '/'
        call MyListManage('g:MySearchList', 'g:MySearchListPointer', "add", @h )
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
        let @h=l:s
        execute '2match MyHighlight2 /\c' . l:s . '/'
        return
    endif
    if a:1 == 'cscope-s'
        if exists("a:2")
            let l:s = input('cs f s :', a:2)
        else
            let l:s = input('cs f s :')
        endif
        if l:s == ''
            echo "Cancel search!"
            return
        endif
        let l:s = substitute(l:s, " ", ".*", "g")
        execute 'cs f s ' . l:s
        let @h=l:s
        execute '2match MyHighlight2 /\c' . l:s . '/'
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
        if glob('**/*.[CcHh]') != ''
            execute 'vimgrep /' . l:s . '/g **/*.[Cc] **/*.[Hh]'
        endif
        if glob('**/*.[CcHh][px+][px+]') != ''
            execute 'vimgrepadd /' . l:s . '/g **/*.[CcHh][px+][px+]'
        endif
        if glob('**/*.[CcHh][px+]') != ''
            execute 'vimgrepadd /' . l:s . '/g **/*.[CcHh][px+]'
        endif
        let @h=l:s
        execute '2match MyHighlight2 /\c' . l:s . '/'
        call MyListManage('g:MySearchList', 'g:MySearchListPointer', "add", @h )
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

" a:1 Listname a:2 Listpointer
function MyListManage(...)
    if a:3 == "add"
        if { ''.a:2 } >= len( { ''.a:1 } )
            call add( { ''.a:1 }, a:4 )
        else
            let { ''.a:1 }[ { ''.a:2 } ] = a:4
        endif
        let { ''.a:2 } = { ''.a:2 } + 1
    elseif a:3 == "back"
        if { ''.a:2 } > 0
            let { ''.a:2 } = { ''.a:2 } - 1
        endif
        if { ''.a:2 } == 0
            return { ''.a:1 }[ 0 ]
        endif
        return { ''.a:1 }[ { ''.a:2 } - 1 ]
    elseif a:3 == "forward"
        if { ''.a:2 } >= len({ ''.a:1 })
           echo 'Reach end!' 
           return
        endif
        let { ''.a:2 } = { ''.a:2 } + 1
        return { ''.a:1 }[ { ''.a:2 } - 1 ]
    elseif a:3 == "get"
        if { ''.a:2 } == 0
            return { ''.a:1 }[ 0 ]
        endif
        return { ''.a:1 }[ { ''.a:2 } - 1 ]
    endif
endfunction

autocmd Filetype [Mm]akefile,*.[HhCc],*.[CcHh][px+][px+],*.[CcHh][px+] mapclear <buffer> 

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
inoremap <expr> <down> ((pumvisible())?("\<C-n>"):("\<C-o>g\<down>"))
inoremap <expr> <up> ((pumvisible())?("\<C-p>"):("\<C-o>g\<up>"))
nnoremap B ^
nnoremap E $

" Copy/Paste
if ! empty(maparg('<C-c>'))
    unmap <C-c>
endif
if ! empty(maparg('<C-v>','i'))
    iunmap <C-v>
endif
if ! empty(maparg('<C-v>'))
    unmap <C-v>
endif
vmap <C-c> "+y
imap <C-v> <ESC>"+gp
cmap <C-v> <C-r>+
xnoremap p "_dP
nnoremap <leader>p "0p
nnoremap <leader>P "0P

" nmap <C-k> a_<Esc>r
map K :call MyShourtcut()<CR>
nmap gdd :let @/='\<'.expand("<cword>").'\>'<CR>:set hls<CR>:echo @/<CR>

command! -nargs=+ CSF :cs f f <args>
command! -nargs=+ CSE :cs f e <args>
command! -nargs=+ CSG :cs f g <args>
command! -nargs=+ CST :cs f t <args>
command! -nargs=+ CSC :cs f c <args>
command! -nargs=+ CSS :cs f s <args>


nnoremap <silent> <MiddleMouse> <ESC><LeftMouse>:exe 'echo "2match"<bar>2match MyHighlight2 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>
inoremap <silent> <MiddleMouse> <ESC><LeftMouse>:exe 'echo "2match"<bar>2match MyHighlight2 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>
vnoremap <silent> <MiddleMouse> <ESC><LeftMouse>:exe 'echo "2match"<bar>2match MyHighlight2 /\V'.escape("<C-R>*", '\').'/'<cr>
map <2-MiddleMouse> mA
imap <2-MiddleMouse> <ESC>mA
map <3-MiddleMouse> <Nop>
imap <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>
imap <4-MiddleMouse> <Nop>
nnoremap <silent> <S-MiddleMouse> <ESC><LeftMouse>:exe 'echo "3match"<bar>3match MyHighlight3 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>viw
nnoremap <silent> <C-MiddleMouse> <ESC><LeftMouse>:exe 'echo "3match"<bar>3match MyHighlight3 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>
inoremap <silent> <S-MiddleMouse> <ESC><LeftMouse>:exe 'echo "3match"<bar>3match MyHighlight3 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>viw
inoremap <silent> <C-MiddleMouse> <ESC><LeftMouse>:exe 'echo "3match"<bar>3match MyHighlight3 /\V\<'.escape(expand('<cword>'), '\').'\>/'<cr>
vnoremap <silent> <S-MiddleMouse> <ESC><LeftMouse>:exe 'echo "3match"<bar>3match MyHighlight3 /\V'.escape("<C-R>*", '\').'/'<cr>
vnoremap <silent> <C-MiddleMouse> <ESC><LeftMouse>:exe 'echo "3match"<bar>3match MyHighlight3 /\V'.escape("<C-R>*", '\').'/'<cr>

"map <S-LeftMouse> <ESC><C-o>
"map <S-RightMouse> <ESC><C-i>
"imap <S-LeftMouse> <ESC><C-o>
"imap <S-RightMouse> <ESC><C-i>

map #1 <ESC>:help<SPACE>
vmap #1 <ESC>:help <C-R>*<CR>
map <C-F1> <ESC>:help <C-R>=expand("<cword>")<CR><CR>
map <S-F1> <ESC>:help <C-R>=expand("<cword>")<CR><CR>

nmap #2 <ESC>:call MySearch('file')<CR>
nmap <S-F2> :call SwitchSourceHeader()<CR>
nmap <C-F2> <ESC>:call MySearch('cscope-f')<CR>
vmap <C-F2> <ESC>:call MySearch('cscope-f', '<C-R>*')<CR>

nmap #3 <ESC>:call MySearch('cscope-g')<CR>
vmap #3 <ESC>:call MySearch('cscope-g', '<C-R>*')<CR>
nmap <C-F3> <ESC>:call MySearch('tag')<CR>
nmap <S-F3> <ESC>:call MySearch('tag')<CR>
vmap <C-F3> <ESC>:call MySearch('tag', '<C-R>*')<CR>
vmap <S-F3> <ESC>:call MySearch('tag', '<C-R>*')<CR>

nmap #4 <ESC>:call MySearch('cscope-s')<CR>
vmap #4 <ESC>:call MySearch('cscope-s', '<C-R>*')<CR>
nmap <C-F4> <ESC>:call MySearch('vimgrep')<CR>
nmap <S-F4> <ESC>:call MySearch('vimgrep')<CR>
vmap <C-F4> <ESC>:call MySearch('vimgrep', '<C-R>*')<CR>
vmap <S-F4> <ESC>:call MySearch('vimgrep', '<C-R>*')<CR>

map #5 <ESC>:call MyHighlight('1')<CR>
nmap <S-F5> <ESC>:call MyHighlight('2')<CR>
nmap <C-F5> <ESC>:call MyHighlight('3')<CR>
nmap <A-F5> <ESC>:call MyHighlight('2')<CR>
vmap #5 <ESC>:call MyHighlight('1', '<C-R>*')<CR>
vmap <S-F5> <ESC>:call MyHighlight('2', '<C-R>*')<CR>
vmap <C-F5> <ESC>:call MyHighlight('3', '<C-R>*')<CR>
vmap <A-F5> <ESC>:call MyHighlight('2', '<C-R>*')<CR>

"map <C-F6> <ESC>mA:echo "'A Mark line:" . <C-R>=line('.')<CR><CR>
nmap #6 <ESC>:echo "Goto mark 'a'"<CR>`a
nmap <C-F6> <ESC>:echo "Goto mark 'b'"<CR>`b
nmap <S-F6> <ESC>:echo "Goto mark 'b'"<CR>`b
nmap <A-F6> <ESC>:echo "Goto mark 'b'"<CR>`b

mapclear <buffer>
map <F9> <ESC>:buffers<CR>:e #
noremap <F9> <ESC>:buffers<CR>:e #
noremap <S-F9> <ESC>:bp<CR>
noremap <C-F9> <ESC>:bn<CR>

map <F10> <ESC>:silent make!<CR><ESC>:copen<CR> /error: <CR>

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
set scrolloff=2
set showmatch
set matchtime=10
set smartcase
set smarttab
set smartindent
syntax enable
syntax on

cd %:p:h
set path=**
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

au VimEnter [Mm]akefile.*,*.[HhCc],*.[CcHh][px+][px+],*.[CcHh][px+],*.mk,*config* call s:MyProjectLoad()
autocmd BufWritePost *.[HhCc],*.[CcHh][px+][px+],*.[CcHh][px+] call s:UpdateTags()
au VimLeave * call s:UpdateTagsLeave()
autocmd Filetype gitcommit setlocal spell textwidth=72

" GUI setting
"Toggle Menu and Toolbar
set guifont=Monospace\ 11
set guioptions+=c
set guioptions-=m
set guioptions-=T
set guioptions-=r
set guioptions-=L
nmap  <F12> :call MyToggle()<CR>
nmap  <S-F12> <ESC>:Tlist<CR>
if has("gui_running")
  " Maximize gvim window.
  set lines=58 columns=89
endif

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
