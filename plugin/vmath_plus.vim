"============================================================================
" File:       vmath_plus.vim
" Maintainer: https://github.com/EvanQuan/vmath-plus/
" Version:    3.4.0
"
" A Vim plugin for math on visual regions. An extension of Damian Conway's
" vmath plugin.
"
" Press ENTER or za to toggle category folding/unfolding.
" ============================================================================
" Set up {{{

" If already loaded, we're done...
if exists("g:vmath_plus#loaded")
  finish
endif
let g:vmath_plus#loaded = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" }}}
" Script variables {{{

" Constants {{{

" What to consider a number...
let s:NUM_PAT = '^[$€£¥]\?[+-]\?[$€£¥]\?\%(\d\{1,3}\%(,\d\{3}\)\+\|\d\+\)\%([.]\d\+\)\?\([eE][+-]\?\d\+\)\?$'

" What to consider a timing...
let s:TIME_PAT = '^\d\+\%([:]\d\+\)\+\%([.]\d\+\)\?$'

" How widely to space the report components...
" Note: Report gap is dynamically calculated based on window width
"
" let s:REPORT_GAP = 5  "spaces between components

" Window width until report labels use full words
"
let s:EXPAND_FULL_LABEL_WIDTH = 115

let s:FULL_LABELS = ['s̲um', 'a̲verage', 'min̲imum', 'max̲imum',
                   \ 'm̲edian', 'p̲roduct', 'r̲ange', 'c̲ount', 'stn d̲ev' ]
let s:SHORT_LABELS = ['s̲um', 'a̲vg', 'min̲', 'max̲',
                    \ 'm̲ed', 'p̲ro', 'r̲an', 'c̲nt', 'std̲']

" }}}
" Metric values {{{

" Last analyze report is saved
" Script variables ensure that report echoes the correct values even if the
" registers are changed after the analisis.
let s:sum = 0
let s:avg = 0
let s:min = 0
let s:max = 0
let s:med = 0
let s:pro = 0
let s:ran = 0
let s:cnt = 0
let s:std = 0

" }}}

" }}}
" Script functions {{{

function! s:analyze() " {{{
  " Do simple math on current yank buffer...
"
  " Extract data from selection...
  let selection = getreg('')
  let raw_numbers = filter(split(selection), 'v:val =~ s:NUM_PAT')
  let raw_numbers = map(raw_numbers, 'substitute(v:val,"[,$€£¥]","","g")')
  let temporal = empty(raw_numbers)

  " If no numerical data, try time data...
  if temporal
    let raw_numbers
      \ = map( filter( split(selection),
      \                'v:val =~ s:TIME_PAT'
      \        ),
      \        's:str2sec(v:val)'
      \   )
  endif

  " Convert to calculable terms...
  let numbers = map(copy(raw_numbers), 'str2float(v:val)')

  " Results include a newline if original selection did...
  let newline = selection =~ "\n" ? "\n" : ""

  " Calculate various interesting metrics...
  let s:sum = s:tidy( eval( len(numbers) ? join( numbers, ' + ') : '0' ) )
  let s:avg = s:average(raw_numbers)
  let s:min = s:tidy( s:minimum(numbers) )
  let s:max = s:tidy( s:maximum(numbers) )
  let s:pro = s:tidy( eval( len(numbers) ? join( numbers, ' * ' ) : '0' ) )
  let s:med = s:median(numbers)
  let s:ran = s:tidy ( str2float(s:max) - str2float(s:min) )
  let s:cnt = s:tidy ( len(numbers) )
  let s:std = s:standard_deviation(raw_numbers)

  " Convert temporals...
  if temporal
    let s:sum = s:tidystr( s:sec2str(s:sum) )
    let s:avg = s:tidystr( s:sec2str(s:avg) )
    let s:min = s:tidystr( s:sec2str(s:min) )
    let s:max = s:tidystr( s:sec2str(s:max) )
    let s:med = s:tidystr( s:sec2str(s:med) )
    let s:pro = s:tidystr( s:sec2str(s:pro) )
    let s:ran = s:tidystr( s:sec2str(s:ran) )
    let s:cnt = s:tidystr( s:sec2str(s:cnt) )
    let s:std = s:tidystr( s:sec2str(s:std) )
  endif

  " En-register metrics...
  call setreg('s', s:sum )
  call setreg('a', s:avg )
  call setreg('n', s:min )
  call setreg('x', s:max )
  call setreg('m', s:med )
  call setreg('p', s:pro )
  call setreg('r', s:ran )
  call setreg('c', s:cnt )
  call setreg('d', s:std )

  " Default paste buffer should depend on original contents (TODO)
  call setreg('', @s )
endfunction " }}}
" Report {{{

