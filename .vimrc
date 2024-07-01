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
"idk what this is but it fixes delay when escaping insert
set timeoutlen=1000
set ttimeoutlen=50

" Automatically install vim plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
au BufLeave * silent! wall " autosave when switching buffers

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install() }} 
Plug 'psliwka/vim-smoothie'
Plug 'tmsvg/pear-tree'
Plug 'prashanthellina/follow-markdown-links'
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

" custom window colors (and syntax highlighting with bat(install in term first)) for fzf
let $FZF_DEFAULT_OPTS="--color=dark,fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f,info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7 --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

" colorsheme settings
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'soft'
colorscheme gruvbox
set background=dark

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
autocmd filetype markdown noremap <expr> k (v:count == 0 ? 'gk' : 'k')
autocmd filetype markdown noremap <expr> j (v:count == 0 ? 'gj' : 'j') 
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

" automatically open pdfs using https://github.com/itsjunetime/tdf
autocmd BufReadPost *.pdf silent :!tdf % 

" type :L to open a file at ~/notes/Stickies/<current date>
fun! OpenLog()
    let fname = strftime("%Y-%m-%d") . ".md"
    if !filereadable(expand("~/notes/Stickies/" . fname))
        exe "!cp ~/notes/Templates/DailyNote.md ~/notes/Stickies/" . fname
    endif
    exe ":e ~/notes/Stickies/" . fname
endfun
command L call OpenLog()

augroup AutoSaveGroup " https://vi.stackexchange.com/questions/13864/bufwinleave-mkview-with-unnamed-file-error-32
  autocmd!
  " view files are about 500 bytes
  " bufleave but not bufwinleave captures closing 2nd tab
  " nested is needed by bufwrite* (if triggered via other autocmd)
  " BufHidden for compatibility with `set hidden`
  autocmd BufWinLeave,BufLeave,BufWritePost,BufHidden,QuitPre ?* nested silent! mkview!
  autocmd BufWinEnter ?* silent! loadview
augroup end

