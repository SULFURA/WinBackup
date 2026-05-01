@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title WinBackup

:: Run Admin
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Check Updates
set "local=1.0"
set "localtwo=%local%"
if exist "%temp%\WinBackup_Updater.bat" del /F /Q "%temp%\WinBackup_Updater.bat" >nul 2>&1
curl -g -L -# -o "%temp%\WinBackup_Updater.bat" "https://raw.githubusercontent.com/SULFURA/WinBackup/main/files/WinBackup_Version" >nul 2>&1
if exist "%temp%\WinBackup_Updater.bat" call "%temp%\WinBackup_Updater.bat"
if "%local%" gtr "%localtwo%" (
    cls
    echo ============================================================
    echo                  MISE À JOUR DISPONIBLE
    echo                       - WinBackup -
    echo ============================================================
    echo.
    echo   Version actuelle : %localtwo%
    echo   Nouvelle version : %local%
    echo.
    echo   [ O ] Mettre à jour WinBackup
    echo   [ N ] Ignorer la mise à jour
    echo.
    choice /C ON /N /M "Votre choix : "
    set "choix_maj=!errorlevel!"
    if !choix_maj! equ 1 (
        curl -L -o "%~f0" "https://github.com/SULFURA/WinBackup/releases/latest/download/WinBackup.cmd" >nul 2>&1
        call "%~f0"
        exit /b
    )
)

:: Police console
call :FORCER_POLICE

:: Robocopy
set "ROBO_OPT=/E /ZB /R:2 /W:2 /XJ /COPY:DAT /DCOPY:DAT /FFT"
set "EXCLUDE_PROFILES=All Users Default Default User Public defaultuser0 default"

:: Étapes
set "NB_ETAPES=12"

set "ETAPE_NOM[1]=Bureau"
set "ETAPE_CLE[1]=DESKTOP"

set "ETAPE_NOM[2]=Documents"
set "ETAPE_CLE[2]=DOCUMENTS"

set "ETAPE_NOM[3]=Téléchargements"
set "ETAPE_CLE[3]=DOWNLOADS"

set "ETAPE_NOM[4]=Favoris Internet Explorer / Windows"
set "ETAPE_CLE[4]=FAVORITES"

set "ETAPE_NOM[5]=Liens"
set "ETAPE_CLE[5]=LINKS"

set "ETAPE_NOM[6]=Musique"
set "ETAPE_CLE[6]=MUSIC"

set "ETAPE_NOM[7]=Images"
set "ETAPE_CLE[7]=PICTURES"

set "ETAPE_NOM[8]=Vidéos"
set "ETAPE_CLE[8]=VIDEOS"

set "ETAPE_NOM[9]=Contacts"
set "ETAPE_CLE[9]=CONTACTS"

set "ETAPE_NOM[10]=Outlook (signatures, modèles, données, RoamCache)"
set "ETAPE_CLE[10]=OUTLOOK"

set "ETAPE_NOM[11]=Navigateurs (Edge, Firefox, Chrome, Brave, Opera, Vivaldi, etc.)"
set "ETAPE_CLE[11]=BROWSERS"

set "ETAPE_NOM[12]=OneNote, Pense-bêtes et fichiers PST"
set "ETAPE_CLE[12]=NOTES_PST"

:: Menu
:MENU
cls
echo ============================================================
echo                         WinBackup
echo            Sauvegarde / Restauration du profil
echo ============================================================
echo.
echo   1 - Sauvegarde
echo   2 - Restauration
echo   3 - Quitter
echo.
set "CHOIX="
set /p "CHOIX=Votre choix : "

if "%CHOIX%"=="1" goto SAUVEGARDE_INIT
if "%CHOIX%"=="2" goto RESTAURATION_INIT
if "%CHOIX%"=="3" exit /b 0
goto MENU

