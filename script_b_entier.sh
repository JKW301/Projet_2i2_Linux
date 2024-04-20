#!/bin/bash

# Fonction pour afficher les informations d'un utilisateur
afficher_informations_utilisateur() {
    utilisateur=$1

    # Récupération des informations sur l'utilisateur
    prenom=$(getent passwd "$utilisateur" | cut -d: -f5 | cut -d' ' -f1)
    nom=$(getent passwd "$utilisateur" | cut -d: -f5 | cut -d' ' -f2)
    login="$utilisateur$utilisateur"
    groupe_primaire=$(id -gn "$utilisateur")
    groupes_secondaires=$(id -Gn "$utilisateur" | sed "s/$groupe_primaire//;s/ $//")
    repertoire=$(du -sb "/home/$utilisateur" 2>/dev/null | cut -f1)

    # Formatage de la taille du répertoire
    formatted_output=()
    while [[ ${#repertoire} -gt 3 ]]; do
        part="${repertoire: -3}" # On prend les trois derniers chiffres
        repertoire="${repertoire%???}" # On supprime les trois derniers caractères
        formatted_output=(" $part" "${formatted_output[@]}") # On ajoute ces trois chiffres au début du tableau
    done

    # Ajout de la taille restante si elle est inférieure à 1000 octets
    if [[ ${#repertoire} -gt 0 ]]; then
        formatted_output=(" $repertoire" "${formatted_output[@]}")
    fi

    # Affichage de la taille sous forme de séries de trois chiffres sur une seule ligne
    taille_repertoire=""
    for index in "${!formatted_output[@]}"; do
        case $index in
            0)
                taille_repertoire+=" ${formatted_output[$index]} Mo"
                ;;
            1)
                taille_repertoire+=" ${formatted_output[$index]} Ko"
                ;;
            2)
                taille_repertoire+=" ${formatted_output[$index]} octets"
                ;;
        esac
    done

    sudoer=$(if sudo grep -q "^$utilisateur" /etc/sudoers /etc/sudoers.d/* 2>/dev/null ; then echo "OUI"; else echo "NON"; fi)

    # Affichage des informations
    echo "+--------------------"
    echo "Utilisateur : $login"
    echo "Prénom : $prenom"
    echo "Nom : $nom"
    echo "Groupe primaire : $groupe_primaire"
    echo "Groupes secondaires : $groupes_secondaires"
    echo "Répertoire personnel : $taille_repertoire"
    echo "Sudoer : $sudoer"
    echo ""
}

# Options par défaut
groupe=""
groupe_secondaire=""
sudoer=""

# Traitement des options
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

# Affichage des informations pour chaque utilisateur humain
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
