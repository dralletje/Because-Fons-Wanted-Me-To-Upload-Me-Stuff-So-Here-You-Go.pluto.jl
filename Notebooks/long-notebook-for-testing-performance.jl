### A Pluto.jl notebook ###
# v0.17.5

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

# ╔═╡ ffb58fdf-9262-43b1-a497-c33c21619937
using ProgressLogging

# ╔═╡ 649234ae-f7c6-4133-8424-b1b2c6420ee6
using PlutoUI

# ╔═╡ 8a1179ba-6c78-42da-9397-dc8f1c441ea6


# ╔═╡ 98198297-06a9-4761-9d49-6369775f44b0


# ╔═╡ f725be45-2a72-4307-84de-30c2961e48ae
Threads.nthreads()

# ╔═╡ 944efcc9-38fc-4011-8759-645eadb644d1
l

# ╔═╡ 779e4aaf-0bb3-49e9-80ee-361a7ad98bb6
a = () -> 10

# ╔═╡ 9507e007-b2c4-432d-80a1-8557c59c1f53


# ╔═╡ 01e43fda-b5f5-4540-b873-682edbbba93d
map([1,2,3]) do 10 end

# ╔═╡ b4b56510-69a0-4e25-bf73-f843b15af33f
a.(a=a)

# ╔═╡ 709e671d-f5cc-416b-b903-55835fc6b3a6
import HypertextLiteral

# ╔═╡ 7941e591-dde5-4d4f-a7de-6242722afb9c
import MarkdownLiteral: @markdown

# ╔═╡ 4c835b6d-d97f-4007-8104-0cdf1b8268ba
macro print(args...)
	quote
		@info $(args...)
		sleep(0.5)
	end
end

# ╔═╡ 617663eb-7bb6-44da-b424-bb8c42baf46b
import Dates

# ╔═╡ b1b886a1-732f-4aec-8d1f-669fc525992a
Dates.now()

# ╔═╡ 89a47dc9-d6d1-4c6d-9f84-c524835d7bd1


# ╔═╡ 281cf2cd-5783-4c06-82f4-f440f976fb39
x = 10

# ╔═╡ 71856746-50a8-493a-abab-7b74ab99be2c
@print x * 2

# ╔═╡ b1a05fe0-fffb-469a-a514-42a3fb01a334
@markdown """
### Should run code: $(@bind should_run PlutoUI.CheckBox())
"""

# ╔═╡ 745309bc-3025-4e12-b5e5-e297d15d9623
should_run

# ╔═╡ 30aec33d-a58b-4978-a19e-915471a7af78
map(x -> sleep(1); x, [1,2,3,4])

# ╔═╡ 88adcfd6-d512-4b6d-b725-496d1d779c74
z = 1

# ╔═╡ b9a1c758-10e2-4183-9c7c-4bb14a9d3c2b
z + 1

# ╔═╡ 5dc45d46-088d-4aca-b4df-a7da271cc68d
startswith

# ╔═╡ 08b693b9-8495-437d-949c-56be07bf3156
function notebook_to_js(notebook)
	Dict{String,Any}(
		"notebook_id" => notebook.notebook_id,
		"path" => notebook.path,
		"in_temp_dir" => startswith(notebook.path, new_notebooks_directory()),
		"shortpath" => basename(notebook.path),
		"process_status" => notebook.process_status,
		"last_save_time" => notebook.last_save_time,
		"last_hot_reload_time" => notebook.last_hot_reload_time,
		"cell_execution_order" => cell_id.(collect(topological_order(notebook))),
	)
end

# ╔═╡ 450fadc2-c9bc-4b39-88af-a433e96eb989
h .()

# ╔═╡ eede5fc8-4494-42cc-b306-1a0d5dcb3737


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"

[compat]
HypertextLiteral = "~0.9.3"
MarkdownLiteral = "~0.1.1"
PlutoUI = "~0.7.30"
ProgressLogging = "~0.1.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4aff51293dbdbd268df314827b7f409ea57f5b70"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.5"

[[Crayons]]
git-tree-sha1 = "b618084b49e78985ffa8422f32b9838e397b9fc2"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

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

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "5c0eb9099596090bb3215260ceca687b888a1575"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.30"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

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

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

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
# ╠═8a1179ba-6c78-42da-9397-dc8f1c441ea6
# ╠═98198297-06a9-4761-9d49-6369775f44b0
# ╠═f725be45-2a72-4307-84de-30c2961e48ae
# ╠═944efcc9-38fc-4011-8759-645eadb644d1
# ╠═779e4aaf-0bb3-49e9-80ee-361a7ad98bb6
# ╠═ffb58fdf-9262-43b1-a497-c33c21619937
# ╠═9507e007-b2c4-432d-80a1-8557c59c1f53
# ╠═01e43fda-b5f5-4540-b873-682edbbba93d
# ╠═b4b56510-69a0-4e25-bf73-f843b15af33f
# ╠═649234ae-f7c6-4133-8424-b1b2c6420ee6
# ╠═709e671d-f5cc-416b-b903-55835fc6b3a6
# ╠═7941e591-dde5-4d4f-a7de-6242722afb9c
# ╠═4c835b6d-d97f-4007-8104-0cdf1b8268ba
# ╠═617663eb-7bb6-44da-b424-bb8c42baf46b
# ╠═b1b886a1-732f-4aec-8d1f-669fc525992a
# ╠═89a47dc9-d6d1-4c6d-9f84-c524835d7bd1
# ╠═281cf2cd-5783-4c06-82f4-f440f976fb39
# ╠═71856746-50a8-493a-abab-7b74ab99be2c
# ╠═b1a05fe0-fffb-469a-a514-42a3fb01a334
# ╠═745309bc-3025-4e12-b5e5-e297d15d9623
# ╠═30aec33d-a58b-4978-a19e-915471a7af78
# ╠═b9a1c758-10e2-4183-9c7c-4bb14a9d3c2b
# ╠═88adcfd6-d512-4b6d-b725-496d1d779c74
# ╠═5dc45d46-088d-4aca-b4df-a7da271cc68d
# ╠═08b693b9-8495-437d-949c-56be07bf3156
# ╠═450fadc2-c9bc-4b39-88af-a433e96eb989
# ╠═eede5fc8-4494-42cc-b306-1a0d5dcb3737
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