:: Reset
:RESET_ETAT
set "TOTAL_ETAPES=0"
set "ETAPE_ACTUELLE=0"
set "POURCENT=0"
set "LIBELLE_ETAPE="
set "MODE="
set "PROFIL_AFFICHE="
set "FICHIER_LOG="
set "DOSSIER_SAUVEGARDE="
set "DOSSIER_BASE_SAUVEGARDE="
set "DOSSIER_RESTAURATION="
set "PROFIL_CIBLE="
set "BKUSER="
set "SELECTED_PROFILE="
set "SRC_PROFILE="
set "PROFILE_NUM="
set "TS="
for /L %%I in (1,1,%NB_ETAPES%) do set "SEL[%%I]=0"
exit /b 0

:: Msgbox
:AfficherMsg
set "MSG_TITRE=%~1"
set "MSG_TEXTE=%~2"
set "MSG_TYPE=%~3"
if not defined MSG_TYPE set "MSG_TYPE=0"

powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $icon = switch ($env:MSG_TYPE) { '16' { [System.Windows.Forms.MessageBoxIcon]::Error } '48' { [System.Windows.Forms.MessageBoxIcon]::Warning } '64' { [System.Windows.Forms.MessageBoxIcon]::Information } default { [System.Windows.Forms.MessageBoxIcon]::None } }; [System.Windows.Forms.MessageBox]::Show($env:MSG_TEXTE, $env:MSG_TITRE, [System.Windows.Forms.MessageBoxButtons]::OK, $icon) | Out-Null"
call :FORCER_POLICE
exit /b 0

:: Choix dossier
:SelectionDossier
set "%~2="

for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description='%~1'; $f.ShowNewFolderButton=$true; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }"`) do (
    set "%~2=%%I"
)
call :FORCER_POLICE
exit /b 0

:: Choix profil
:SELECTION_PROFIL
set "COUNT=0"

for /f "delims=" %%U in ('dir /b /ad "C:\Users" 2^>nul') do (
    set "SKIP="
    for %%X in (%EXCLUDE_PROFILES%) do (
        if /I "%%U"=="%%X" set "SKIP=1"
    )
    if not defined SKIP (
        set /a COUNT+=1
        set "PROFILE[!COUNT!]=%%U"
    )
)

if "%COUNT%"=="0" (
    call :AfficherMsg "Erreur" "Aucun profil utilisateur exploitable n'a été trouvé dans C:\Users." 16
    goto MENU
)

:SELECTION_PROFIL_AGAIN
cls
echo ============================================================
echo                  SÉLECTION DU PROFIL
echo ============================================================
echo.
for /L %%N in (1,1,%COUNT%) do (
    echo   %%N - !PROFILE[%%N]!
)
echo.
set "PROFILE_NUM="
set /p "PROFILE_NUM=Choisissez le numéro du profil : "

if not defined PROFILE_NUM goto SELECTION_PROFIL_AGAIN
for /f "delims=0123456789" %%A in ("%PROFILE_NUM%") do goto SELECTION_PROFIL_AGAIN
if %PROFILE_NUM% LSS 1 goto SELECTION_PROFIL_AGAIN
if %PROFILE_NUM% GTR %COUNT% goto SELECTION_PROFIL_AGAIN

set "SELECTED_PROFILE=!PROFILE[%PROFILE_NUM%]!"
set "SRC_PROFILE=C:\Users\%SELECTED_PROFILE%"
exit /b 0

:: Choix étapes
:SELECTION_ETAPES
set "TITRE_SEL=%~1"

for /L %%I in (1,1,%NB_ETAPES%) do set "SEL[%%I]=0"

:SELECTION_ETAPES_AFFICHE
cls
echo ============================================================
echo            SÉLECTION DES ÉTAPES - %TITRE_SEL%
echo ============================================================
echo.
echo   Tapez le numéro pour cocher/décocher une étape.
echo   Tapez T pour Tout cocher, R pour Tout décocher.
echo   Tapez V pour Valider et lancer l'opération.
echo   Tapez Q pour revenir au menu principal.
echo.
set "NB_SELECTIONNES=0"
for /L %%I in (1,1,%NB_ETAPES%) do (
    if "!SEL[%%I]!"=="1" (
        set /a NB_SELECTIONNES+=1
        echo   [X] %%I - !ETAPE_NOM[%%I]!
    ) else (
        echo   [ ] %%I - !ETAPE_NOM[%%I]!
    )
)
echo.
echo   Étapes cochées : !NB_SELECTIONNES! / %NB_ETAPES%
echo.
set "REPONSE="
set /p "REPONSE=Votre saisie : "

