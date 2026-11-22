#!/bin/bash
# upgrade.sh — Mise à jour du Raspberry Pi « pi-wifi » protégé par overlay (carte SD en lecture seule).
#
# Enchaîne, avec les redémarrages nécessaires et sans intervention :
#   1. désactivation de l'overlay (si actif)                      → redémarrage
#   2. /boot/firmware en écriture, apt update + full-upgrade,
#      autoremove, clean                                          → redémarrage si nouveau noyau
#   3. (si nouveau noyau) retrait de l'ancien noyau v6 et des dossiers de modules orphelins
#   4. réactivation de l'overlay + /boot/firmware en lecture seule → redémarrage
#
# La reprise après chaque redémarrage est faite par le service systemd « upgrade-pi.service »,
# qui ne s'exécute que si le fichier d'état /boot/firmware/upgrade-pi.etat existe.
#
# Utilisation (en root) :
#   upgrade-pi installer   copie le script dans /usr/local/sbin et installe le service (protection désactivée)
#   upgrade-pi             lance la mise à jour complète
#   upgrade-pi statut      affiche l'état de la protection et d'une mise à jour en cours
#   upgrade-pi reprendre   reprend une mise à jour interrompue (après correction d'une erreur)
#   upgrade-pi abandonner  supprime l'état en cours, réactive la protection et redémarre
#   upgrade-pi deproteger  désactive la protection (overlay + /boot/firmware), redémarre ; suite automatique
#   upgrade-pi proteger    réactive la protection et redémarre (sans mise à jour)
#
# Journal : /var/log/upgrade-pi.log (conservé, car écrit pendant les étapes sans overlay)
#           et journalctl -u upgrade-pi

set -Eeuo pipefail

NOM=upgrade-pi
CIBLE=/usr/local/sbin/$NOM
SERVICE=/etc/systemd/system/$NOM.service
BOOT=/boot/firmware
ETAT=$BOOT/$NOM.etat
LOG=/var/log/$NOM.log
VERROU=/run/$NOM.lock
ESPACE_MIN_MO=250

log() { echo "$(date '+%F %T') [$NOM] $*" | tee -a "$LOG" >&2; }
die() {
  log "ERREUR : $*"
  # une mise à jour en cours passe en état « erreur » : pas de reprise automatique en boucle
  if [ -f "$ETAT" ] && [ "$(tr -d '[:space:]' < "$ETAT")" != "erreur" ]; then
    { mount -o remount,rw "$BOOT" 2>/dev/null || true; echo erreur > "$ETAT"; sync; } || true
    log "état → erreur. Corriger puis : sudo $NOM reprendre   (ou : sudo $NOM abandonner)"
  fi
  exit 1
}

[ "$(id -u)" -eq 0 ] || { echo "À lancer avec sudo : sudo $0 ${*:-}" >&2; exit 1; }

overlay_actif()      { grep -q "overlayroot=tmpfs" /proc/cmdline; }
boot_ro_maintenant() { findmnt -no OPTIONS "$BOOT" | grep -qE '(^|,)ro(,|$)'; }

boot_rw() {
  if boot_ro_maintenant; then
    mount -o remount,rw "$BOOT" || die "impossible de remonter $BOOT en écriture"
  fi
}

lire_etat()  { if [ -f "$ETAT" ]; then tr -d '[:space:]' < "$ETAT"; fi; }
ecrire_etat() { boot_rw; echo "$1" > "$ETAT"; sync; log "état → $1"; }
effacer_etat() { boot_rw; rm -f "$ETAT"; sync; log "état effacé"; }

redemarrer() {
  log "redémarrage ($1)"
  sync
  sleep 3
  systemctl reboot
  exit 0
}

