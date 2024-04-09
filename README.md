# Consignes et exercices du Projet

## Script_a
Vous allez créer un premier script permettant de créer automatiquement des utilisateurs 
utilisables. Vous utiliserez un fichier source pour cette création dont chaque ligne aura la 
structure suivante :
prénom:nom:groupe1,groupe2,…:sudo:motdepasse
Avant tout, vous devez vérifier que le fichier a un format correct.

- Le login sera généré automatiquement avec la première lettre du prénom suivie du nom. 
Si un utilisateur existe déjà, il faut ajouter un chiffre à la fin de son login
- Chaque utilisateur aura, dans le champ commentaire de /etc/passwd, son prénom suivi 
de son nom, il pourra se connecter avec le login généré et le mot de passe donnés dans 
le fichier. De plus, l'utilisateur devra changer son mot de passe lors de sa première
connexion.

- Le premier groupe cité sera le groupe primaire de l'utilisateur, les éventuels autres 
groupes seront ses groupes secondaires. Si un groupe n'existe pas, il devra être créé par 
le script. S'il n'y a pas de groupe dans la ligne de l'utilisateur, son groupe primaire aura le 
même nom que le login de l'utilisateur.

- Le champ sudo sera à 'oui' ou 'non' et s'il est à 'oui', l'utilisateur sera un sudoer, sinon il 
ne le sera pas.
Vous peuplerez leurs répertoires de 5 à 10 fichiers d'une taille aléatoire, pour chaque fichier, entre 
5Mo et 50Mo. Si vous lancez le script plusieurs fois, il ne doit pas recréer des utilisateurs qui 
existent déjà (même login, même nom et même prénom).

- Vous créerez ensuite un script qui va afficher chaque utilisateur humain du système, son nom, 
son prénom suivi de son login, avec ses groupes, en séparant son groupe primaire de ses groupes 
secondaires. Vous afficherez aussi la taille de son répertoire personnel et s’il est sudoer ou pas.

Exemple :
Utilisateur : fsananes
Prénom : Frédéric
Nom : Sananes
Groupe primaire : DirectionPédagogique
Groupes secondaires : professeur, administration
Répertoire personnel : 135Mo 213ko 12octets
Sudoer : OUI
Vous ajouterez des options à ce script :
-G groupe : affiche uniquement les informations des utilisateurs dont le groupe primaire est groupe.
-g groupe : affiche uniquement les informations des utilisateurs dont un des groupes secondaires est 
groupe.
-s val : si val=0, affiche les informations des utilisateurs qui ne sont pas sudoers, si val=1, c’est l’inverse.
-u nom : affiche toutes les informations sur l’utilisateur nom et seulement lui


## Script_b
Vous allez créer un script permettant de contrôler les exécutables pour lesquels le SUID et/ou le 
SGID est activé. Il permettra de générer une liste de ces fichiers et de la comparer, si elle existe, 
avec la liste créée lors du précédent appel du script.
Si les 2 listes sont différentes, un avertissement s'affiche avec la liste des différences. Vous 
afficherez la date de modification des fichiers litigieux

## Serveur DNS
Vous mettrez en place un serveur DNS primaire sur votre machine. Il devra être capable de résoudre des 
requêtes concernant des machines du réseau local et des requêtes concernant des hôtes sur internet. Le 
nom de la zone est laissé à votre choix.
Vous devrez définir au moins 2 machines avec un alias pour l'une d'entre elles.
Vous définirez aussi la zone reverse et mettrez en place un serveur secondaire sur une autre machine.

# Soutenance et tests
Lors de la soutenance, vous devrez avoir prévu des procédures de test de toutes les fonctionnalités. 
Vous rédigerez une notice donnant les différentes configurations et scripts. Vous la téléchargerez sur 
l'interface de gestion de projet.
