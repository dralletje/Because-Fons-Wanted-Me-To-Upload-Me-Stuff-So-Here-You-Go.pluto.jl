### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 1a556ad6-0b73-11eb-2879-0734ae095628
using REPL

# ╔═╡ ee69fbc0-0b59-11eb-1295-854954f81f30
begin
    import Pkg
    Pkg.add(url="https://github.com/Pocket-titan/DarkMode")
    import DarkMode
    # DarkMode.enable()
end

# ╔═╡ 5a3a25e4-0bdc-11eb-0e14-b126edab352d
r"123"

# ╔═╡ 81e97bd0-0be1-11eb-28b2-41c95565cfda


# ╔═╡ 350e3e02-0be8-11eb-02aa-fbe89d920d1d
html"""<div style="height: 300px" />"""

# ╔═╡ 8294788a-0be8-11eb-1060-c9264dc85612
⇟ #Nice

# ╔═╡ 5052c388-0be8-11eb-1230-db877fecfd34
html"""<div style="height: 300px" />"""

# ╔═╡ dadf0740-0be2-11eb-25f6-2b3ae1e1b1b3
sprint(dump, REPL.completions("\\", 1)[1][1].bslash) |> Text

# ╔═╡ f8d6c9a8-0be3-11eb-1a61-65dce15f0412
REPL.REPLCompletions.latex_symbols

# ╔═╡ 56d6148c-0be4-11eb-196c-f1f525f65a69
\

# ╔═╡ b178f960-0be2-11eb-2cd6-c193605f9f3e
PlutoRunner.completion_fetcher("\\ne", 3)

# ╔═╡ c285588a-0be3-11eb-34b3-c3d586655138
PlutoRunner.completion_fetcher("\\", 1)

# ╔═╡ 07ab8cfe-0bdd-11eb-0de6-ad9498ab442e
a::AbstractArray{String{Dong,Std}}

# ╔═╡ 3bfa51f8-0be1-11eb-2f04-61f04d380551
\nLeftarrow

# ╔═╡ 525deef2-0bdf-11eb-2e2d-d52e5964192c
AbstractArray{String}

# ╔═╡ b35e6288-0bdf-11eb-040a-396733f27e9d


# ╔═╡ 7f737dc4-0aec-11eb-18d2-a341bc178fb0
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 949229b0-0aec-11eb-053a-6fc335d39745
var"@install" = ingredients("./Install.jl").var"@install"

# ╔═╡ db0d9c48-0b58-11eb-1ac0-c906ea1a8bcc
@install using PlutoUI v"0.6.1"

# ╔═╡ af37e120-0b60-11eb-38a9-43924a993e14
@install using JSON v"0.21.1"

# ╔═╡ 8a803d5e-0b66-11eb-0f30-7d5a8e48c295
loaded_modules = Base.loaded_modules

# ╔═╡ 1f753692-0b69-11eb-1754-b7d6bb9a4cb3
md"---"

# ╔═╡ de8ab792-0b7c-11eb-3968-efe4e18ceba4
sprint(dump, :(AbstractArray{String})) |> Text

# ╔═╡ 0fd133e0-0b5e-11eb-0b77-8fe8394d5be5
observable_cell(;
	notebook::String = "@dralletje/corona-compare",
	cells::AbstractArray{String} = ["selected_country_view"],
	overwrites::Dict{Symbol, Any} = Dict{Symbol,Any}(:SELECTED_COUNTRY => "Netherlands")
) = HTML("""
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@observablehq/inspector/src/style.css"></link>

<script>
let cells = $(JSON.json(cells));
let overwrites = $(JSON.json(overwrites));
	
let { Runtime, Inspector, Library } = await import("https://cdn.jsdelivr.net/npm/@observablehq/runtime@4/dist/runtime.js")

let element = DOM.element('div')
let cell = currentScript.closest('pluto-output')

let observer = Inspector.into(element)
const runtime = new Runtime(Object.assign(new Library, { width: cell.clientWidth - 30 }));
	
const main = runtime.module();
for (let [name, value] of Object.entries(overwrites)) {
	main.variable(observer(name)).define(name, () => {
		return value;
	});
}


let { default: imported_module } = await import(`https://api.observablehq.com/$(notebook).js?v=3`)
const child1 = runtime.module(imported_module, (name) => {
	// if (cells.includes(name)) {
	//	return observer(name)
	// }
}).derive(Object.keys(overwrites), main);
console.log('child1._scope:', child1._scope)

for (let cell_name of cells) {
	main.variable(observer("")).import(cell_name, child1);
}

return element
""")

