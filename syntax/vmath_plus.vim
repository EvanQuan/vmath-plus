" ============================================================================
" File: vmath_plus.vim
" Maintainer: https://github.com/EvanQuan/vmath-plus/
" Version: 0.1.0
"
" Syntax highlighting for vmath-plus results.
"
" ============================================================================
if exists("b:current_syntax")
  finish
endif

syntax match vmathNumber /[-]\?[0-9]\+/
syntax match vmathFloat /[-]\?[0-9]\+.[0-9]\+/
syntax match vmathSeparator /:/
" syntax match vmathSum /s̲\zeum/
syntax match vmathSum /s̲/
syntax match vmathAverage /a̲/
syntax match vmathMininum /n̲/
syntax match vmathMaximum /x̲/
syntax match vmathMean /m̲/
syntax match vmathProduct /p̲/
syntax match vmathRange /r̲/
syntax match vmathCount /c̲/
syntax match vmathStandardDeviation /d̲/

highlight def link vmathNumber Number
highlight def link vmathFloat Number
highlight def link vmathSeparator Operator
highlight def link vmathSum Keyword
highlight def link vmathAverage Keyword
highlight def link vmathMininum Keyword
highlight def link vmathMaximum Keyword
highlight def link vmathMean Keyword
highlight def link vmathProduct Keyword
highlight def link vmathRange Keyword
highlight def link vmathCount Keyword
highlight def link vmathStandardDeviation Keyword

let b:current_syntax = "vmath_plus"
