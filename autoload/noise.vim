vim9script noclear

import autoload './utils.vim'
import autoload './player/pactl.vim'

# autoloads to be triggered in Handler
import autoload './events/ale.vim' as events_ale

var loadedPlayerType: string

var PlayerFunc: func

# Ensure the g:noise_player is available.
# Store the result and backend Play function.
export def LoadPlayer(name: string): bool
  if !empty(loadedPlayerType)
    return true
  endif

  if name == 'pactl'
    if pactl.Load()
      PlayerFunc = pactl.Play
    endif
  endif

  if empty(PlayerFunc)
    utils.PrintError(printf("Can't load player '%s'", name))
    return false
  else
    loadedPlayerType = name
    return true
  endif
enddef

# To export autoload handler functions, e.g.,
#   noise#Handler("events_ale.ALELintPost", %s)
export def Handler(path: string, ...args: list<any>)
  call(path, args)
enddef

def OnPlayError(channel: channel, msg: string)
  utils.PrintError("Error play sound: " .. msg)
enddef

export def Play(sound_id: string)
  if !exists('g:noise_player') || !LoadPlayer(g:noise_player)
    return
  endif

  var soundIndex = get(g:, 'noise_sounds', [])->indexof((_, s) => s.id == sound_id)

  if soundIndex < 0
    utils.PrintError("Unknown sound id: " .. sound_id)
    return
  endif

  var sound = g:noise_sounds[soundIndex]

  PlayerFunc(sound, {err_cb: OnPlayError})
enddef