# ╔═╡ 74b9a70e-0b60-11eb-1b99-89a945ec0456
observable_cell(
	notebook = "@dralletje/corona-compare",
	cells = ["selected_country_view"],
	overwrites = Dict{Symbol,Any}(:SELECTED_COUNTRY => "France")
)

# ╔═╡ 50d8dfb2-0bd8-11eb-3189-b58015bb0bbe
"""
Well this is obvious no?
"""
function PlutoRunner.is_pure_expression()
end

# ╔═╡ 6f4c5050-0bd8-11eb-284b-abd7d7c63eb2
"""
What now?
"""
function PlutoRunner.is_pure_expression(a)
end

# ╔═╡ d39e00a0-0b7c-11eb-3ed3-35239e082d41
PlutoRunner.is_pure_expression(:(AbstractArray{String}))

# ╔═╡ b466adb6-0b60-11eb-0ca9-c9578be2a88d
observable_cell(
	notebook = "@dralletje/corona-compare",
	cells = ["selected_country_view"],
	overwrites = Dict{Symbol,Any}(:SELECTED_COUNTRY => "Netherlands")
)

# ╔═╡ 630eff6a-0b63-11eb-196f-b17bb7ccea97
data = JSONText("""
[{"name":"A","value":0.08167},{"name":"B","value":0.01492},{"name":"C","value":0.02782},{"name":"D","value":0.04253},{"name":"E","value":0.12702},{"name":"F","value":0.02288},{"name":"G","value":0.02015},{"name":"H","value":0.06094},{"name":"I","value":0.06966},{"name":"J","value":0.00153},{"name":"K","value":0.00772},{"name":"L","value":0.04025},{"name":"M","value":0.02406},{"name":"N","value":0.06749},{"name":"O","value":0.07507},{"name":"P","value":0.01929},{"name":"Q","value":0.00095},{"name":"R","value":0.05987},{"name":"S","value":0.06327},{"name":"T","value":0.09056},{"name":"U","value":0.02758},{"name":"V","value":0.00978},{"name":"W","value":0.0236},{"name":"X","value":0.0015},{"name":"Y","value":0.01974},{"name":"Z","value":0.00074}]
""")


# ╔═╡ 7eac6e20-0b62-11eb-3f18-bbc3cd7045f4
observable_cell(
	notebook = "@d3/sortable-bar-chart",
	cells = ["viewof order", "chart"],
	overwrites = Dict{Symbol,Any}(:data => data)
)

# ╔═╡ 5b9c0182-0b69-11eb-1bda-a9f432cdc065
md"---"

# ╔═╡ 12a9b16a-0bd5-11eb-1b06-09b2d8cd2e09
sprint(dump, Meta.parse("AbstractArray{String}")) |> Text

# ╔═╡ da6b288e-0be7-11eb-35fe-4778696e4f35
b =  Meta.parse("AbstractArray{String}")

# ╔═╡ bdaa6a9c-0bde-11eb-2eca-511f2e8a5154
b::AbstractArray{String}

# ╔═╡ fdc7740e-0bdd-11eb-0ac7-338d002317d6
b::AbstractArray

# ╔═╡ df193dee-0be7-11eb-2330-5335ea58138d


# ╔═╡ 31e71482-0bd5-11eb-1dd3-d365d91745b5
sprint(dump, Meta.parse("::AbstractArray")) |> Text

# ╔═╡ 2b13313e-0b78-11eb-2a68-07a2e8350445
PlutoRunner.is_pure_expression(Meta.parse("AbstractArray{String}"))

