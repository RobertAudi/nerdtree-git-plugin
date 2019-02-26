" ============================================================================
" File: autoload/NERDTreeGitStatus/callbacks/CursorHold.vim
" Author: Robert Audi
" Last Modified: February 26, 2019
" ============================================================================

function! NERDTreeGitStatus#callbacks#CursorHold#update() abort
  if g:NERDTreeGitStatusUpdateOnCursorHold != 1
    return
  endif

  if !g:NERDTree.IsOpen()
    return
  endif

  " Do not update when a special buffer is selected
  if !empty(&l:buftype)
    return
  endif

  let l:curWin = winnr()
  let l:jumpBack = 0

  if !g:NERDTree.ExistsForBuf()
    let l:jumpBack = 1

    call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . g:NERDTree.GetWinNum() . 'wincmd w')
  endif

  call b:NERDTree.root.refreshFlags()
  call NERDTreeRender()

  if l:jumpBack
    call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . l:curWin . 'wincmd w')
  endif

  redraw
endfunction
