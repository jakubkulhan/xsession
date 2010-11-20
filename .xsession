#!/bin/sh

. "$HOME/.xsession.d/init.sh"

exec erl -name "node@$ip" \
    -setcookie "$erlang_cookie" \
    -noshell \
    -pa "$HOME/.xsession.d/fyzlab/ebin" \
    -pa "$HOME/.xsession.d/nbh/ebin" \
    -fyzlab_continue "$HOME/.xsession.d/continue.sh" \
    -fyzlab_desktop_spawnkillable "$HOME/.xsession.d/spawnkillable.sh" \
    -s fyzlab