# ╔═╡ 74921e10-0b78-11eb-3be5-5bce7970483a
PlutoRunner.eval(quote 
		binding_from(s::Symbol, workspace::Module=current_module) = Core.eval(workspace, s)
	end)


# ╔═╡ 8c0c9446-0bd5-11eb-36cc-ed9a02cb4a8c


# ╔═╡ cd5efeea-0b74-11eb-26d0-ad0ce0769f6e
function REPL.REPLCompletions.completion_text(completion::REPL.REPLCompletions.ModuleCompletion)
	if startswith(completion.mod, "@")
		completion.mod
	else
		string(Expr(:., :B, QuoteNode(Symbol(completion.mod))))[3:end]
	end
end

# ╔═╡ 26d5d854-0be3-11eb-0041-a918c9a24cef
function PlutoRunner.pluto_completion_text(completion::REPL.REPLCompletions.BslashCompletion)
	normal = REPL.REPLCompletions.completion_text(completion)
	complete = get(REPL.REPLCompletions.latex_symbols, completion.bslash, "")
	if (complete == "")
		normal
	else
		Dict(:text => complete, :displayText => normal)
	end
end

# ╔═╡ 374b184e-0b6a-11eb-1ae8-d991b6a9382c
x = Pkg.CTRL_C

# ╔═╡ 89622aa4-0b6b-11eb-0599-5b1b91a57daf
Pkg.UPLEVEL_MINOR

# ╔═╡ b4603d5a-0b6f-11eb-2676-61d0b38bf8d0
Pkg.UPLEVEL_MINOR

# ╔═╡ 2e352f24-0b6c-11eb-2027-a787119b66dc
Base.loaded_modules

# ╔═╡ 0dd2f3e2-0b38-11eb-0860-8b18f48d4d27
struct ZZZ
	a
	b
	c
end

# ╔═╡ 17bda32a-0b38-11eb-29d1-27a8b2b9c684
k = ZZZ(nothing, ZZZ(nothing, nothing, ZZZ("COOL", nothing, nothing)), nothing)

# ╔═╡ 6d3e7a1a-0b6d-11eb-2213-bf79ef00ffc5
k.b

# ╔═╡ 4724f1e6-0b6b-11eb-1bec-8f39ac86da63
PlutoRunner.eval(quote
	function doc_fetcher(query, workspace::Module=current_module)
		try
			println("Meta.parse(query):", Meta.parse(query))
			value = binding_from(Meta.parse(query), workspace)
			println("binding:", value)
			(
				repr(MIME"text/html"(), Docs.doc(value)),
				PlutoRunner.format_output(value),
				:👍
			)
		catch ex
			println(sprint(showerror, ex))
			(nothing, nothing, :👎)
		end
	end
end)

# ╔═╡ 5c171f64-0bd9-11eb-19de-0dd9b29915b2
module X
	module Y
		"Hey there"
		module Z

		end
	end
end

# ╔═╡ d1874bc4-0bda-11eb-2e19-a3e384b2cf65
REPL.REPLCompletions

# ╔═╡ 66fe41e6-0bd9-11eb-1fc7-af69c43e01df
function a_function()
	
end

# ╔═╡ 96306b92-0bd9-11eb-220f-4fdd6c213a38
sprint(dump, a_function)

# ╔═╡ afb8163c-0bd9-11eb-17b3-0baf607a65ac
collect(methods(a_function))

# ╔═╡ ffa73178-0b34-11eb-3014-79147bfe4b37
:(@Base.assert) == :(Base.@assert)

