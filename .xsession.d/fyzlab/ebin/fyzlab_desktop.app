{application, fyzlab_desktop,
    [{description, "Shared desktop"},
     {author, "Jakub Kulhan <jakub.kulhan@gmail.com>"},
     {modules, [fyzlab_desktop, fyzlab_desktop_sup]},
     {applications, [kernel, stdlib]},
     {mod, {fyzlab_desktop, []}},
     {env, [{command, "vncviewer -fullscreen"}]}
    ]}.
