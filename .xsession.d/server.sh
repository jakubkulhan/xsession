#!/bin/sh

. "$HOME/.xsession.d/init.sh"

exec erl -name "master@$ip" \
    -setcookie "$erlang_cookie" \
    -noshell \
    -pa "$HOME/.xsession.d/nbh/ebin" \
    -eval 'application:start(crypto)' \
    -eval 'application:start(nbh)'
