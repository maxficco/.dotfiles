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
set incsearch
set ignorecase smartcase
set cursorline
set number
augroup numbertoggle " relative line numbers only in normal/visual mode
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
set showcmd
set splitright splitbelow
set fillchars+=vert:│
set scrolloff=5
" save folds and cursor location
autocmd BufLeave,BufWinLeave * silent! mkview
autocmd BufReadPost * silent! loadview

set termguicolors
colorscheme koehler

" key bindings
let mapleader=","
nnoremap <leader>m :Sex<CR>  " ;-)
nnoremap <leader>n :Lex 30<CR>
nnoremap <silent> <C-e> 3<C-e>
nnoremap <silent> <C-y> 3<C-y>
nnoremap <CR> :noh<CR><CR>
nnoremap <space> za
autocmd filetype python noremap <leader>; :!python3 %<cr>
autocmd filetype java noremap <leader>; :!javac % && java %<cr>
autocmd filetype cpp noremap <leader>; :!g++ % -std=c++11 && ./a.out<cr>
autocmd filetype c noremap <leader>; :!gcc % && ./a.out<cr>
autocmd filetype c noremap m<leader>; :!gcc % -lm && ./a.out<cr>
autocmd filetype rust noremap <leader>; :!rustc % && ./%:r<cr>
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
