#!/usr/bin/env bash
# Local F-Droid repo maintenance: stages the real keystore material from
# ~/.bvapp-release/ into fdroid/ and runs `fdroid update`.
# Mirrors what the CI publish job does with repo secrets. Secrets never
# reach git: release.keystore is untracked and config.yml is restored.
#
# Usage: place the signed release APK as
#   fdroid/repo/org.berlin_vegan.bvapp_<versionCode>.apk
# then run this script.
set -euo pipefail
cd "$(dirname "$0")/../fdroid"

BVAPP_SECRETS="${BVAPP_SECRETS:-$HOME/.bvapp-release}"
export BVAPP_SECRETS
python3 -c "import base64,os,sys; sys.stdout.buffer.write(base64.b64decode(open(os.path.join(os.environ['BVAPP_SECRETS'], 'keystore-b64.txt')).read()))" > release.keystore
chmod 600 release.keystore
PASS=$(cat "$BVAPP_SECRETS/keystore-password.txt")
sed -e "s/FDROID_KEYSTOREPASS_PLACEHOLDER/$PASS/g" \
    config.yml > config.local.yml
cp config.local.yml config.yml
trap 'rm -f config.local.yml release.keystore; git checkout -q -- config.yml 2>/dev/null || true' EXIT

# fdroidserver shells out to apksigner; it is not on a default PATH.
export PATH="$ANDROID_HOME/build-tools/36.1.0:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

fdroid update
