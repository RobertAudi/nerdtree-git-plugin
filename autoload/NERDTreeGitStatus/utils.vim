" ============================================================================
" File: autoload/NERDTreeGitStatus/utils.vim
" Author: Robert Audi
" Last Modified: February 22, 2019
" ============================================================================

function! NERDTreeGitStatus#utils#TrimWhitespace(input_string) abort
  return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! NERDTreeGitStatus#utils#TrimDoubleQuotes(pathStr) abort
  let l:toReturn = substitute(a:pathStr, '^"', '', '')
  let l:toReturn = substitute(l:toReturn, '"$', '', '')

  return l:toReturn
endfunction

function! NERDTreeGitStatus#utils#exec(cmd) abort
  let l:eventignore_keep = &eventignore
  let l:lazyredraw_keep  = &lazyredraw

  set eventignore=all
  set lazyredraw

  execute a:cmd

  let &eventignore = l:eventignore_keep
  let &lazyredraw  = l:lazyredraw_keep
endfunction
