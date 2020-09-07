# Customization

Misc. personal customization files.


## Dotfiles

- Methods for coordinating dotfiles between machines:
  - Coordinate between machines by [symlinking](https://www.cyberciti.biz/faq/creating-soft-link-or-symbolic-link/) the files to the right place, e.g. `ln -s ~/Projects/dot_files/.bash_profile .bash_profile`
  - [Rsync method](https://medium.com/free-code-camp/dive-into-dotfiles-part-2-6321b4a73608): `rsync . ~`. This copies the contents of the source (the current directory: .) to the destination (the home directory: ~); note `--exclude` flag to only move some files.
- [Atom dotfiles](http://jbranchaud.github.io/splitting-atoms/adding-atom-to-dotfiles.html)
- [Example setups](https://dotfiles.github.io/):
  - [iamlemec](https://github.com/iamlemec/dotfiles)
  - [nicksp](https://github.com/nicksp/dotfiles): Mac OS (incl. Atom, iterm)

## Customizing Checklist

### Command Line

- Zsh
  - [Installation walkthrough](https://www.freecodecamp.org/news/how-to-configure-your-macos-terminal-with-zsh-like-a-pro-c0ab3f3c1156/)
  - oh-my-zsh is an essential configuration manager for Zsh, should be installed at the same time.
    - oh-my-zsh controls [themes](https://github.com/robbyrussell/oh-my-zsh/wiki/themes) and [aliases](https://github.com/robbyrussell/oh-my-zsh/wiki/Cheatsheet)
      - Remember to [install font](https://www.fontsquirrel.com/fonts/source-code-pro) for [powerlevel9k theme](https://github.com/Powerlevel9k/powerlevel9k/wiki/Install-Instructions#step-1-install-powerlevel9k) and change iTerm2 (`iTerm2 > Preferences > Profiles > Text > Change Font`)
  - Zsh has a configuration file (`.zshrc`), which controls shell configuration and aliases, more or less equivalent to the `bash_profile`. It also has `.zshenv`,  which sets various environment variables.  
    - ([Lengthy explanation](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout) of the difference between the two kinds of dot files.)
    - Anaconda automatically updates the bashprofile; but for zsh, `run conda init zsh`
- iTerm2
  - Installation: `brew cask install iterm2`
  - Walkthrough for [iTerm2 profile syncing](http://stratus3d.com/blog/2015/02/28/sync-iterm2-profile-with-dotfiles-repository/)
- [Homebrew](https://brew.sh/)
  - Installation: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
- [Fuzzy Finder](https://github.com/junegunn/fzf): interactive Unix filter for command-line that can be used with any list; files, command history, processes, hostnames, bookmarks, git commits, etc.
  - Installation: `brew install fzf`
    - Then `$(brew --prefix)/opt/fzf/install` (`/usr/local/opt/fzf/install`) to add `**`-triggered fuzzy completion (this step is easy to miss).
- MacOS has a deficient `xargs` operator, [necessary to install](https://github.com/pickettj/dot_files/issues/5#issuecomment-687909883) `gxargs`: `brew install findutils`

### Git

- [Multi-Git-Status](https://github.com/fboender/multi-git-status/): List status of all repos in a folder.
- [MacOS Gitignore](https://github.com/github/gitignore/blob/master/Global/macOS.gitignore)


### Workflow

- [Alfred](https://www.alfredapp.com/workflows/) (w/ Powerpack)
  - [Curated list of workflows](https://github.com/derimagia/awesome-alfred-workflows)
  - [Zothero](https://github.com/deanishe/zothero): Citation wizard.
  - [Anki](https://github.com/bikenik/alfred-anki)
  - [Advanced Google Maps](http://www.packal.org/workflow/advanced-google-and-apple-maps-search)
    - Extra install: 'brew cask install corelocationcli'
  - [StackExchange Search](https://github.com/deanishe/alfred-stackoverflow)
  - [iTerm integration](https://github.com/stuartcryan/custom-iterm-applescripts-for-alfred)
  - [Calendar](https://github.com/deanishe/alfred-gcal)
- [Pandoc](https://pandoc.org/installing.html) document converter


### Mac OS

- Organize Dock with extra spaces: `defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'; killall`
- Display all dot files in Finder:`defaults write com.apple.Finder AppleShowAllFiles true; killall Finder`

### [Dashboard](https://github.com/pickettj/dot_files/tree/master/Dashboard)

- Relative links transferable between machines: `ln -s ../../../Box`

### Customization Files

- [Brill Typeface](https://brill.com/page/BrillFont/brill-typeface)
- [Customized Keyboards](https://github.com/pickettj/dot_files/tree/master/custom_keyboard_layouts)
  - Setups:
    - English Academic (including diacritical marks for Islamicate langauges);
    - Persianate (Arabic, Persian, Urdu, Uyghur from the same keyboard);
    - Cyrillic (Russian, Tajik, Uzbek, imperial Russian characters).
  - Setup (Mac OS):
    - Copy to `Library/Keyboard Layouts`
    - Keyboard `Preferences > Add` > find in "Others" folder at bottom.
- Zotero:
  - `Pref/Advanced/Shortcuts`: Cmd+Shift+W for citation.
    - Pref/Export must be on Chicago Full Note.
  - Install [Better Bibtex](https://retorque.re/zotero-better-bibtex/installation/) for MarkDown citations.
  - Install [ZotFile](http://zotfile.com/) to control which folder automatic downloads go into.
- [Fuzzy Search](https://github.com/iamlemec/fuzzy)
