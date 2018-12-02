# :sunrise_over_mountains: vim-mathematize

This plugin allows you to do simple math on visual regions. It is an
extension of Damian Conway's [vmath
plugin](https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/vmath.vim).
(He did all the hard work, not me.)

This exists to additionally calculate products on top of the already
implemented sum/average/min/max since I found myself needing to do so in my own
work.

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
