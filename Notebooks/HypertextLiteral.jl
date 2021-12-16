### A Pluto.jl notebook ###
# v0.17.1

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

# ╔═╡ 1c282a20-3e7c-11ec-39a0-9dc5384de908
using PlutoHooks

# ╔═╡ d91585f0-cf67-40a4-ad2f-bbacd878bdcc
import BenchmarkTools

# ╔═╡ ae127348-86cc-4565-8aad-acf3c4a4f1fc
import PlutoUI

# ╔═╡ fb557a62-ff1f-4949-91b9-8f3c53c30638
import HypertextLiteral as OldHypertextLiteral

# ╔═╡ 4b131c1f-f1f9-4e93-bc46-b94edfa91ea9
import Random

# ╔═╡ 233ea42b-7fad-4112-b7e0-3b0fa349e2d0
macro identity(expr)
	QuoteNode(expr)
end

# ╔═╡ ce161e8b-0296-4836-9cfb-2a8b74d819c9
md"## Really Simple"

# ╔═╡ b0d77aea-4e24-4788-9cf9-37a0713589a2
Text("""
BenchmarkTools.Trial: 10000 samples with 9 evaluations.
 Range (min … max):  2.005 μs … 433.319 μs  ┊ GC (min … max): 0.00% … 97.89%
 Time  (median):     2.079 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.221 μs ±   7.227 μs  ┊ GC (mean ± σ):  5.55% ±  1.70%

         ▇▁▁▁█▁  ▄                                             
  ▁▁▂▄▄▆▆██████▇▇█▅▄▄▆▃▃▂▃▂▂▂▂▂▁▁▂▂▁▂▂▂▁▂▂▁▁▁▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▂
  2 μs            Histogram: frequency by time        2.35 μs <

 Memory estimate: 1.77 KiB, allocs estimate: 33.
""")

# ╔═╡ bce0c288-ace2-4238-8dcf-f0b78fcc041b
BenchmarkTools.@benchmark HypertextLiteral.interpolate(@identity("""
	<div>
		<p>
			$([1,2,3])
		</p>
""").args)

# ╔═╡ 758cfed2-e810-4cca-a802-80e579a7d73b
4 ∈ [1,2,3]

# ╔═╡ 028e7b7f-c22e-419c-95a8-259a187b625e
gg = HypertextLiteral.@htl """
	<div>
		<pre>
			<a>
				$([1,2,3])
		</p>
"""

# ╔═╡ 97182dab-7c9c-4db8-b5da-92676a1813d7
Text("$gg")

# ╔═╡ bcd5f408-aa4a-43f2-a380-8a1ac274ceab
findlast(x -> x == 2, [1,2,3])

# ╔═╡ a2a3fb20-2f90-410f-ac46-dee770edddaa
md"## More complex"

# ╔═╡ 28e4c5c0-58ed-4159-affd-f58dd9def64b
Text("""
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  12.292 μs …  51.833 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     12.625 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   12.800 μs ± 832.194 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

     ▃██▆█▇▃▄▂▁                                                 
  ▁▂▄██████████▇▆▆▄▄▄▃▃▂▂▂▂▂▂▂▂▁▂▁▁▁▁▁▁▁▁▁▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▃
  12.3 μs         Histogram: frequency by time         14.8 μs <

 Memory estimate: 6.64 KiB, allocs estimate: 135.
""")

