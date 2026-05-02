## 
<h1 align="center">
  <br>
  <a href="https://github.com/SULFURA/WinBackup"><img src="https://raw.githubusercontent.com/SULFURA/WinBackup/main/files/Logo.png" alt="WinBackup" width="200"></a>
  <br>
  WinBackup
  <br>
</h1>

<h4 align="center"><a href="https://github.com/SULFURA/WinBackup/releases/latest" target="_blank">WinBackup</a> est un script Windows gratuit et open source pour sauvegarder et restaurer votre profil utilisateur (bureau, documents, navigateurs, Outlook, et plus) sur un périphérique externe</h4>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GNU AGPLv3 License][license-shield]][license-url]

<p align="center">
  <a href="#fonctionnalités">Fonctionnalités</a> •
  <a href="#utilisation">Utilisation</a> •
  <a href="#téléchargement">Téléchargement</a> •
  <a href="#licence">Licence</a>
</p>

## Fonctionnalités

* Sauvegardez et restaurez votre profil utilisateur Windows en quelques clics
* Choisissez exactement ce que vous voulez sauvegarder ou restaurer via un menu de cases à cocher (ou tout sélectionner d'un coup)
* Sauvegarde du Bureau, Documents, Téléchargements, Images, Musique, Vidéos, Contacts, Liens et Favoris
* Sauvegarde complète des données de tous les navigateurs courants : Edge, Firefox, Chrome, Chromium, Brave, Vivaldi, Opera, Opera GX, Yandex, Tor Browser et Internet Explorer (profils, extensions, paramètres, favoris, historique)
* Sauvegarde des données Outlook (signatures, modèles, données de messagerie, RoamCache)
* Sauvegarde des blocs-notes OneNote, Pense-bêtes et de tous les fichiers PST trouvés dans le profil
* Sauvegarde du fond d'écran avec réapplication automatique à la restauration
* Export de la liste des applications installées (via winget ou le registre) pour faciliter la réinstallation
* Garde-fou intégré empêchant de sauvegarder à l'intérieur du profil en cours de sauvegarde (évite les boucles infinies)
* Compteur d'étapes dynamique et pourcentage d'avancement adaptés aux étapes réellement sélectionnées
* Affichage en temps réel des Mo copiés pendant chaque opération de copie
* Fichier de log détaillé généré pour chaque sauvegarde et restauration
* Compatible avec les ordinateurs multi-utilisateurs : choisissez quel profil Windows sauvegarder ou restaurer

## Utilisation

Pour utiliser ce script, téléchargez-le <a href="https://github.com/SULFURA/WinBackup/releases/latest" target="_blank">ICI</a> et lancez-le en tant qu'administrateur (le script demandera lui-même l'élévation si nécessaire).

Avant de lancer une sauvegarde, branchez un périphérique externe (clé USB ou disque dur externe, idéalement chiffré avec BitLocker). La sauvegarde ne doit JAMAIS être enregistrée dans le profil que vous êtes en train de sauvegarder (en particulier pas sur le Bureau, les Documents ou les Téléchargements du même utilisateur) sous peine de créer une boucle infinie qui saturerait votre disque.

Une fois lancé :
* Sélectionnez l'option 1 pour Sauvegarder ou l'option 2 pour Restaurer
* Choisissez le profil Windows sur lequel travailler
* Cochez les étapes souhaitées avec leur numéro, tapez T pour tout cocher, R pour tout décocher, V pour valider
* Choisissez le dossier de destination (pour la sauvegarde) ou le dossier de sauvegarde à restaurer

Fermez toutes les applications, toutes les fenêtres et tous les programmes en arrière-plan avant de lancer le script, y compris dans la zone de notification (la petite flèche vers le haut à côté de l'horloge).

Vous pouvez laisser le script s'exécuter seul : un écran de progression indique quelle étape est en cours, son avancement, ainsi que les Mo copiés en temps réel. Une fenêtre de confirmation vous avertit une fois la tâche terminée.

Lors d'une restauration, le script lit automatiquement les métadonnées du dossier de sauvegarde et vous avertit si le profil source et le profil cible sont différents.

## Téléchargement

Vous pouvez [télécharger](https://github.com/SULFURA/WinBackup/releases/latest) la dernière version

## Licence

GNU Affero General Public License v3.0

---

> GitHub [@SULFURA](https://github.com/SULFURA) &nbsp;&middot;&nbsp;
> Tiktok [@sulfur4x](https://www.tiktok.com/@sulfur4x) &nbsp;&middot;&nbsp;
> Twitch [@sulfur4x](https://www.twitch.tv/sulfur4x) &nbsp;&middot;&nbsp;
> Twitter [@isulfurax](https://twitter.com/isulfurax) &nbsp;&middot;&nbsp;
> YouTube [@SULFURAX](https://youtube.com/SULFURAX)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/SULFURA/WinBackup.svg?style=for-the-badge
[contributors-url]: https://github.com/SULFURA/WinBackup/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/SULFURA/WinBackup.svg?style=for-the-badge
[forks-url]: https://github.com/SULFURA/WinBackup/network/members
[stars-shield]: https://img.shields.io/github/stars/SULFURA/WinBackup.svg?style=for-the-badge
[stars-url]: https://github.com/SULFURA/WinBackup/stargazers
[issues-shield]: https://img.shields.io/github/issues/SULFURA/WinBackup.svg?style=for-the-badge
[issues-url]: https://github.com/SULFURA/WinBackup/issues
[license-shield]: https://img.shields.io/github/license/SULFURA/WinBackup.svg?style=for-the-badge
[license-url]: https://github.com/SULFURA/WinBackup/blob/main/LICENCE.md
