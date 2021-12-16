### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 66be6141-f565-4a02-b815-fe182e899707
const var"@skip_as_script" = try Main.PlutoRunner.var"@skip_as_script" catch; (_, _, expr) -> nothing end

# ╔═╡ 2ca22f96-1422-4145-90c6-6cd3e078abfa
@skip_as_script begin
	import HypertextLiteral
	
	PrettyFunctions = Main.eval(:(module PrettyFunctions
		include("./PrettyFunctions.jl")
	end))
	import .PrettyFunctions: prettycolors, PrettyFunctions

	function Base.show(io::IO, ::MIME"text/html", expr::Expr)
		show(io, MIME("text/html"), prettycolors(expr, Main))
	end

	PrettyFunctions
end

# ╔═╡ 4a541e79-37bd-48cb-a069-b3c1ff991ec4
macro identity(expr)
	expr
end

# ╔═╡ e7aebc04-b800-4949-bdeb-c73791bd2dde
@macroexpand @identity quote
	quote end
end

# ╔═╡ ad7d591b-1ed4-4648-a506-684a3d62a969
macro huh()
	quote
		1 + 1
		quote
			10
		end
	end
end

# ╔═╡ 032214d4-89e7-4093-aa45-ba158c65f251
@macroexpand @huh()

# ╔═╡ a4957b0e-3d42-4766-b3bf-6fd25ea15bc9
module X
	macro child()
		quote
			10
		end
	end

	macro parent()
		quote
			@child()
		end
	end
end

# ╔═╡ 1f77efce-422f-11ec-1fd2-b53b15059368
module RecursiveMacroExpand
	include("./RecursiveMacroExpand.jl")
end

# ╔═╡ 3c2f6636-bf21-4550-bfcf-769c407d202e
RecursiveMacroExpand.recursive_macroexpand1(
	mod=@__MODULE__(),
	expr=:(@identity quote
		quote end
	end),
)

# ╔═╡ 299e4f76-3b9f-43f0-a497-6ce39bf65b10
begin
	metadata = RecursiveMacroExpand.MacroexpandMetadata()
	RecursiveMacroExpand.recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=quote
			@parent()
		end,
		# expr=:(1 + 1),
		metadata=metadata,
	)
	metadata
end

# ╔═╡ a98d5b7b-4c41-4935-a7a3-80ab9643ee6b
ast = quote
	:($(x) + 1)
end

# ╔═╡ 28d29f1d-af59-4d3d-9bf8-11cc4050d1b1
RecursiveMacroExpand.recursive_macroexpand1(
	mod=@__MODULE__(),
	expr=ast,
)

# ╔═╡ ec20b514-bcde-4a6e-be7a-46a10815edcd
RecursiveMacroExpand.macrohygiene(esc(ast))

# ╔═╡ 9d8e9b57-0025-498a-ade4-3b644282c5a2
macroexpand(@__MODULE__(), ast)

# ╔═╡ 7a28685e-3260-4be7-b09a-e24982609e77
z = macroexpand(@__MODULE__(), ast, recursive=false)

# ╔═╡ f3fbdb75-fc62-49f7-a8ab-0fb882fd13c0
z.args[2].args[1].value.head

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
# ╟─66be6141-f565-4a02-b815-fe182e899707
# ╟─2ca22f96-1422-4145-90c6-6cd3e078abfa
# ╠═4a541e79-37bd-48cb-a069-b3c1ff991ec4
# ╠═e7aebc04-b800-4949-bdeb-c73791bd2dde
# ╠═3c2f6636-bf21-4550-bfcf-769c407d202e
# ╠═ad7d591b-1ed4-4648-a506-684a3d62a969
# ╠═032214d4-89e7-4093-aa45-ba158c65f251
# ╠═a4957b0e-3d42-4766-b3bf-6fd25ea15bc9
# ╠═299e4f76-3b9f-43f0-a497-6ce39bf65b10
# ╠═1f77efce-422f-11ec-1fd2-b53b15059368
# ╠═a98d5b7b-4c41-4935-a7a3-80ab9643ee6b
# ╠═28d29f1d-af59-4d3d-9bf8-11cc4050d1b1
# ╠═ec20b514-bcde-4a6e-be7a-46a10815edcd
# ╠═9d8e9b57-0025-498a-ade4-3b644282c5a2
# ╠═7a28685e-3260-4be7-b09a-e24982609e77
# ╠═f3fbdb75-fc62-49f7-a8ab-0fb882fd13c0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
