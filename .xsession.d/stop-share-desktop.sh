#!/bin/sh

. "$HOME/.xsession.d/init.sh"

exec erl -name "dummy@$ip" \
    -setcookie "$erlang_cookie" \
    -noshell \
    -pa "$HOME/.xsession.d/fyzlab/ebin" \
    -pa "$HOME/.xsession.d/nbh/ebin" \
    -eval 'fyzlab:stop_share_desktop()'
