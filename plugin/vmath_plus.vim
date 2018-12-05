"============================================================================
" File:       vmath_plus.vim
" Maintainer: https://github.com/EvanQuan/vmath-plus/
" Version:    3.4.1
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
let s:METRIC_COUNT = 9
let s:FULL_LABELS = ['s̲um', 'a̲verage', 'min̲imum', 'max̲imum',
                   \ 'm̲edian', 'p̲roduct', 'r̲ange', 'c̲ount', 'stn d̲ev' ]
let s:SHORT_LABELS = ['s̲um', 'a̲vg', 'min̲', 'max̲',
                    \ 'm̲ed', 'p̲ro', 'r̲an', 'c̲nt', 'std̲']
let s:LABEL_EXTENSION_LENGTH = 2 * s:METRIC_COUNT
let s:FULL_LABELS_LENGTH = 3 + 7 + 7 + 7
                       \ + 6 + 7 + 5 + 5 + 7
let s:SHORT_LABELS_LENGTH = 3 * s:METRIC_COUNT
let s:SHOW_COMMAND_SPACE = 10

" Fake enums
let s:SUM = 0
let s:AVG = 1
let s:MIN = 2
let s:MAX = 3
let s:MED = 4
let s:PRO = 5
let s:RAN = 6
let s:CNT = 7
let s:STD = 8

" Last analyze report is saved
" Script variables ensure that report echoes the correct values even if the
" registers are changed after the analisis.
let s:values = [0, 0, 0, 0, 0, 0, 0, 0, 0]

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
  let s:values[s:SUM] = s:tidy( eval( len(numbers) ? join( numbers, ' + ') : '0' ) )
  let s:values[s:AVG] = s:average(raw_numbers)
  let s:values[s:MIN] = s:tidy( s:minimum(numbers) )
  let s:values[s:MAX] = s:tidy( s:maximum(numbers) )
  let s:values[s:MED] = s:tidy( eval( len(numbers) ? join( numbers, ' * ' ) : '0' ) )
  let s:values[s:PRO] = s:median(numbers)
  let s:values[s:RAN] = s:tidy ( str2float(s:values[s:MAX]) - str2float(s:values[s:values[s:MIN]]) )
  let s:values[s:CNT] = s:tidy ( len(numbers) )
  let s:values[s:STD] = s:standard_deviation(raw_numbers)

  " Convert temporals...
  if temporal
    let s:values[s:SUM] = s:tidystr( s:sec2str(s:values[s:SUM]) )
    let s:values[s:AVG] = s:tidystr( s:sec2str(s:values[s:AVG]) )
    let s:values[s:MIN] = s:tidystr( s:sec2str(s:values[s:MIN]) )
    let s:values[s:MAX] = s:tidystr( s:sec2str(s:values[s:MAX]) )
    let s:values[s:MED] = s:tidystr( s:sec2str(s:values[s:MED]) )
    let s:values[s:PRO] = s:tidystr( s:sec2str(s:values[s:PRO]) )
    let s:values[s:RAN] = s:tidystr( s:sec2str(s:values[s:RAN]) )
    let s:values[s:CNT] = s:tidystr( s:sec2str(s:values[s:CNT]) )
    let s:values[s:STD] = s:tidystr( s:sec2str(s:values[s:STD]) )
  endif

  " En-register metrics...
  call setreg('s', s:values[s:SUM] )
  call setreg('a', s:values[s:AVG] )
  call setreg('n', s:values[s:MIN] )
  call setreg('x', s:values[s:MAX] )
  call setreg('m', s:values[s:MED] )
  call setreg('p', s:values[s:PRO] )
  call setreg('r', s:values[s:RAN] )
  call setreg('c', s:values[s:CNT] )
  call setreg('d', s:values[s:STD] )

  " Default paste buffer should depend on original contents (TODO)
  call setreg('', @s )
endfunction " }}}
" Report {{{

