vim9script noclear

# autoloads to be triggered in RegisterAutoloadEvents
import autoload '../autoload/events/ale.vim'

if exists("g:loaded_noise")
  finish
endif
g:loaded_noise = 1

# type Sound dict<?name: string
#                 id: string
#                 path: string>
#
# type Event dict<?name: string
#                 ?autoload: string
#                 ?autocmd: string
#                 sound_id: string>

var events = copy(get(g:, 'noise_events', []))


def FilterByKey(items: list<dict<any>>, key: string): list<any>
  return copy(items)->filter((_, i) => i->has_key(key) && !empty(i[key]))
enddef

# Consume events have {autoload: 'foo#bar'} property,
# find corresponding autoload file (../autoload/events/foo.vim) and call its
# Register function with targeted key (bar).
def RegisterAutoloadEvents(items: list<dict<any>>)
  for e in items
    var module_and_key = e.autoload->matchlist('\v(\w+)#(.+)')[1 : ]->filter((_, i) => !empty(i))
    if len(module_and_key) == 2
      var [module, key] = module_and_key
      call(printf('%s.Register', module), [key, e])
    endif
  endfor
enddef

def RegisterAutocmdEvents(items: list<dict<any>>)
  augroup noise_auto
    for e in items
      execute printf('autocmd %s noise#Play(%s)', e.autocmd, e.sound_id->shellescape())
    endfor
  augroup END
enddef

augroup noise_auto
  autocmd!
augroup END

RegisterAutocmdEvents(FilterByKey(events, 'autocmd'))
RegisterAutoloadEvents(FilterByKey(events, 'autoload'))
