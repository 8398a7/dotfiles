pssh() {
  local ns=$KUBE_PS1_NAMESPACE
  if [ -n "$1" ]; then
    ns=$1
  fi
  local cmd="/bin/sh"
  if [ -n "$2" ]; then
    cmd=$2
  fi
  local res=$(kubectl get po -n $ns | sed '1d' | fzf)
  if [ -n "$res" ]; then
    local pod_name=$(echo $res | cut -d' ' -f1)
    _peco_insert_command "kubectl exec -it -n $ns $pod_name $cmd"
  fi
}
