### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ b7226fee-25b0-4ef3-baee-d92412298ea0
module PlutoHooks
	include("/Users/michiel/Projects/PlutoHooks.jl/src/notebook.jl")
end

# ╔═╡ 782069b1-1eac-4fb5-a14b-fa15f39cad84
import .PlutoHooks: @use_ref, @give_me_rerun_cell_function, @use_deps, @use_effect

# ╔═╡ 18961124-6885-4001-bab3-c74c67f9bd55
import PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4: @from_gist

# ╔═╡ 96c3f335-dc62-42ae-b172-4d0b4e3e39a3
@from_gist("https://gist.github.com/dralletje/48b253aeb035b8dc437a106315a3fba0") do
	import PlutoNotebook_Gist_dralletje_PrettyExpr_v5: PrettyExpr
end

# ╔═╡ e3cae9a5-0941-4ad5-b0c2-ce9971c7d630
sprint(dump, :(@X.x() do; end)) |> Text

# ╔═╡ 6aeb0d47-633a-4de3-9c6c-7419f59266f6
@m (* 2 2)

# ╔═╡ ad4c26ad-f3ab-477f-9a1a-6ce0472f7004
macro X(fn)
	quote $(fn) end
end

# ╔═╡ 15aa4e95-9928-4b56-a825-4ddeb072ed36


# ╔═╡ 46dee276-094c-4b93-bf9c-946da711026e
sprint(dump, :(X.@x() do; end)) |> Text

# ╔═╡ a2b097e7-476f-4ac6-bfce-eadb471f9c70
macro run_f(block)
	quote
		let
			my_value = :from_run_f
			$(block)
		end
	end
end

# ╔═╡ 80bbeef5-4f5f-49c7-8330-f5357a3eeb45
macro assigns_to_my_value()
	quote my_value = :from_nested_macro end
end

# ╔═╡ b1f0365f-e85b-4819-a377-44c68f1684ad
macro has_my_value()
	quote
		my_value = :from_outer_macro
		@assigns_to_my_value()
		my_value
	end
end

# ╔═╡ c22c84eb-167b-45d5-b729-68bcbfbbe946
PrettyExpr(@macroexpand @has_my_value())

# ╔═╡ e90e7991-d0e0-4e71-8cd7-49077a574ccc
@has_my_value()

# ╔═╡ ad6a76a0-a3b7-4729-9130-0dcd2a9a33dc
module Grrr
	macro run_f(block)
		quote
			my_value = :from_run_f
			$(esc(block))
		end
	end
	macro parent()
		quote
			my_value = :parent
			@run_f begin
				my_value
			end
		end
	end

	gg = @parent()
end

# ╔═╡ 4cd3555c-2d01-45b8-9319-e450d22394a5
Grrr.gg

# ╔═╡ 9b48db38-cbee-422c-bbdc-d319b711d65f
RecursiveMacroExpand.@recursive_macroexpand1(@parent)

# ╔═╡ 6bb95004-4698-4897-b5ce-34655394e95b
 @parent()

# ╔═╡ 9d73cff3-3093-4d7a-baef-ab4b748ece99
module RecursiveMacroExpand
	include(expanduser("~/Projects/Notebooks/RecursiveMacroExpand.jl"))
end

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
# ╠═b7226fee-25b0-4ef3-baee-d92412298ea0
# ╠═782069b1-1eac-4fb5-a14b-fa15f39cad84
# ╠═18961124-6885-4001-bab3-c74c67f9bd55
# ╠═96c3f335-dc62-42ae-b172-4d0b4e3e39a3
# ╠═e3cae9a5-0941-4ad5-b0c2-ce9971c7d630
# ╠═6aeb0d47-633a-4de3-9c6c-7419f59266f6
# ╠═ad4c26ad-f3ab-477f-9a1a-6ce0472f7004
# ╠═15aa4e95-9928-4b56-a825-4ddeb072ed36
# ╠═46dee276-094c-4b93-bf9c-946da711026e
# ╠═a2b097e7-476f-4ac6-bfce-eadb471f9c70
# ╠═80bbeef5-4f5f-49c7-8330-f5357a3eeb45
# ╠═b1f0365f-e85b-4819-a377-44c68f1684ad
# ╠═c22c84eb-167b-45d5-b729-68bcbfbbe946
# ╠═e90e7991-d0e0-4e71-8cd7-49077a574ccc
# ╟─ad6a76a0-a3b7-4729-9130-0dcd2a9a33dc
# ╠═4cd3555c-2d01-45b8-9319-e450d22394a5
# ╠═9b48db38-cbee-422c-bbdc-d319b711d65f
# ╠═6bb95004-4698-4897-b5ce-34655394e95b
# ╠═9d73cff3-3093-4d7a-baef-ab4b748ece99
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
