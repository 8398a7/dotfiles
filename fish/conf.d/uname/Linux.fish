set -x GOPATH /usr/local/go
if [ -d $GOPATH/bin ]
  set -x PATH $GOPATH/bin $PATH
end
