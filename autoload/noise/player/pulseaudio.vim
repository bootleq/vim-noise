" import autoload '../utils.vim'

function! noise#player#pulseaudio#Load() abort
  if executable('pactl') && executable('paplay')
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

function! noise#player#pulseaudio#Play(sound, job_options) abort
  let event_sound_name = a:sound.path->match('^event:') > -1 ? a:sound.path->strpart(len('event:')) : ''

  if !empty(event_sound_name)
    return s:JobStart(['pactl', 'play-sample', event_sound_name], a:job_options)
  endif

  let args = get(g:, 'noise_player_args', ['--latency-msec=200'])
  return s:JobStart(['paplay'] + args + [a:sound.path], a:job_options)
endfunction
