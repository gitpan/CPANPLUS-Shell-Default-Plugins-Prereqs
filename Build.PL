use Module::Build;
my $build = Module::Build->new(
    module_name             => 'CPANPLUS::Shell::Default::Plugins::Prereqs',
    license                 => 'perl',
    create_readme           =>  1,
    create_makefile_pl      => 'passthrough',
    requires                => {
            'Carp'              => 0,
            'Params::Check'     => 0,
            'Data::Dumper'      => 0,
        },
);

$build->create_build_script;


