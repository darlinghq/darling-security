
find . -type f -not -wholename \*.git\* -exec sed -i 's/CoreServices\/\.\.\/Frameworks\/CarbonCore\.framework\/Headers/CoreServices/' {} \;

