function! husq#git#root()
  let response = system('git rev-parse --show-toplevel')
  let result = substitute(response, "\n", '', 'g')
  return result
endfunction