if not defined REPONSE goto SELECTION_ETAPES_AFFICHE

if /I "%REPONSE%"=="Q" (
    set "NB_SELECTIONNES=0"
    exit /b 1
)

if /I "%REPONSE%"=="V" (
    if !NB_SELECTIONNES! EQU 0 (
        call :AfficherMsg "Aucune étape" "Vous devez cocher au moins une étape." 48
        goto SELECTION_ETAPES_AFFICHE
    )
    exit /b 0
)

if /I "%REPONSE%"=="T" (
    for /L %%I in (1,1,%NB_ETAPES%) do set "SEL[%%I]=1"
    goto SELECTION_ETAPES_AFFICHE
)

if /I "%REPONSE%"=="R" (
    for /L %%I in (1,1,%NB_ETAPES%) do set "SEL[%%I]=0"
    goto SELECTION_ETAPES_AFFICHE
)

:: Filtre saisie
for /f "delims=0123456789" %%A in ("%REPONSE%") do goto SELECTION_ETAPES_AFFICHE
if %REPONSE% LSS 1 goto SELECTION_ETAPES_AFFICHE
if %REPONSE% GTR %NB_ETAPES% goto SELECTION_ETAPES_AFFICHE

:: Bascule
if "!SEL[%REPONSE%]!"=="1" (
    set "SEL[%REPONSE%]=0"
) else (
    set "SEL[%REPONSE%]=1"
)
goto SELECTION_ETAPES_AFFICHE

:: Progression
:INIT_PROGRESSION
set "TOTAL_ETAPES=%~1"
set "ETAPE_ACTUELLE=0"
set "POURCENT=0"
set "LIBELLE_ETAPE="
exit /b 0

:AFFICHER_PROGRESSION
set /a ETAPE_ACTUELLE+=1
set "LIBELLE_ETAPE=%~1"
set /a POURCENT=(ETAPE_ACTUELLE*100)/TOTAL_ETAPES

cls
echo ============================================================
echo                       PROGRESSION
echo ============================================================
echo.
echo Opération   : %MODE%
echo Profil      : %PROFIL_AFFICHE%
echo Étape       : %ETAPE_ACTUELLE% / %TOTAL_ETAPES%
echo Avancement  : %POURCENT%%%
echo.
echo EN COURS    : %LIBELLE_ETAPE%
echo.
exit /b 0

:: Vérifie si une étape est cochée via sa clé
:EST_COCHE
set "ETAPE_OK=0"
for /L %%I in (1,1,%NB_ETAPES%) do (
    if /I "!ETAPE_CLE[%%I]!"=="%~1" (
        if "!SEL[%%I]!"=="1" set "ETAPE_OK=1"
    )
)
exit /b 0

:: Sauvegarde
:SAUVEGARDE_INIT
call :RESET_ETAT
call :SELECTION_PROFIL

call :SELECTION_ETAPES "Sauvegarde"
if errorlevel 1 goto MENU

:: Avertissement périphérique externe
call :AfficherMsg "Important - lieu de sauvegarde" "La sauvegarde doit être enregistrée sur un périphérique externe (clé USB ou disque dur externe), de préférence chiffré avec BitLocker. N'enregistrez JAMAIS la sauvegarde dans le profil que vous êtes en train de sauvegarder, en particulier sur le Bureau, les Documents ou les Téléchargements : le script copierait sa propre sauvegarde dans elle-même et entrerait dans une boucle infinie qui finirait par saturer le disque." 48

call :SelectionDossier "Choisissez le dossier de sauvegarde" DOSSIER_BASE_SAUVEGARDE
if not defined DOSSIER_BASE_SAUVEGARDE goto MENU

:: Garde-fou anti-boucle
call :VERIFIER_DOSSIER_SUR
if errorlevel 1 goto MENU

for /f %%I in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyy-MM-dd_HHmmss')"') do set "TS=%%I"

set "DOSSIER_SAUVEGARDE=%DOSSIER_BASE_SAUVEGARDE%\Sauvegarde_%SELECTED_PROFILE%_%TS%"
md "%DOSSIER_SAUVEGARDE%" 2>nul

