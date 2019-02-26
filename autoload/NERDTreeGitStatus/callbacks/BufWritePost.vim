" ============================================================================
" File: autoload/NERDTreeGitStatus/callbacks/BufWritePost.vim
" Author: Robert Audi
" Last Modified: February 26, 2019
" ============================================================================

function! NERDTreeGitStatus#callbacks#BufWritePost#update(fname) abort
  if g:NERDTreeGitStatusUpdateOnWrite != 1
    return
  endif

  if !g:NERDTree.IsOpen()
    return
  endif

  let l:curWin = winnr()
  let l:jumpBack = 0

  if !g:NERDTree.ExistsForBuf()
    let l:jumpBack = 1

    call NERDTreeGitStatus#utils#jump_to_window(g:NERDTree.GetWinNum())
  endif

  let l:node = b:NERDTree.root.findNode(g:NERDTreePath.New(a:fname))

  if l:node == {}
    if l:jumpBack
      call NERDTreeGitStatus#utils#jump_to_window(l:curWin)
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

  if l:jumpBack
    call NERDTreeGitStatus#utils#jump_to_window(l:curWin)
  endif

  redraw
endfunction
