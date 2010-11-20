{application, fyzlab,
    [{description, "Control program"},
     {author, "Jakub Kulhan <jakub.kulhan@gmail.com>"},
     {modules, [fyzlab, fyzlab_sup]},
     {applications, [kernel, stdlib]},
     {mod, {fyzlab, []}},
     {env, [{cant_start, "zenity --error --text 'Cannot start some application.'"},
            {cant_find_master, "zenity --error --text 'Cannot find master.'"},
            {badarg_spawnkillable, "zenity --error --text 'Bad spawnkillable argument.'"},
            {badarg_continue, "zenity --error --text 'Bad continue argument.'"}
           ]}
    ]}.
