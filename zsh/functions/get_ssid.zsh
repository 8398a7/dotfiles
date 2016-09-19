get_ssid() {
  if echo $OSTYPE | grep -q darwin; then
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep " SSID" | awk '{$1="";print}' | sed "s/ //"
  else
    echo ""
  fi
}
