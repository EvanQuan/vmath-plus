"
"============================================================================
" File:       vmath_plus.vim
" Maintainer: https://github.com/EvanQuan/vmath-plus/
" Version:    3.0.0
"
" A Vim plugin for math on visual regions. An extension of Damian Conway's
" vmath plugin.
" ============================================================================

"############################################################################
"##                                                                        ##
"##  To use:                                                               ##
"##                                                                        ##
"## xnoremrap <silent> <leader>m y:call g:vmath_plus#analyze()<Return>     ##
"## nnoremap  <silent> <leader>m vipy:call g:vmath_plus#analyze()<Return>  ##
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
  let sum = s:tidy( eval( len(numbers) ? join( numbers, ' + ') : '0' ) )
  let avg = s:average(raw_numbers)
  let min = s:tidy( s:min(numbers) )
  let max = s:tidy( s:max(numbers) )
  let pro = s:tidy( eval( len(numbers) ? join( numbers, ' * ' ) : '0' ) )
  let med = s:median(numbers)
  let ran = s:tidy ( str2float(max) - str2float(min) )
  let cnt = s:tidy ( len(numbers) )

  " Convert temporals...
  if temporal
    let sum = s:tidystr( s:sec2str(sum) )
    let avg = s:tidystr( s:sec2str(avg) )
    let min = s:tidystr( s:sec2str(min) )
    let max = s:tidystr( s:sec2str(max) )
    let med = s:tidystr( s:sec2str(med) )
    let pro = s:tidystr( s:sec2str(pro) )
    let ran = s:tidystr( s:sec2str(ran) )
    let cnt = s:tidystr( s:sec2str(cnt) )
 endif

  " En-register metrics...
  call setreg('s', sum )
  call setreg('a', avg )
  call setreg('n', min )
  call setreg('x', max )
  call setreg('m', med )
  call setreg('p', pro )
  call setreg('r', ran )
  call setreg('c', cnt )

  " Default paste buffer should depend on original contents (TODO)
  call setreg('', @s )

  " Report...
  " Gap depends on window width
  let expand_full_labels = winwidth(0) >= s:EXPAND_FULL_LABEL_WIDTH
  let report_labels = expand_full_labels ? ['s̲um', 'a̲verage', 'min̲imum', 'max̲imum',
                                        \ 'm̲edian', 'p̲roduct', 'r̲ange', 'c̲ount' ] :
                                        \ ['s̲um', 'a̲vg', 'min̲', 'max̲',
                                        \ 'm̲ed', 'p̲ro', 'r̲an', 'c̲nt']
  let label_space = len( join(report_labels) ) + len(report_labels) * 2
  let number_space = len(sum) + len(max) + len(min) + len(med) + len(pro) + len(ran) + len(cnt)
  let used_space = number_space + label_space
  let available_space = winwidth(0) - used_space
  let report_gap = max(1, float2nr(available_space * 1.0 / len(report_labels)))
  let gap = repeat(" ", report_gap)
  redraw
  echo
  \    report_labels[0] . ': ' . @s . gap
  \  . report_labels[1] . ': ' . @a . gap
  \  . report_labels[2] . ': ' . @n . gap
  \  . report_labels[3] . ': ' . @x . gap
  \  . report_labels[4] . ': ' . @m . gap
  \  . report_labels[5] . ': ' . @p . gap
  \  . report_labels[5] . ': ' . @r . gap
  \  . report_labels[6] . ': ' . @c

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

  let min = duration % 60
  let duration = duration / 60
  if !duration
    return printf('%d:%02d', min, sec) . (fraction > 0 ? fracstr : '')
  endif

  let hrs = duration % 24
  let duration = duration / 24
  if !duration
    return printf('%d:%02d:%02d', hrs, min, sec) . (fraction > 0 ? fracstr : '')
  endif

  return printf('%d:%02d:%02d:%02d', duration, hrs, min, sec) . (fraction > 0 ? fracstr : '')
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
  let avg = 1.0 * summation / s:max([len(a:numbers), 1])

  " Determine significant figures...
  let min_decimals = 15
  for num in a:numbers
    let decimals = strlen(matchstr(num, '[.]\d\+$')) - 1
    if decimals < min_decimals
      let min_decimals = decimals
    endif
  endfor

  " Adjust answer...
  return min_decimals > 0 ? printf('%0.'.min_decimals.'f', avg)
  \                       : string(avg)
endfunction

" Compute the median with meaningful number of decimal places
function! s:median (numbers)
  " Sort list
  let sorted_numbers = sort(a:numbers, 'f')

  let length = len(a:numbers)

  " Compute average...
  if length == 0
    let med = 0
  elseif length % 2 == 0 " Even
    let med = (sorted_numbers[length/2] + sorted_numbers[length/2 - 1]) / 2.0
  else " Odd
    let med = sorted_numbers[(length - 1)/2]
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
  return min_decimals > 0 ? printf('%0.'.min_decimals.'f', med)
  \                       : string(med)
endfunction

" Reimplement these because the builtins don't handle floats (!!!)
function! s:max (numbers)
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

function! s:min (numbers)
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