# ╔═╡ Cell order:
# ╟─ee69fbc0-0b59-11eb-1295-854954f81f30
# ╠═5a3a25e4-0bdc-11eb-0e14-b126edab352d
# ╠═81e97bd0-0be1-11eb-28b2-41c95565cfda
# ╟─350e3e02-0be8-11eb-02aa-fbe89d920d1d
# ╠═8294788a-0be8-11eb-1060-c9264dc85612
# ╠═5052c388-0be8-11eb-1230-db877fecfd34
# ╠═dadf0740-0be2-11eb-25f6-2b3ae1e1b1b3
# ╠═f8d6c9a8-0be3-11eb-1a61-65dce15f0412
# ╠═26d5d854-0be3-11eb-0041-a918c9a24cef
# ╠═56d6148c-0be4-11eb-196c-f1f525f65a69
# ╠═b178f960-0be2-11eb-2cd6-c193605f9f3e
# ╠═c285588a-0be3-11eb-34b3-c3d586655138
# ╠═07ab8cfe-0bdd-11eb-0de6-ad9498ab442e
# ╠═3bfa51f8-0be1-11eb-2f04-61f04d380551
# ╠═bdaa6a9c-0bde-11eb-2eca-511f2e8a5154
# ╠═525deef2-0bdf-11eb-2e2d-d52e5964192c
# ╠═b35e6288-0bdf-11eb-040a-396733f27e9d
# ╠═fdc7740e-0bdd-11eb-0ac7-338d002317d6
# ╟─7f737dc4-0aec-11eb-18d2-a341bc178fb0
# ╟─949229b0-0aec-11eb-053a-6fc335d39745
# ╠═8a803d5e-0b66-11eb-0f30-7d5a8e48c295
# ╟─1f753692-0b69-11eb-1754-b7d6bb9a4cb3
# ╟─db0d9c48-0b58-11eb-1ac0-c906ea1a8bcc
# ╟─af37e120-0b60-11eb-38a9-43924a993e14
# ╠═d39e00a0-0b7c-11eb-3ed3-35239e082d41
# ╠═de8ab792-0b7c-11eb-3968-efe4e18ceba4
# ╟─0fd133e0-0b5e-11eb-0b77-8fe8394d5be5
# ╟─74b9a70e-0b60-11eb-1b99-89a945ec0456
# ╠═50d8dfb2-0bd8-11eb-3189-b58015bb0bbe
# ╠═6f4c5050-0bd8-11eb-284b-abd7d7c63eb2
# ╠═b466adb6-0b60-11eb-0ca9-c9578be2a88d
# ╠═7eac6e20-0b62-11eb-3f18-bbc3cd7045f4
# ╠═630eff6a-0b63-11eb-196f-b17bb7ccea97
# ╟─5b9c0182-0b69-11eb-1bda-a9f432cdc065
# ╠═1a556ad6-0b73-11eb-2879-0734ae095628
# ╠═12a9b16a-0bd5-11eb-1b06-09b2d8cd2e09
# ╠═da6b288e-0be7-11eb-35fe-4778696e4f35
# ╠═df193dee-0be7-11eb-2330-5335ea58138d
# ╠═31e71482-0bd5-11eb-1dd3-d365d91745b5
# ╠═2b13313e-0b78-11eb-2a68-07a2e8350445
# ╠═74921e10-0b78-11eb-3be5-5bce7970483a
# ╠═8c0c9446-0bd5-11eb-36cc-ed9a02cb4a8c
# ╠═cd5efeea-0b74-11eb-26d0-ad0ce0769f6e
# ╠═6d3e7a1a-0b6d-11eb-2213-bf79ef00ffc5
# ╠═374b184e-0b6a-11eb-1ae8-d991b6a9382c
# ╠═89622aa4-0b6b-11eb-0599-5b1b91a57daf
# ╠═b4603d5a-0b6f-11eb-2676-61d0b38bf8d0
# ╠═2e352f24-0b6c-11eb-2027-a787119b66dc
# ╠═0dd2f3e2-0b38-11eb-0860-8b18f48d4d27
# ╠═17bda32a-0b38-11eb-29d1-27a8b2b9c684
# ╠═4724f1e6-0b6b-11eb-1bec-8f39ac86da63
# ╠═5c171f64-0bd9-11eb-19de-0dd9b29915b2
# ╠═d1874bc4-0bda-11eb-2e19-a3e384b2cf65
# ╠═66fe41e6-0bd9-11eb-1fc7-af69c43e01df
# ╠═96306b92-0bd9-11eb-220f-4fdd6c213a38
# ╠═afb8163c-0bd9-11eb-17b3-0baf607a65ac
# ╠═ffa73178-0b34-11eb-3014-79147bfe4b37
