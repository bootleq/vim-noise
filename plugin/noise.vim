" # autoloads to be triggered in RegisterAutoloadEvents
" import autoload '../autoload/noise/events/ale.vim'

if exists("g:loaded_noise")
  finish
endif
let g:loaded_noise = 1


let s:ids = {}

function! s:next_id(scope) abort " {{{
  if !has_key(s:ids, a:scope)
    let s:ids[a:scope] = 0
  endif

  let s:ids[a:scope] += 1
  return s:ids[a:scope]
endfunction " }}}


" type Sound dict<?name: string
"                 id: string
"                 path: string>
"
" type Event dict<?name: string
"                 ?autoload: string
"                 ?autocmd: string
"                 sound_id: string>

let events = copy(get(g:, 'noise_events', []))
for e in events
  let e.id = s:next_id('events')
endfor

function! s:FilterByKey(items, key) abort
  return copy(a:items)->filter({_, i -> i->has_key(a:key) && !empty(i[a:key])})
endfunction

" Consume events have {autoload: 'foo#bar'} property,
" find corresponding autoload file (../autoload/noise/events/foo.vim) and call its
" Register function with targeted key (bar).
function! s:RegisterAutoloadEvents(items) abort
  for e in a:items
    let module_and_key = e.autoload->matchlist('\v(\w+)#(.+)')[1 : ]->filter({_, i -> !empty(i)})
    if len(module_and_key) == 2
      let [module, key] = module_and_key
      call call(printf('noise#events#%s#Register', module), [key, e])
    endif
  endfor
endfunction

function! s:RegisterAutocmdEvents(items) abort
  augroup noise_auto
    for e in a:items
      let cmd_name = e.autocmd

      if len(cmd_name->split(' ')) == 1
        let cmd_name = cmd_name . ' *' " default an wild matching |{aupat}|
      endif
      execute printf('autocmd %s call noise#Play(%s, %s)', cmd_name, e.sound_id->shellescape(), e.id)
    endfor
  augroup END
endfunction

augroup noise_auto
  autocmd!
augroup END

call s:RegisterAutocmdEvents(s:FilterByKey(events, 'autocmd'))
call s:RegisterAutoloadEvents(s:FilterByKey(events, 'autoload'))
