## 
<h1 align="center">
  <br>
  <a href="https://github.com/SULFURA/WinBackup"><img src="https://raw.githubusercontent.com/SULFURA/WinBackup/main/files/Logo.png" alt="WinBackup" width="200"></a>
  <br>
  WinBackup
  <br>
</h1>

<h4 align="center"><a href="https://github.com/SULFURA/WinBackup/releases/latest" target="_blank">WinBackup</a> is a free and open source Windows script that aims to backup and restore your user profile (desktop, documents, browsers, Outlook, and more) to an external device </h4>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GNU AGPLv3 License][license-shield]][license-url]

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#download">Download</a> •
  <a href="#license">License</a>
</p>

## Key Features

* Backup and restore your Windows user profile in a few clicks
* Pick exactly what you want to save or restore from a checkbox menu (or select everything at once)
* Backup your Desktop, Documents, Downloads, Pictures, Music, Videos, Contacts, Links and Favorites
* Backup all your known browsers data : Edge, Firefox, Chrome, Chromium, Brave, Vivaldi, Opera, Opera GX, Yandex, Tor Browser and Internet Explorer
* Backup your Outlook data (signatures, templates, mail data, RoamCache)
* Backup your OneNote notebooks, Sticky Notes and every PST file found in your profile
* Built-in safety check that prevents you from saving the backup inside the profile you are saving (avoids infinite loop)
* Dynamic step counter and progress percentage that adapts to the steps you actually picked
* Detailed log file generated for every backup and restore operation
* Compatible with multi-user computers : pick which Windows profile you want to backup or restore

## How To Use

To use this script, download it <a href="https://github.com/SULFURA/WinBackup/releases/latest" target="_blank">HERE</a> and run it as administrator (the script will ask for elevation by itself if needed).

Before launching a backup, plug in an external device (USB key or external hard drive, ideally encrypted with BitLocker). The backup must NEVER be saved inside the profile you are saving (especially not on the Desktop, Documents or Downloads of the same user) or it would create an infinite loop that fills up your disk.

Once launched : 
* Select option 1 for Backup or option 2 for Restore
* Pick the Windows profile you want to work on
* Tick the steps you want with their number, type T to tick everything, R to untick everything, V to validate
* Choose the destination folder (for backup) or the backup folder to restore from
* Close every application, every window and every background program before letting the script run, including in the system tray (the small up arrow next to the clock)

You can let the script run by itself, a progress screen will tell you which step is in progress and how far it is. Once finished, a confirmation window will tell you everything is done.

For a restore, the script automatically reads the metadata of the backup folder and warns you if the source profile and the target profile are different.

## Download

You can [download](https://github.com/SULFURA/WinBackup/releases/latest) the latest version

## License

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