" import autoload '../utils.vim'

function! noise#player#vimsound#Load() abort
  if has('sound') && exists('*sound_playfile')
    return v:true
  endif

  return v:false
endfunction

function! s:Callback(id, status) abort
  if a:status > 1
    call noise#utils#PrintError('Error play sound.')
  endif
endfunction

function! noise#player#vimsound#Play(sound, job_options) abort
  let event_sound_name = a:sound.path->match('^event:') > -1 ? a:sound.path->strpart(len('event:')) : ''
  let played_id = -1

  if !empty(event_sound_name)
    let played_id = sound_playevent(event_sound_name, function('s:Callback'))
  else
    let played_id = sound_playfile(a:sound.path, function('s:Callback'))
  endif

  if played_id == 0
    call noise#utils#PrintError('Error play sound.')
  endif
endfunction
