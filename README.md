# :sunrise_over_mountains: vmath-plus

This plugin allows you to do simple math on visual regions. It is an
extension of Damian Conway's [vmath
plugin](https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/vmath.vim).

(He did all the hard work, not me.)

Here is a video demonstration of the plugin in use from OSCON 2013:

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

## Usage

There are two functions `g:vmath_plus#analyze()`, and `g:vmath_plus#report()`.
By default, they are not mapped to anything so you can map them to whatever you
like. I personally use:

```vim
" Analyze
"
xnoremrap <silent> <leader>ma y:call g:vmath_plus#analyze()<Return>
nnoremap  <silent> <leader>ma vipy:call g:vmath_plus#analyze()<Return> 

" Report
"
noremrap  <silent> <leader>mr :call g:vmath_plus#report()<Return>
```

### Analyze

`g:vmath_plus#analyze()` calculates the numbers in your current visual
selection (visual/line/block mode). As shown, I have normal mode mapped to
calculate the numbers in the current paragraph.

For example, suppose you were to visually select the numbers:

```
1
1
4
```

The following result would be echoed:

```
s̲um: 6   a̲vg: 2.0   min̲: 1   max̲: 4   m̲ed: 1.0   p̲ro: 4   r̲an: 3   c̲nt: 3
```

These values are then stored in the following registers:

| Register | Value   |
|:--------:|:-------:|
| s        | sum     |
| a        | average |
| n        | minimum |
| x        | maximum |
| m        | median  |
| p        | product |
| r        | range   |
| c        | count   |

which can be pasted with `"<register>p` in normal mode.

### Report

`g:vmath_plus#report()` reports the results of the most recent analysis. Since
the values are only temporarily echoed, it can be useful to go back and see
previous results without having to recalculate them or manually check the
register contents.

The report message is dynamically calculated based on the window width at the
time of the report. Spacing is increased to expand the window, and if wide
enough, the value labels are expanded to their full names.

## References

- http://www.oscon.com/oscon2013/public/schedule/detail/28875
- https://docs.google.com/file/d/0Bx3f0gFZh5Jqc0MtcUstV3BKdTQ/edit
- http://www.youtube.com/watch?v=aHm36-na4-4
