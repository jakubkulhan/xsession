#!/bin/sh
ip="$(ifconfig | egrep 'inet add?r:' |
      grep -v '127.0.0.1' |
      cut -d: -f2 | awk '{print $1}')"

erlang_cookie="$(cat "$HOME/.xsession.d/cookie")"
