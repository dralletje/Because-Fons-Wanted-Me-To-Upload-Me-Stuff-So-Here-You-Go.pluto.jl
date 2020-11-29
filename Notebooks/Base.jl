### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 4d135c4c-13f9-11eb-3950-1bdae8a6aa1d
md"## DarkMode"

# ╔═╡ ee2d8b1c-0c14-11eb-2a10-df7a3694196f
export DarkmodePlus

# ╔═╡ 1a194d82-0c09-11eb-0de0-2b2213dc128a
# DarkmodePlus = let
# 	[
# 		DarkMode.enable(),
# 		html"""<style>
# 			html {
# 				filter: hue-rotate(180deg) sepia(.5);
# 			}

# 			nav#at_the_top img {
# 				filter: invert(1);
# 			}

# 			jlerror > header {
# 				color: #a3a3a3;
# 			}

# 			pluto-filepicker .cm-s-material-palenight .cm-operator {
# 				color: #ff3b00;
# 			}
# 		"""
# 	]
# end

# ╔═╡ 90757d7c-13f8-11eb-1edf-23ec807b42c9
PlutoCssFixes = html"""<style>
pluto-output > div > style:only-child,
v > style:only-child {
	display: block;
	font-size: 0;
}

pluto-output > div > style:only-child::before,
v > style:only-child::before {
	content: "<style>";
	font-size: 0.75rem;
	color: #ef6155;
	font-family: JuliaMono, monospace;
	display: block;
	padding-bottom: 5px;
	padding-top: 5px;
}
"""

# ╔═╡ 6147793e-13f9-11eb-2f2c-5b262554c1cd
export PlutoCssFixes

# ╔═╡ 40abb370-13f9-11eb-0076-8702beb8070b
md"## DralCore"

# ╔═╡ aa23d698-13c0-11eb-28db-93ea968fb0e4
module DralCore include("./DralCore.jl") end

# ╔═╡ ae8a7fa4-13c0-11eb-109e-fb69f1aaea5f
@eval import .$(:DralCore): @identity, @displayonly, Inspect, PlutoWidget

# ╔═╡ 4632c982-13f9-11eb-11d2-4bc580dc4f1c
export @identity, @displayonly, Inspect, PlutoWidget

# ╔═╡ ec70f096-17f8-11eb-2c09-631b81dd9602
module X
	Main.PlutoRunner
end

# ╔═╡ 6b53e4b0-13f9-11eb-20a8-999862e6ece1
md"## @add"

# ╔═╡ 40ef5f2e-0c08-11eb-30c5-15375fce7ca7
module InstallMacro include("./installmacro.jl") end

# ╔═╡ 6f246b96-0c08-11eb-0f50-610116c8edd4
import .InstallMacro: @add

# ╔═╡ 9435db42-13f7-11eb-02d2-87b600569544
@add import DarkMode "https://github.com/Pocket-titan/DarkMode"

# ╔═╡ 68edd35e-13f9-11eb-350c-ad2fc06da27e
export @add

# ╔═╡ ffc548ee-1781-11eb-0438-e9bb4094e57e
md"## ForceMime"

# ╔═╡ ffc65ba8-1781-11eb-3f45-5de579f50a2a
PlutoTree = MIME"application/vnd.pluto.tree+xml"

# ╔═╡ ffe0a2ee-1781-11eb-3e80-374566dde9ee
struct ForceMime{T_MIME <: MIME}
	mime::T_MIME
	value
end

# ╔═╡ 6e959048-1783-11eb-0550-e75856e5be64
export ForceMime

# ╔═╡ 000b1d06-1782-11eb-1ba2-69af25f4e610
function Base.show(io::IO, ::T, forced::ForceMime{T}) where T
	show(io, T(), forced.value)
end

# ╔═╡ 004453dc-1782-11eb-001f-e7f96cd76a50
function Base.show(io::IO, ::PlutoTree, forced::ForceMime{PlutoTree})
	if showable(PlutoTree(), forced.value)
		show(io, PlutoTree(), forced.value)
	else
		PlutoRunner.show_struct(io, forced.value)
	end
end

# ╔═╡ 0047b6ee-1782-11eb-34fe-a5ef24c2d909
function Base.show(io::IO, ::MIME"text/plain", forced::ForceMime)
	show(io, forced.mime, forced.value)
end

# ╔═╡ 008d78be-1782-11eb-2b3d-bf3227d80e89
function Base.showable(mime::MIME"text/plain", forced::ForceMime)
	true
end

# ╔═╡ 0090561a-1782-11eb-1e42-617e44814e03
function Base.showable(mime::MIME, forced::ForceMime)
	forced.mime == mime
end

# ╔═╡ Cell order:
# ╟─4d135c4c-13f9-11eb-3950-1bdae8a6aa1d
# ╠═ee2d8b1c-0c14-11eb-2a10-df7a3694196f
# ╠═9435db42-13f7-11eb-02d2-87b600569544
# ╠═1a194d82-0c09-11eb-0de0-2b2213dc128a
# ╠═6147793e-13f9-11eb-2f2c-5b262554c1cd
# ╠═90757d7c-13f8-11eb-1edf-23ec807b42c9
# ╟─40abb370-13f9-11eb-0076-8702beb8070b
# ╠═4632c982-13f9-11eb-11d2-4bc580dc4f1c
# ╠═aa23d698-13c0-11eb-28db-93ea968fb0e4
# ╠═ae8a7fa4-13c0-11eb-109e-fb69f1aaea5f
# ╠═ec70f096-17f8-11eb-2c09-631b81dd9602
# ╟─6b53e4b0-13f9-11eb-20a8-999862e6ece1
# ╠═68edd35e-13f9-11eb-350c-ad2fc06da27e
# ╠═40ef5f2e-0c08-11eb-30c5-15375fce7ca7
# ╠═6f246b96-0c08-11eb-0f50-610116c8edd4
# ╟─ffc548ee-1781-11eb-0438-e9bb4094e57e
# ╠═6e959048-1783-11eb-0550-e75856e5be64
# ╟─ffc65ba8-1781-11eb-3f45-5de579f50a2a
# ╟─ffe0a2ee-1781-11eb-3e80-374566dde9ee
# ╟─000b1d06-1782-11eb-1ba2-69af25f4e610
# ╟─004453dc-1782-11eb-001f-e7f96cd76a50
# ╟─0047b6ee-1782-11eb-34fe-a5ef24c2d909
# ╟─008d78be-1782-11eb-2b3d-bf3227d80e89
# ╟─0090561a-1782-11eb-1e42-617e44814e03
