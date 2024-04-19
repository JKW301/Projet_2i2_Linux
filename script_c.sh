#!/bin/bash

set -x
# Chemin du fichier contenant la liste précédente
LIST_FILE="/$HOME/liste_precedente.txt"

# Chemin du fichier de sortie pour la nouvelle liste
NEW_LIST_FILE="/$HOME/nouvelle_liste.txt"

# Vérification de l'existence de la liste précédente
if [ -f "$LIST_FILE" ]; then
    # Création de la nouvelle liste
    find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | sort > "$NEW_LIST_FILE"
    
    # Comparaison des deux listes
    diff_output=$(diff "$LIST_FILE" "$NEW_LIST_FILE")
    
    # Si les listes sont différentes
    if [ $? -ne 0 ]; then
        echo "Attention : des changements ont été détectés dans les permissions SUID/SGID :"
        echo "$diff_output"
        
        # Affichage de la date de modification des fichiers litigieux
        echo "Date de modification des fichiers litigieux :"
        while IFS= read -r line; do
            file=$(echo "$line" | awk '{print $2}')
            modification_date=$(stat -c %y "$file")
            echo "$modification_date - $file"
        done <<< "$diff_output"
    else
        echo "Aucun changement détecté dans les permissions SUID/SGID depuis la dernière exécution."
    fi
else
    echo "Aucune liste précédente trouvée. Création d'une nouvelle liste."
    find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | sort > "$LIST_FILE"
fi
