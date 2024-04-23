#!/bin/bash

#set -x

afficher_informations_utilisateur() {
    utilisateur=$1

    prenom=$(getent passwd "$utilisateur" | cut -d: -f5 | cut -d' ' -f1)
    nom=$(getent passwd "$utilisateur" | cut -d: -f5 | cut -d' ' -f2)
    login="$utilisateur$utilisateur"
    groupe_primaire=$(id -gn "$utilisateur")
    groupes_secondaires=$(id -Gn "$utilisateur" | sed "s/$groupe_primaire//;s/ $//")
    repertoire=$(du -sh "/home/$utilisateur" | cut -f1)
    sudoer=$(if sudo grep -q "^$utilisateur" /etc/sudoers /etc/sudoers.d/* 2>/dev/null ; then echo "OUI"; else echo "NON"; fi)
   
    echo "+--------------------"
    echo "Utilisateur : $login"
    echo "Prénom : $prenom"
    echo "Nom : $nom"
    echo "Groupe primaire : $groupe_primaire"
    echo "Groupes secondaires : $groupes_secondaires"
    echo "Répertoire personnel : $repertoire"
    echo "Sudoer : $sudoer"
    echo ""
}

groupe=""
groupe_secondaire=""
sudoer=""

while getopts ":G:g:s:u:" option; do
    case $option in
        G) groupe="$OPTARG";;
        g) groupe_secondaire="$OPTARG";;
        s)
            if [ "$OPTARG" = "0" ]; then
                sudoer="NON"
            elif [ "$OPTARG" = "1" ]; then
                sudoer="OUI"
            else
                echo "Valeur invalide pour l'option -s. Utilisez 0 ou 1." >&2
                exit 1
            fi
            ;;
        u) afficher_informations_utilisateur "$OPTARG"; exit;;
        \?) echo "Option invalide: -$OPTARG" >&2; exit 1;;
        :) echo "L'option -$OPTARG requiert un argument." >&2; exit 1;;
    esac
done

while IFS=: read -r utilisateur _ _ _ _ _ _; do
    if [ "$(id -u "$utilisateur")" -ge 1000 ]; then
        if [ -n "$groupe" ] && [ "$groupe" != "$(id -gn "$utilisateur")" ]; then
            continue
        fi
        if [ -n "$groupe_secondaire" ] && ! id -Gn "$utilisateur" | grep -q "$groupe_secondaire"; then
            continue
        fi
        
        if [ "$sudoer" = "OUI" ]; then
            if sudo grep -q "^$utilisateur" /etc/sudoers /etc/sudoers.d/* 2>/dev/null || sudo find /etc/sudoers /etc/sudoers.d/* -type f -exec grep -q "^(ALL) ALL.*$utilisateur" {} +; then
        afficher_informations_utilisateur "$utilisateur"
        fi
            elif [ "$sudoer" = "NON" ]; then
                if ! sudo grep -q "^$utilisateur" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
                    afficher_informations_utilisateur "$utilisateur"
                fi
            fi

        fi
done < /etc/passwd

if [ $OPTIND -eq 1 ]; then
    while IFS=: read -r utilisateur _ _ _ _ _ _; do
        if [ "$(id -u "$utilisateur")" -ge 1000 ]; then
            afficher_informations_utilisateur "$utilisateur"
        fi
    done < /etc/passwd
fi
