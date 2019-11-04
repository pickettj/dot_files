# Dot Files

Misc. personal customization files. ([Example system](https://github.com/iamlemec/dotfiles).)

Coordinate between machines by symlinking the files to the right place, e.g. `ln -s dotfiles/.bash_profile .bash_profile`

## Customizing Checklist

- Zsh
  - [Installation walkthrough](https://www.freecodecamp.org/news/how-to-configure-your-macos-terminal-with-zsh-like-a-pro-c0ab3f3c1156/)
  - oh-my-zsh is an essential configuration manager for Zsh, should be installed at the same time.
    - oh-my-zsh controls [themes](https://github.com/robbyrussell/oh-my-zsh/wiki/themes) and [aliases](https://github.com/robbyrussell/oh-my-zsh/wiki/Cheatsheet)
  - Zsh has a configuration file (`.zshrc`), which controls shell configuration and aliases, more or less equivalent to the `bash_profile`. It also has ``.zshenv`,  which sets various environment variables.  
    - ([Lengthy explanation](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout) of the difference between the two kinds of dot files.)

- [Brill Typeface](https://brill.com/page/BrillFont/brill-typeface)
- Customized Keyboards
  - Setups:
    - English Academic (including diacritical marks for Islamicate langauges);
    - Persianate (Arabic, Persian, Urdu, Uyghur from the same keyboard);
    - Cyrillic (Russian, Tajik, Uzbek, imperial Russian characters).
  - Setup (Mac OS):
    - Copy to `Library/Keyboard Layouts`
    - Keyboard Preferences > Add > find in "Others" folder at bottom.
