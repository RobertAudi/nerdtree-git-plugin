" ============================================================================
" File: autoload/NERDTreeGitStatus.vim
" Author: Robert Audi
" Last Modified: February 26, 2019
" ============================================================================

function! NERDTreeGitStatus#RefreshListener(event) abort
  if !g:NERDTree.ExistsForBuf()
    return
  endif

  if !exists('b:NOT_A_GIT_REPOSITORY')
    call NERDTreeGitStatus#Refresh()
  endif

  let l:path = a:event.subject
  let l:flag = NERDTreeGitStatus#GetPathIndicator(l:path)

  call l:path.flagSet.clearFlags('git')

  if l:flag !=# ''
    call l:path.flagSet.addFlag('git', l:flag)
  endif
endfunction

" Refresh cached git status
function! NERDTreeGitStatus#Refresh() abort
  if !g:NERDTree.ExistsForTab()
    throw 'NERDTree.NoTreeError: No tree exists for the current tab'
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

  let b:NERDTreeCachedGitFileStatus = {}
  let b:NERDTreeCachedGitDirtyDir   = {}
  let b:NOT_A_GIT_REPOSITORY        = 1

  let l:root = fnamemodify(b:NERDTree.root.path.str(), ':p:S')
  let l:gitcmd = 'git status --porcelain'

  if g:NERDTreeGitStatusShowIgnoredStatus
    let l:gitcmd = l:gitcmd . ' --ignored'
  endif

  if exists('g:NERDTreeGitStatusIgnoreSubmodules')
    let l:gitcmd = l:gitcmd . ' --ignore-submodules'

    if g:NERDTreeGitStatusIgnoreSubmodules ==# 'all' || g:NERDTreeGitStatusIgnoreSubmodules ==# 'dirty' || g:NERDTreeGitStatusIgnoreSubmodules ==# 'untracked'
      let l:gitcmd = l:gitcmd . '=' . g:NERDTreeGitStatusIgnoreSubmodules
    endif
  endif

  let l:statusesStr   = system(l:gitcmd . ' ' . l:root)
  let l:statusesSplit = split(l:statusesStr, '\n')

  if l:statusesSplit != [] && l:statusesSplit[0] =~# 'fatal:.*'
    let l:statusesSplit = []

    if l:jumpBack
      call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . l:curWin . 'wincmd w')
    endif

    return
  endif

  let b:NOT_A_GIT_REPOSITORY = 0

  for l:statusLine in l:statusesSplit
    " cache git status of files
    let l:pathStr   = substitute(l:statusLine, '..', '', '')
    let l:pathSplit = split(l:pathStr, ' -> ')

    if len(l:pathSplit) == 2
      call NERDTreeGitStatus#helpers#CacheDirtyDir(l:pathSplit[0])

      let l:pathStr = l:pathSplit[1]
    else
      let l:pathStr = l:pathSplit[0]
    endif

    let l:pathStr = NERDTreeGitStatus#utils#TrimDoubleQuotes(l:pathStr)

    if l:pathStr =~# '\.\./.*'
      continue
    endif

    let l:statusKey = NERDTreeGitStatus#helpers#GetStatusKey(l:statusLine[0], l:statusLine[1])
    let l:pathStr   = NERDTreeGitStatus#utils#TrimWhitespace(l:pathStr)
    let b:NERDTreeCachedGitFileStatus[fnameescape(l:pathStr)] = l:statusKey

    if l:statusKey ==# 'Ignored'
      if isdirectory(l:pathStr)
        let b:NERDTreeCachedGitDirtyDir[fnameescape(l:pathStr)] = l:statusKey
      endif
    else
      call NERDTreeGitStatus#helpers#CacheDirtyDir(l:pathStr)
    endif
  endfor

  if l:jumpBack
    call NERDTreeGitStatus#utils#exec('keepjumps keepalt ' . l:curWin . 'wincmd w')
  endif
endfunction

" Return the indicator of the path
let s:GitStatusCacheTimeExpiry = 2
let s:GitStatusCacheTime = 0
function! NERDTreeGitStatus#GetPathIndicator(path) abort
  if !g:NERDTree.ExistsForTab()
    return
  endif

  if localtime() - s:GitStatusCacheTime > s:GitStatusCacheTimeExpiry
    let s:GitStatusCacheTime = localtime()

    call NERDTreeGitStatus#Refresh()
  endif

  let l:NERDTree = g:NERDTree.ExistsForBuf() ? b:NERDTree : g:NERDTree.ForCurrentTab()
  let l:NERDTreeBufnr = bufnr(t:NERDTreeBufName)

  let l:pathStr = a:path.str()
  let l:cwd = l:NERDTree.root.path.str() . nerdtree#slash()

  if nerdtree#runningWindows()
    let l:pathStr = a:path.WinToUnixPath(l:pathStr)
    let l:cwd = a:path.WinToUnixPath(l:cwd)
  endif

  let l:cwd = substitute(l:cwd, '\~', '\\~', 'g')
  let l:pathStr = substitute(l:pathStr, l:cwd, '', '')
  let l:statusKey = ''

  if a:path.isDirectory
    let l:NERDTreeCachedGitDirtyDir = getbufvar(l:NERDTreeBufnr, 'NERDTreeCachedGitDirtyDir', {})
    let l:statusKey = get(l:NERDTreeCachedGitDirtyDir, fnameescape(l:pathStr . '/'), '')
  else
    let l:NERDTreeCachedGitFileStatus = getbufvar(l:NERDTreeBufnr, 'NERDTreeCachedGitFileStatus', {})
    let l:statusKey = get(l:NERDTreeCachedGitFileStatus, fnameescape(l:pathStr), '')
  endif

  return NERDTreeGitStatus#helpers#GetIndicator(l:statusKey)
endfunction

" Return the indicator of current path (cwd)
function! NERDTreeGitStatus#GetCurrentPathIndicator() abort
  if !g:NERDTree.ExistsForTab()
    return
  endif

  let l:NERDTreeBufnr = bufnr(t:NERDTreeBufName)

  if getbufvar(l:NERDTreeBufnr, 'NOT_A_GIT_REPOSITORY', 0)
    return ''
  endif

  let l:NERDTreeCachedGitDirtyDir   = getbufvar(l:NERDTreeBufnr, 'NERDTreeCachedGitDirtyDir',   {})
  let l:NERDTreeCachedGitFileStatus = getbufvar(l:NERDTreeBufnr, 'NERDTreeCachedGitFileStatus', {})

  if l:NERDTreeCachedGitDirtyDir == {} && l:NERDTreeCachedGitFileStatus == {}
    return NERDTreeGitStatus#helpers#GetIndicator('Clean')
  endif

  return NERDTreeGitStatus#helpers#GetIndicator('Dirty')
endfunction

function! NERDTreeGitStatus#JumpToNextHunk(node) abort
  let l:position = search(NERDTreeGitStatus#helpers#GetIndicatorRegex(), '')

  if l:position
    call nerdtree#echo('Jump to next hunk ')
  endif
endfunction

function! NERDTreeGitStatus#JumpToPrevHunk(node) abort
  let l:position = search(NERDTreeGitStatus#helpers#GetIndicatorRegex(), 'b')

  if l:position
    call nerdtree#echo('Jump to prev hunk ')
  endif
endfunction
