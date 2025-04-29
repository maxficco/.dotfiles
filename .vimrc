" basic settings
syntax on
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nowrap
augroup WrapLinesInMarkdown
    autocmd!
    autocmd FileType markdown setlocal wrap
augroup END
set number
set noswapfile
set smartcase
set incsearch
set cursorline
set backspace=indent,eol,start
set fillchars+=vert:│
augroup numbertoggle "relative line numbers only in normal/visual mode
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
"fix delay when escaping insert
augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
augroup END

" Automatically install vim plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
au BufLeave * silent! wall " autosave when switching buffers

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'sts10/vim-pink-moon'
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install() }} 
Plug 'psliwka/vim-smoothie'
Plug 'tmsvg/pear-tree'
call plug#end()

" NERDTree stuff
let NERDTreeMinimalUI=1
let NERDTreeChDirMode = 3
let g:DevIconsEnableFoldersOpenClose = 1
autocmd BufEnter * if tabpagenr('$') == 1 " Exit Vim if NERDTree is the only window remaining in the only tab.
      \ && winnr('$') == 1 
      \ && exists('b:NERDTree') 
      \ && b:NERDTree.isTabTree()
      \ | quit | endif

" fzf preview and syntax highlighting with bat
let $FZF_DEFAULT_OPTS="--preview 'bat --color=always --theme=gruvbox-dark --style=header,grid --line-range :300 {}'"

set background=dark
colorscheme gruvbox

" for lightline
set laststatus=2
set noshowmode
set ttimeoutlen=1

" coc
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-prettier',
  \ 'coc-json',
  \ 'coc-clangd',
  \ 'coc-pyright',
  \ 'coc-tsserver',
  \ 'coc-java',
  \ 'coc-html',
  \ 'coc-rust-analyzer',
  \ ]
" pear tree
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1

" key bindings
let mapleader=","
noremap <leader>n :NERDTreeToggle<cr>
noremap <leader>m :NERDTreeFind<cr>
noremap <leader>f :FZF<cr>
noremap <leader>F :FZF!<cr>
nnoremap <space> za
autocmd filetype python noremap <leader>; :!python3 %<cr>
autocmd filetype java noremap <leader>; :!javac % && java %<cr>
autocmd filetype cpp noremap <leader>; :!g++ % -std=c++11 && ./a.out<cr>
autocmd filetype rust noremap <leader>; :!rustc % && ./%:r<cr>
autocmd filetype markdown noremap <leader>; :w !wc -w<cr>
autocmd filetype markdown noremap <expr> k (v:count == 0 ? 'gk' : 'k')
autocmd filetype markdown noremap <expr> j (v:count == 0 ? 'gj' : 'j') 
autocmd filetype pdf noremap <leader>; :!open %<cr><cr><C-o>
autocmd filetype c noremap <leader>; :!gcc % && ./a.out<cr>
autocmd filetype c noremap m<leader>; :!gcc % -lm && ./a.out<cr>

" Set filetype for all image files
augroup FileTypeImages
  autocmd!
  autocmd BufRead,BufNewFile *.jpg,*.jpeg,*.png,*.gif,*.bmp set filetype=image
augroup END
autocmd filetype image noremap <leader>; :!open %<cr><cr><C-o>

for key in ['<Up>', '<Down>', '<Left>', '<Right>']
    exec 'noremap' key '<Nop>'
    exec 'inoremap' key '<Nop>'
    exec 'cnoremap' key '<Nop>'
endfor

" COC: make sure to run :CocConfig and paste {"suggest.noselect": true} in coc-settings.json
" use <Tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
" show documentation in preview window with K
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
inoremap <c-l> <plug>(coc-snippets-expand)



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

" type :L to open a note for the current date
fun! OpenLog()
    let fname = strftime("%Y-%m-%d") . ".md"
    call system('mkdir -p ~/notes')
    call system('touch ~/notes/' . fname)
    execute 'edit ~/notes/' . fname
endfun
command! L call OpenLog()

augroup AutoSaveGroup " https://vi.stackexchange.com/questions/13864/bufwinleave-mkview-with-unnamed-file-error-32
  autocmd!
  " view files are about 500 bytes
  " bufleave but not bufwinleave captures closing 2nd tab
  " nested is needed by bufwrite* (if triggered via other autocmd)
  " BufHidden for compatibility with `set hidden`
  autocmd BufWinLeave,BufLeave,BufWritePost,BufHidden,QuitPre ?* nested silent! mkview!
  autocmd BufWinEnter ?* silent! loadview
augroup end

" https://claude.site/artifacts/2b4acb73-2bd9-4537-8ac3-40106ece1fba
" following written by Claude 3.5 (with several prompts to debug and add features, but no direct intervention)
function! s:OpenMarkdownLink()
    let line = getline('.')
    let cur_col = col('.')
    let link_pattern = '\v\[([^\]]+)\]\(([^\)]+)\)'
    let closest_link = {}
    let min_distance = 999999  " A large number
    let start = 0

    while 1
        let [match_str, match_start, match_end] = matchstrpos(line, link_pattern, start)
        if match_start == -1
            break
        endif

        let distance = min([abs(cur_col - match_start - 1), abs(cur_col - match_end - 1)])
        if distance < min_distance
            let min_distance = distance
            let closest_link = {'start': match_start, 'end': match_end, 'full_match': match_str}
        endif

        let start = match_end
    endwhile

    if empty(closest_link)
        echo "No link found"
        return
    endif

    let link_parts = matchlist(closest_link.full_match, link_pattern)
    if len(link_parts) < 3
        echo "Invalid link format"
        return
    endif

    let link_target = link_parts[2]

    if link_target =~# '^https\?://'
        let cmd = has('mac') ? 'open' : has('unix') ? 'xdg-open' : has('win32') || has('win64') ? 'start' : ''
        if empty(cmd)
            echo "Unsupported operating system for opening URLs"
            return
        endif
        call job_start([cmd, link_target])
    else
        let file_path = substitute(link_target, '#.*', '', '')
        let full_path = expand('%:p:h') . '/' . file_path
        if !filereadable(full_path)
            " File doesn't exist, create it
            let create_file = input("File '" . full_path . "' doesn't exist. Create it? (y/N): ")
            if create_file ==? 'y'
                " Ensure the directory exists
                let dir = fnamemodify(full_path, ':h')
                if !isdirectory(dir)
                    call mkdir(dir, 'p')
                endif
                " Create the file
                call writefile([], full_path)
                echo "Created new file: " . full_path
            else
                echo "File creation cancelled"
                return
            endif
        endif
        execute 'edit ' . fnameescape(full_path)
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