set "FICHIER_LOG=%DOSSIER_SAUVEGARDE%\sauvegarde.log"
set "MODE=Sauvegarde"
set "PROFIL_AFFICHE=%SELECTED_PROFILE%"

:: Métadonnées
echo USERNAME=%SELECTED_PROFILE%>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
echo COMPUTERNAME=%COMPUTERNAME%>>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
echo BACKUP_DATE=%DATE% %TIME%>>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
echo SOURCE_PROFILE=%SRC_PROFILE%>>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
echo.>>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
echo [Etapes sauvegardees]>>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
for /L %%I in (1,1,%NB_ETAPES%) do (
    if "!SEL[%%I]!"=="1" echo ETAPE=!ETAPE_CLE[%%I]!>>"%DOSSIER_SAUVEGARDE%\backup_meta.txt"
)

call :AfficherMsg "Attention - fermeture obligatoire" "Avant de lancer la sauvegarde, tout doit être fermé sauf ce script. Fermez absolument toutes les applications, toutes les fenêtres, tous les logiciels en arrière-plan, et vérifiez aussi dans la barre des tâches ainsi que dans la zone de notification, la petite flèche vers le haut, qu'il ne reste rien d'ouvert. Faites clic droit puis Quitter sur tout ce qui peut l'être. Ne rouvrez rien pendant toute la durée de la sauvegarde." 48

:: Total = étapes cochées + export applications + finalisation
set /a TOTAL_DYN=NB_SELECTIONNES+2
call :INIT_PROGRESSION %TOTAL_DYN%
call :FAIRE_SAUVEGARDE

call :AfficherMsg "Sauvegarde terminée" "La sauvegarde est terminée dans : %DOSSIER_SAUVEGARDE%" 64
goto MENU

:: Vérifie que le dossier choisi n'est pas dans le profil source
:VERIFIER_DOSSIER_SUR
for /f "usebackq delims=" %%R in (`powershell -NoProfile -Command "if ('%DOSSIER_BASE_SAUVEGARDE%' -like '%SRC_PROFILE%*') { 'DANS_PROFIL' } else { 'OK' }"`) do set "VERIF=%%R"
call :FORCER_POLICE

if /I "%VERIF%"=="DANS_PROFIL" (
    call :AfficherMsg "Dossier interdit" "Le dossier choisi se trouve à l'intérieur du profil utilisateur que vous voulez sauvegarder (%SRC_PROFILE%). Cela provoquerait une boucle infinie. Choisissez un autre emplacement, idéalement un périphérique externe." 16
    exit /b 1
)
exit /b 0

:FAIRE_SAUVEGARDE
echo Début de la sauvegarde... > "%FICHIER_LOG%"

call :EST_COCHE DESKTOP
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie du Bureau"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Desktop" "%DOSSIER_SAUVEGARDE%\Bureau"
)

call :EST_COCHE DOCUMENTS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Documents"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Documents" "%DOSSIER_SAUVEGARDE%\Documents"
)

call :EST_COCHE DOWNLOADS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Téléchargements"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Downloads" "%DOSSIER_SAUVEGARDE%\Téléchargements"
)

call :EST_COCHE FAVORITES
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Favoris"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Favorites" "%DOSSIER_SAUVEGARDE%\Favoris"
)

call :EST_COCHE LINKS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Liens"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Links" "%DOSSIER_SAUVEGARDE%\Liens"
)

call :EST_COCHE MUSIC
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie de la Musique"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Music" "%DOSSIER_SAUVEGARDE%\Musique"
)

call :EST_COCHE PICTURES
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Images"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Pictures" "%DOSSIER_SAUVEGARDE%\Images"
)

call :EST_COCHE VIDEOS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Vidéos"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Videos" "%DOSSIER_SAUVEGARDE%\Vidéos"
)

call :EST_COCHE CONTACTS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des Contacts"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Contacts" "%DOSSIER_SAUVEGARDE%\Contacts"
)

