# Ngram Completion Based on Google Ngrams Viewer

This plugin is a helper for Vim completion plugin
[Vimcomplete](https://github.com/girishji/vimcomplete). It suggests (completes)
next word based on bigram, trigram and 4-gram word association by querying [Google Ngrams
Viewer](https://books.google.com/ngrams/). No additional packages or databases are required.
Google queries can be slow and can take over a second. However, Vim's responsiveness
is not degraded since queries are asynchronous and results are cached.

![image](https://i.imgur.com/HHDt2yh.png)

# Requirements

- Vim >= 9.0

# Installation

Install this plugin after [Vimcomplete](https://github.com/girishji/vimcomplete).

Install using [vim-plug](https://github.com/junegunn/vim-plug).

```
vim9script
plug#begin()
Plug 'girishji/ngram-complete.vim'
plug#end()
```

For those who prefer legacy script.

```
call plug#begin()
Plug 'girishji/ngram-complete.vim'
call plug#end()
```

Or use Vim's builtin package manager.

# Configuration

Default options are as follows.

```
vim9script
export var options: dict<any> = {
    priority: 11,    # Higher priority items are shown at the top
    maxCount: 10,    # Maximum number of next-word items shown
    cacheSize: 100,  # Each ngram takes up one slot in the cache
}
autocmd VimEnter * g:VimCompleteOptionsSet(options)
```
