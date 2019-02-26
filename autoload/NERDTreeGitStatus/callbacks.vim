" ============================================================================
" File: autoload/NERDTreeGitStatus/callbacks.vim
" Author: Robert Audi
" Last Modified: February 26, 2019
" ============================================================================

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
