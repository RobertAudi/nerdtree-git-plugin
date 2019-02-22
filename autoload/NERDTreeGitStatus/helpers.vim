" ============================================================================
" File: autoload/NERDTreeGitStatus/helpers.vim
" Author: Robert Audi
" Last Modified: February 22, 2019
" ============================================================================

function! NERDTreeGitStatus#helpers#CacheDirtyDir(pathStr) abort
  " cache dirty dir
  let l:dirtyPath = NERDTreeGitStatus#utils#TrimDoubleQuotes(a:pathStr)

  if l:dirtyPath =~# '\.\./.*'
    return
  endif

  let l:dirtyPath = substitute(l:dirtyPath, '/[^/]*$', '/', '')

  while l:dirtyPath =~# '.\+/.*' && has_key(b:NERDTreeCachedGitDirtyDir, fnameescape(l:dirtyPath)) == 0
    let l:dirtyPath = NERDTreeGitStatus#utils#TrimDoubleQuotes(l:dirtyPath)
    let b:NERDTreeCachedGitDirtyDir[fnameescape(l:dirtyPath)] = 'Dirty'
    let l:dirtyPath = substitute(l:dirtyPath, '/[^/]*/$', '/', '')
  endwhile
endfunction

function! NERDTreeGitStatus#helpers#GetIndicator(statusKey) abort
  return get(g:NERDTreeGitStatusIndicatorMap, a:statusKey, '')
endfunction

function! NERDTreeGitStatus#helpers#GetStatusKey(us, them) abort
  if a:us ==# '?' && a:them ==# '?'
    return 'Untracked'
  elseif a:us ==# ' ' && a:them ==# 'M'
    return 'Modified'
  elseif a:us =~# '[MAC]'
    return 'Staged'
  elseif a:us ==# 'R'
    return 'Renamed'
  elseif a:us ==# 'U' || a:them ==# 'U' || (a:us ==# 'A' && a:them ==# 'A') || (a:us ==# 'D' && a:them ==# 'D')
    return 'Unmerged'
  elseif a:them ==# 'D'
    return 'Deleted'
  elseif a:us ==# '!'
    return 'Ignored'
  else
    return 'Unknown'
  endif
endfunction
