" import autoload '../utils.vim'

function! noise#player#pulseaudio#Load() abort
  if executable('pactl') && executable('paplay')
    return v:true
  endif

  return v:false
endfunction

function! noise#player#pulseaudio#Play(sound, job_options) abort
  let event_sound_name = a:sound.path->match('^event:') > -1 ? a:sound.path->strpart(len('event:')) : ''

  if !empty(event_sound_name)
    return job_start(['pactl', 'play-sample', event_sound_name], a:job_options)
  endif

  return job_start(['paplay', a:sound.path], a:job_options)
endfunction
