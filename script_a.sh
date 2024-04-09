#!/bin/bash

# NON FONCTIONNEL

# Vérifier si le fichier source est spécifié en argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 fichier_source"
    exit 1
fi

source_file=$1

# Vérifier si le fichier source existe
if [ ! -f "$source_file" ]; then
    echo "Le fichier source $source_file n'existe pas."
    exit 1
fi

# Fonction pour générer un login unique
generate_login() {
    local firstname=$1
    local lastname=$2
    local login="${firstname:0:1}${lastname}"
    local counter=0

    # Vérifier si le login existe déjà, si oui, ajouter un chiffre à la fin
    while id -u "$login" &>/dev/null; do
        ((counter++))
        login="${firstname:0:1}${lastname}${counter}"
    done

    echo "$login"
}

# Fonction pour créer un utilisateur
create_user() {
    local firstname=$1
    local lastname=$2
    local groups=$3
    local sudo=$4
    local password=$5

    local login=$(generate_login "$firstname" "$lastname")

    # Créer le groupe primaire s'il n'existe pas
    primary_group=$(echo "$groups" | cut -d, -f1)
    if ! grep -q "^$primary_group:" /etc/group; then
        sudo groupadd "$primary_group"
    fi

    # Créer les groupes secondaires s'ils n'existent pas
    IFS=',' read -ra secondary_groups <<<"$groups"
    for group in "${secondary_groups[@]}"; do
        if ! grep -q "^$group:" /etc/group; then
            sudo groupadd "$group"
        fi
    done

    # Créer l'utilisateur avec le login généré et les informations fournies
    sudo useradd -m -s /bin/bash -g "$primary_group" -G "${secondary_groups[*]}" -c "$firstname $lastname" "$login"

    # Définir le mot de passe pour l'utilisateur
    echo "$login:$password" | sudo chpasswd

    # Définir si l'utilisateur est sudoer
    if [ "$sudo" = "oui" ]; then
        sudo usermod -aG sudo "$login"
    fi

    echo "Utilisateur $firstname $lastname ($login) créé avec succès."
}

# Fonction pour générer des fichiers aléatoires dans le répertoire de l'utilisateur
generate_files() {
    local user_home=$1

    # Générer entre 5 et 10 fichiers aléatoires de taille entre 5Mo et 50Mo
    for ((i = 1; i <= RANDOM % 6 + 5; i++)); do
        size=$((RANDOM % 46 + 5))
        dd if=/dev/urandom of="$user_home/file_$i" bs=1M count="$size" &>/dev/null
    done

    echo "Fichiers générés dans $user_home."
}

# Parcourir le fichier source ligne par ligne
while IFS=':' read -r firstname lastname groups sudo password; do
    # Vérifier le format de la ligne
    if [ -z "$firstname" ] || [ -z "$lastname" ] || [ -z "$groups" ] || [ -z "$sudo" ] || [ -z "$password" ]; then
        echo "Erreur: Format incorrect dans le fichier source."
        continue
    fi

    # Vérifier si l'utilisateur existe déjà
    login=$(generate_login "$firstname" "$lastname")
    if id -u "$login" &>/dev/null; then
        echo "Utilisateur $firstname $lastname existe déjà, saut de création."
        continue
    fi

    # Créer l'utilisateur
    create_user "$firstname" "$lastname" "$groups" "$sudo" "$password"

    # Récupérer le répertoire personnel de l'utilisateur
    user_home=$(eval echo ~"$login")

    # Générer des fichiers aléatoires dans le répertoire de l'utilisateur
    generate_files "$user_home"

done <"$source_file"
