project('com.github.phoneybadger.trimmer', 'c', 'vala', version: '1.0.1')

subdir('src')
subdir('data')
subdir('po')
subdir('test')

glib_dep = [dependency('glib-2.0')]
gtk_dep = [dependency('gtk+-3.0')]
granite_dep = [dependency('granite')]
gst_deps = [dependency('clutter-gst-3.0'), dependency('clutter-gtk-1.0')]

executable (
    meson.project_name(),
    trimmer_resources,
    sources,
    dependencies : [glib_dep, gtk_dep, granite_dep, gst_deps],
    install: true
)

meson.add_install_script('meson/post_install.py')
