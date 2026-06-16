set-cluster() {
  local dirs=() files=() i=1 j=1 sel cluster cfgdir cfg

  for d in "$HOME"/.kube/*; do
    [ -d "$d" ] || continue
    [ "$(basename "$d")" = "cache" ] && continue
    dirs+=("$(basename "$d")")
  done
  [ ${#dirs[@]} -gt 0 ] || { echo "No cluster dirs in ~/.kube"; return 1; }

  echo "Available cluster folders:"
  for cluster in "${dirs[@]}"; do echo "  $i. $cluster"; i=$((i+1)); done
  echo "  $i. Exit"
  read -r -p "Select folder: " sel
  [ "$sel" = "$i" ] && return 0
  [[ "$sel" =~ ^[0-9]+$ ]] || { echo "Invalid"; return 1; }
  [ "$sel" -ge 1 ] && [ "$sel" -lt "$i" ] || { echo "Invalid"; return 1; }

  cluster="${dirs[$((sel-1))]}"
  cfgdir="$HOME/.kube/$cluster"

  while IFS= read -r f; do files+=("$f"); done < <(
    find "$cfgdir" -maxdepth 1 -type f \( -name 'config*' -o -name '*.yaml' -o -name '*.yml' \) | sort
  )
  [ ${#files[@]} -gt 0 ] || { echo "No kubeconfig files in $cfgdir"; return 1; }

  if [ ${#files[@]} -eq 1 ]; then
    cfg="${files[0]}"
  else
    echo "Available kubeconfig files in $cluster:"
    for f in "${files[@]}"; do echo "  $j. $(basename "$f")"; j=$((j+1)); done
    echo "  $j. Exit"
    read -r -p "Select config: " sel
    [ "$sel" = "$j" ] && return 0
    [[ "$sel" =~ ^[0-9]+$ ]] || { echo "Invalid"; return 1; }
    [ "$sel" -ge 1 ] && [ "$sel" -lt "$j" ] || { echo "Invalid"; return 1; }
    cfg="${files[$((sel-1))]}"
  fi

  export KUBECONFIG="$cfg"
  echo "Switched: $cluster -> $KUBECONFIG"
}