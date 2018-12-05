# :sunrise_over_mountains: vmath-plus

This plugin allows you to do simple math on visual regions. It is an
extension of Damian Conway's [vmath
plugin](https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/vmath.vim).

Here is a video demonstrating the original plugin from OSCON 2013:

[![](https://img.youtube.com/vi/aHm36-na4-4/0.jpg)](https://www.youtube.com/watch?v=aHm36-na4-4&feature=youtu.be&t=1792)

I have two main goals for this plugin:

1. Add extra functionality on top of the already implemented
   sum/average/min/max in vmath.
2. Avoid recursive key mappings, and expression mappings. I like my `nnoremap`
   and `vnoremap` and hate having to change them to accommodate for plugins.

## Installation

Install using your favorite package manager, or use Vim's built-in package
support:

#### Vim 8 Native Package Manager

```bash
mkdir ~/.vim/pack/plugin/start/vmath-plus
git clone https://github.com/EvanQuan/vmath-plus.git ~/.vim/pack/plugin/start/vmath-plus
```

#### [Vim-Plug](https://github.com/junegunn/vim-plug)

1. Add `Plug 'EvanQuan/vmath-plus'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:PlugInstall`

#### [Vundle](https://github.com/VundleVim/Vundle.vim)

1. Add `Plugin 'EvanQuan/vmath-plus'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:BundleInstall`

#### [NeoBundle](https://github.com/Shougo/neobundle.vim)

1. Add `NeoBundle 'EvanQuan/vmath-plus'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:NeoUpdate`

#### [Pathogen](https://github.com/tpope/vim-pathogen)

```bash
git clone https://github.com/EvanQuan/vmath-plus.git ~/.vim/bundle/vmath-plus
```

### Functions

This plugin provides 4 functions:
- `g:vmath_plus#analyze()`
- `g:vmath_plus#analyze_buffer()`
- `g:vmath_plus#report()`
- `g:vmath_plus#report_buffer()`

By default, they are not mapped to anything so you can map them to whatever you
like. I personally use:

```vim
" Analyze
"
xnoremap <silent> <leader>ma y:call g:vmath_plus#analyze()<Return>
xnoremap <silent> <leader>mba y:call g:vmath_plus#analyze_buffer()<Return>
nnoremap <silent> <leader>ma vipy:call g:vmath_plus#analyze()<Return>
nnoremap <silent> <leader>mba vipy:call g:vmath_plus#analyze_buffer()<Return>

" Report
"
noremap <silent> <leader>mr :call g:vmath_plus#report()<Return>
noremap <silent> <leader>mbr :call g:vmath_plus#report_buffer()<Return>
```

### Analyze

`g:vmath_plus#analyze()` calculates the numbers in your current visual
selection (visual/line/block mode). As shown, I have normal mode mapped to
calculate the numbers in the current paragraph.

For example, if you were to visually select the following numbers and call
`g:vmath_plus#analyze()`:

```
1
1.0
4
```

The following result would be echoed to the screen:

```
s̲um: 6   a̲vg: 2.0   min̲: 1   max̲: 4   m̲ed: 1.0   p̲ro: 4   r̲an: 3   c̲nt: 3   std̲: 1.732051
```

These values are then stored in the following registers:

| Register | Value              |
|:--------:|:------------------:|
| s        | sum                |
| a        | average            |
| n        | minimum            |
| x        | maximum            |
| m        | median             |
| p        | product            |
| r        | range              |
| c        | count              |
| d        | standard deviation |

which can be pasted with `"<register>p` in normal mode.

`g:vmath_plus#analyze_buffer()` does the same thing but prints the result in
a small read-only buffer at the bottom of the window instead of echoing it.
The buffer is persistently open until you manually close it, and lets you copy
and paste portions of it as you please.

### Report

`g:vmath_plus#report()` reports the results of the most recent analysis. Since
the values are only temporarily echoed, it can be useful to go back and see
previous results without having to recalculate them or manually check the
register contents.

The report message is dynamically calculated based on the window width at the
time of the report. Spacing is increased to expand the window, and if wide
enough, the value labels are expanded to their full names.

`g:vmath_plus#report_buffer()` does the same thing but prints the result in
a small read-only buffer at the bottom of the window instead of echoing it.
The buffer is persistently open until you manually close it, and lets you copy
and paste portions of it as you please.

### Report variables

The last analysis results are stored in global variables for you to do whatever
you want with them, such as making your own commands or functions. They are as
follows:

```vim
g:vmath_plus#sum
g:vmath_plus#average
g:vmath_plus#minimum
g:vmath_plus#maximum
g:vmath_plus#median
g:vmath_plus#product
g:vmath_plus#range
g:vmath_plus#count
g:vmath_plus#stn_dev
```

If you manually change these values, subsequent report function calls will
still output the correct report values. These values are also updated to their
proper values after any `vmath_plus` function call.

## "More Instantly Better Vim" at OSCON 2013

More information about the talk from which the original `vmath` plugin was
presented.

- [Event](http://www.oscon.com/oscon2013/public/schedule/detail/28875)
- [Files](https://docs.google.com/file/d/0Bx3f0gFZh5Jqc0MtcUstV3BKdTQ/edit)
- [Presentation](http://www.youtube.com/watch?v=aHm36-na4-4)
