vim9script noclear

import autoload '../utils.vim'

var player = 'pactl'

export def Load(): bool
  return executable(player) == 1
enddef

export def Play(sound: dict<any>): any
  var event_sound_name = sound.path->match('^event:') > -1 ? sound.path->strpart(len('event:')) : ''

  if !empty(event_sound_name)
    return job_start([player, 'play-sample', event_sound_name])
  endif

  # upload-sample every time, because WSLg seems reset samples periodically
  system(
    printf(
      '%s upload-sample %s %s',
      player,
      shellescape(sound.path),
      shellescape(sound.id)
    )
  )
  if v:shell_error
    utils.PrintError(
      printf(
        "Fail loading sound: '%s'%s",
        sound.id,
        has_key(sound, 'name') ? printf(' (name: %s)', sound.name) : ''
      )
    )
    return null
  endif

  return job_start([player, 'play-sample', sound.id])
enddef
