" import autoload '../utils.vim'

function! noise#player#afplay#Load() abort
  if executable('afplay')
    return v:true
  endif

  return v:false
endfunction

function! s:JobStart(cmd, options) abort
  if exists('*job_start')
    return job_start(a:cmd, a:options)
  elseif exists('*jobstart') " neovim
    let options = deepcopy(a:options)
    if has_key(options, 'err_cb')
      let options['on_stderr'] = options.err_cb
      let options['stderr_buffered'] = v:true
      unlet options.err_cb
    endif
    return jobstart(a:cmd, options)
  endif
endfunction

function! noise#player#afplay#Play(sound, job_options) abort
  let event_sound_name = a:sound.path->match('^event:') > -1 ? a:sound.path->strpart(len('event:')) : ''

  if !empty(event_sound_name)
    call noise#utils#PrintError("Player afplay doesn't support event sounds.")
    return
  endif

  let args = get(g:, 'noise_player_args', [])
  return s:JobStart(['afplay'] + args + [a:sound.path], a:job_options)
endfunction
