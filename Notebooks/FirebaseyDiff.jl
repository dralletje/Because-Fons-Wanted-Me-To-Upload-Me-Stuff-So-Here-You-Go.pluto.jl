### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 74613e4c-3801-11ec-0194-e5f3299edb04
module Firebasey include("../Pluto.jl/src/webserver/Firebasey.jl") end

# ╔═╡ 3414acb6-b946-47cc-a7e1-c7eb72df7535
statefile = read("~/Downloads/test_logging.plutostate" |> expanduser)

# ╔═╡ 721d530c-f176-4584-abe0-a14e4772a69d
import Pluto

# ╔═╡ e1fbad0b-d7e0-4a82-ad3b-7effdc57ee37
statejs = Pluto.unpack(statefile)

# ╔═╡ 50f3e466-ad99-43c9-8241-1fab2ca061da
lens(x) = x["cell_results"]["3599eb82-0003-11eb-3814-dfd0f5737846"]["logs"]

# ╔═╡ 4fda71d7-cd2d-435b-bf2b-ef141d650188
Base.@kwdef struct Line
	line::Int
	msg::Tuple{String, String}
	cell_id::String
	kwargs::Array{Any}
	id::String
	file::String
	group::String
	level::String
end

# ╔═╡ 73f58aba-ed2e-42fb-885e-2855797d6ffc
function diff(o1::T, o2::T) where T <: AbstractDict
	changes = JSONPatch[]
	# for key in keys(o1) ∪ keys(o2)
	# 	for change in diff(get(o1, key, nothing), get(o2, key, nothing))
	# 		push!(changes, wrappath([key], change))
	# 	end
	# end
	
	# same as above but faster:
	
	for (key1, val1) in o1
		for change in diff(val1, get(o2, key1, nothing))
			push!(changes, wrappath([key1], change))
		end
	end
	for (key2, val2) in o2
		if !haskey(o1, key2)
			for change in diff(nothing, val2)
				push!(changes, wrappath([key2], change))
			end
		end
	end
	changes
end


# ╔═╡ d5aa6c44-e1e3-4f55-acf6-79e6a6b765ce
struct DeepVector{T <: Vector}
	v::T
end

# ╔═╡ 41da40bd-85a7-47da-a0fb-fd0270de21cb
function Firebasey.diff(_old::T, _new::T) where T <: DeepVector
	old = _old.v
	new = _new.v
	largest, smallest = if length(old) > length(new)
		old, new
	else
		new, old
	end

	changes = []
	for (index, value) in enumerate(largest)
		for change in Firebasey.diff(get(old, index, nothing), get(new, index, nothing))
			push!(changes, Firebasey.wrappath([index], change))
		end
	end
	changes
end

# ╔═╡ 6fcc29d9-0ec7-41ff-84a6-62ec40f53928
x = Dict(map(collect(lens(statejs))) do (key, value)
	key => Line(
		line=value["line"],
		msg=(value["msg"][1], value["msg"][2]),
		cell_id=value["cell_id"],
		kwargs=value["kwargs"],
		id=value["id"],
		file=value["file"],
		group=value["group"],
		level=value["level"],
	)
end)

# ╔═╡ dc628a2b-48a4-4a2c-8d57-362ccb5786b8
Firebasey.diff(Firebasey.Deep(x["1"]), Firebasey.Deep(x["2"]))

# ╔═╡ ae7e9127-8fa9-48cc-861f-6e5b87d9b63a


# ╔═╡ 3b149062-39a0-458e-a29e-6731052051ac
z = Base.ImmutableDict(x...)

# ╔═╡ 7c29843c-f48e-4b92-a7d3-2d6c81f21c42
objectid(z)

# ╔═╡ 1f9fe237-ab14-4cc5-aee7-14a62412b232
y = Base.ImmutableDict(x...)

# ╔═╡ 9f05e54f-ef6a-4d2d-a5c8-a248d5b9a86e
objectid(y)

# ╔═╡ d21fee0f-6dd4-460a-91ff-256a3510b36b
import BenchmarkTools

# ╔═╡ ce0e8099-d58d-48c0-aff5-0c3f4808ede3
BenchmarkTools.@benchmark Firebasey.diff(DeepVector(ls), DeepVector(ps2))

# ╔═╡ 9839367d-4ea1-47e6-882a-d8ec1a663d57
BenchmarkTools.@benchmark y === z

# ╔═╡ de607058-08f6-4d5e-8928-83f599f9654d
BenchmarkTools.@benchmark y == z

# ╔═╡ c1e2a58d-ae0b-43e3-be21-342cfd86fe32
BenchmarkTools.@benchmark objectid(y) === objectid(z)

# ╔═╡ 10f8bb21-1244-484b-a09e-98807566e3fe
BenchmarkTools.@benchmark objectid(y)

# ╔═╡ c14fd351-4aa6-4f5f-8f62-fbd1f9cd710d
# x = Dict(map(collect(lens(statejs))) do (key, value)
# 	key => Line(
# 		line=value["line"],
# 		msg=(value["msg"][1], value["msg"][2]),
# 		cell_id=value["cell_id"],
# 		kwargs=value["kwargs"],
# 		id=value["id"],
# 		file=value["file"],
# 		group=value["group"],
# 		level=value["level"],
# 	)
# end)sl

# ╔═╡ e727bdc9-b776-4a9e-85d1-5c84e839bb18
ls = collect(values(x))

# ╔═╡ 1187778e-d0a6-48c6-8be2-7f2347023cc5
begin
	ps2 = copy(ls)
	ps2[1] = ps2[2]
end

