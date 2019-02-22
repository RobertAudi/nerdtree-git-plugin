" ============================================================================
" File:        git_status.vim
" Description: plugin for NERD Tree that provides git status support
" Maintainer:  Xuyuan Pang <xuyuanp at gmail dot com>
" Last Change: February 22, 2019
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ============================================================================
scriptencoding utf-8

if exists('g:loaded_nerdtree_git_status')
  finish
endif
let g:loaded_nerdtree_git_status = 1

" Don't bother if git is not installed
if !executable('git')
  finish
endif

if !exists('g:NERDTreeShowGitStatus')
  let g:NERDTreeShowGitStatus = 1
endif

if g:NERDTreeShowGitStatus == 0
  finish
endif

if !exists('g:NERDTreeGitStatusWithFlags')
  let g:NERDTreeGitStatusWithFlags = 1
endif

if !exists('g:NERDTreeGitStatusNodeColorization')
  let g:NERDTreeGitStatusNodeColorization = 0
endif

if !exists('g:NERDTreeMapNextHunk')
  let g:NERDTreeMapNextHunk = ']c'
endif

if !exists('g:NERDTreeMapPrevHunk')
  let g:NERDTreeMapPrevHunk = '[c'
endif

if !exists('g:NERDTreeUpdateOnWrite')
  let g:NERDTreeUpdateOnWrite = 1
endif

if !exists('g:NERDTreeUpdateOnCursorHold')
  let g:NERDTreeUpdateOnCursorHold = 1
endif

if !exists('g:NERDTreeShowIgnoredStatus')
  let g:NERDTreeShowIgnoredStatus = 0
endif

if !exists('g:NERDTreeGitStatusIndicatorMap')
  let g:NERDTreeGitStatusIndicatorMap = {
        \   'Modified'  : '✹',
        \   'Staged'    : '✚',
        \   'Untracked' : '✭',
        \   'Renamed'   : '➜',
        \   'Unmerged'  : '═',
        \   'Deleted'   : '✖',
        \   'Dirty'     : '✗',
        \   'Clean'     : '✔︎',
        \   'Ignored'   : '☒',
        \   'Unknown'   : '?'
        \ }
endif

augroup NERDTreeGitStatus
  autocmd!

  autocmd CursorHold * silent! call NERDTreeGitStatus#callbacks#CursorHoldUpdate()
  autocmd BufWritePost * call NERDTreeGitStatus#callbacks#FileUpdate(expand('%:p'))
  autocmd FileType nerdtree call NERDTreeGitStatus#callbacks#AddHighlighting()
  autocmd FileType nerdtree call NERDTreeGitStatus#callbacks#ConcealFlag()
augroup END

if g:NERDTreeShowGitStatus
  " Setup key maps
  call NERDTreeAddKeyMap({
        \   'key': g:NERDTreeMapNextHunk,
        \   'scope': 'Node',
        \   'callback': 'NERDTreeGitStatus#JumpToNextHunk',
        \   'quickhelpText': 'Jump to next git hunk'
        \ })

  call NERDTreeAddKeyMap({
        \   'key': g:NERDTreeMapPrevHunk,
        \   'scope': 'Node',
        \   'callback': 'NERDTreeGitStatus#JumpToPrevHunk',
        \   'quickhelpText': 'Jump to prev git hunk'
        \ })

  " Setup Listeners
  call g:NERDTreePathNotifier.AddListener('init', 'NERDTreeGitStatus#RefreshListener')
  call g:NERDTreePathNotifier.AddListener('refresh', 'NERDTreeGitStatus#RefreshListener')
  call g:NERDTreePathNotifier.AddListener('refreshFlags', 'NERDTreeGitStatus#RefreshListener')
endif
