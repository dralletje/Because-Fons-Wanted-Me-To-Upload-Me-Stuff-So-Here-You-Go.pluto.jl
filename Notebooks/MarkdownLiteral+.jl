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

# ╔═╡ cf8cc669-1274-4b29-b077-8c7e0102dbe1
import MarkdownLiteral

# ╔═╡ defc15e9-5bef-4231-924c-a4b086c3cd4b
import HypertextLiteral: HypertextLiteral, @htl, Bypass, Render, Reprint

# ╔═╡ 562584b7-7684-442e-891f-0b82a076bc13
import CommonMark

# ╔═╡ e25d36f4-a256-48f7-987b-c56bf903f855
import PlutoTest: @test

# ╔═╡ 5a001c64-7c0a-4cfc-94c4-e19e3f9820d1
struct HtmlSpoofer
	spoof_html
	actual_value
end

# ╔═╡ c15ed53b-6cec-47f3-8d98-e11afd624cd3
import PlutoUI

# ╔═╡ a3023b4f-75c0-4c6a-aa38-a4ab87b05917
HypertextLiteral.content(x::HtmlSpoofer) = HypertextLiteral.content(x.spoof_html)

# ╔═╡ 07996781-d070-46e1-815a-6bc809453392
MarkdownLiteral.@markdown """
$(@bind x PlutoUI.RangeSlider(1:10))
"""

# ╔═╡ da887527-259f-46e7-b4ec-757ceb42c8ba
HypertextLiteral.attribute_pair(x::HtmlSpoofer) = HypertextLiteral.attribute_pair(x.actual_value)

# ╔═╡ 384b3bb0-5a8e-41fa-b294-b60c3e39c648
HypertextLiteral.attribute_value(x::HtmlSpoofer) = HypertextLiteral.attribute_value(x.actual_value)

# ╔═╡ fdd44b53-fe9f-4b56-9050-8008158767a3
macro markdown(expr)
    cm_parser = CommonMark.Parser()
    CommonMark.enable!(cm_parser, [
        CommonMark.AdmonitionRule(),
        CommonMark.AttributeRule(),
        CommonMark.AutoIdentifierRule(),
        CommonMark.CitationRule(),
        CommonMark.FootnoteRule(),
        CommonMark.MathRule(),
        CommonMark.RawContentRule(),
        CommonMark.TableRule(),
        CommonMark.TypographyRule(),
    ])

	spoofs! = Dict()
	if Meta.isexpr(expr, :string)
		spoofs! = Dict()
		expr = Expr(expr.head, map(enumerate(expr.args)) do (index, arg)
			if arg isa String
				arg
			else
				tag = "markdownliteral-replacement-tag-$(string(index))"
				html = repr(MIME("text/html"), @htl("<$tag></$tag>"))

				:(let
					arg = $arg
					html = $html
					$spoofs![html] = arg
					$HtmlSpoofer(
						HTML(html),
						$arg
					)
				end)
			end
		end...)
	end
	
    quote
        result = $(esc(Expr(:macrocall, getfield(HypertextLiteral, Symbol("@htl")), __source__, expr)))
        CMParsedRenderer(contents = result, parser = $cm_parser, spoofs! = $spoofs!)
    end
end

# ╔═╡ 94cf465f-ff2d-4437-bdfa-d1400741be5b
Base.@kwdef struct CMParsedRenderer
    contents::Any
    parser::CommonMark.Parser
	spoofs!
end

# ╔═╡ 2c09c621-c7dc-41b7-8544-99f2b05af2ec
@markdown """
$(@bind y PlutoUI.RangeSlider(1:10))
"""

# ╔═╡ bcf5b34a-30c5-407d-a023-2be3719da820
@test repr(MIME("text/html"), @markdown("""$("**hi**")""")) == repr(MIME("text/html"), @markdown("""\\*\\*hi\\*\\*"""))

# ╔═╡ 836aba02-1fc8-44e7-863a-6c4409ddca70
@markdown "$(html"hi")"

# ╔═╡ 5663964b-5fe2-4cf3-a33c-fa23422d6a7d
@markdown("""$("**hi**")""")

# ╔═╡ 47145022-6f32-4708-8652-5b0da8fff258
result = repr(MIME("text/html"), @markdown """
<div class=$("hi")>
<hi></hi>

$(md"hi")
""")

# ╔═╡ 5dbf97c6-d0f3-430b-b548-423b1df16c27
function Base.show(io::IO, m::MIME"text/html", p::CMParsedRenderer)
    # Use the given IO as context, render to HTML
    html_render = sprint(show, m, p.contents; context = io)
    # Parse the result
    cm_parsed = p.parser(html_render)
    # And render to HTML again
    html_with_slots = sprint(show, m, cm_parsed; context = io)

	for (key, value) in p.spoofs!
		html = showable(m, value) ? sprint(show, m, value; context = io) : String(value)
		html_with_slots = replace(html_with_slots, key => html)
	end
	print(io, html_with_slots)
end

# ╔═╡ d04bd78d-c9e3-46b2-9767-59d4ed77bb69
# Some aliases, it's up to you which one to import.

# ╔═╡ a65da25a-4835-465e-bc6b-202cb974117c
const var"@markdownliteral" = var"@markdown"

# ╔═╡ 331650f9-4edf-479d-a4c6-d8cd5fea5a8e
const var"@mdx" = var"@markdown"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CommonMark = "~0.8.5"
HypertextLiteral = "~0.9.3"
MarkdownLiteral = "~0.1.1"
PlutoTest = "~0.2.0"
PlutoUI = "~0.7.30"
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

[[PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "92b8ae1eee37c1b8f70d3a8fb6c3f2d81809a1c5"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.0"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "5c0eb9099596090bb3215260ceca687b888a1575"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.30"

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
# ╠═cf8cc669-1274-4b29-b077-8c7e0102dbe1
# ╠═defc15e9-5bef-4231-924c-a4b086c3cd4b
# ╠═562584b7-7684-442e-891f-0b82a076bc13
# ╠═e25d36f4-a256-48f7-987b-c56bf903f855
# ╠═5a001c64-7c0a-4cfc-94c4-e19e3f9820d1
# ╠═c15ed53b-6cec-47f3-8d98-e11afd624cd3
# ╠═07996781-d070-46e1-815a-6bc809453392
# ╠═2c09c621-c7dc-41b7-8544-99f2b05af2ec
# ╠═a3023b4f-75c0-4c6a-aa38-a4ab87b05917
# ╠═da887527-259f-46e7-b4ec-757ceb42c8ba
# ╠═384b3bb0-5a8e-41fa-b294-b60c3e39c648
# ╠═bcf5b34a-30c5-407d-a023-2be3719da820
# ╠═836aba02-1fc8-44e7-863a-6c4409ddca70
# ╠═5663964b-5fe2-4cf3-a33c-fa23422d6a7d
# ╠═47145022-6f32-4708-8652-5b0da8fff258
# ╟─fdd44b53-fe9f-4b56-9050-8008158767a3
# ╠═94cf465f-ff2d-4437-bdfa-d1400741be5b
# ╠═5dbf97c6-d0f3-430b-b548-423b1df16c27
# ╠═d04bd78d-c9e3-46b2-9767-59d4ed77bb69
# ╠═a65da25a-4835-465e-bc6b-202cb974117c
# ╠═331650f9-4edf-479d-a4c6-d8cd5fea5a8e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
