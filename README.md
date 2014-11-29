# pelican-mode.el

[Pelican](http://getpelican.com) static site generator mode for emacs

## Dependencies

+ [S](https://github.com/magnars/s.el)

## installation

Download `pelican-mode.el` and add the following to your init file:

```lisp
(add-to-list 'load-path "/path/to/pelican-mode.el")
(require 'pelican-mode)
```

## Keybinding suggestions

```lisp
(eval-after-load 'pelican-mode
  '(define-key ruby-mode-map (kbd "C-c = d") 'pelican-new-post-draft)))
(eval-after-load 'pelican-mode
  '(define-key ruby-mode-map (kbd "C-c = c") 'pelican-open-conf)))
```

## License [GPLv3](http://www.gnu.org/copyleft/gpl.html)

Copyright (C) 2014 Marcwebbie

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
