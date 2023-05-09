#!/bin/bash

trezor_suite_app_image=
trezor_suite_icon=

check_verification() {
  verification=

  while true
  do
    read -r -p "Did you read the README.md file? It's recommended to read the README.md file, verify the integrity of this installation script, and verify the Trezor Suite install binary before continuing. [Y/n] " verification

    case $verification in
      [yY][eE][sS]|[yY]|"")
        printf "\nProceeding with installation...\n\n"
        break
        ;;
      [nN][oO]|[nN])
        printf "\nAlright come back when you have read the README.md file, verified the integrity of this script, and verified the Trezor Suite install binary which you can do by running the verify-trezor-suite.sh script.\n"
        exit 1
        ;;
      *)
        printf "\nInvalid input...\n\n"
        ;;
    esac
  done
}

check_for_file() {
  if compgen -G "$1" > /dev/null; then
    if [ "$1" == "Trezor-Suite-*.AppImage" ]; then
      trezor_suite_app_image=$(compgen -G "$1")
      printf "Located the $trezor_suite_app_image file.\n\n"
    elif [ "$1" == "trezor-suite-icon.png" ]; then
      trezor_suite_icon=$(compgen -G "$1")
      printf "Located the $trezor_suite_icon file.\n\n"
    fi
  else
    printf "$1 not found.\n"
    printf "Make sure to download the file to the same directory as the installation script.\n"
    exit 1
  fi
}

check_sudo() {
  until $1
  do
    exit 1
    sleep 1
  done
}

set_up_sudo_session() {
  printf "Setting up sudo session...\n"
  check_sudo 'sudo -v'
}

make_file_executable() {
  printf "\nMaking the $trezor_suite_app_image file executable.\n\n"
  chmod u+x $trezor_suite_app_image
}

rename_file() {
  printf "Renaming the $trezor_suite_app_image file to trezor-suite.AppImage.\n\n"
  mv $trezor_suite_app_image "trezor-suite.AppImage"
  trezor_suite_app_image="trezor-suite.AppImage"
}

move_file_to_opt() {
  printf "Moving the $trezor_suite_app_image file to /opt.\n\n"
  sudo mv $trezor_suite_app_image /opt
}

make_symbolic_link() {
  printf "Making a symbolic link for the $trezor_suite_app_image file in /opt to /usr/bin/trezor-suite.\n\n"
  sudo ln -sf /opt/$trezor_suite_app_image /usr/bin/trezor-suite
}

move_icon() {
  printf "Moving the $trezor_suite_icon file to $HOME/.local/share/icons.\n\n"
  if [ ! -d $HOME/.local/share/icons ]; then
    mkdir $HOME/.local/share/icons
  fi
  mv $trezor_suite_icon $HOME/.local/share/icons
}

make_desktop_entry() {
  printf "Making a desktop entry for Trezor Suite in /usr/share/applications/trezor-suite.desktop with the following contents:\n\n"
  cat <<EOF | sudo tee /usr/share/applications/trezor-suite.desktop
[Desktop Entry]
Type=Application
Name=Trezor Suite
Comment=Trezor Suite
Icon=$HOME/.local/share/icons/trezor-suite-icon.png
Exec=trezor-suite
Terminal=false
Categories=Finance;
EOF
}

how_to_run_app() {
  printf "\nTrezor Suite installation complete!\n\n"
  printf "You can launch Trezor Suite from anywhere in the terminal using the following command:\n\n"
  printf "trezor-suite\n\n"
  printf "You can also launch Trezor Suite by clicking on the desktop entry.\n"
}

check_verification
check_for_file "Trezor-Suite-*.AppImage"
check_for_file "trezor-suite-icon.png"
set_up_sudo_session
make_file_executable
rename_file
move_file_to_opt
make_symbolic_link
move_icon
make_desktop_entry
how_to_run_app
