### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ cb419bfa-a78f-11ec-3108-853890511d03
import JSON3

# ╔═╡ 719ad612-b4a2-4fb8-906c-cd2a7949117c
struct JSONMatrix{T} <: AbstractMatrix{T}
	matrix::AbstractMatrix{T}
end

# ╔═╡ acab41a5-1b43-4259-bfa4-a297de4a8edd
Base.size(matrix::JSONMatrix) = (Base.size(matrix.matrix)[1],)

# ╔═╡ 83d077c8-099c-4bbb-a49a-3ac658b4212a
Base.getindex(matrix::JSONMatrix, i) = Base.getindex(matrix.matrix, i, :)

# ╔═╡ 93af90c3-497b-4844-969c-dd2f74aa4b5b
import PlotlyLight

# ╔═╡ 45147412-a4af-46e4-b554-6bb98ce55078
z = rand(10, 10)

# ╔═╡ 6b9d9e6b-fc2c-4eab-9368-32c4937f7a8a
PlotlyLight.Plot(PlotlyLight.Config(
	x = 1:10,
	y = 1:10,
	z = z,
	type = "heatmap"
))

# ╔═╡ 1d478468-3176-4107-82b8-270341d973ac
PlotlyLight.Plot(PlotlyLight.Config(
	x = 1:10,
	y = 1:10,
	z = JSONMatrix(z),
	type = "heatmap"
))

# ╔═╡ 5b1adc90-7b96-499c-b272-1f91f6834579
PlotlyLight.Plot(PlotlyLight.Config(
	x = 1:10,
	y = 1:10,
	z = collect(eachrow(z)),
	type = "heatmap"
))

# ╔═╡ 8c41d958-56fb-4552-8e3c-3fd297fec310
import MarkdownLiteral: @markdown

# ╔═╡ 1a8ce4ef-b853-4ad3-8dd1-f61b91eb8088
@markdown """
# JSON3 doesn't like multidimensional matrices

And because I want to love JSON3 (🥲), here is a small wrapper type to fix JSON3s stringification.

You can see in the example here that JSON3 will flatten the matrix instead of creating nested arrays :(

[Related issue for PlotlyLight](https://github.com/JuliaComputing/PlotlyLight.jl/issues/12)
"""

# ╔═╡ 0fa56a5a-7d0e-4471-a0bd-f3b0ea3ffc4b
@markdown """
So I create the wrapper type `JSONMatrix`:
"""

# ╔═╡ da423e0d-5b19-4150-aa4b-8fb49fdf4c1d
@markdown """
Though people already figured out a simple `collect(eachrow(matrix))` also does the trick:
"""

# ╔═╡ 4aa2d2f0-552d-4849-b2cc-4c787ce9b338
@markdown """
But I still love wrapper types so... you're welcome? I'm welcome? I don't know.
"""

# ╔═╡ d1b2e912-12b0-4cbf-b32c-303255f07450
@markdown """
## Example with PlotlyLight
"""

# ╔═╡ 37b7c5d5-b724-4855-933a-986c3c4bcf0a
@markdown """
### Without any magix (wrong!!)
"""

# ╔═╡ 8ef1a952-9ef8-4ab7-9313-6185f4b0fc0c
@markdown """
### With wrapper type
"""

# ╔═╡ 7dd89e5a-4e35-4b54-98c0-d7897b36e1b2
@markdown """
### With `collect(eachrow(matrix))`
"""

# ╔═╡ cfb27cc4-484d-47a0-b8a8-19d3ea8bd54d
@markdown """
## Appendix
"""

# ╔═╡ 3a902fa8-2166-41f5-bbd4-aa83ab804adf
import PlutoTest: @test

# ╔═╡ 44c83f62-9ceb-4917-bbe0-cc7ba80a5248
@test JSON3.write([1 2; 3 4]) == "[[1,2],[3,4]]"

# ╔═╡ 444aa836-97c2-4afe-a0fa-33c2b151c6cf
@test JSON3.write(JSONMatrix([1 2; 3 4])) == "[[1,2],[3,4]]"

# ╔═╡ 43a73871-0d21-4efe-8de0-809d624c18c6
@test JSON3.write(collect(eachrow([1 2; 3 4]))) == "[[1,2],[3,4]]"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
PlotlyLight = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"

[compat]
JSON3 = "~1.9.4"
MarkdownLiteral = "~0.1.1"
PlotlyLight = "~0.5.0"
PlutoTest = "~0.2.2"
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

[[Cobweb]]
deps = ["DefaultApplication", "Markdown", "Scratch"]
git-tree-sha1 = "02690a956a19e94c40feacbf368a5adcce5625fd"
uuid = "ec354790-cf28-43e8-bb59-b484409b7bad"
version = "0.1.1"

[[CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4cd7063c9bdebdbd55ede1af70f3c2f48fab4215"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.6"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "fc2b7122761b22c87fec8bf2ea4dc4563d9f8c24"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.0.0"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EasyConfig]]
deps = ["JSON3", "OrderedCollections", "StructTypes"]
git-tree-sha1 = "c070b3c48a8ba3c6e6507997f0a7f5ebf85c3600"
uuid = "acab07b0-f158-46d4-8913-50acef6d41fe"
version = "0.1.10"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "8c1f668b24d999fb47baf80436194fdccec65ad2"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.4"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

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

[[MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "85b5da0fa43588c75bb1ff986493443f821c70b7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.3"

[[PlotlyLight]]
deps = ["Artifacts", "Cobweb", "DefaultApplication", "Downloads", "EasyConfig", "JSON3", "Random"]
git-tree-sha1 = "6e25a9f62ec9cb5335d2a88eb324c62e9b1448ef"
uuid = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
version = "0.5.0"

[[PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

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
"""

# ╔═╡ Cell order:
# ╟─1a8ce4ef-b853-4ad3-8dd1-f61b91eb8088
# ╠═cb419bfa-a78f-11ec-3108-853890511d03
# ╠═44c83f62-9ceb-4917-bbe0-cc7ba80a5248
# ╟─0fa56a5a-7d0e-4471-a0bd-f3b0ea3ffc4b
# ╠═719ad612-b4a2-4fb8-906c-cd2a7949117c
# ╠═acab41a5-1b43-4259-bfa4-a297de4a8edd
# ╠═83d077c8-099c-4bbb-a49a-3ac658b4212a
# ╠═444aa836-97c2-4afe-a0fa-33c2b151c6cf
# ╟─da423e0d-5b19-4150-aa4b-8fb49fdf4c1d
# ╠═43a73871-0d21-4efe-8de0-809d624c18c6
# ╟─4aa2d2f0-552d-4849-b2cc-4c787ce9b338
# ╟─d1b2e912-12b0-4cbf-b32c-303255f07450
# ╠═93af90c3-497b-4844-969c-dd2f74aa4b5b
# ╠═45147412-a4af-46e4-b554-6bb98ce55078
# ╟─37b7c5d5-b724-4855-933a-986c3c4bcf0a
# ╠═6b9d9e6b-fc2c-4eab-9368-32c4937f7a8a
# ╟─8ef1a952-9ef8-4ab7-9313-6185f4b0fc0c
# ╠═1d478468-3176-4107-82b8-270341d973ac
# ╟─7dd89e5a-4e35-4b54-98c0-d7897b36e1b2
# ╠═5b1adc90-7b96-499c-b272-1f91f6834579
# ╟─cfb27cc4-484d-47a0-b8a8-19d3ea8bd54d
# ╠═8c41d958-56fb-4552-8e3c-3fd297fec310
# ╠═3a902fa8-2166-41f5-bbd4-aa83ab804adf
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