call :EST_COCHE OUTLOOK
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des données Outlook (signatures, modèles, données, RoamCache)"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Microsoft\Signatures" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Microsoft\Signatures"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Microsoft\Templates" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Microsoft\Templates"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Microsoft\Outlook" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Microsoft\Outlook"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Microsoft\Outlook" "%DOSSIER_SAUVEGARDE%\AppData\Local\Microsoft\Outlook"
)

call :EST_COCHE BROWSERS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie des données des navigateurs"
    call :SAUVEGARDER_NAVIGATEURS
)

call :EST_COCHE NOTES_PST
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Copie OneNote, Pense-bêtes et fichiers PST"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Microsoft\OneNote" "%DOSSIER_SAUVEGARDE%\AppData\Local\Microsoft\OneNote"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Microsoft\OneNote" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Microsoft\OneNote"
    call :COPIER_DOSSIER "%SRC_PROFILE%\Documents\OneNote Notebooks" "%DOSSIER_SAUVEGARDE%\Documents\OneNote Notebooks"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "%DOSSIER_SAUVEGARDE%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
    call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Microsoft\Sticky Notes" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Microsoft\Sticky Notes"

    echo.>>"%FICHIER_LOG%"
    echo [Recherche des fichiers PST]>>"%FICHIER_LOG%"
    for /r "%SRC_PROFILE%" %%F in (*.pst) do (
        call :COPIER_FICHIER_PST "%%~fF" "%DOSSIER_SAUVEGARDE%\Fichiers_PST"
    )
)

call :AFFICHER_PROGRESSION "Export de la liste des applications installées"
set "_APPS_FILE=%DOSSIER_SAUVEGARDE%\applications_installees.txt"
where winget >nul 2>&1
if not errorlevel 1 (
    powershell -NoProfile -Command "$f=$env:_APPS_FILE; $s=winget list --accept-source-agreements 2>$null; if($s -and $s.Count -gt 2){$h=$s[0..1]; $c=$s[2..($s.Count-1)]|Where-Object{$_ -match '\S'}|Sort-Object; ($h+$c)|Out-File -FilePath $f -Encoding UTF8}" >nul 2>&1
) else (
    powershell -NoProfile -Command "$f=$env:_APPS_FILE; $p='HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'; Get-ItemProperty $p | Where-Object{$_.DisplayName} | Select-Object DisplayName,DisplayVersion,Publisher | Sort-Object DisplayName | Format-Table -AutoSize | Out-String | Out-File -FilePath $f -Encoding UTF8" >nul 2>&1
)

call :AFFICHER_PROGRESSION "Finalisation"
echo Sauvegarde terminée >> "%FICHIER_LOG%"
exit /b 0

:: Sauvegarde des navigateurs
:SAUVEGARDER_NAVIGATEURS
:: Edge
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Microsoft\Edge\User Data" "%DOSSIER_SAUVEGARDE%\AppData\Local\Microsoft\Edge\User Data"

:: Firefox
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Mozilla\Firefox" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Mozilla\Firefox"
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Mozilla\Firefox" "%DOSSIER_SAUVEGARDE%\AppData\Local\Mozilla\Firefox"

:: Chrome
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Google\Chrome\User Data" "%DOSSIER_SAUVEGARDE%\AppData\Local\Google\Chrome\User Data"

:: Chromium
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Chromium\User Data" "%DOSSIER_SAUVEGARDE%\AppData\Local\Chromium\User Data"

:: Brave
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\BraveSoftware\Brave-Browser\User Data" "%DOSSIER_SAUVEGARDE%\AppData\Local\BraveSoftware\Brave-Browser\User Data"

:: Vivaldi
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Vivaldi\User Data" "%DOSSIER_SAUVEGARDE%\AppData\Local\Vivaldi\User Data"

:: Opera
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Opera Software\Opera Stable" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Opera Software\Opera Stable"

:: Opera GX
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Opera Software\Opera GX Stable" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Opera Software\Opera GX Stable"

:: Yandex
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Local\Yandex\YandexBrowser\User Data" "%DOSSIER_SAUVEGARDE%\AppData\Local\Yandex\YandexBrowser\User Data"

:: Tor (portable)
call :COPIER_DOSSIER "%SRC_PROFILE%\Desktop\Tor Browser\Browser\TorBrowser\Data" "%DOSSIER_SAUVEGARDE%\Tor Browser\Data"

