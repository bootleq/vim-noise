Noise.vim
=========

Make sound response when event happen.

Status: developing, **not stable**

Tested Vim version: `9.0.1062`


Architecture
------------

- Player

  Abstract the underlying way Vim plays sound, try to make it portable.

  Current supported backends:

  - `pactl`: PulseAudio's [pactl][] CLI, it should work on [WSLg][] without manually setup.

- Events

  Define when to play a sound.

  Can target Vim's built-in autocommands ([autocommand-events][]).

  Also provide some autoload functions (only loaded when they were really
  called) to handle special use cases:

  - `ale#all-fixed`: after fix all [ale][] lint issues in current buffer.

- Sounds

  Define available sounds.

  A sound should have an `id`, a `path` to real audio file or system event name (e.g., `event:x11-bell`).


Config example
--------------

In legacy Vim syntax:

```vim
let g:noise_player = 'pactl'

let g:noise_sounds = [
      \   #{name: 'x11 bell', id: 'x11-bell',      path: 'event:x11-bell'},
      \   #{name: 'Power Up', id: 'kunio-powerup', path: '/mnt/c/SE/kunio_mg2_powerup-3.wav'},
      \   #{                  id: 'ikaruga',       path: '/mnt/c/SE/斑鳩_energy_max.aiff'},
      \ ]

let g:noise_events = [
      \   #{name: 'Inserted',      autocmd:  'InsertLeave *', sound_id: 'x11-bell'},
      \   #{name: 'Search wrapped' autocmd:  'User AnzuWrap', sound_id: 'ikaruga'},
      \   #{name: 'ale Cleared',   autoload: 'ale#all-fixed', sound_id: 'kunio-powerup'},
      \ ]
```

- Event `User Anzu` requires [vim-anzu][]
- Event `ale#all-fixed` requires [ale][]


Limitations
-----------

- Currently, doesn't support dynamically reload settings, you have to restart
  Vim to take effect of changed settings.



[pactl]: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/CLI/#pactl
[WSLg]: https://github.com/microsoft/wslg
[autocommand-events]: https://vimhelp.org/autocmd.txt.html#autocommand-events
[vim-anzu]: https://github.com/osyo-manga/vim-anzu
[ale]: https://github.com/dense-analysis/ale