function! s:get_gap_and_labels() " {{{
  " Get the gap for the report message based on the specified labels and
  " values at the time.
  " @param List[string] labels
  " @param List[string] values
  " @return List[int, List[string]] gap and labels

  let values_length =  0
  for value in s:values
    let values_length += len(value)
  endfor

  " Calculate spacing for full labels
  let labels = s:FULL_LABELS
  let used_space = s:FULL_LABELS_LENGTH + values_length
        \ + s:LABEL_EXTENSION_LENGTH

  let available_space = winwidth(0) - s:SHOW_COMMAND_SPACE - used_space
  let report_gap = max(
        \ [1, float2nr(available_space * 1.0 / (s:METRIC_COUNT - 1))])

  " If full labels are too squished, switch to short labels
  if report_gap < 2
    let labels = s:SHORT_LABELS
    let used_space = s:SHORT_LABELS_LENGTH + values_length
          \ + s:LABEL_EXTENSION_LENGTH
    let available_space = winwidth(0) - s:SHOW_COMMAND_SPACE - used_space
    let report_gap = max(
          \ [1, float2nr(available_space * 1.0 / (s:METRIC_COUNT - 1))])
  endif
  return [report_gap, labels]
endfunction " }}}
function! s:get_report_message() " {{{
  " Store global merics in case of tampering
  let g:vmath_plus#sum     = s:values[s:SUM]
  let g:vmath_plus#average = s:values[s:AVG]
  let g:vmath_plus#minimum = s:values[s:MIN]
  let g:vmath_plus#maximum = s:values[s:MAX]
  let g:vmath_plus#median  = s:values[s:MED]
  let g:vmath_plus#product = s:values[s:PRO]
  let g:vmath_plus#range   = s:values[s:RAN]
  let g:vmath_plus#count   = s:values[s:CNT]
  let g:vmath_plus#stn_dev = s:values[s:STD]
  " Report...
  " Gap depends on window width
  let gap_and_labels = s:get_gap_and_labels()
  let gap = repeat(" ", gap_and_labels[0])
  " redraw " What is the purpose of redrawing?
  return
  \    gap_and_labels[1][s:SUM] . ': ' . s:values[s:SUM]  . gap
  \  . gap_and_labels[1][s:AVG] . ': ' . s:values[s:AVG]  . gap
  \  . gap_and_labels[1][s:MIN] . ': ' . s:values[s:MIN]  . gap
  \  . gap_and_labels[1][s:MAX] . ': ' . s:values[s:MAX]  . gap
  \  . gap_and_labels[1][s:MED] . ': ' . s:values[s:MED]  . gap
  \  . gap_and_labels[1][s:PRO] . ': ' . s:values[s:PRO]  . gap
  \  . gap_and_labels[1][s:RAN] . ': ' . s:values[s:RAN]  . gap
  \  . gap_and_labels[1][s:CNT] . ': ' . s:values[s:CNT]  . gap
  \  . gap_and_labels[1][s:STD] . ': ' . s:values[s:STD]
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

  let s:values[s:MIN] = duration % 60
  let duration = duration / 60
  if !duration
    return printf('%d:%02d', s:values[s:MIN], sec) . (fraction > 0 ? fracstr : '')
  endif

  let hrs = duration % 24
  let duration = duration / 24
  if !duration
    return printf('%d:%02d:%02d', hrs, s:values[s:MIN], sec) . (fraction > 0 ? fracstr : '')
  endif

  return printf('%d:%02d:%02d:%02d', duration, hrs, s:values[s:MIN], sec) . (fraction > 0 ? fracstr : '')
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
  let std = s:standard_deviation_raw(a:numbers)
  return s:significant_figures(a:numbers, std)
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
  let avg = s:average_raw(a:numbers)
  return s:significant_figures(a:numbers, avg)
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
  let med = s:median_raw(a:numbers)
  return s:significant_figures(a:numbers, med)
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
  redraw
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
