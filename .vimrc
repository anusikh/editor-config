" STEPS
" pre-req: vim-plug, ripgrep
" source and run :PlugInstall to install all plugins
" install lang servers -> :CocInstall coc-java coc-json coc-tsserver coc-rust-analyzer coc-java-debug
" install debuggers -> :VimspectorInstall CodeLLDB
" for quickfix: open rg search, press tab on the item you want to add to quickfix and then press enter
 
" for java lombok support add this in coc config
" {
"   "java.jdt.ls.vmargs": "-javaagent:/home/anusikh/Downloads/lombok-1.18.28.jar",
"   "java.jdt.ls.lombokSupport.enabled": true,
"   "java.trace.server": "verbose",
"   "java.jdt.ls.java.home": "/home/anusikh/.jvem/java"
" }

" a sample .vimspector.json file for rust debugging
" {
"   "$schema": "https://puremourning.github.io/vimspector/schema/vimspector.schema.json",
"   "adapters": {
"     "CodeLLDB-localbuild": {
"       "extends": "CodeLLDB",
"       "command": [
"         "$HOME/Development/vimspector/CodeLLDB/build/adapter/codelldb",
"         "--port",
"         "${unusedLocalPort}"
"       ]
"     }
"   },
"   "configurations": {
"     "jvem -- current": {
"       "adapter": "CodeLLDB",
"       "configuration": {
"         "request": "launch",
"         "program": "cargo",
" 	    "args": ["run", "--", "current"],
"         "expressions": "native"
"       }
"     }
"   }
" }

" a sample .vimspector.json file for java debugging
" {
"   "adapters": {
"     "java-debug-server": {
"       "name": "vscode-java",
"       "port": "${AdapterPort}"
"     }
"   },
"   "configurations": {
"     "Java Attach": {
"       "default": true,
"       "adapter": "java-debug-server",
"       "configuration": {
"         "request": "attach",
"         "host": "127.0.0.1",
"         "port": "5005"
"       },
"       "breakpoints": {
"         "exception": {
"           "caught": "N",
"           "uncaught": "N"
"         }
"       }
"     }
"   }
" }
" first run the jar of a java application with command: java -jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 ./target/demo-0.0.1-SNAPSHOT.jar
" then simply cd to attach debugger

set encoding=utf-8
set nobackup
set nowritebackup
set number
set re=2
set mouse=a
set updatetime=300
set signcolumn=yes
set autoindent expandtab tabstop=2 shiftwidth=2
set clipboard=unnamed

call plug#begin()

Plug 'tpope/vim-sensible'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'puremourning/vimspector'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'

call plug#end()

" NERDTree keymaps (for file/folder operations, press m)
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" Vimspector keymaps (for .vimspector.json examples, refer vimpsector repo)
nnoremap <silent> cd :call vimspector#Launch()<CR>
nnoremap <silent> t :call vimspector#ToggleBreakpoint()<CR>
nnoremap <silent> sa :VimspectorBreakpoints<CR>
nnoremap <silent> r :VimspectorReset<CR>
" FZF and Rg keymaps
nnoremap <silent> <C-p> :FZF<CR>
nnoremap <silent> <C-r> :Rg<CR>
" COC keymaps (copied from coc.nvim README.md)
"
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)
" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" See: https://github.com/dansomething/coc-java-debug
function! JavaStartDebugCallback(err, port)
	execute "cexpr! 'Java debug started on port: " . a:port . "'"
	call vimspector#LaunchWithSettings({ "configuration": "Java Attach", "AdapterPort": a:port })
endfunction

function JavaRunDebugMode()
	let l:class_name = expand('%:t:r')
	execute 'AsyncRun -pos=tab -mode=term -name=' . l:class_name . ' -cwd=' . getcwd() . ' javac -g ' . l:class_name .'.java && java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5005,suspend=y ' . l:class_name
	tabp
endfunction

function JavaStartDebug()
	call CocActionAsync('runCommand', 'vscode.java.startDebugSession', function('JavaStartDebugCallback'))
endfunction

command -nargs=0 JavaRunDebugMode call JavaRunDebugMode()
command -nargs=0 JavaStartDebug call JavaStartDebug()
