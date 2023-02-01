" import autoload '../utils.vim'

let s:module_name = 'ale'

function! noise#events#ale#ALELintPost(sound_id, event_id) abort
  let l:count = ale#statusline#Count(bufnr('%')).total
  " unsilent echomsg 'LintPost ' .. string(count)

  if l:count > 0
    let b:noise_ale_dirty = l:count
  else
    if get(b:, 'noise_ale_dirty', 0) > 0
      call noise#Play(a:sound_id, a:event_id)
      call remove(b:, 'noise_ale_dirty')
    endif
  endif
endfunction

function! noise#events#ale#Register(key, event) abort
  let sound_id = a:event.sound_id

  if a:key == 'all-fixed'
    augroup noise_auto
      execute printf('autocmd User ALELintPost call noise#Handler("noise#events#ale#ALELintPost", %s, %s)',
            \  sound_id->shellescape(),
            \  a:event['id']
            \)
    augroup END
  else
    call noise#utils#PrintError(printf("Unknown event in %s module: '%s'", s:module_name, a:key))
  endif
endfunction
