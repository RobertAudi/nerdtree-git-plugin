" ============================================================================
" File: autoload/NERDTreeGitStatus/callbacks.vim
" Author: Robert Audi
" Last Modified: February 26, 2019
" ============================================================================

function! NERDTreeGitStatus#callbacks#CursorHoldUpdate() abort
  if g:NERDTreeUpdateOnCursorHold != 1
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

  redraw

  if l:jumpBack
    call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . l:curWin . 'wincmd w')
  endif
endfunction

function! NERDTreeGitStatus#callbacks#BufWritePostUpdate(fname) abort
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

function! NERDTreeGitStatus#callbacks#AddHighlighting() abort
  if &filetype !=# 'nerdtree'
    throw 'NERDTree.NoTreeError: No tree exists for the current buffer'
  endif

  let l:synmap = {
        \   'NERDTreeGitStatusModified'  : NERDTreeGitStatus#helpers#GetIndicator('Modified'),
        \   'NERDTreeGitStatusStaged'    : NERDTreeGitStatus#helpers#GetIndicator('Staged'),
        \   'NERDTreeGitStatusUntracked' : NERDTreeGitStatus#helpers#GetIndicator('Untracked'),
        \   'NERDTreeGitStatusRenamed'   : NERDTreeGitStatus#helpers#GetIndicator('Renamed'),
        \   'NERDTreeGitStatusIgnored'   : NERDTreeGitStatus#helpers#GetIndicator('Ignored'),
        \   'NERDTreeGitStatusDirDirty'  : NERDTreeGitStatus#helpers#GetIndicator('Dirty'),
        \   'NERDTreeGitStatusDirClean'  : NERDTreeGitStatus#helpers#GetIndicator('Clean')
        \ }

  for l:name in keys(l:synmap)
    if g:NERDTreeGitStatusNodeColorization || !g:NERDTreeGitStatusWithFlags
      execute 'syntax match ' . l:name . ' ".*' . l:synmap[l:name] . '.*" containedin=NERDTreeDir'
      execute 'syntax match ' . l:name . ' ".*' . l:synmap[l:name] . '.*" containedin=NERDTreeFile'
      execute 'syntax match ' . l:name . ' ".*' . l:synmap[l:name] . '.*" containedin=NERDTreeExecFile'
    else
      execute 'syntax match ' . l:name . ' #' . escape(l:synmap[l:name], '~') . '# containedin=NERDTreeFlags'
    endif
  endfor

  highlight def link NERDTreeGitStatusUnmerged  Function
  highlight def link NERDTreeGitStatusModified  Special
  highlight def link NERDTreeGitStatusStaged    Function
  highlight def link NERDTreeGitStatusRenamed   Title
  highlight def link NERDTreeGitStatusUnmerged  Label
  highlight def link NERDTreeGitStatusUntracked Comment
  highlight def link NERDTreeGitStatusDirDirty  Tag
  highlight def link NERDTreeGitStatusDirClean  DiffAdd
  " TODO: use different color than NERDTreeGitStatusDirClean
  highlight def link NERDTreeGitStatusIgnored   DiffAdd
endfunction

function! NERDTreeGitStatus#callbacks#ConcealFlag() abort
  if &filetype !=# 'nerdtree'
    throw 'NERDTree.NoTreeError: No tree exists for the current buffer'
  endif

  if !has('conceal')
    return
  endif

  if g:NERDTreeGitStatusWithFlags
    return
  endif

  let l:regex = NERDTreeGitStatus#helpers#GetIndicatorRegex()

  execute 'syntax match NERDTreeGitStatusFlag "\[\(' . l:regex . '\)\]" contained containedin=ALL conceal keepend'

  setlocal conceallevel=3
  setlocal concealcursor=nvic
endfunction
