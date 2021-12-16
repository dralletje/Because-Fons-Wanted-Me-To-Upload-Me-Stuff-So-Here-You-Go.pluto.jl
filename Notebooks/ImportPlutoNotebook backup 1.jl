### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 169b7cf5-e220-43e9-8041-6d22936bb5bd
import Pkg

# ╔═╡ e24a3b1f-bc46-44e6-83d7-fa0f98011fd8
ALPHA_WARNING = md"""
> ⚠️  This is really only meant as an preview.
> Your notebooks that use this **WILL GUARANTEED FAIL IN THE FUTURE**.
> For sure the urls and names will changes, at least, so even if we
> keep the exact same api... your notebooks will stop working.
> (We'll have an upgrade path though)
"""

# ╔═╡ dc03f5ee-3684-4619-8c73-ee544cbfd732
md"# Pluto Notebook from Gist"

# ╔═╡ bcffbd96-2890-4dc2-b1df-1f2265b0e024
md"## Implementation"

# ╔═╡ c7ce73fa-9ec8-4603-b26a-29d6f7ca0aae
import JSON3

# ╔═╡ 5dc644cb-3cf1-42a9-9a7e-6a7b603a51de
import Downloads

# ╔═╡ 4cc38bec-9154-4a41-bce5-32ff9ab81f2b
FILE_EXTENSION = ".pluto.jl"

# ╔═╡ 84d0aa73-cac7-416e-92fb-705067a95aaa
API_URL = "https://pluto-packages.dral.eu/api"

# ╔═╡ 48c239a0-b210-4564-8ea7-f83ea461bb4f
gist_url_regex = r"^https://gist.github.com/\w+/(\w+)$"

# ╔═╡ 65a75a15-dc5b-4b20-a834-5dd8e04b7bb5
macro from_gist(args...)
	error("Wrong syntax for `@from_gist`")
end

# ╔═╡ d76fe954-16f6-4b85-9a19-e680f40e2388
macro from_gist(do_fn::Expr, gist_url::String)
	# Pkg.Registry.add(Pkg.RegistrySpec(
	# 	url="http://161.35.80.175/PlutoPackages.git/"
	# ))

	@assert Meta.isexpr(do_fn, :(->), 2)
	@assert Meta.isexpr(do_fn.args[begin], :(tuple), 0)
	@assert Meta.isexpr(do_fn.args[begin+1], :(block), 2)

	import_statement = do_fn.args[begin+1].args[begin+1]

	@assert Meta.isexpr(import_statement, :import)

	alpha_warning = repr(MIME("text/html"), ALPHA_WARNING)
	html = HTML("""
	$(alpha_warning)
	<div style="height: 12px"></div>
	
	<code class="language-julia">
	$(import_statement)
	</code>
	<span style="
		font-family: JuliaMono, Menlo;
		font-size: 0.8em;
	">(from <a href="$(gist_url)">gist</a>)</span>
	""")
	
	quote
		$(esc(do_fn.args[begin+1]))
		$(html)
	end
end

# ╔═╡ b544098b-e406-4487-8c7f-e0bc84ea1d89
md"### Pluto Packages API"

# ╔═╡ b9ea7e78-ed1c-4eea-af7d-1ae192254385
function try_fetch_remote_gist(id)
	JSON3.read(sprint() do io
		gist_url = "$(API_URL)/fetch/gist/$id"
		Downloads.download(gist_url, io)
	end)
end

# ╔═╡ bbbd63ea-0462-4be1-8636-9f6bedf29af2
function is_in_local_registry(name)
	index = findfirst(Pkg.REPLMode.complete_remote_package(name)) do pkgname
		pkgname == name
	end

	index !== nothing
end

# ╔═╡ 6d53cd39-ac30-4092-b8be-a3a9e8e1c890
md"### Gist API"

# ╔═╡ 14c49f0e-0757-4d86-9f1f-619632393d90
function gist_by_id(id)
	JSON3.read(sprint() do io
		gist_url = "https://api.github.com/gists/$id"
		Downloads.download(gist_url, io,
			headers = Dict(
				"Accept" => "application/vnd.github.v3+json"
			),
		)
	end)
end

# ╔═╡ 7d067e4b-8fd4-4a87-bb26-c51996a4ef78
function gist_to_cute_name(gist)
	_, file = first(gist.files)

	@assert(
		endswith(file.filename, FILE_EXTENSION),
		"Filename has to end with $(FILE_EXTENSION)",
	)
	
	file.filename[begin:end-length(FILE_EXTENSION)]
end

# ╔═╡ 7e1cac70-2214-4f70-a3ba-bc6f86595d93
function gist_to_package_name(gist)
	username = gist.owner.login
	user_url = gist.owner.html_url
	last_version = length(gist.history)

	_, file = first(gist.files)

	@assert file.truncated == false "Can't handle too big files yet"
	@assert(
		endswith(file.filename, FILE_EXTENSION),
		"Filename has to end with $(FILE_EXTENSION)",
	)
	
	filename = file.filename[begin:end-length(FILE_EXTENSION)]
	
	# @assert(
	# 	match(r"^\w+$", filename) != nothing,
	# 	"Filename can only contain letters and numbers",
	# )
	
	"PlutoNotebook_Gist_$(username)_$(filename)_v$(last_version)"
