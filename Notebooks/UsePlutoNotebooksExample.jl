### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 7e2f081c-2cba-48db-a252-7bc04879d24b
md"""
# ImportPlutoNotebooks Example

Before this notebook even works, you need to add my PlutoPackages registry:

```julia
(@v1.6) pkg> registry add https://pluto-packages.dral.eu/PlutoPackages.git
```
"""

# ╔═╡ 3e1c9d7d-eb63-46aa-854b-3226f41e4023
md"""
After that you can import the `ImportPlutoNotebook` package with its
special, long, import name. I'll explain why these are this long in a bit.
"""

# ╔═╡ 2f03bf8e-16e5-4b67-ae27-b50a40c3572f
import PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4: @from_gist

# ╔═╡ 8347969b-dc01-42d7-bb74-26e77f773e50
md"""
With this installed, you can ask the package server to fetch you a notebook from a [GitHub Gist](https://gist.github.com/). I'll use my own [`PrettyExpr.pluto.jl`](https://gist.github.com/dralletje/48b253aeb035b8dc437a106315a3fba0) as an example:
"""

# ╔═╡ 4f96fa63-4e84-4845-b389-52386a2beb15
html"""<div style="height: 30px"></div>"""

# ╔═╡ 72cfc62d-3939-4c3b-b3ac-81b28179a3aa
md"""
## 1. Ask server to fetch

With the `@from_gist` macro we send a request to the server asking it to turn
the gist from the url into a julia package. Once it has done that, the macro will
show you the code to import the package.

The name is automatically generated based on the gist it comes from:
```julia
"PlutoNotebooks_Gist_$(username)_$(filename)_v$(revision)"
```

This is sooo long because we want to make it generic and not collide with any
packages in general.
"""

# ╔═╡ 29ead1f6-27ab-463f-aa86-363b406cd3a7
md"---"

# ╔═╡ 5047e6c4-c4f5-4639-bad2-375a28ae7294
@from_gist("https://gist.github.com/dralletje/48b253aeb035b8dc437a106315a3fba0")

# ╔═╡ b32554ad-7fbe-4482-8119-cd456b931519
html"""<div style="height: 60px"></div>"""

# ╔═╡ 18ab3cdc-ae98-480b-a321-79adeede6973
md"## 2. Put `import` in"

# ╔═╡ 5f664b3a-2f0d-4c38-b02c-f520a2e13a7c
md"""
It now turned the gist into a package in the back, and this allows you to import it.
You can just `import` it, but I'd suggest keeping the `@from_gist` wrapper.
"""

# ╔═╡ 2ea247ab-f8b0-4f61-97e3-145b9d1efe43
md"---"

# ╔═╡ be2331eb-9f7d-424e-aea0-1df25cb520a6
@from_gist("https://gist.github.com/dralletje/48b253aeb035b8dc437a106315a3fba0") do
	import PlutoNotebook_Gist_dralletje_PrettyExpr_v5 as PrettyExpr
end

# ╔═╡ 910d7d37-f3e1-4d58-b4b1-cc005908c2c4
html"""<div style="height: 60px"></div>"""

# ╔═╡ 17884504-d7a7-40b2-a42f-8a97da586ba9
md"## 3. Fun"

# ╔═╡ 8ad4a21d-6bbb-4a5e-8bf5-cf0ade0868a4
md"""
And now we can use it!
"""

# ╔═╡ f43ff98f-6106-4fc3-b8a6-5acdca3c1b28
md"---"

# ╔═╡ d698ab0b-e4d3-4023-a3bc-e12ae0b24191
PrettyExpr.PrettyExpr(quote
	const g = 20
	
	"My function"
	function X(z)
		z + z^2
	end
end)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4 = "b76dd30b-315f-5257-a48f-1ecd7c99085e"
PlutoNotebook_Gist_dralletje_PrettyExpr_v5 = "db0f8c0b-b3dc-5b5a-b085-90fac21b36eb"

[compat]
PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4 = "~0.1.0"
PlutoNotebook_Gist_dralletje_PrettyExpr_v5 = "~0.1.0"
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

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

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

[[PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4]]
deps = ["Downloads", "JSON3", "Markdown", "Pkg"]
git-tree-sha1 = "fe07f6a5f963189c3a828e57154b33da4ca3f262"
uuid = "b76dd30b-315f-5257-a48f-1ecd7c99085e"
version = "0.1.0"

[[PlutoNotebook_Gist_dralletje_PrettyExpr_v5]]
deps = ["HypertextLiteral", "Markdown"]
git-tree-sha1 = "05905fb4a21ed7be4c8a01e3b739984528ba4290"
uuid = "db0f8c0b-b3dc-5b5a-b085-90fac21b36eb"
version = "0.1.0"

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
# ╟─7e2f081c-2cba-48db-a252-7bc04879d24b
# ╟─3e1c9d7d-eb63-46aa-854b-3226f41e4023
# ╠═2f03bf8e-16e5-4b67-ae27-b50a40c3572f
# ╟─8347969b-dc01-42d7-bb74-26e77f773e50
# ╟─4f96fa63-4e84-4845-b389-52386a2beb15
# ╟─72cfc62d-3939-4c3b-b3ac-81b28179a3aa
# ╟─29ead1f6-27ab-463f-aa86-363b406cd3a7
# ╠═5047e6c4-c4f5-4639-bad2-375a28ae7294
# ╟─b32554ad-7fbe-4482-8119-cd456b931519
# ╟─18ab3cdc-ae98-480b-a321-79adeede6973
# ╟─5f664b3a-2f0d-4c38-b02c-f520a2e13a7c
# ╟─2ea247ab-f8b0-4f61-97e3-145b9d1efe43
# ╠═be2331eb-9f7d-424e-aea0-1df25cb520a6
# ╟─910d7d37-f3e1-4d58-b4b1-cc005908c2c4
# ╠═17884504-d7a7-40b2-a42f-8a97da586ba9
# ╟─8ad4a21d-6bbb-4a5e-8bf5-cf0ade0868a4
# ╟─f43ff98f-6106-4fc3-b8a6-5acdca3c1b28
# ╠═d698ab0b-e4d3-4023-a3bc-e12ae0b24191
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
