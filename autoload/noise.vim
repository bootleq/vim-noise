" import autoload './noise/utils.vim'
" import autoload './noise/player/pulseaudio.vim'

" # autoloads to be triggered in Handler
" import autoload './noise/events/ale.vim' as events_ale

let s:loadedPlayerType = ''

let s:PlayerFunc = v:null
let s:timers = {} " stores throttle timer per event id

" Ensure the g:noise_player is available.
" Store the result and backend Play function.
function! s:LoadPlayer(name) abort
  if !empty(s:loadedPlayerType)
    return v:true
  endif

  if !empty(a:name)
    try
      " e.g., call noise#player#pulseaudio#Load() to get noise#player#pulseaudio#Play()
      let prefix = printf('noise#player#%s', substitute(a:name, '\W', '_', 'g'))
      if call(prefix . '#Load', [])
        let s:PlayerFunc = function(prefix . '#Play')
      endif
    endtry
  endif

  if empty(s:PlayerFunc)
    call noise#utils#PrintError(printf("Can't load player '%s'", a:name))
    return v:false
  else
    let s:loadedPlayerType = a:name
    return v:true
  endif
endfunction

" To export autoload handler functions, e.g.,
"   noise#Handler("events_ale.ALELintPost", %s)
function! noise#Handler(path, ...) abort
  call call(a:path, a:000)
endfunction

function! s:OnPlayError(channel, msg, ...) abort
  let msg = a:msg

  if type(msg) == type([]) " neovim
    let msg = join(msg, '')
  endif

  if !empty(msg)
    call noise#utils#PrintError("Error play sound: " . msg)
  endif
endfunction

function! s:findBy(items, fn) abort
  for i in a:items
    if a:fn(i)
      return i
    endif
  endfor
endfunction

function! s:remove_timer(event_id, id) abort " {{{
  call timer_stop(a:id)
  if has_key(s:timers, a:event_id)
    call remove(s:timers, a:event_id)
  endif
endfunction " }}}

function! noise#Play(sound_id, ...) abort
  let event_id = a:1
  let throttle_timeout = get(g:, 'noise_throttle_timeout', 200)

  if !exists('g:noise_player') || !s:LoadPlayer(g:noise_player)
    return
  endif

  if has_key(s:timers, event_id)
    return
  else
    let s:timers[event_id] = timer_start(throttle_timeout, function('s:remove_timer', [event_id]))
  endif

  let sound = s:findBy(get(g:, 'noise_sounds', []), {s -> s.id == a:sound_id})

  if empty(sound)
    call noise#utils#PrintError("Unknown sound id: " . a:sound_id)
    return
  endif

  call s:PlayerFunc(sound, #{err_cb: function('s:OnPlayError')})
endfunction
