"============================================================================
" File:       vmath_plus.vim
" Maintainer: https://github.com/EvanQuan/vmath-plus/
" Version:    3.1.0
"
" A Vim plugin for math on visual regions. An extension of Damian Conway's
" vmath plugin.
" ============================================================================

"############################################################################
"##                                                                        ##
"##  To use:                                                               ##
"##                                                                        ##
"## xnoremrap <silent> <leader>ma y:call g:vmath_plus#analyze()<Return>    ##
"## nnoremap  <silent> <leader>ma vipy:call g:vmath_plus#analyze()<Return> ##
"## noremap   <silent> <leader>mr vipy:call g:vmath_plus#report()<Return>  ##
"##                                                                        ##
"##  (or whatever keys you prefer to remap these actions to)               ##
"##                                                                        ##
"############################################################################


" If already loaded, we're done...
if exists("g:vmath_plus#loaded")
  finish
endif
let g:vmath_plus#loaded = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

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
                   \ 'm̲edian', 'p̲roduct', 'r̲ange', 'c̲ount' ]
let s:SHORT_LABELS = ['s̲um', 'a̲vg', 'min̲', 'max̲',
                    \ 'm̲ed', 'p̲ro', 'r̲an', 'c̲nt']

" Last analyze report is saved
let s:sum = 0
let s:avg = 0
let s:min = 0
let s:max = 0
let s:med = 0
let s:pro = 0
let s:ran = 0
let s:cnt = 0
let s:report_values = [0, 0, 0, 0, 0, 0, 0, 0]

" Do simple math on current yank buffer...
function! g:vmath_plus#analyze()
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

  " Save metrics for report
  let s:report_values = [s:sum, s:avg, s:min, s:max, s:med, s:pro, s:ran, s:cnt]

  " Default paste buffer should depend on original contents (TODO)
  call setreg('', @s )

  call g:vmath_plus#report()

endfunction

function! g:vmath_plus#report()
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
  redraw
  echo
  \    report_labels[0] . ': ' . s:report_values[0] . gap
  \  . report_labels[1] . ': ' . s:report_values[1] . gap
  \  . report_labels[2] . ': ' . s:report_values[2] . gap
  \  . report_labels[3] . ': ' . s:report_values[3] . gap
  \  . report_labels[4] . ': ' . s:report_values[4] . gap
  \  . report_labels[5] . ': ' . s:report_values[5] . gap
  \  . report_labels[6] . ': ' . s:report_values[6] . gap
  \  . report_labels[7] . ': ' . s:report_values[7]
endfunction

" Convert times to raw seconds...
function! s:str2sec (time)
  let components = split(a:time, ':')
  let multipliers = [60, 60*60, 60*60*24]
  let duration = str2float(remove(components, -1))
  while len(components)
    let duration += 1.0 * remove(multipliers,0) * remove(components, -1)
  endwhile
  return string(duration)
endfunction

" Convert raw seconds to times...
function! s:sec2str (duration)
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
endfunction

" Prettify numbers...
function! s:tidy (number)
  let tidied = printf('%g', a:number)
  return substitute(tidied, '[.]0\+$', '', '')
endfunction

function! s:tidystr (str)
  return substitute(a:str, '[.]0\+$', '', '')
endfunction

" Compute average with meaningful number of decimal places...
function! s:average (numbers)
  " Compute average...
  let summation = eval( len(a:numbers) ? join( a:numbers, ' + ') : '0' )
  let s:avg = 1.0 * summation / max([len(a:numbers), 1])

  " Determine significant figures...
  let min_decimals = 15
  for num in a:numbers
    let decimals = strlen(matchstr(num, '[.]\d\+$')) - 1
    if decimals < min_decimals
      let min_decimals = decimals
    endif
  endfor

  " Adjust answer...
  return min_decimals > 0 ? printf('%0.'.min_decimals.'f', s:avg)
  \                       : string(s:avg)
endfunction

" Compute the median with meaningful number of decimal places
function! s:median (numbers)
  " Sort list
  let sorted_numbers = sort(a:numbers, 'f')

  let length = len(a:numbers)

  " Compute average...
  if length == 0
    let s:med = 0
  elseif length % 2 == 0 " Even
    let s:med = (sorted_numbers[length/2] + sorted_numbers[length/2 - 1]) / 2.0
  else " Odd
    let s:med = sorted_numbers[(length - 1)/2]
  endif

  " Determine significant figures...
  let min_decimals = 15
  for num in a:numbers
    let decimals = strlen(matchstr(string(num), '[.]\d\+$')) - 1
    if decimals < min_decimals
      let min_decimals = decimals
    endif
  endfor

  " Adjust answer...
  return min_decimals > 0 ? printf('%0.'.min_decimals.'f', s:med)
  \                       : string(s:med)
endfunction

" Reimplement these because the builtins don't handle floats (!!!)
function! s:maximum (numbers)
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
endfunction

function! s:minimum (numbers)
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
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
