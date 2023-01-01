function! noise#utils#PrintError(msg, ...) abort
  let full_msg = "[Noise] " . a:msg

  if a:0 > 0 && a:1
    echoerr full_msg
  else
    echohl ErrorMsg | echomsg full_msg | echohl None
  endif
endfunction
