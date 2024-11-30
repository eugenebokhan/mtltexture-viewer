#!/bin/bash 

if [ "$(which create-dmg)" = "" ] ;then
	echo "DMG builder 'create-dmg' is not found. install it from https://github.com/create-dmg/create-dmg"
	exit 1
fi

executablePath=$1

if [ -z "${executablePath}" ]; then
	echo "Specify archived app folder path"
	exit 1
fi

scriptPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
backgroundPath="${scriptPath}/DropBackground.png"

create-dmg --app-drop-link 250 175 --icon MTLTextureViewer 10 175 --background $backgroundPath  MTLTextureViewer.dmg $executablePath