function! s:get_report_message() " {{{
  " Store global merics in case of tampering
  let g:vmath_plus#sum = s:sum
  let g:vmath_plus#average = s:avg
  let g:vmath_plus#minimum = s:min
  let g:vmath_plus#maximum = s:max
  let g:vmath_plus#median = s:med
  let g:vmath_plus#range = s:ran
  let g:vmath_plus#count = s:cnt
  let g:vmath_plus#stn_dev = s:std
  " Report...
  " Gap depends on window width
  let expand_full_labels = winwidth(0) >= s:EXPAND_FULL_LABEL_WIDTH
  let report_labels = expand_full_labels ?  s:FULL_LABELS : s:SHORT_LABELS
  let label_space = len( join(report_labels) ) + len(report_labels) * 2
  let number_space = len(s:sum) + len(s:max) + len(s:min) + len(s:med) + len(s:pro) + len(s:ran) + len(s:cnt)
  let used_space = number_space + label_space
  let available_space = winwidth(0) - used_space
  let report_gap = max([1, float2nr(available_space * 1.0 / len(report_labels))])
  let gap = repeat(" ", report_gap)
  " redraw " What is the purpose of redrawing?
  return
  \    report_labels[0] . ': ' . s:sum . gap
  \  . report_labels[1] . ': ' . s:avg . gap
  \  . report_labels[2] . ': ' . s:min . gap
  \  . report_labels[3] . ': ' . s:max . gap
  \  . report_labels[4] . ': ' . s:med . gap
  \  . report_labels[5] . ': ' . s:pro . gap
  \  . report_labels[6] . ': ' . s:ran . gap
  \  . report_labels[7] . ': ' . s:cnt . gap
  \  . report_labels[8] . ': ' . s:std
endfunction " }}}
function! s:split_report() " {{{
  let s:output_buffer_name = "VMath Report"
  let s:output_buffer_filetype = "output"
  " reuse existing buffer window if it exists otherwise create a new one
  if !exists("s:buf_nr") || !bufexists(s:buf_nr)
    silent execute 'botright new ' . s:output_buffer_name
    let s:buf_nr = bufnr('%')
  elseif bufwinnr(s:buf_nr) == -1
    silent execute 'botright new'
    silent execute s:buf_nr . 'buffer'
  elseif bufwinnr(s:buf_nr) != bufwinnr('%')
    silent execute bufwinnr(s:buf_nr) . 'wincmd w'
  endif

  silent execute "setlocal filetype=" . s:output_buffer_filetype
  setlocal bufhidden=delete
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nobuflisted
  setlocal winfixheight
  setlocal cursorline " make it easy to distinguish
  setlocal nonumber
  setlocal norelativenumber
  setlocal showbreak=""

  " clear the buffer and make it modifiable for terminal output
  setlocal noreadonly
  setlocal modifiable
  %delete _

  execute ".! echo '" . s:get_report_message() . "'"

  " decrease window size
  execute 'resize' . line('$')

  " make the buffer non modifiable
  setlocal readonly
  setlocal nomodifiable
endfunction " }}}

" }}}
" Time {{{

" Convert times to raw seconds...
function! s:str2sec(time) " {{{
  let components = split(a:time, ':')
  let multipliers = [60, 60*60, 60*60*24]
  let duration = str2float(remove(components, -1))
  while len(components)
    let duration += 1.0 * remove(multipliers,0) * remove(components, -1)
  endwhile
  return string(duration)
endfunction " }}}
" Convert raw seconds to times...
function! s:sec2str(duration) " {{{
  let fraction = str2float(a:duration)
  let duration = str2nr(a:duration)
  let fraction -= duration
  let fracstr = substitute(string(fraction), '^0', '', '')

  let sec = duration % 60
  let duration = duration / 60
  if !duration
    return printf('0:%02d', sec) . (fraction > 0 ? fracstr : '')
  endif

  let s:min = duration % 60
  let duration = duration / 60
  if !duration
    return printf('%d:%02d', s:min, sec) . (fraction > 0 ? fracstr : '')
  endif

  let hrs = duration % 24
  let duration = duration / 24
  if !duration
    return printf('%d:%02d:%02d', hrs, s:min, sec) . (fraction > 0 ? fracstr : '')
  endif

  return printf('%d:%02d:%02d:%02d', duration, hrs, s:min, sec) . (fraction > 0 ? fracstr : '')
endfunction " }}}

" }}}
" Tidy Results {{{

" Prettify numbers...
function! s:tidy(number) " {{{
  let tidied = printf('%g', a:number)
  return substitute(tidied, '[.]0\+$', '', '')
endfunction " }}}
function! s:tidystr(str) " {{{
  return substitute(a:str, '[.]0\+$', '', '')
