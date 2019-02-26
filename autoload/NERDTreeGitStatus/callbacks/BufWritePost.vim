" ============================================================================
" File: autoload/NERDTreeGitStatus/callbacks/BufWritePost.vim
" Author: Robert Audi
" Last Modified: February 26, 2019
" ============================================================================

function! NERDTreeGitStatus#callbacks#BufWritePost#update(fname) abort
  if g:NERDTreeUpdateOnWrite != 1
    return
  endif

  if !g:NERDTree.IsOpen()
    return
  endif

  let l:curWin = winnr()
  let l:jumpBack = 0

  if !g:NERDTree.ExistsForBuf()
    let l:jumpBack = 1

    call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . g:NERDTree.GetWinNum() . 'wincmd w')
  endif

  let l:node = b:NERDTree.root.findNode(g:NERDTreePath.New(a:fname))

  if l:node == {}
    if l:jumpBack
      call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . l:curWin . 'wincmd w')
    endif

    return
  endif

  call l:node.refreshFlags()

  let l:node = l:node.parent

  while !empty(l:node)
    call l:node.refreshDirFlags()

    let l:node = l:node.parent
  endwhile

  call NERDTreeRender()

  redraw

  if l:jumpBack
    call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . l:curWin . 'wincmd w')
  endif
endfunction