# ╔═╡ 105b5072-f649-4587-b58c-ddacac8c8291
BenchmarkTools.@benchmark OldHypertextLiteral.interpolate(@identity("
    <dl>
      <dt>Company<dd>$(c.company)
      <dt>Phrase<dd>$(c.phrase)
      <dt>Active Since<dd>$(c.active)
      <dt>Employees<dd>
        <table>
          <tr><th>Last Name<th>First Name<th>Title
              <th>E-Mail<th>Office Phone<th>Cell Phone
              <th>Comments</tr>
          $((map(c.employees) do e; htl_employee(e); end))</table>
    </dl>
").args)

# ╔═╡ 97b5511f-20a0-44f6-9ac2-f5b1d7ebc3c6
BenchmarkTools.@benchmark HypertextLiteral.interpolate(@identity("
    <dl>
      <dt>Company<dd>$(c.company)
      <dt>Phrase<dd>$(c.phrase)
      <dt>Active Since<dd>$(c.active)
      <dt>Employees<dd>
        <table>
          <tr><th>Last Name<th>First Name<th>Title
              <th>E-Mail<th>Office Phone<th>Cell Phone
              <th>Comments</tr>
          $((map(c.employees) do e; htl_employee(e); end))</table>
    </dl>
").args)

# ╔═╡ 0d9c898a-b176-4545-b096-aaa24a4769ce
md"## With tags already closed"

# ╔═╡ 367c6a5c-1cf8-4790-89a7-b540e2a830f6
module _HypertextLiteral include("../HypertextLiteral.jl/src/HypertextLiteral.jl") end

# ╔═╡ 6367b14a-5532-4777-a873-600d46003a8b
HypertextLiteral = _HypertextLiteral.HypertextLiteral

# ╔═╡ 96272c01-9bcd-42f6-9caa-9dba7a4db887
var"@htl" = HypertextLiteral.var"@htl"

# ╔═╡ a6f0aa44-f05b-4b48-94ee-222026624bb2
HypertextLiteral.interpolate(@identity("""
	<div $(x)>
""").args)

# ╔═╡ 7142855c-33b7-4a35-82b1-b8cac8645efe
BenchmarkTools.@benchmark OldHypertextLiteral.interpolate(@identity("
    <dl>
      <dt>Company</dt><dd>$(c.company)</dd>
      <dt>Phrase</dt><dd>$(c.phrase)</dt>
      <dt>Active Since</dt><dd>$(c.active)</dd>
      <dt>Employees</dt><dd>
        <table>
          <tr><th>Last Name</th><th>First Name</th><th>Title</th>
              <th>E-Mail</th><th>Office Phone</th><th>Cell Phone</th>
              <th>Comments</th></tr>
          $((map(c.employees) do e; htl_employee(e); end))</table>
		</dd>
    </dl>
").args)

# ╔═╡ 965b5dc9-f31b-4845-b1b7-912bc2a18967
BenchmarkTools.@benchmark HypertextLiteral.interpolate(@identity("
    <dl>
      <dt>Company</dt><dd>$(c.company)</dd>
      <dt>Phrase</dt><dd>$(c.phrase)</dt>
      <dt>Active Since</dt><dd>$(c.active)</dd>
      <dt>Employees</dt><dd>
        <table>
          <tr><th>Last Name</th><th>First Name</th><th>Title</th>
              <th>E-Mail</th><th>Office Phone</th><th>Cell Phone</th>
              <th>Comments</th></tr>
          $((map(c.employees) do e; htl_employee(e); end))</table>
		</dd>
    </dl>
").args)

# ╔═╡ 0b91ad9a-b141-49ed-823b-856283de666e
collect(0:1)

# ╔═╡ 0dd97ace-8c9c-4095-87d8-9facb9b2327f
html"""<script>
console.log('x:', (html`
	<dl>
		<div>
			<table>

		</div>
`).outerHTML)
"""

# ╔═╡ d3c02695-db06-44fc-886f-5b5d873bf14c
Iterators

# ╔═╡ 9461dc08-1c21-4640-8384-e7154d427334
HypertextLiteral.interpolate(@identity("""
	<div>
		$([1,2,3])
""").args)

# ╔═╡ 6f3e181c-48a6-4715-8ab6-622344b6ac93
@bind x PlutoUI.Slider(1:10)

# ╔═╡ cb4034e9-6e12-487f-90eb-8b3ff695326a
HypertextLiteral.@htl """<div>
	$([1,2,x])
"""

# ╔═╡ 27fa73a1-685f-41cf-9a2c-f1d4403719d3
BenchmarkTools.@benchmark HypertextLiteral.interpolate(@identity("""
	<div>
		$([1,2,3])
""").args)

# ╔═╡ 2b6c60f3-d10a-480d-b60c-f9a675558769
md"### HTL demo"

# ╔═╡ a8ce94bc-a5e7-4100-a1ff-419b2f69363f


# ╔═╡ fb95f561-2a07-4dd9-a5d6-d2643ff2f50b
htl_employee(e) = @htl("
      <tr><td>$(e.last_name)<td>$(e.first_name)<td>$(e.title)
          <td><a href='mailto:$(e.email)'>$(e.email)</a>
          <td>$(e.main_number)<td>$(e.cell_phone)
          <td>$((@htl("<span>$c</span>") for c in e.comments))
")

# ╔═╡ 1f44183c-61e7-4aef-ab75-70ca177de10c
htl_customer(c) = @htl("
    <dl>
      <dt>Company<dd>$(c.company)
      <dt>Phrase<dd>$(c.phrase)
      <dt>Active Since<dd>$(c.active)
      <dt>Employees<dd>
        <table>
          <tr><th>Last Name<th>First Name<th>Title
              <th>E-Mail<th>Office Phone<th>Cell Phone
              <th>Comments</tr>
          $((map(c.employees) do e; htl_employee(e); end))</table>
    </dl>
")

# ╔═╡ 0534d685-3f31-4f5f-893c-4d0ea1bf1252
htl_database(d) = @htl("
  <html>
    <head><title>Customers &amp; Employees)</title></head>
    <body>
    $((map(d) do c; htl_customer(c); end))</body>
  </html>
")

# ╔═╡ 21149fc1-5f01-4219-99b6-f3500ab6896a
html"""<script>
console.log((html`<table>
          <tr><th>Last Name<th>First Name<th>Title
              <th>E-Mail<th>Office Phone<th>Cell Phone
              <th>Comments</th></th></th></th></th></th>
		</tr>`).outerHTML)
"""

# ╔═╡ 15512a8e-e247-4bbb-990c-bf0b442e69eb
html"""<script>
console.log((html`<table>
          <p><th>Last Name<th>First Name<th>Title
              <th>E-Mail<th>Office Phone<th>Cell Phone
              <div>Comments</th></th></th></th></th></th></p>
		</tr>`).outerHTML)
"""

# ╔═╡ c91b06e7-7d16-4890-b4e3-986248e79e04
md"## Fake Database"

# ╔═╡ f4dc6a16-3010-4fa3-a25a-b6cdaa75a462
import Faker

# ╔═╡ fa0a927e-6620-41c9-8fc1-62ddd7c69fd1
make_employee() = (
  first_name=Faker.first_name(),
  last_name=Faker.last_name(),
  title=Faker.job(),
  main_number=Faker.phone_number(),
  email=Faker.email(),
  cell_phone=Faker.cell_phone(),
  color= Faker.hex_color(),
  comments= Faker.paragraphs()
)

# ╔═╡ 358e877f-66f3-43cd-9e16-c3ce2b19734b
make_customer() = (
   company=Faker.company(),
   url=Faker.url(),
   phrase=Faker.catch_phrase(),
   active=Faker.date_time_this_decade(before_now=true, after_now=false),
   notes= Faker.sentence(number_words=rand(2:9), variable_nb_words=true),
   employees=[make_employee() for x in 1:rand(3:18)])

# ╔═╡ a94ba41c-8741-439a-89c5-04d78cd645ec
database = [make_customer() for x in 1:13]

# ╔═╡ cf7f1eb1-a4f8-41fd-ab0d-27ac622602ff
Text("$(htl_database(database))")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Faker = "0efc519c-db33-5916-ab87-703215c3906f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoHooks = "0ff47ea0-7a50-410d-8455-4348d5de0774"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
BenchmarkTools = "~1.2.0"
Faker = "~0.3.1"
HypertextLiteral = "~0.9.2"
PlutoHooks = "~0.0.2"
PlutoUI = "~0.7.18"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0ec322186e078db08ea3e7da5b8b2885c099b393"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.0"

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

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Faker]]
deps = ["Dates", "Random", "YAML"]
git-tree-sha1 = "58f48c6ce369fd3739e860041596ed0250be098e"
uuid = "0efc519c-db33-5916-ab87-703215c3906f"
version = "0.3.1"

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

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

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

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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
git-tree-sha1 = "57312c7ecad39566319ccf5aa717a20788eb8c1f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.18"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

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

[[StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "50ccd5ddb00d19392577902f0079267a72c5ab04"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.5"

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

[[YAML]]
deps = ["Base64", "Dates", "Printf", "StringEncodings"]
git-tree-sha1 = "3c6e8b9f5cdaaa21340f841653942e1a6b6561e5"
uuid = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"
version = "0.4.7"

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
# ╠═1c282a20-3e7c-11ec-39a0-9dc5384de908
# ╠═d91585f0-cf67-40a4-ad2f-bbacd878bdcc
# ╠═ae127348-86cc-4565-8aad-acf3c4a4f1fc
# ╠═fb557a62-ff1f-4949-91b9-8f3c53c30638
# ╠═4b131c1f-f1f9-4e93-bc46-b94edfa91ea9
# ╠═6367b14a-5532-4777-a873-600d46003a8b
# ╠═96272c01-9bcd-42f6-9caa-9dba7a4db887
# ╟─233ea42b-7fad-4112-b7e0-3b0fa349e2d0
# ╟─ce161e8b-0296-4836-9cfb-2a8b74d819c9
# ╟─b0d77aea-4e24-4788-9cf9-37a0713589a2
# ╠═bce0c288-ace2-4238-8dcf-f0b78fcc041b
# ╠═a6f0aa44-f05b-4b48-94ee-222026624bb2
# ╠═758cfed2-e810-4cca-a802-80e579a7d73b
# ╠═028e7b7f-c22e-419c-95a8-259a187b625e
# ╠═97182dab-7c9c-4db8-b5da-92676a1813d7
# ╠═bcd5f408-aa4a-43f2-a380-8a1ac274ceab
# ╟─a2a3fb20-2f90-410f-ac46-dee770edddaa
# ╟─28e4c5c0-58ed-4159-affd-f58dd9def64b
# ╠═105b5072-f649-4587-b58c-ddacac8c8291
# ╠═97b5511f-20a0-44f6-9ac2-f5b1d7ebc3c6
# ╟─0d9c898a-b176-4545-b096-aaa24a4769ce
# ╠═367c6a5c-1cf8-4790-89a7-b540e2a830f6
# ╠═7142855c-33b7-4a35-82b1-b8cac8645efe
# ╠═965b5dc9-f31b-4845-b1b7-912bc2a18967
# ╠═0b91ad9a-b141-49ed-823b-856283de666e
# ╠═0dd97ace-8c9c-4095-87d8-9facb9b2327f
# ╠═d3c02695-db06-44fc-886f-5b5d873bf14c
# ╠═9461dc08-1c21-4640-8384-e7154d427334
# ╠═6f3e181c-48a6-4715-8ab6-622344b6ac93
# ╠═cb4034e9-6e12-487f-90eb-8b3ff695326a
# ╠═27fa73a1-685f-41cf-9a2c-f1d4403719d3
# ╟─2b6c60f3-d10a-480d-b60c-f9a675558769
# ╠═a8ce94bc-a5e7-4100-a1ff-419b2f69363f
# ╠═0534d685-3f31-4f5f-893c-4d0ea1bf1252
# ╠═1f44183c-61e7-4aef-ab75-70ca177de10c
# ╠═fb95f561-2a07-4dd9-a5d6-d2643ff2f50b
# ╠═cf7f1eb1-a4f8-41fd-ab0d-27ac622602ff
# ╠═21149fc1-5f01-4219-99b6-f3500ab6896a
# ╠═15512a8e-e247-4bbb-990c-bf0b442e69eb
# ╟─c91b06e7-7d16-4890-b4e3-986248e79e04
# ╠═f4dc6a16-3010-4fa3-a25a-b6cdaa75a462
# ╠═fa0a927e-6620-41c9-8fc1-62ddd7c69fd1
# ╠═358e877f-66f3-43cd-9e16-c3ce2b19734b
# ╠═a94ba41c-8741-439a-89c5-04d78cd645ec
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