# ╔═╡ 1c50d7fb-8577-40f7-90a6-734b829348a0
ls[1] == ps2[1]

# ╔═╡ 67bf6358-7d99-4e56-96e3-6b8ee3023190
typeof(ls)

# ╔═╡ 8a4927b6-7823-4c7d-b762-1ecafc8896cf
(@elapsed Pluto.Firebasey.diff(ls, ls)) * 100

# ╔═╡ 9be06ab2-f81b-40db-b888-96f82f298ae0
begin
	ps = deepcopy(ls)
	ps[1] = ps[2]
end

# ╔═╡ 5081f259-3065-426b-92d8-38b8c769c6e5
@which Firebasey.diff(DeepVector(ls), DeepVector(ps))

# ╔═╡ 139a87c5-7ba4-493c-9389-1c7a14e04adb
typeof(ps)

# ╔═╡ 0fa0d433-764d-42e9-befb-a3b06ab57dc3
(@elapsed Pluto.Firebasey.diff(x, x)) * 100

# ╔═╡ 6b2362e8-82de-4f8d-8dbf-b57c051bc7bb
(@elapsed Pluto.Firebasey.diff(lens(statejs), lens(statejs))) * 100

# ╔═╡ f61ef743-fc71-485c-bae8-113c24b1eddd
results = map(collect(statejs["cell_results"]["3599eb82-0003-11eb-3814-dfd0f5737846"])) do (key, value)
	key => @elapsed Pluto.Firebasey.diff(value, value)
end

# ╔═╡ 2d2b78cb-d3d3-4075-9ec2-0cf07145d0a9
sort(results, by=x -> x[2])

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"

[compat]
BenchmarkTools = "~1.2.0"
Pluto = "~0.17.0"
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

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "79e812c535bb9780ba00f3acba526bde5652eb13"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.16.6"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[ExproniconLite]]
git-tree-sha1 = "c04d5c3442126d75ee4500aa6b0e402cae3bf6ac"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.6.12"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "2cc2791b324e8ed387a91d7226d17be754e9de61"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.4.3"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

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

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d911b6a12ba974dabe2291c6d450094a7226b372"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.1"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Pluto]]
deps = ["Base64", "Configurations", "Dates", "Distributed", "FileWatching", "FuzzyCompletions", "HTTP", "InteractiveUtils", "Logging", "Markdown", "MsgPack", "Pkg", "REPL", "Sockets", "TableIOInterface", "Tables", "UUIDs"]
git-tree-sha1 = "ea742b160cac4540c7e259aed390550a4ce2b9a9"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.17.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

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

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableIOInterface]]
git-tree-sha1 = "9a0d3ab8afd14f33a35af7391491ff3104401a35"
uuid = "d1efa939-5518-4425-949f-ab857e148477"
version = "0.1.6"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

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

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═74613e4c-3801-11ec-0194-e5f3299edb04
# ╠═3414acb6-b946-47cc-a7e1-c7eb72df7535
# ╠═721d530c-f176-4584-abe0-a14e4772a69d
# ╠═e1fbad0b-d7e0-4a82-ad3b-7effdc57ee37
# ╠═50f3e466-ad99-43c9-8241-1fab2ca061da
# ╠═4fda71d7-cd2d-435b-bf2b-ef141d650188
# ╠═dc628a2b-48a4-4a2c-8d57-362ccb5786b8
# ╠═73f58aba-ed2e-42fb-885e-2855797d6ffc
# ╠═d5aa6c44-e1e3-4f55-acf6-79e6a6b765ce
# ╠═41da40bd-85a7-47da-a0fb-fd0270de21cb
# ╠═5081f259-3065-426b-92d8-38b8c769c6e5
# ╠═1c50d7fb-8577-40f7-90a6-734b829348a0
# ╠═1187778e-d0a6-48c6-8be2-7f2347023cc5
# ╠═ce0e8099-d58d-48c0-aff5-0c3f4808ede3
# ╠═6fcc29d9-0ec7-41ff-84a6-62ec40f53928
# ╠═ae7e9127-8fa9-48cc-861f-6e5b87d9b63a
# ╠═3b149062-39a0-458e-a29e-6731052051ac
# ╠═7c29843c-f48e-4b92-a7d3-2d6c81f21c42
# ╠═1f9fe237-ab14-4cc5-aee7-14a62412b232
# ╠═9f05e54f-ef6a-4d2d-a5c8-a248d5b9a86e
# ╠═d21fee0f-6dd4-460a-91ff-256a3510b36b
# ╠═9839367d-4ea1-47e6-882a-d8ec1a663d57
# ╠═de607058-08f6-4d5e-8928-83f599f9654d
# ╠═c1e2a58d-ae0b-43e3-be21-342cfd86fe32
# ╠═10f8bb21-1244-484b-a09e-98807566e3fe
# ╠═c14fd351-4aa6-4f5f-8f62-fbd1f9cd710d
# ╠═e727bdc9-b776-4a9e-85d1-5c84e839bb18
# ╠═67bf6358-7d99-4e56-96e3-6b8ee3023190
# ╠═8a4927b6-7823-4c7d-b762-1ecafc8896cf
# ╠═9be06ab2-f81b-40db-b888-96f82f298ae0
# ╠═139a87c5-7ba4-493c-9389-1c7a14e04adb
# ╠═0fa0d433-764d-42e9-befb-a3b06ab57dc3
# ╠═6b2362e8-82de-4f8d-8dbf-b57c051bc7bb
# ╠═f61ef743-fc71-485c-bae8-113c24b1eddd
# ╠═2d2b78cb-d3d3-4075-9ec2-0cf07145d0a9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
