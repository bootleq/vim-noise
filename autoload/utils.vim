vim9script noclear

export def PrintError(msg: string, raise: bool = false)
  var full_msg = "[Noise] " .. msg

  if raise
    echoerr full_msg
  else
    echohl ErrorMsg | echomsg full_msg | echohl None
  endif
enddef
