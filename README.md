Noise.vim
=========

Make sound response when event happen.


Tested Vim versions:

- Vim `9.0.1062`
- NVIM `v0.8.2`


Architecture
------------

- Player

  Abstract the underlying way Vim plays sound, try to make it portable.

  Current supported backends:

  - `pulseaudio`: Use PulseAudio's `pactl` and `paplay` [CLI utils][pulseaudio-cli], this should work on [WSLg][] with simply `apt-get install pulseaudio-utils`.
  - `afplay`: Use macOS' `afplay` utility.
  - `vimsound`: Use Vim's sound functions, e.g., `sound_playfile()`.

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
let g:noise_player = 'pulseaudio'

let g:noise_sounds = [
      \   #{name: 'x11 bell', id: 'x11-bell',      path: 'event:x11-bell'},
      \   #{name: 'Power Up', id: 'kunio-powerup', path: '/mnt/c/SE/kunio_mg2_powerup-3.wav'},
      \   #{                  id: 'ikaruga',       path: '/mnt/c/SE/斑鳩_energy_max.aiff'},
      \ ]

let g:noise_events = [
      \   #{name: 'Inserted',      autocmd:  'InsertLeave *', sound_id: 'x11-bell'},
      \   #{name: 'SearchWrapped'  autocmd:  'SearchWrapped', sound_id: 'ikaruga'},
      \   #{name: 'Search wrapped' autocmd:  'User AnzuWrap', sound_id: 'ikaruga'},
      \   #{name: 'ale Cleared',   autoload: 'ale#all-fixed', sound_id: 'kunio-powerup'},
      \ ]

let g:noise_throttle_timeout = 140  " default is 200
let g:noise_player_args      = ['--latency-msec=200']
```

- Event `User AnzuWrap` requires [vim-anzu][]
- Event `ale#all-fixed` requires [ale][]


Functions
---------

- `noise#Play({id}[, event_id])`

  Examples:

  `call noise#Play('some-id')` (`some-id` must be a key in `g:noise_sounds` dictionary)
  `call noise#Play('file:/mnt/c/SE/foo.mp3')`
  `call noise#Play('event:x11-bell')`


Limitations
-----------

- Currently, doesn't support dynamically reload settings, you have to restart
  Vim to take effect of changed settings.


Development
-----------

### Test

Run the test script, will clone [vim-themis][] and execute it.

```sh
./test/run.sh
```


[pulseaudio-cli]: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/CLI/
[WSLg]: https://github.com/microsoft/wslg
[autocommand-events]: https://vimhelp.org/autocmd.txt.html#autocommand-events
[vim-anzu]: https://github.com/osyo-manga/vim-anzu
[ale]: https://github.com/dense-analysis/ale
[vim-themis]: https://github.com/thinca/vim-themis
