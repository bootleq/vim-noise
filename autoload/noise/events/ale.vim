vim9script noclear

import autoload '../utils.vim'

const module_name = 'ale'

export def ALELintPost(sound_id: string)
  var count = ale#statusline#Count(bufnr('%')).total
  # unsilent echomsg 'LintPost ' .. string(count)

  if count > 0
    b:noise_ale_dirty = count
  else
    if get(b:, 'noise_ale_dirty', 0) > 0
      noise#Play(sound_id)
      remove(b:, 'noise_ale_dirty')
    endif
  endif
enddef

export def Register(key: string, event: dict<any>): void
  var sound_id: string = event.sound_id

  if key == 'all-fixed'
    augroup noise_auto
      execute printf('autocmd User ALELintPost noise#Handler("events_ale.ALELintPost", %s)', sound_id->shellescape())
    augroup END
  else
    utils.PrintError(printf("Unknown event in %s module: '%s'", module_name, key))
  endif
enddef