# En cas d'erreur pendant une étape : on note l'erreur, on ne redémarre pas,
# la protection reste désactivée pour pouvoir corriger.
on_error() {
  local code=$?
  log "ERREUR (code $code) à la ligne $1. Protection laissée désactivée."
  log "Corriger puis lancer : sudo $NOM reprendre   (ou : sudo $NOM abandonner)"
  if [ -f "$ETAT" ] && [ "$(lire_etat)" != "erreur" ]; then
    { mount -o remount,rw "$BOOT" 2>/dev/null || true; echo erreur > "$ETAT"; sync; } || true
  fi
  exit "$code"
}

attendre_reseau() {
  local i
  for i in $(seq 1 20); do
    if apt-get update -q; then return 0; fi
    log "apt-get update a échoué (tentative $i/20), nouvel essai dans 30 s"
    sleep 30
  done
  die "pas de réseau ou dépôts injoignables"
}

noyau_v6_le_plus_recent() {
  dpkg-query -W -f='${db:Status-Abbrev} ${Package}\n' 'linux-image-*-rpi-v6' 2>/dev/null \
    | awk '$1=="ii"{print $2}' | grep -v '^linux-image-rpi-v6$' \
    | sed 's/^linux-image-//' | sort -V | tail -1 || true
}

APT_OPTS=(-y -q -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)
export DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------- étapes

etape_desactiver_overlay() {
  log "étape 1 : désactivation de l'overlay"
  ecrire_etat mise-a-jour
  raspi-config nonint do_overlayfs 1
  if grep -q "overlayroot=tmpfs" "$BOOT/cmdline.txt"; then die "overlayroot toujours présent dans cmdline.txt"; fi
  redemarrer "pour démarrer sans overlay"
}

etape_mise_a_jour() {
  log "étape 2 : mise à jour (noyau en service : $(uname -r))"
  if overlay_actif; then die "l'overlay est encore actif, mise à jour impossible"; fi
  ecrire_etat mise-a-jour
  # /boot/firmware modifiable durablement (fstab) et tout de suite (remount)
  raspi-config nonint do_overlayfs 1
  boot_rw

  local libre
  libre=$(df -Pm / | awk 'NR==2{print $4}')
  log "espace libre avant : ${libre} Mo"
  if [ "$libre" -lt "$ESPACE_MIN_MO" ]; then
    apt-get clean
    libre=$(df -Pm / | awk 'NR==2{print $4}')
    if [ "$libre" -lt "$ESPACE_MIN_MO" ]; then die "seulement ${libre} Mo libres (minimum ${ESPACE_MIN_MO} Mo)"; fi
  fi

  attendre_reseau
  apt-get full-upgrade "${APT_OPTS[@]}"
  apt-get autoremove --purge "${APT_OPTS[@]}"
  apt-get clean
  log "espace libre après : $(df -Pm / | awk 'NR==2{print $4}') Mo"

  local recent
  recent=$(noyau_v6_le_plus_recent)
  if [ -n "$recent" ] && [ "$recent" != "$(uname -r)" ]; then
    log "nouveau noyau installé : $recent (en service : $(uname -r))"
    ecrire_etat nettoyage-noyau
    redemarrer "pour passer sur le noyau $recent"
  fi
  etape_reactiver
}

