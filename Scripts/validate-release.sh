#!/bin/sh

set -eu

archive_path="${1:-/tmp/MarvelChallenge-2.0.0.xcarchive}"
app_path="$archive_path/Products/Applications/MarvelChallenge.app"
binary_path="$app_path/MarvelChallenge"
expected_version="2.0.0"

if [ ! -f "$binary_path" ]; then
    echo "Archive não encontrado em $archive_path"
    exit 1
fi

actual_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$app_path/Info.plist")
if [ "$actual_version" != "$expected_version" ]; then
    echo "Versão esperada: $expected_version; encontrada: $actual_version"
    exit 1
fi

forbidden_symbols="DebugHeroService|DebugFavoritesStore|DebugSampleData|-useLiveData"
if strings "$binary_path" | grep -E "$forbidden_symbols" >/dev/null; then
    echo "O executável Release contém suporte exclusivo do modo Debug"
    exit 1
fi

if strings "$binary_path" | grep -E '(^|[^[:alnum:]])[0-9a-fA-F]{32,}([^[:alnum:]]|$)' >/dev/null; then
    echo "O executável contém um valor com aparência de credencial"
    exit 1
fi

echo "Archive $actual_version validado sem suporte de demonstração ou valores com aparência de credencial"
