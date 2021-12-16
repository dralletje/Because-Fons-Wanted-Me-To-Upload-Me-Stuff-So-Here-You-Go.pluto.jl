### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 81d729ac-407c-11ec-36fb-93a0c081f4eb
import HypertextLiteral: HypertextLiteral, @htl

# ╔═╡ 630c9cbe-feec-42dc-8304-cc029fa72b26
x = Dict(:uint8_array => UInt8[1,2,3,4,5,6])

# ╔═╡ 93c9f2a3-6d22-4404-8856-2bff6601168a
@htl """<script id="hi">
let suffix = html`<b>@htl PlutoRunner.publish_to_js(x)</b>`
let x = $(PlutoRunner.publish_to_js(x))
if (x.uint8_array instanceof Uint8Array) {
	return html`<div>✅ \${suffix}</div>`
} else {
	return html`<div>☠️ \${suffix}</div>`
}
"""

# ╔═╡ 0fa1ebe0-b802-40f3-b47f-80291bfdd1db
@htl("""<script>
let suffix = html`<b>HypertextLiteral.JavaScript(PlutoRunner.publish_to_js(x))</b>`
let x = $(HypertextLiteral.JavaScript(PlutoRunner.publish_to_js(x)))
if (x.uint8_array instanceof Uint8Array) {
	return html`<div>✅ \${suffix}</div>`
} else {
	return html`<div>☠️ \${suffix}</div>`
}
""")

# ╔═╡ f4c74b63-18ba-4b05-8a87-8c5c02bfa293
HTML("""<script>
let suffix = html`<b>HTML(PlutoRunner.publish_to_js(x))</b>`
let x = $(PlutoRunner.publish_to_js(x))
if (x.uint8_array instanceof Uint8Array) {
	return html`<div>✅ \${suffix}</div>`
} else {
	return html`<div>☠️ \${suffix}</div>`
}
""")

# ╔═╡ c795962e-b3a4-4158-a4ce-41b6996deaac
md"## Errors"

# ╔═╡ a659db06-9331-4c58-a567-b2030af29d82
published_in_different_cell = PlutoRunner.publish_to_js(Dict(:uint8_array => UInt8[1,2,3,4,5,6]))

# ╔═╡ 5a14628b-028f-4a78-b527-595ea44d6e5a
HTML("""<script>
let x = $(published_in_different_cell)
console.log("Publish in different cell: This shouldn't be shown")
""")

# ╔═╡ ed3af2b4-de41-4405-bc89-265b06962056
@htl """<script>
let x = $(published_in_different_cell)
console.log("Publish in different cell: This shouldn't be shown")
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"
"""

# ╔═╡ Cell order:
# ╠═81d729ac-407c-11ec-36fb-93a0c081f4eb
# ╠═630c9cbe-feec-42dc-8304-cc029fa72b26
# ╠═93c9f2a3-6d22-4404-8856-2bff6601168a
# ╠═0fa1ebe0-b802-40f3-b47f-80291bfdd1db
# ╠═f4c74b63-18ba-4b05-8a87-8c5c02bfa293
# ╟─c795962e-b3a4-4158-a4ce-41b6996deaac
# ╠═a659db06-9331-4c58-a567-b2030af29d82
# ╠═5a14628b-028f-4a78-b527-595ea44d6e5a
# ╠═ed3af2b4-de41-4405-bc89-265b06962056
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
