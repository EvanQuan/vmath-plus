# :sunrise_over_mountains: vmath-plus

This plugin allows you to do simple math on visual regions. It is an
extension of Damian Conway's [vmath
plugin](https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/vmath.vim).

Here is a video demonstrating the original plugin from OSCON 2013:

[![](https://img.youtube.com/vi/aHm36-na4-4/0.jpg)](https://www.youtube.com/watch?v=aHm36-na4-4&feature=youtu.be&t=1792)

Table of Contents
-----------------
1. [Installation](#installation)
2. [Usage](#usage)
    - [Analyze](#analyze)
         - [Numbers](#numbers)
         - [Time](#time)
         - [Storing results](#storing-results)
    - [Report](#report)
    - [Report variables](#report-variables)
    - [Buffer settings](#buffer-settings)
3. [More Information](#more-information)

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

This plugin provides 6 functions:
- `<Plug>(vmath_plus#normal_analyze)`
- `<Plug>(vmath_plus#normal_analyze_buffer)`
- `<Plug>(vmath_plus#visual_analyze)`
- `<Plug>(vmath_plus#visual_analyze_buffer)`
- `<Plug>(vmath_plus#report)`
- `<Plug>(vmath_plus#report_buffer)`

By default, they are not mapped to anything so you can map them to whatever
you like. I personally use:

```vim
" Analyze
"
nmap <silent> <leader>ma <Plug>(vmath_plus#normal_analyze)
nmap <silent> <leader>mba <Plug>(vmath_plus#normal_analyze_buffer)
xmap <silent> <leader>ma <Plug>(vmath_plus#visual_analyze)
xmap <silent> <leader>mba <Plug>(vmath_plus#visual_analyze_buffer)

" Report
"
nmap <silent> <leader>mr <Plug>(vmath_plus#report)
nmap <silent> <leader>mbr <Plug>(vmath_plus#report_buffer)
```

Note that the mapping must be bound with `nmap` and `xmap`.

### Analyze

`<Plug>(vmath_plus#visual_analyze)` calculates the numbers in your current
visual selection (visual/line/block mode). As shown, I have normal mode mapped
to calculate the numbers in the current paragraph.

#### Numbers

You can calculate some useful metrics on a selection of numbers. If you were
to visually select the following text and call
`<Plug>(vmath_plus#visual_analyze)`:

```
1
192.168.1.1
1.0
foo
4
```

The following result would be echoed to the screen:

```
s̲um: 6   a̲vg: 2.0   min̲: 1   max̲: 4   m̲ed: 1.0   p̲ro: 4   r̲an: 3   c̲nt: 3   std̲: 1.732051
```

Note that both `192.168.1.1` and `foo` are ignored in the calculation as they
are not numbers, even though they are included in the selected visual region.

#### Time

You can also calculate the same metrics on a selection of times. Times are `:`
separated, in the form `day:hour:minute:sec`. For example, if the following
text is analyzed:

```
0:22        // twenty-two seconds
1:07        // one minute, seven seconds
1:18:00     // one hour, eighteen minutes
```

the result would be:

```
s̲um: 1:19:29    a̲vg: 26:29.666667    min̲: 0:22    max̲: 1:18:00    m̲ed: 1:07    p̲ro: 79:20:12:00    r̲an: 1:17:38    c̲nt: 3    std̲: 44:36.401751
```

#### Storing results

After analysis, the values are stored in the following yank registers:

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

which can be pasted with `"<register>p` in normal mode. For example, the sum
can be pasted with `"sp`.

`<Plug>(vmath_plus#visual_analyze_buffer)` does the same thing but prints the
result in a small read-only buffer at the bottom of the window instead of
echoing it. The buffer is persistently open until you manually close it, and
lets you copy and paste portions of it as you please.

### Report

`<Plug>(vmath_plus#report)` reports the results of the most recent analysis. Since
the values are only temporarily echoed, it can be useful to go back and see
previous results without having to recalculate them or manually check the
register contents.

The report message is dynamically calculated based on the window width at the
time of the report. Spacing is increased to expand the window, and if wide
enough, the value labels are expanded to their full names.

`<Plug>(vmath_plus#report_buffer)` does the same thing but prints the result in
a small read-only buffer at the bottom of the window instead of echoing it.
The buffer is persistently open until you manually close it, and lets you copy
and paste portions of it as you please.

### Report variables

The last analysis results are stored in global variables for you to do whatever
you want with them, such as making your own commands or functions. They are as
follows:

```
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

### Buffer settings

By default, For the buffer functions
`<Plug>(vmath_plus#normal_analyze_buffer)`,
`<Plug>(vmath_plus#visual_analyze_buffer)` and
`<Plug>(vmath_plus#report_buffer)`, the report buffer resizes to fit only the
text of the report to be as unobtrusive as possible. If you do not want the
buffer to be resized, you can disable it in your `vimrc` with:
```vim
let g:vmath_plus#resize_buffer = 0
```

The report message expands to fit the window width in both the label spacing
and in the label abbreviations. The aim is to the make the message both more
readable for wide windows and to prevent it from overflowing to multiple lines
for small windows and thus creating an annoying `Press ENTER or type command
to continue` prompt.

By default, the report buffer uses the same message as the echoed report.
However, since it does not suffer from the single-line constraint as the
echoed report, there is no need to shorten it. If you would like the report
buffer to always use full labels no matter the window width, you can disable
buffer label resizing in your `vimrc` with:
```vim
let g:vmath_plus#resize_buffer_labels = 0
```

Similarly, the minimum buffer spacing can be adjusted if resizing is disabled
with:
```vim
let g:vmath_plus#min_buffer_gap = 2
```
By default it is set to 2, meaning that the buffer label spacing will either
be 2 or greater if `g:vmath_plus#resize_buffer_labels = 0`. Non-positive gap
sizes will be readjusted to 1.

By default when the report buffer is created, the cursor stays in the original
window. If you would like the cursor to move into the report buffer as soon as
an analysis is done, you can set that with:
```vim
g:vmath_plus#move_cursor_to_buffer = 1
```

## More Information

More information about the talk from which the original `vmath` plugin was
presented.

- [Event](http://www.oscon.com/oscon2013/public/schedule/detail/28875)
- [Files](https://docs.google.com/file/d/0Bx3f0gFZh5Jqc0MtcUstV3BKdTQ/edit)
- [Presentation](http://www.youtube.com/watch?v=aHm36-na4-4)
