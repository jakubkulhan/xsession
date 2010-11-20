#!/bin/sh

server_ip="$1"
home_tar="$HOME/.xsession.d/home.tar.gz"

if ! wget -q -O "$home_tar" "http://$server_ip/home.tar.gz"; then
    zenity --error --text "Cannot fetch home.tar.gz."
    exit 1
fi

if ! find $HOME ! -path "$HOME" ! -path "$HOME/.xsession*" ! -path "$HOME/.xinitrc" -delete; then
    zenity --error --text "Cannot delete home directory."
    exit 1
fi

cd "$HOME"
tar -xzf "$home_tar"

exec gnome-session
