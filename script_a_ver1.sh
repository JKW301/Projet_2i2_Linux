#!/bin/bash

set -x

# Vérifie que le script est exécuté en tant que superutilisateur
if [ "$(id -u)" != "0" ]; then
    echo "Ce script doit être exécuté en tant que superutilisateur" 1>&2
    exit 1
fi

# Recherche un fichier source dans le répertoire courant
fichier_source=$(find . -name "fichier_source")

# Vérifie si un fichier source a été trouvé
if [ -z "$fichier_source" ]; then
    echo "Aucun fichier source trouvé dans le répertoire courant."
    exit 1
fi

# Fonction pour créer un utilisateur
creer_utilisateur() {
    prenom=$1
    nom=$2
    groupes=$3
    sudo=$4
    mot_de_passe=$5
    
    login=$(echo "${prenom:0:1}${nom}" | tr '[:upper:]' '[:lower:]')
    commentaire="$prenom $nom"
    
    # Vérifie si l'utilisateur existe déjà
    if id "$login" &>/dev/null; then
        i=1
        while id "${login}${i}" &>/dev/null; do
            ((i++))
        done
        login="${login}${i}"
    fi
    
    # Création de l'utilisateur avec le mot de passe donné
    useradd -m -c "$commentaire" -s /bin/bash "$login" &>/dev/null
    echo "$login:$mot_de_passe" | chpasswd
    
    # Définition des groupes
    groupadd "$login" &>/dev/null
    usermod -aG "$login" "$login" &>/dev/null
    IFS=',' read -ra group_array <<< "$groupes"
    for groupe in "${group_array[@]}"; do
        groupadd "$groupe" &>/dev/null
        usermod -aG "$groupe" "$login" &>/dev/null
    done
    
    # Définition des privilèges sudo
    if [ "$sudo" = "oui" ]; then
        usermod -aG sudo "$login" &>/dev/null
    fi
    
    # Obliger l'utilisateur à changer son mot de passe à la première connexion
    chage -d 0 "$login" &>/dev/null
}

# Fonction pour peupler le répertoire de l'utilisateur avec des fichiers aléatoires
peupler_repertoire() {
    utilisateur=$1
    min_size=5242880  # 5 Mo en octets
    max_size=52428800 # 50 Mo en octets
    nb_fichiers=$((RANDOM % 6 + 5))  # Nombre aléatoire de fichiers entre 5 et 10
    
    for ((i=1; i<=nb_fichiers; i++)); do
        taille=$((RANDOM % (max_size - min_size + 1) + min_size))
        dd if=/dev/urandom of="/home/$utilisateur/fichier$i" bs=1 count=$taille &>/dev/null
    done
}

# Parcours du fichier source
while IFS=':' read -r prenom nom groupes sudo mot_de_passe; do
    # Vérifie le format de la ligne
    if [ -n "$prenom" ] && [ -n "$nom" ] && [ -n "$groupes" ] && [ -n "$sudo" ] && [ -n "$mot_de_passe" ]; then
        creer_utilisateur "$prenom" "$nom" "$groupes" "$sudo" "$mot_de_passe"
        peupler_repertoire "$(echo "${prenom:0:1}${nom}" | tr '[:upper:]' '[:lower:]')"
    else
        echo "Format de ligne incorrect dans le fichier source."
    fi
done < "$fichier_source"

exit 0
