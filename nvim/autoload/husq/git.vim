function! husq#git#root()
  let response = system('git rev-parse --show-toplevel')
  if v:shell_error == 128
    let result = getcwd()
  else
    let result = substitute(response, "\n", '', 'g')
  end
  return result
endfunction
