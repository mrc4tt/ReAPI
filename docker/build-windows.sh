#!/bin/bash
# Windows build, mirroring the windows job of build.yml with support/vcxbuild.py
# (cl/link from msvc-wine) in place of msbuild. Two steps, two images:
#
#   build-windows.sh compile   in Dockerfile.windows (msvc-wine): Release
#   build-windows.sh finish    in Dockerfile.wine32 (Authenticode when /run/sign/cert.pfx is mounted):
#                              publish/, rcedit (needs COMMIT and SLUG in the environment)
set -euo pipefail
owner=$(stat -c %u:%g .)

case "${1:-}" in
compile)
	git config --global --add safe.directory '*'
	reapi/version/appversion.sh . >/dev/null
	rm -rf build-win
	echo "==> Release"
	python3 support/vcxbuild.py reapi/msvc/reapi.vcxproj --sln msvc/reapi.sln --config Release --out build-win
	chown -R "$owner" build-win reapi/version/appversion.h
	;;
finish)
	echo "==> publish/ (win32)"
	rm -rf publish/debug
	mkdir -p publish/addons/amxmodx/modules publish/debug
	cp build-win/Release/reapi_amxx.dll publish/addons/amxmodx/modules/reapi_amxx.dll
	cp build-win/Release/reapi_amxx.pdb publish/debug/reapi_amxx.pdb

	echo "==> rcedit"
	wine /opt/rcedit-x86.exe publish/addons/amxmodx/modules/reapi_amxx.dll \
		--set-version-string CompanyName "ReHLDS Dev Team" \
		--set-version-string LegalCopyright "Copyright 2025 ReHLDS DevTeam" \
		--set-icon reapi/msvc/icon.ico
	if [ -f /run/sign/cert.pfx ]; then
		echo "==> Authenticode signing"
		f=publish/addons/amxmodx/modules/reapi_amxx.dll
		osslsigncode sign -pkcs12 /run/sign/cert.pfx -readpass /run/sign/pass -h sha256 \
			-n "ReAPI - reapi_amxx.dll" -i "https://github.com/$SLUG" -ts "$PFX_TIMESTAMP" -in "$f" -out "$f.signed"
		mv "$f.signed" "$f"
	fi
	chown -R "$owner" build-win publish
	;;
*) echo "usage: build-windows.sh compile|finish" >&2; exit 2 ;;
esac
