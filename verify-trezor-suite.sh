#!/bin/sh

check_readme() {
  verification=

  while true
  do
    read -r -p "Did you read the README.md file? It's recommended to read the README.md file and verify the integrity of this verification script before continuing. [Y/n] " verification

    case $verification in
      [yY][eE][sS]|[yY]|"")
        printf "\nProceeding with verification...\n\n"
        break
        ;;
      [nN][oO]|[nN])
        printf "\nAlright come back when you have read the README.md file and verified the integrity of this script.\n"
        exit 1
        ;;
      *)
        printf "\nInvalid input...\n\n"
        ;;
    esac
  done
}

signing_key_notification() {
  confirmation=
  while true
  do
    printf "Trezor updates their signing key, so if you have the option to download multiple keys only download one of the keys.\n"
    printf "Use the newest key if you're using the latest version of Trezor Suite.\n"
    printf "If you're using an older version of Trezor Suite, then download the key used with your release.\n"
    read -r -p "Have you downloaded the correct signing key? [Y/n] " confirmation

    case $confirmation in
      [yY][eE][sS]|[yY]|"")
        printf "\nProceeding with verification...\n\n"
        break
        ;;
      [nN][oO]|[nN])
        printf "\nYou can download the signing key for the release you're using from their website.\n"
        printf "https://trezor.io/trezor-suite\n\n"
        ;;
      *)
        printf "\nInvalid input...\n\n"
        ;;
    esac
  done
}

initial_instructions() {
  printf "To verify your Trezor Suite install binary you need to download the following files:\n"
  printf "Trezor-Suite-*.AppImage\n"
  printf "Trezor-Suite-*.AppImage.asc\n"
  printf "satoshilabs-*-signing-key.asc\n\n"
  printf "Here's a link to the Trezor Suite releases, signatures, and signing keys page where you can download the above files.\n"
  printf "If you prefer to not share your IP address with Trezor, then use a trusted VPN or Tor when visiting their website to mask your IP address.\n"
  printf "https://trezor.io/trezor-suite\n\n"
  printf "If you want to download an older release, then take a look at the releases page on GitHub:\n"
  printf "https://github.com/trezor/trezor-suite/releases\n\n"
  signing_key_notification
  printf "The *'s in the file names above will be replaced by whatever version of Trezor Suite you're verifying.\n"
  printf "Note if Trezor updates their signing key again, then the newer signing key will have to be used instead of the older one during verification.\n"
  printf "Currently the script only supports checking for the 2020 and 2021 signing keys, so the script will have to be updated to handle any new key or to handle any arbitrary signing key.\n"
  printf "Be sure to double check the link is bringing you to Trezor's official website!\n"
  printf "Also make sure you download the files to the same directory as the verification script.\n\n"
}

trezor_suite_app_image=
trezor_suite_app_image_asc=
satoshilabs_signing_key=

check_for_file() {
  if compgen -G "$1" > /dev/null; then
    if [ "$1" == "Trezor-Suite-*.AppImage" ]; then
      trezor_suite_app_image=$(compgen -G "$1")
      printf "The $trezor_suite_app_image is the binary installation file that we'll be verifying.\n\n"
    elif [ "$1" == "Trezor-Suite-*.AppImage.asc" ]; then
      trezor_suite_app_image_asc=$(compgen -G "$1")
      printf "The $trezor_suite_app_image_asc file is the signature file we'll be using.\n\n"
    elif [ "$1" == "satoshilabs-*-signing-key.asc" ]; then
      satoshilabs_signing_key=$(compgen -G "$1")
      printf "The $satoshilabs_signing_key file is Trezor's signing key we'll be using.\n\n"
    fi
  else
    printf "$1 not found.\n"
    printf "Make sure to download the file to the same directory as the verification script.\n"
    exit 1
  fi
}

import_signing_key() {
  printf "To verify the authenticity of the Trezor suite binary installation file we need to import the signing key used with the release.\n\n"

  gpg --import $satoshilabs_signing_key
  printf "\nIf you want to be certain you're inputting the correct signing key, then check the code and/or run the commands manually.\n"
  printf "You can find the commands on the Download and Verify Trezor Suite App webpage:\n"
  printf "https://trezor.io/learn/a/download-verify-trezor-suite-app\n\n"
}

verify_signature() {
  printf "We're now ready to verify the signature using the Trezor-Suite-*.AppImage.asc file.\n\n"

  if gpg --verify $trezor_suite_app_image_asc;  then

    printf '\nGnuPG returned a positive match on the signing key, i.e., Good signature from "SatoshiLabs 2021 Signing Key".\n'
    printf "The primary key fingerprint should be: EB48 3B26 B078 A4AA 1B6F 425E E21B 6950 A2EC B65C\n\n"
    printf "Unless you tell GnuPG to trust the key, you'll see a warning similar to the following:\n\n"
    printf "gpg: WARNING: This key is not certified with a trusted signature!\n"
    printf "gpg:          There is no indication that the signature belongs to the owner.\n\n"
    printf "This warning means that the key is not certified by another third party authority.\n"
    printf "If the downloaded file was a fake, then the signature verification process would fail and you would be warned that the fingerprints don't match.\n\n"
    printf "When you get a warning like this it's also good practice to check the key against other sources, e.g., the Download and Verify Trezor Suite App webpage:\n"
    printf "https://trezor.io/learn/a/download-verify-trezor-suite-app\n\n"
    printf "Your Trezor Suite download has been successfully verified!\n\n"
    printf "If you want to be certain the signature verification was correct, then check the code and/or run the commands manually.\n"
    printf "You can find the commands on the Download and Verify Trezor Suite App webpage:\n"
    printf "https://trezor.io/learn/a/download-verify-trezor-suite-app\n\n"
    printf "You're now ready to install Trezor Suite!\n"
  else
    printf "\nThe signature verification failed.\n"
    printf "Double check that you're using Trezor's official website, that you downloaded the correct Trezor Suite binary installation, signature, and signing key.\n"
    printf "The Trezor Suite binary installation file name should be in the following format: Trezor-Suite-*.AppImage.\n"
    printf "The Trezor Suite binary signature file name should be in the following format: Trezor-Suite-*.AppImage.asc.\n"
    exit 1
  fi
}

check_readme
initial_instructions
check_for_file "Trezor-Suite-*.AppImage"
check_for_file "Trezor-Suite-*.AppImage.asc"
check_for_file "satoshilabs-*-signing-key.asc"
import_signing_key
verify_signature