:: Internet Explorer
call :COPIER_DOSSIER "%SRC_PROFILE%\AppData\Roaming\Microsoft\Internet Explorer" "%DOSSIER_SAUVEGARDE%\AppData\Roaming\Microsoft\Internet Explorer"

exit /b 0

:: Restauration
:RESTAURATION_INIT
call :RESET_ETAT
cls
echo ============================================================
echo                    RESTAURATION
echo ============================================================
echo.

call :SelectionDossier "Choisissez le dossier de sauvegarde à restaurer" DOSSIER_RESTAURATION
if not defined DOSSIER_RESTAURATION goto MENU

if not exist "%DOSSIER_RESTAURATION%\backup_meta.txt" (
    call :AfficherMsg "Erreur" "Le fichier backup_meta.txt est introuvable dans le dossier sélectionné." 16
    goto MENU
)

set "BKUSER="
for /f "tokens=1,* delims==" %%A in ('findstr /b /i "USERNAME=" "%DOSSIER_RESTAURATION%\backup_meta.txt"') do (
    set "BKUSER=%%B"
)

if not defined BKUSER (
    call :AfficherMsg "Erreur" "Le nom d'utilisateur est introuvable dans backup_meta.txt." 16
    goto MENU
)

call :SELECTION_PROFIL
set "PROFIL_CIBLE=C:\Users\%SELECTED_PROFILE%"

if not exist "%PROFIL_CIBLE%" (
    call :AfficherMsg "Erreur" "Le profil cible est introuvable : %PROFIL_CIBLE%" 16
    goto MENU
)

if /I not "%BKUSER%"=="%SELECTED_PROFILE%" (
    cls
    echo ============================================================
    echo                        AVERTISSEMENT
    echo ============================================================
    echo.
    echo Le profil source de la sauvegarde est : %BKUSER%
    echo Le profil cible choisi pour la restauration est : %SELECTED_PROFILE%
    echo.
    echo Les deux profils sont différents.
    echo.
    choice /C ON /N /M "Continuer quand même ? [O/N] : "
    if errorlevel 2 goto MENU
    if errorlevel 1 goto SUITE_RESTAURATION
    goto MENU
)

:SUITE_RESTAURATION
call :SELECTION_ETAPES "Restauration"
if errorlevel 1 goto MENU

set "FICHIER_LOG=%DOSSIER_RESTAURATION%\restauration.log"
set "MODE=Restauration"
set "PROFIL_AFFICHE=%SELECTED_PROFILE%"

call :AfficherMsg "Attention - fermeture obligatoire" "Avant de lancer la restauration, tout doit être fermé sauf ce script. Fermez absolument toutes les applications, toutes les fenêtres, tous les logiciels en arrière-plan, et vérifiez aussi dans la barre des tâches ainsi que dans la zone de notification, la petite flèche vers le haut, qu'il ne reste rien d'ouvert. Faites clic droit puis Quitter sur tout ce qui peut l'être. Ne rouvrez rien jusqu'à la fin complète de la restauration." 48

:: Total = étapes cochées + finalisation
set /a TOTAL_DYN=NB_SELECTIONNES+1
call :INIT_PROGRESSION %TOTAL_DYN%
call :FAIRE_RESTAURATION "%DOSSIER_RESTAURATION%" "%PROFIL_CIBLE%"

call :AfficherMsg "Restauration terminée" "La restauration est terminée." 64

if exist "%DOSSIER_RESTAURATION%\applications_installees.txt" (
    call :AfficherMsg "Applications à réinstaller" "La liste des applications installées au moment de la sauvegarde va s'ouvrir. Utilisez-la pour réinstaller vos logiciels manuellement." 64
    start notepad "%DOSSIER_RESTAURATION%\applications_installees.txt"
)
goto MENU

:FAIRE_RESTAURATION
set "SRC=%~1"
set "DST=%~2"

echo Début de la restauration... > "%FICHIER_LOG%"

call :EST_COCHE DESKTOP
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration du Bureau"
    call :COPIER_DOSSIER "%SRC%\Bureau" "%DST%\Desktop"
)

