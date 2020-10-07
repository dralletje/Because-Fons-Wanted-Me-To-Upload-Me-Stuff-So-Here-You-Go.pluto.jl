cd pluto-on-binder

PLUTO_BRANCH=$(cd ../Pluto.jl && git rev-parse --abbrev-ref HEAD)

TEMPLATE=$(cat << EOF
using Pkg;
Pkg.activate(".");
Pkg.add(url="https://github.com/dralletje/Pluto.jl", rev=ARGS[1])
EOF
)

git add Manifest.toml
git commit -m "Bump" 

julia -e "$TEMPLATE" "$PLUTO_BRANCH"