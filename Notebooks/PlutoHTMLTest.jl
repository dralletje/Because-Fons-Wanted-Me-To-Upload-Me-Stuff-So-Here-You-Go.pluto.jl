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

# ╔═╡ 92b7f3bd-9646-4464-bc3a-7bb27a575cfb
using .PlutoRunner.PlutoHTML: PlutoHTMLElement, PlutoHTMLElementList, embed_display

# ╔═╡ f50a68f0-d64d-411f-9ffe-2f8bd6321842
import HypertextLiteral: @htl

# ╔═╡ 1b2d625f-2868-4f81-ad57-6217219e8acc
import Gumbo

# ╔═╡ c8f2ba71-b707-483c-9084-4d07384b6a97


# ╔═╡ 7a85b2f7-ba0a-494a-b586-e5aa4df277fb
Base.pushmeta!(Expr(:call, :hi), :symbol)

# ╔═╡ 6852c6cd-bc53-43a1-9662-ab150cddfd35
Main.Gumbo

# ╔═╡ 930a57d8-fb7c-4368-b268-af898151d0a3
Expr(:meta)

# ╔═╡ fd9bb774-7e7c-4889-ab5f-c8bd620a0f42
g = Base.require(Main, :Gumbo)

# ╔═╡ 97befe88-6a44-444a-9944-f0db988d214e
function gumbo_element_to_pluto_element(gumbo_text::Gumbo.HTMLText)
	HTML(gumbo_text)
end

# ╔═╡ cf9e6366-0eda-4817-9b44-7336cc750c89
function gumbo_element_to_pluto_element(gumbo_element::Gumbo.HTMLElement{T}) where T
	PlutoRunner.PlutoHTML.PlutoHTMLElement(
		tagname=string(T),
		attributes=gumbo_element.attributes,
		children=map(gumbo_element.children) do element
			gumbo_element_to_pluto_element(element)
		end
	)
end

# ╔═╡ f6b29060-ad0f-4d0e-a0f2-297028df20a8
function html_to_pluto_element(html_able)
	@assert showable(MIME("text/html"), html_able)

	html = repr(MIME("text/html"), html_able)
	gumbo_document = Gumbo.parsehtml(html)
	body_element = gumbo_document.root.children[2].children[1]
	pluto_element = gumbo_element_to_pluto_element(body_element)
end

# ╔═╡ e7479e30-841a-4aaf-bbfd-c542f4a068ed
p = html_to_pluto_element(@htl("""
<div>
	<input type="text">
</div>
"""))

# ╔═╡ a9f008d5-9850-435e-9745-b4a75c272580
key = "10"

# ╔═╡ bd0ff150-5ea8-40d8-927d-dcf50fe5c01e
signup = @htl """<div
	style=$(Dict(
		:display => "flex",
		:flex_direction => "column"
	))
>
	$(@bind username @htl("<input type=text placeholder=username />"))
	$(@bind password @htl("<input type=password placeholder=password />"))
</div>"""

# ╔═╡ 02c09904-a1db-4849-9db9-aa560cf8fb92
function Whitespace(; height=0, width=0)
	@htl """<div style=$(Dict(
		:width => "$(width)px",
		:height => "$(height)px",
	))></div>"""
end

# ╔═╡ aa149152-5dae-49d1-9ef9-a35ac854d2ba
user = "Michiel"

# ╔═╡ e5579ac8-38ef-4c57-b38a-95380dcf0cda
@htl """<div
	style=$(Dict(
		:display => "flex",
		:flex_direction => "row",
	))
>
	$(signup)

	$(Whitespace(width=16))

	<div style=$(Dict(
		:flex => 1,
		:align_self => "stretch",
		
		:background_color => "red",
		:color => "white",

		:display => "flex",
		:align_items => "center",
		:justify_content => "center",
	))>
		Welcome $(user)
		$(embed_display(hmm))
	</div>
</div>"""

# ╔═╡ e9e4074f-09d5-4abe-adfb-a28ab23bcfb6
SingleElement(x) = PlutoHTMLElementList(Dict("key" => x))

# ╔═╡ 9d4d089d-88dc-470e-916b-81038c3192b1
x = PlutoHTMLElement(
	tagname="p",
	children=[
		@htl("<input type=text>"),
		Text("Hi"),
		["hi"],
		PlutoHTMLElementList(Dict(
			key => @htl("<input type=text>")
		)),
		PlutoHTMLElement(
			tagname="input",
			attributes=Dict("type" => "text", "value" => "Hi"),
			children=[],
		),
	],
	attributes=Dict(),
)

# ╔═╡ 01288ccc-90f9-4939-b8f5-808e6fd8dfdc
z = PlutoRunner.PlutoHTML.PlutoHTMLElementList(Dict(
	key => @bind(l, @htl("<input type=text>"))
))

# ╔═╡ d5116e67-2078-4c7d-a346-1568e507d31e
PlutoRunner.format_output_default(z)

# ╔═╡ 67971142-3e52-4f68-b4e7-9034f6633c39
z

# ╔═╡ 521ca4fb-017c-4a30-8b98-16f0e7716fc6
html"""
<div.asd>Hi
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Gumbo = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
Gumbo = "~0.8.0"
HypertextLiteral = "~0.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

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

[[Gumbo]]
deps = ["AbstractTrees", "Gumbo_jll", "Libdl"]
git-tree-sha1 = "e711d08d896018037d6ff0ad4ebe675ca67119d4"
uuid = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
version = "0.8.0"

[[Gumbo_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "86111f5523d7c42da0edd85ef7999c663881ac1e"
uuid = "528830af-5a63-567c-a44a-034ed33b8444"
version = "0.10.1+1"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

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
# ╠═f50a68f0-d64d-411f-9ffe-2f8bd6321842
# ╠═1b2d625f-2868-4f81-ad57-6217219e8acc
# ╠═92b7f3bd-9646-4464-bc3a-7bb27a575cfb
# ╠═c8f2ba71-b707-483c-9084-4d07384b6a97
# ╠═7a85b2f7-ba0a-494a-b586-e5aa4df277fb
# ╠═6852c6cd-bc53-43a1-9662-ab150cddfd35
# ╠═930a57d8-fb7c-4368-b268-af898151d0a3
# ╠═fd9bb774-7e7c-4889-ab5f-c8bd620a0f42
# ╟─97befe88-6a44-444a-9944-f0db988d214e
# ╟─cf9e6366-0eda-4817-9b44-7336cc750c89
# ╟─f6b29060-ad0f-4d0e-a0f2-297028df20a8
# ╠═e7479e30-841a-4aaf-bbfd-c542f4a068ed
# ╠═a9f008d5-9850-435e-9745-b4a75c272580
# ╠═bd0ff150-5ea8-40d8-927d-dcf50fe5c01e
# ╠═02c09904-a1db-4849-9db9-aa560cf8fb92
# ╠═aa149152-5dae-49d1-9ef9-a35ac854d2ba
# ╠═e5579ac8-38ef-4c57-b38a-95380dcf0cda
# ╠═e9e4074f-09d5-4abe-adfb-a28ab23bcfb6
# ╠═9d4d089d-88dc-470e-916b-81038c3192b1
# ╠═01288ccc-90f9-4939-b8f5-808e6fd8dfdc
# ╠═d5116e67-2078-4c7d-a346-1568e507d31e
# ╠═67971142-3e52-4f68-b4e7-9034f6633c39
# ╠═521ca4fb-017c-4a30-8b98-16f0e7716fc6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