call :EST_COCHE DOCUMENTS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Documents"
    call :COPIER_DOSSIER "%SRC%\Documents" "%DST%\Documents"
)

call :EST_COCHE DOWNLOADS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Téléchargements"
    call :COPIER_DOSSIER "%SRC%\Téléchargements" "%DST%\Downloads"
)

call :EST_COCHE FAVORITES
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Favoris"
    call :COPIER_DOSSIER "%SRC%\Favoris" "%DST%\Favorites"
)

call :EST_COCHE LINKS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Liens"
    call :COPIER_DOSSIER "%SRC%\Liens" "%DST%\Links"
)

call :EST_COCHE MUSIC
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration de la Musique"
    call :COPIER_DOSSIER "%SRC%\Musique" "%DST%\Music"
)

call :EST_COCHE PICTURES
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Images"
    call :COPIER_DOSSIER "%SRC%\Images" "%DST%\Pictures"
)

call :EST_COCHE VIDEOS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Vidéos"
    call :COPIER_DOSSIER "%SRC%\Vidéos" "%DST%\Videos"
)

call :EST_COCHE CONTACTS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des Contacts"
    call :COPIER_DOSSIER "%SRC%\Contacts" "%DST%\Contacts"
)

call :EST_COCHE OUTLOOK
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des données Outlook"
    call :COPIER_DOSSIER "%SRC%\AppData\Roaming\Microsoft\Signatures" "%DST%\AppData\Roaming\Microsoft\Signatures"
    call :COPIER_DOSSIER "%SRC%\AppData\Roaming\Microsoft\Templates" "%DST%\AppData\Roaming\Microsoft\Templates"
    call :COPIER_DOSSIER "%SRC%\AppData\Roaming\Microsoft\Outlook" "%DST%\AppData\Roaming\Microsoft\Outlook"
    call :COPIER_DOSSIER "%SRC%\AppData\Local\Microsoft\Outlook" "%DST%\AppData\Local\Microsoft\Outlook"
)

call :EST_COCHE BROWSERS
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration des données des navigateurs"
    call :RESTAURER_NAVIGATEURS "%SRC%" "%DST%"
)

call :EST_COCHE NOTES_PST
if "%ETAPE_OK%"=="1" (
    call :AFFICHER_PROGRESSION "Restauration OneNote, Pense-bêtes et fichiers PST"
    call :COPIER_DOSSIER "%SRC%\AppData\Local\Microsoft\OneNote" "%DST%\AppData\Local\Microsoft\OneNote"
    call :COPIER_DOSSIER "%SRC%\AppData\Roaming\Microsoft\OneNote" "%DST%\AppData\Roaming\Microsoft\OneNote"
    call :COPIER_DOSSIER "%SRC%\Documents\OneNote Notebooks" "%DST%\Documents\OneNote Notebooks"
    call :COPIER_DOSSIER "%SRC%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "%DST%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
    call :COPIER_DOSSIER "%SRC%\AppData\Roaming\Microsoft\Sticky Notes" "%DST%\AppData\Roaming\Microsoft\Sticky Notes"
    call :COPIER_DOSSIER "%SRC%\Fichiers_PST" "%DST%"
)

call :AFFICHER_PROGRESSION "Finalisation"
echo Restauration terminée >> "%FICHIER_LOG%"
exit /b 0

:: Restauration des navigateurs
:RESTAURER_NAVIGATEURS
set "RSRC=%~1"
set "RDST=%~2"

:: Edge
call :COPIER_DOSSIER "%RSRC%\AppData\Local\Microsoft\Edge\User Data" "%RDST%\AppData\Local\Microsoft\Edge\User Data"

:: Firefox
call :COPIER_DOSSIER "%RSRC%\AppData\Roaming\Mozilla\Firefox" "%RDST%\AppData\Roaming\Mozilla\Firefox"
call :COPIER_DOSSIER "%RSRC%\AppData\Local\Mozilla\Firefox" "%RDST%\AppData\Local\Mozilla\Firefox"

:: Chrome
call :COPIER_DOSSIER "%RSRC%\AppData\Local\Google\Chrome\User Data" "%RDST%\AppData\Local\Google\Chrome\User Data"