end

# ╔═╡ dcec2b45-59d9-4833-9857-a638064b9568
macro from_gist(url::String)	
	# Pkg.Registry.add(Pkg.RegistrySpec(
	# 	url="http://161.35.80.175/PlutoPackages.git/"
	# ))

	gist_match = match(gist_url_regex, url)
	@assert gist_match !== nothing "Not a valid gist url"
	gist_id = gist_match.captures[1]
	
	gist = gist_by_id(gist_id)
	package_name = gist_to_package_name(gist)
	cute_name = gist_to_cute_name(gist)

	if !is_in_local_registry(package_name)
		response = try_fetch_remote_gist(gist_id)
		@info "response" response
		if response.status == "already_fetched" || response.status == "fetched"
			Pkg.Registry.update()
		else
			error("local registry $(response)")
		end
	end

	if !is_in_local_registry(package_name)
		error("Server says you have it, you say you don't.. who knows who's right")
	end

	Markdown.parse("""
	$(ALPHA_WARNING)
	
	Package is available on the Pluto packages server! 
	Now to actual use it, you need to replace the code in your cell
	with code that imports your package (so Pluto knows to install it).

	**Replace code:**
	```julia
	@from_gist("$(url)") do
		import $(package_name) as $(cute_name)
	end
	```
	""")
end

# ╔═╡ ced83598-9a38-4c0d-a81a-35555989fd1e
export @from_gist

# ╔═╡ 9f798726-a0e3-4bfd-a124-48edf2d3df81
@from_gist("https://gist.github.com/dralletje/2f38628516ee79ff580ae8faa258c43e")

# ╔═╡ 41ee322c-e583-4b01-a31e-8a01de87c90d
@from_gist("https://gist.github.com/dralletje/2f38628516ee79ff580ae8faa258c43e") do
	import var"PlutoNotebook_Gist_dralletje_Spaties in je naam_v1" as var"Spaties in je naam"
end

# ╔═╡ 7128d407-54b1-4003-a88b-1b7d9136ffe3
md"### Utilities"

# ╔═╡ 49067b9e-247f-45d6-a165-df530af1435e
macro skip_as_script(expr)
    if isdefined(Main, :PlutoRunner) && parentmodule(__module__) == Main
        Expr(:toplevel, esc(expr))
    else
        nothing
    end
end

# ╔═╡ 9f9e2b77-16ea-499d-99c6-6f052362f887
@skip_as_script html"""<div style="height:50px"></div>"""

# ╔═╡ eefc62a3-ccfe-474e-a162-ad4dce580992
@skip_as_script begin
@from_gist("https://gist.github.com/dralletje/48b253aeb035b8dc437a106315a3fba0")
end

# ╔═╡ f9263bb0-129a-4065-9635-c0ec71fac51e
@skip_as_script html"<div style='height: 30px'>"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[compat]
JSON3 = "~1.9.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─e24a3b1f-bc46-44e6-83d7-fa0f98011fd8
# ╟─dc03f5ee-3684-4619-8c73-ee544cbfd732
# ╠═ced83598-9a38-4c0d-a81a-35555989fd1e
# ╟─9f9e2b77-16ea-499d-99c6-6f052362f887
# ╠═eefc62a3-ccfe-474e-a162-ad4dce580992
# ╟─f9263bb0-129a-4065-9635-c0ec71fac51e
# ╟─bcffbd96-2890-4dc2-b1df-1f2265b0e024
# ╠═c7ce73fa-9ec8-4603-b26a-29d6f7ca0aae
# ╠═5dc644cb-3cf1-42a9-9a7e-6a7b603a51de
# ╠═169b7cf5-e220-43e9-8041-6d22936bb5bd
# ╟─4cc38bec-9154-4a41-bce5-32ff9ab81f2b
# ╟─84d0aa73-cac7-416e-92fb-705067a95aaa
# ╟─48c239a0-b210-4564-8ea7-f83ea461bb4f
# ╠═65a75a15-dc5b-4b20-a834-5dd8e04b7bb5
# ╠═dcec2b45-59d9-4833-9857-a638064b9568
# ╠═d76fe954-16f6-4b85-9a19-e680f40e2388
# ╟─b544098b-e406-4487-8c7f-e0bc84ea1d89
# ╟─b9ea7e78-ed1c-4eea-af7d-1ae192254385
# ╟─bbbd63ea-0462-4be1-8636-9f6bedf29af2
# ╟─6d53cd39-ac30-4092-b8be-a3a9e8e1c890
# ╟─14c49f0e-0757-4d86-9f1f-619632393d90
# ╟─7d067e4b-8fd4-4a87-bb26-c51996a4ef78
# ╠═7e1cac70-2214-4f70-a3ba-bc6f86595d93
# ╠═9f798726-a0e3-4bfd-a124-48edf2d3df81
# ╠═41ee322c-e583-4b01-a31e-8a01de87c90d
# ╟─7128d407-54b1-4003-a88b-1b7d9136ffe3
# ╟─49067b9e-247f-45d6-a165-df530af1435e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
