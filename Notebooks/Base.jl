### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ e9412b62-0c08-11eb-074f-718b5111f7d7
begin
    import Pkg
    Pkg.add(url="https://github.com/Pocket-titan/DarkMode")
    import DarkMode
	
    DarkMode.enable()
end

# ╔═╡ ee2d8b1c-0c14-11eb-2a10-df7a3694196f
export DarkMode

# ╔═╡ 1a194d82-0c09-11eb-0de0-2b2213dc128a
DarkmodePlus = let
	DarkMode
	html"""<style>
	html {
		filter: hue-rotate(180deg) sepia(.5);
	}

	nav#at_the_top img {
		filter: invert(1);
	}
	
	jlerror > header {
		color: #a3a3a3;
	}
	
	pluto-filepicker .cm-s-material-palenight .cm-operator {
		color: #ff3b00;
	}
	"""
end

# ╔═╡ 40ef5f2e-0c08-11eb-30c5-15375fce7ca7
module Install include("./Install.jl") end

# ╔═╡ 6f246b96-0c08-11eb-0f50-610116c8edd4
var"@add" = Install.var"@install"

# ╔═╡ c2760cb0-0c16-11eb-1a2d-a3db33a6836c
export var"@add"

# ╔═╡ Cell order:
# ╠═ee2d8b1c-0c14-11eb-2a10-df7a3694196f
# ╠═e9412b62-0c08-11eb-074f-718b5111f7d7
# ╠═1a194d82-0c09-11eb-0de0-2b2213dc128a
# ╠═40ef5f2e-0c08-11eb-30c5-15375fce7ca7
# ╠═c2760cb0-0c16-11eb-1a2d-a3db33a6836c
# ╠═6f246b96-0c08-11eb-0f50-610116c8edd4
