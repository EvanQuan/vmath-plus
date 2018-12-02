# :sunrise_over_mountains: vim-mathematize

This plugin allows you to do simple math on visual regions. It is an
extension of Damian Conway's [vmath
plugin](https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/vmath.vim).
(He did all the hard work, not me.)

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
mkdir ~/.vim/pack/plugin/start/vim-mathematize
git clone https://github.com/EvanQuan/vim-mathematize.git ~/.vim/pack/plugin/start/vim-mathematize
```

#### [Vim-Plug](https://github.com/junegunn/vim-plug)

1. Add `Plug 'EvanQuan/vim-mathematize'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:PlugInstall`

#### [Vundle](https://github.com/VundleVim/Vundle.vim)

1. Add `Plugin 'EvanQuan/vim-mathematize'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:BundleInstall`

#### [NeoBundle](https://github.com/Shougo/neobundle.vim)

1. Add `NeoBundle 'EvanQuan/vim-mathematize'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:NeoUpdate`

#### [Pathogen](https://github.com/tpope/vim-pathogen)

```bash
git clone https://github.com/EvanQuan/vim-mathematize.git ~/.vim/bundle/vim-mathematize
```

## Extended Features

- Product

### TODO

- Mode (o)
- Median (m)
- Range (r)

## Usage

There is one function `g:mathematize#analyze`. By default, it is not mapped to
anything so you can map them to whatever you like. I personally use:

```vim
xnoremrap <silent> <leader>m y:call g:mathematize#analyze()<Return>
nnoremap  <silent> <leader>m vipy:call g:mathematize#analyze()<Return> 
```

 The function calculates the numbers in your current visual selection and its
 contents must be yanked for the results to be saved in their respective
 registers. As shown, I have normal mode mapped to calculate the numbers in the
 current paragraph.