endfunction " }}}
function! s:significant_figures(numbers, answer) " {{{
  " Find the significant figures from list of numbers
  " @param List[string] of numbers
  " @param string of answer to round
  " @return string of answer rounded to alotted decimal places
  let min_decimals = 15
  for num in a:numbers
    let decimals = strlen(matchstr(string(num), '[.]\d\+$')) - 1
    if decimals < min_decimals
      let min_decimals = decimals
    endif
  endfor
  " Adjust answer...
  return min_decimals > 0 ? printf('%0.'.min_decimals.'f', a:answer)
  \                       : string(a:answer)
endfunction " }}}

" }}}
" Metrics {{{

" Standard deviation {{{

function! s:standard_deviation_raw(numbers) " {{{
  " Compute the standard deviation
  " @param List[string] of numbers
  " @return float of standard deviation unrounded
  let length = len(a:numbers)

  if length <= 1
    return 0.0
  endif

  let mean = s:average_raw(a:numbers)
  let std = 0.0

  for num in a:numbers
    let std += (num * 1.0 - mean) * (num * 1.0 - mean)
  endfor
  return sqrt(std / ((length - 1) * 1.0))
endfunction " }}}
function! s:standard_deviation(numbers) " {{{
  " Compute standard deviation with meaningful number of decimal places...
  " @param List[string] of numbers
  " @return string of standard deviation with correct significant figures
  let s:std = s:standard_deviation_raw(a:numbers)
  return s:significant_figures(a:numbers, s:std)
endfunction " }}}

" }}}
" Average {{{

function! s:average_raw(numbers) " {{{
  " Compute average unrounded
  " @param List[float] of numbers
  " @return float of average unrounded
  let summation = eval( len(a:numbers) ? join( a:numbers, ' + ') : '0' )
  return 1.0 * summation / max([len(a:numbers), 1])
endfunction " }}}
function! s:average(numbers) " {{{
  " Compute average with meaningful number of decimal places...
  " @param List[float] of numbers
  " @return string of average with correct significant figures
  let s:avg = s:average_raw(a:numbers)
  return s:significant_figures(a:numbers, s:avg)
endfunction " }}}

" }}}
" Median {{{

function! s:median_raw(numbers) " {{{
  " Compute average with meaningful number of decimal places...
  " @param List[string] of numbers
  " @return float of median unrounded
  " Sort list
  let sorted_numbers = sort(a:numbers, 'f')

  let length = len(a:numbers)

  if length == 0
    return 0
  elseif length % 2 == 0 " Even
    return (sorted_numbers[length/2] + sorted_numbers[length/2 - 1]) / 2.0
  else " Odd
    return sorted_numbers[(length - 1)/2]
  endif
endfunction " }}}
function! s:median(numbers) " {{{
  " Compute the median with meaningful number of decimal places
  " @param List[string] of numbers
  " @return string of median with correct significant figures
  let s:med = s:median_raw(a:numbers)
  return s:significant_figures(a:numbers, s:med)
endfunction " }}}

" }}}
function! s:maximum(numbers) " {{{
  " Reimplement these because the builtins don't handle floats (!!!)
  " @param List[string] of numbers
  " @return string of maximum
  if !len(a:numbers)
    return 0
  endif
  let numbers = copy(a:numbers)
  let maxnum = numbers[0]
  for nextnum in numbers[1:]
    if nextnum > maxnum
      let maxnum = nextnum
    endif
  endfor
  return maxnum
endfunction " }}}
function! s:minimum(numbers) " {{{
  " @param List[string] of numbers
  " @return string of minimum
  if !len(a:numbers)
    return 0
  endif
  let numbers = copy(a:numbers)
  let minnum = numbers[0]
  for nextnum in numbers[1:]
    if nextnum < minnum
      let minnum = nextnum
    endif
  endfor
  return minnum
endfunction " }}}

" }}}

" }}}
" Global variables {{{

" Global variables allow user to use analysis values however they want without
" needing to check register contents. They are restored to script variables on
" report in case the user tampers with them.
let g:vmath_plus#sum = 0
let g:vmath_plus#average = 0
let g:vmath_plus#minimum = 0
let g:vmath_plus#maximum = 0
let g:vmath_plus#median = 0
let g:vmath_plus#range = 0
let g:vmath_plus#count = 0
let g:vmath_plus#stn_dev = 0

" }}}
" Global functions {{{

" Analyize {{{

function! g:vmath_plus#analyze()
  call s:analyze()
  call g:vmath_plus#report()
endfunction

function! g:vmath_plus#analyze_buffer()
  call s:analyze()
  call g:vmath_plus#report_buffer()
endfunction

" }}}
" Report {{{

function! g:vmath_plus#report()
  " redraw
  echo s:get_report_message()
endfunction

function! g:vmath_plus#report_buffer()
  call s:split_report()
endfunction

" }}}

" }}}
" Tear down {{{

" Restore previous external compatibility options
let &cpo = s:save_cpo

" }}}
