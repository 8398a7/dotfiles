function! husq#git#root()
  let response = system('git rev-parse --show-toplevel')
  echomsg v:shell_error
  if v:shell_error == 128
    let result = getcwd()
  else
    let result = substitute(response, "\n", '', 'g')
  end
  return result
endfunction
