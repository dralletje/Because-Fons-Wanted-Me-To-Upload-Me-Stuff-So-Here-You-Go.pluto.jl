### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 336cfd1a-82b8-4fb0-a22f-2c0c34344020
using PlutoHooks: @skip_as_script

# ╔═╡ a2c9f284-52aa-4ef6-b621-4da78daa52d4
k = 20

# ╔═╡ 6c333c3c-3e8e-11ec-3e08-0dd9af005a97
import HypertextLiteral: @htl, inside_tag, is_alpha, is_space

# ╔═╡ bbc1336f-3b43-4de7-8e8e-ca6d6479682e
import PlutoUI

# ╔═╡ f08c2332-36fd-47c0-8b53-e5a166e5ea80
@bind g html"""<input type=range />"""

# ╔═╡ abe7d7e9-d425-4e9e-aa02-4fe3b24c9605
p = g

# ╔═╡ 7846550d-d04a-4313-bf26-f701cbabb9be
l = 30

# ╔═╡ e0fe8e40-2af9-4ed8-aa25-3c2260be00f6
struct AddAttributes
	wrapped::Any
	attributes::Dict{Symbol,Any}
end

# ╔═╡ e50c9d50-ae1e-4f34-a24b-4fa0cecad4c8
function Base.show(io::IO, mime::MIME"text/html", add_attributes::AddAttributes)	
	html = repr(MIME("text/html"), add_attributes.wrapped)
	
	first_tag_open = -1
	for index in firstindex(html):lastindex(html)
		char = html[index]
		if is_space(char)
			continue
		elseif char == '<'
			first_tag_open = index
			break
		else
			error("Looking for a tag start (<), but got a ($char)")
		end
	end
	if first_tag_open == -1
		error("Looking for a tag start (<), but couldn't find any")
	end
	
	after_tag_name = -1
	for index in first_tag_open+1:lastindex(html)
		char = html[index]
		if char == '>' || char == ' ' || char == '/'
			after_tag_name = index - 1
			break
		elseif is_alpha(char) || char == '-' || '0' < char < '9' 
			continue
		else
			error("Looking for a tag start (>) or space (' '), but got a ($char)")
		end
	end
	if after_tag_name == nothing
		error("Couldn't find tag close! (>)")
	end
	
	print(io, html[begin:after_tag_name])
	print(io, inside_tag(add_attributes.attributes))
	print(io, html[after_tag_name+1:end])
end

# ╔═╡ e9c985e7-02f2-428f-8a57-e49d665dc9d1
@skip_as_script my_html = """<thing>
	<template shadowroot>
		<div>Hi</div>
	</template>
</thing>
"""

# ╔═╡ 1f14b2e6-aa17-40c8-b5d1-8d2779f8d4e6
z = 20

# ╔═╡ 36149b23-31e2-46c2-8daf-7e086167fb63
@skip_as_script Text(repr(MIME("text/html"), AddAttributes(my_html, Dict(
	:fullscreen => "fullscreen"
))))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoHooks = "0ff47ea0-7a50-410d-8455-4348d5de0774"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.2"
PlutoHooks = "~0.0.2"
PlutoUI = "~0.7.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "abb72771fd8895a7ebd83d5632dc4b989b022b5b"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.2"

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

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[PlutoHooks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "d551bccd095218255fae60ab3305ca4f3e4d2968"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.2"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "b68904528fd538f1cb6a3fbc44d2abdc498f9e8e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.21"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╠═a2c9f284-52aa-4ef6-b621-4da78daa52d4
# ╠═6c333c3c-3e8e-11ec-3e08-0dd9af005a97
# ╠═336cfd1a-82b8-4fb0-a22f-2c0c34344020
# ╠═bbc1336f-3b43-4de7-8e8e-ca6d6479682e
# ╠═f08c2332-36fd-47c0-8b53-e5a166e5ea80
# ╠═abe7d7e9-d425-4e9e-aa02-4fe3b24c9605
# ╠═7846550d-d04a-4313-bf26-f701cbabb9be
# ╠═e0fe8e40-2af9-4ed8-aa25-3c2260be00f6
# ╠═e50c9d50-ae1e-4f34-a24b-4fa0cecad4c8
# ╠═e9c985e7-02f2-428f-8a57-e49d665dc9d1
# ╠═1f14b2e6-aa17-40c8-b5d1-8d2779f8d4e6
# ╠═36149b23-31e2-46c2-8daf-7e086167fb63
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