etape_nettoyage_noyau() {
  log "étape 3 : retrait des anciens noyaux (en service : $(uname -r))"
  if overlay_actif; then die "l'overlay est actif, nettoyage impossible"; fi
  boot_rw
  local garder a_retirer d v
  garder="linux-image-$(uname -r)"
  a_retirer=$(dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' 'linux-image-*' \
    | awk '$1=="ii"{print $2}' \
    | grep -v -e "^${garder}\$" -e '^linux-image-rpi-v6$' || true)
  if [ -n "$a_retirer" ]; then
    log "paquets retirés : $(echo $a_retirer)"
    # garde-fou : jamais le noyau en service ni le méta-paquet v6
    if echo "$a_retirer" | grep -qx -e "$garder" -e 'linux-image-rpi-v6'; then die "liste de retrait incorrecte"; fi
    # shellcheck disable=SC2086
    apt-get purge "${APT_OPTS[@]}" $a_retirer
  else
    log "aucun ancien noyau à retirer"
  fi
  for d in /lib/modules/*; do
    [ -d "$d" ] || continue
    v=$(basename "$d")
    [ "$v" = "$(uname -r)" ] && continue
    if ! dpkg -s "linux-image-$v" >/dev/null 2>&1 && ! dpkg -s "linux-image-$v:arm64" >/dev/null 2>&1; then
      log "dossier de modules orphelin supprimé : $d"
      rm -rf -- "$d"
    fi
  done
  apt-get autoremove --purge "${APT_OPTS[@]}"
  apt-get clean
  log "espace libre : $(df -Pm / | awk 'NR==2{print $4}') Mo"
  etape_reactiver
}

etape_reactiver() {
  log "étape 4 : réactivation de la protection (overlay + $BOOT en lecture seule)"
  effacer_etat
  raspi-config nonint do_overlayfs 0
  grep -q "overlayroot=tmpfs" "$BOOT/cmdline.txt" || die "overlayroot absent de cmdline.txt après activation"
  log "${1:-mise à jour terminée}"
  redemarrer "pour activer la protection"
}

# ---------------------------------------------------------------- commandes

aide_desactiver() {
  cat >&2 <<EOF
Pour désactiver la protection :
  - si la commande est disponible :   sudo $NOM deproteger
    (le Pi redémarre ; attendre environ 3 min puis se reconnecter)
  - sinon, à la main :
      sudo raspi-config nonint do_overlayfs 1
      sudo reboot
    puis, après redémarrage :
      sudo raspi-config nonint do_overlayfs 1
      sudo mount -o remount,rw $BOOT
Pour la réactiver ensuite :           sudo $NOM proteger
  (ou : sudo raspi-config nonint do_overlayfs 0 && sudo reboot)
EOF
}

cmd_installer() {
  if overlay_actif; then
    aide_desactiver
    die "l'overlay est actif : l'installation serait perdue au redémarrage. Désactivez d'abord la protection (voir ci-dessus), puis relancez : sudo bash $0 installer"
  fi
  install -m 0755 "$(readlink -f "$0")" "$CIBLE"
  cat > "$SERVICE" <<EOF
[Unit]
Description=Reprise de la mise à jour du Pi après redémarrage ($NOM)
Wants=network-online.target
After=network-online.target NetworkManager-wait-online.service
ConditionPathExists=$ETAT

[Service]
Type=oneshot
ExecStart=$CIBLE reprendre
TimeoutStartSec=infinity
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable "$NOM.service"
  log "installé : $CIBLE et $SERVICE (activé)"
}

cmd_statut() {
  if overlay_actif; then echo "Overlay          : ACTIF (modifications perdues au redémarrage)"
  else echo "Overlay          : inactif (modifications conservées)"; fi
  if grep -q "overlayroot=tmpfs" "$BOOT/cmdline.txt"; then echo "Overlay prévu    : oui, au prochain démarrage"
  else echo "Overlay prévu    : non"; fi
  if boot_ro_maintenant; then echo "$BOOT : lecture seule"; else echo "$BOOT : écriture"; fi
  echo "Noyau en service : $(uname -r)"
  if overlay_actif && mountpoint -q /media/root-ro; then
    echo "Espace carte SD  : $(df -Pm /media/root-ro | awk 'NR==2{print $4}') Mo libres (partition protégée, /media/root-ro)"
    echo "Espace en RAM    : $(df -Pm / | awk 'NR==2{print $4}') Mo libres pour les écritures temporaires (perdues au redémarrage)"
  else
    echo "Espace libre /   : $(df -Pm / | awk 'NR==2{print $4}') Mo"
  fi
  local e; e=$(lire_etat)
  echo "Mise à jour      : ${e:-aucune en cours}"
  if [ -x "$CIBLE" ] && systemctl is-enabled -q "$NOM.service" 2>/dev/null; then
    echo "Service reprise  : installé"
  else
    echo "Service reprise  : NON installé (sudo $0 installer, protection désactivée)"
  fi
}

cmd_lancer() {
  [ -x "$CIBLE" ] && systemctl is-enabled -q "$NOM.service" 2>/dev/null \
    || die "service de reprise non installé : lancez d'abord « sudo $0 installer » (protection désactivée)"
  local e; e=$(lire_etat)
  if [ -n "$e" ]; then die "une mise à jour est déjà en cours (état : $e). Voir : sudo $NOM statut"; fi
  log "début de la mise à jour"
  if overlay_actif; then
    echo "Le Pi va redémarrer plusieurs fois (20 à 90 min au total sur un Pi 1)."
    echo "La suite est automatique. Suivi : sudo $NOM statut, ou le journal $LOG une fois l'overlay retiré."
    etape_desactiver_overlay
  else
    etape_mise_a_jour
  fi
}

cmd_reprendre() {
  local e; e=$(lire_etat)
  case "$e" in
    "")               log "aucune mise à jour en cours"; exit 0 ;;
    mise-a-jour)      etape_mise_a_jour ;;
    nettoyage-noyau)  etape_nettoyage_noyau ;;
    deprotection)     etape_deprotection_fin ;;
    erreur)
      if [ "${INVOCATION_ID:-}" != "" ]; then
        log "mise à jour en erreur : rien fait au démarrage (sudo $NOM reprendre ou abandonner)"
        exit 0
      fi
      log "reprise manuelle après erreur"
      etape_mise_a_jour ;;
    *)                die "état inconnu : $e" ;;
  esac
}

cmd_deproteger() {
  local e; e=$(lire_etat)
  if [ -n "$e" ]; then die "une mise à jour est en cours (état : $e). Voir : sudo $NOM statut"; fi
  if overlay_actif; then
    [ -x "$CIBLE" ] && systemctl is-enabled -q "$NOM.service" 2>/dev/null \
      || die "service de reprise non installé ; désactivation manuelle : voir sudo $NOM aide"
    log "désactivation de la protection (2 étapes, 1 redémarrage)"
    echo "Le Pi va redémarrer ; la protection sera entièrement désactivée environ 3 min plus tard."
    echo "Ensuite : modifications conservées. Pour réactiver : sudo $NOM proteger"
    ecrire_etat deprotection
    raspi-config nonint do_overlayfs 1
    redemarrer "pour démarrer sans overlay"
  fi
  etape_deprotection_fin
}

etape_deprotection_fin() {
  if overlay_actif; then die "l'overlay est encore actif"; fi
  raspi-config nonint do_overlayfs 1
  boot_rw
  if [ -f "$ETAT" ]; then effacer_etat; fi
  log "protection désactivée : modifications conservées, $BOOT en écriture. Pour réactiver : sudo $NOM proteger"
}

cmd_proteger() {
  local e; e=$(lire_etat)
  if [ -n "$e" ]; then die "une mise à jour est en cours (état : $e). Voir : sudo $NOM statut"; fi
  if overlay_actif; then log "protection déjà active"; exit 0; fi
  etape_reactiver "protection programmée"
}

cmd_abandonner() {
  log "abandon de la mise à jour"
  if overlay_actif; then effacer_etat; log "overlay déjà actif, rien d'autre à faire"; exit 0; fi
  etape_reactiver
}

exec 9>"$VERROU"
flock -n 9 || { echo "$NOM est déjà en cours d'exécution." >&2; exit 1; }
trap 'on_error $LINENO' ERR

case "${1:-}" in
  "")          cmd_lancer ;;
  installer)   cmd_installer ;;
  statut)      cmd_statut ;;
  reprendre)   cmd_reprendre ;;
  abandonner)  cmd_abandonner ;;
  deproteger)  cmd_deproteger ;;
  proteger)    cmd_proteger ;;
  -h|--help|aide) awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' "$0"; echo; aide_desactiver ;;
  *)           echo "Commande inconnue : $1 (installer | statut | reprendre | abandonner | deproteger | proteger | aide)" >&2; exit 1 ;;
esac