:: Chromium
call :COPIER_DOSSIER "%RSRC%\AppData\Local\Chromium\User Data" "%RDST%\AppData\Local\Chromium\User Data"

:: Brave
call :COPIER_DOSSIER "%RSRC%\AppData\Local\BraveSoftware\Brave-Browser\User Data" "%RDST%\AppData\Local\BraveSoftware\Brave-Browser\User Data"

:: Vivaldi
call :COPIER_DOSSIER "%RSRC%\AppData\Local\Vivaldi\User Data" "%RDST%\AppData\Local\Vivaldi\User Data"

:: Opera
call :COPIER_DOSSIER "%RSRC%\AppData\Roaming\Opera Software\Opera Stable" "%RDST%\AppData\Roaming\Opera Software\Opera Stable"

:: Opera GX
call :COPIER_DOSSIER "%RSRC%\AppData\Roaming\Opera Software\Opera GX Stable" "%RDST%\AppData\Roaming\Opera Software\Opera GX Stable"

:: Yandex
call :COPIER_DOSSIER "%RSRC%\AppData\Local\Yandex\YandexBrowser\User Data" "%RDST%\AppData\Local\Yandex\YandexBrowser\User Data"

:: Tor (portable)
call :COPIER_DOSSIER "%RSRC%\Tor Browser\Data" "%RDST%\Desktop\Tor Browser\Browser\TorBrowser\Data"

:: Internet Explorer
call :COPIER_DOSSIER "%RSRC%\AppData\Roaming\Microsoft\Internet Explorer" "%RDST%\AppData\Roaming\Microsoft\Internet Explorer"

exit /b 0

:: Copie dossier
:COPIER_DOSSIER
set "SRC_DIR=%~1"
set "DST_DIR=%~2"

if exist "%SRC_DIR%" (
    echo [COPIE] "%SRC_DIR%" >> "%FICHIER_LOG%"
    if not exist "%DST_DIR%" md "%DST_DIR%" 2>nul
    robocopy "%SRC_DIR%" "%DST_DIR%" * %ROBO_OPT% /LOG+:"%FICHIER_LOG%" >nul
) else (
    echo [ABSENT] "%SRC_DIR%" >> "%FICHIER_LOG%"
)
exit /b 0

:: Copie fichier PST
:COPIER_FICHIER_PST
set "FULLFILE=%~1"
set "PSTROOT=%~2"
set "FILEDIR=%~dp1"
set "FILENAME=%~nx1"

set "REL_DIR=%FILEDIR:%SRC_PROFILE%=_%"
set "REL_DIR=%REL_DIR:~1,-1%"

set "DEST_DIR=%PSTROOT%\%REL_DIR%"
if not exist "%DEST_DIR%" md "%DEST_DIR%" 2>nul

echo [PST] "%FULLFILE%" >> "%FICHIER_LOG%"
robocopy "%FILEDIR%" "%DEST_DIR%" "%FILENAME%" /ZB /R:2 /W:2 /COPY:DAT /LOG+:"%FICHIER_LOG%" >nul
exit /b 0

:: Force la police de la console à Consolas pour éviter qu'elle change après PowerShell
:FORCER_POLICE
powershell -NoProfile -Command "$s='using System;using System.Runtime.InteropServices;public class CF { [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct CFI { public uint cbSize; public uint nFont; public short dwFontSizeX; public short dwFontSizeY; public uint FontFamily; public uint FontWeight; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string FaceName; } [DllImport(\"kernel32.dll\")] public static extern IntPtr GetStdHandle(int n); [DllImport(\"kernel32.dll\", CharSet=CharSet.Unicode)] public static extern bool SetCurrentConsoleFontEx(IntPtr h, bool b, ref CFI f); }'; Add-Type -TypeDefinition $s; $f = New-Object CF+CFI; $f.cbSize = [uint32][Runtime.InteropServices.Marshal]::SizeOf($f); $f.FaceName='Consolas'; $f.dwFontSizeY=16; $f.FontFamily=54; $f.FontWeight=400; [void][CF]::SetCurrentConsoleFontEx([CF]::GetStdHandle(-11), $false, [ref]$f)" 2>nul
exit /b 0