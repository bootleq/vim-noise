vim9script noclear

import autoload '../utils.vim'

export def Load(): bool
  if executable('pactl') && executable('paplay')
    return true
  endif

  return false
enddef

export def Play(sound: dict<any>, job_options: dict<any>): any
  var event_sound_name = sound.path->match('^event:') > -1 ? sound.path->strpart(len('event:')) : ''

  if !empty(event_sound_name)
    return job_start(['pactl', 'play-sample', event_sound_name], job_options)
  endif

  return job_start(['paplay', sound.path], job_options)
enddef
