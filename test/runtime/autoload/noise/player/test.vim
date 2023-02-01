function! noise#player#test#Load() abort
  return v:true
endfunction

function! noise#player#test#Play(sound, job_options) abort
  call add(g:noise_test_played, #{sound: a:sound, job: a:job_options})
endfunction
