" basic settings
syntax on
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab
filetype plugin indent on
set nowrap
augroup WrapLinesInMarkdown
    autocmd!
    autocmd FileType markdown setlocal wrap
augroup END
set noswapfile
set incsearch hlsearch
set ignorecase smartcase
set cursorline
set number
augroup numbertoggle " relative line numbers only in normal/visual mode
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
set splitright splitbelow
set fillchars+=vert:│
set scrolloff=5
" save folds and cursor location
autocmd BufLeave,BufWinLeave * silent! mkview
autocmd BufReadPost * silent! loadview
" bottom bar
set showcmd
set laststatus=2
" folds
set foldmethod=indent
set foldlevelstart=99
set foldnestmax=2

" Automatically install vim plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

set termguicolors
colorscheme koehler

" key bindings
let mapleader=","
nnoremap <silent> <leader>m :Lex 30<CR>
nnoremap <silent> <leader>n :NERDTreeToggle<CR>
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>/ :Lines<CR>
nnoremap <leader>c :cd %:p:h<CR>:pwd<CR>
nnoremap <silent> <C-e> 3<C-e>
nnoremap <silent> <C-y> 3<C-y>
nnoremap <space> za
nnoremap <CR> :noh<CR><CR>
autocmd filetype python noremap <leader>; :!python3 %<cr>
autocmd filetype java noremap <leader>; :!javac % && java %<cr>
autocmd filetype cpp noremap <leader>; :!g++ % -std=c++11 && ./a.out<cr>
autocmd filetype c noremap <leader>; :!gcc % && ./a.out<cr>
autocmd filetype c noremap <leader>l; :!gcc % -lm && ./a.out<cr>
autocmd filetype markdown noremap <leader>; :w !wc -w<cr>
autocmd filetype markdown noremap <expr> k (v:count == 0 ? 'gk' : 'k')
autocmd filetype markdown noremap <expr> j (v:count == 0 ? 'gj' : 'j')
autocmd filetype pdf noremap <leader>; :!open %<cr><cr><C-o>
augroup FileTypeImages
  autocmd!
  autocmd BufRead,BufNewFile *.jpg,*.jpeg,*.png,*.gif,*.bmp set filetype=image
augroup END
autocmd filetype image noremap <leader>; :!open %<cr><cr><C-o>

" look ma, no training wheels!
for key in ['<Up>', '<Down>', '<Left>', '<Right>']
    exec 'noremap' key '<Nop>'
    exec 'inoremap' key '<Nop>'
    exec 'cnoremap' key '<Nop>'
endfor

" custom functions
function Gitacp() " git add, commit, and push
    execute "!git add . && git commit -m 'vim' && git push"
endfunction
command! ACP call Gitacp()

function! ToggleCheckbox()
  let line = getline('.')
  if line =~ '- \[ \]'
    call setline('.', substitute(line, '- \[ \]', '- \[x\]', ''))
  elseif line =~ '- \[x\]'
    call setline('.', substitute(line, '- \[x\]', '- \[ \]', ''))
  elseif line =~ '- '
    call setline('.', substitute(line, '- ', '- \[ \] ', ''))
  endif
endf

autocmd filetype markdown noremap <Leader><space> :call ToggleCheckbox()<CR>
autocmd FileType markdown setl comments=b:*,b:-,b:+,n:>
autocmd FileType markdown setl formatoptions+=r

" Thank you Claude (Sonnet 4)
function! s:OpenMarkdownLink()
    let line = getline('.')
    let col = col('.')

    " Find all markdown links and pick the closest one
    let links = []
    let start = 0
    while 1
        let match = matchstrpos(line, '\v\[([^\]]+)\]\(([^\)]+)\)', start)
        if match[1] == -1 | break | endif
        let dist = min([abs(col - match[1]), abs(col - match[2])])
        call add(links, {'dist': dist, 'url': matchstr(match[0], '\v\]\(\zs[^\)]+\ze\)')})
        let start = match[2]
    endwhile

    if empty(links) | echo "No link found" | return | endif

    let url = sort(links, {a, b -> a.dist - b.dist})[0].url

    if url =~# '^https\?://'
        " Open URL
        if exists('*netrw#BrowseX')
            call netrw#BrowseX(url, 0)
        else
            call job_start([has('mac') ? 'open' : has('win32') ? 'start' : 'xdg-open', url])
        endif
    else
        " Open/create file
        let filepath = expand('%:p:h') . '/' . substitute(url, '#.*', '', '')
        if !filereadable(filepath) && input('Create "' . filepath . '"? (y/N): ') !=? 'y' | echo "File creation cancelled" | return | endif
        if !filereadable(filepath) | call mkdir(fnamemodify(filepath, ':h'), 'p') | call writefile([], filepath) | endif
        execute 'edit ' . fnameescape(filepath)
    endif
endfunction

function! s:GoBackToPreviousFile()
    execute "normal! \<C-o>"
endfunction

augroup MarkdownLinks
    autocmd!
    autocmd FileType markdown nnoremap <buffer> <CR> :call <SID>OpenMarkdownLink()<CR>
    autocmd FileType markdown nnoremap <buffer> <BS> :call <SID>GoBackToPreviousFile()<CR>
augroup END

function! ToggleMouse()
    if &mouse == 'a'
        set mouse=
        echo "Mouse disabled"
    else
        set mouse=a
        echo "Mouse enabled"
    endif
endfunction

nnoremap <F2> :call ToggleMouse()<CR>

" A much faster vimgrep using regular grep (Thanks again Claude)
function! SearchWordUnderCursor()
    let word = expand('<cword>')
    if empty(word)
        echo "No word under cursor to grep"
        return
    endif

    echo "Searching for: " . word . "..."
    " Sets the search register to the word and turn on highlights
    let @/ = word
    set hlsearch


    let ext = expand('%:e')
    let include_pattern = empty(ext) ? '' : '--include="*.' . ext . '"'
    let grep_command = 'grep -irn ' . include_pattern . ' "' . escape(word, '"') . '" .'

    " Execute grep and capture results
    let results = system(grep_command)
    let exit_code = v:shell_error

    if exit_code != 0 || empty(trim(results))
        redraw | echo "No matches found for: " . word
        return
    endif

    " Parse results into quickfix format
    let qf_list = []
    for line in filter(split(results, "\n"), 'v:val !~ "^$"')
        let match = matchlist(line, '\([^:]\+\):\(\d\+\):\(.*\)')
        if !empty(match)
            call add(qf_list, {
                \ 'filename': match[1],
                \ 'lnum': str2nr(match[2]),
                \ 'text': trim(match[3])
            \ })
        endif
    endfor

    if empty(qf_list)
        redraw | echo "No valid matches found for: " . word
        return
    endif

    call setqflist(qf_list, 'r')
    copen
    redraw | echo "Found " . len(qf_list) . " matches for: " . word
endfunction

nnoremap <leader>s :call SearchWordUnderCursor()<CR>
autocmd FileType qf nnoremap <buffer> o <CR><C-w>p
autocmd FileType qf nnoremap <buffer> q :q<CR>
autocmd FileType qf nnoremap <buffer> <C-n> :cnext<CR><C-w>p
autocmd FileType qf nnoremap <buffer> <C-p> :cprev<CR><C-w>p
autocmd FileType qf nnoremap <buffer> q :q<CR>
nnoremap <C-n> :cnext<CR>
nnoremap <C-p> :cprev<CR>
