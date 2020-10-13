### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 727665fc-0955-11eb-29bf-b9b2cc1505c9
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

# ╔═╡ ce79af58-0955-11eb-0265-dd381e32f838
var"@install" = ingredients("./Install.jl").var"@install"

# ╔═╡ d1eeb0e0-0958-11eb-0ee8-e99dbcac5c7f


# ╔═╡ 760509b6-0956-11eb-0b0d-c7506cf8126b
html"""
<style>
@import "https://unpkg.com/@observablehq/inspector@3.2.1/src/style.css";

.inspector a {
	font-weight: normal;
}
</style>

<script>
	let { Inspector } = await import("https://unpkg.com/@observablehq/inspector@3.2.1/src/index.js?module")

	console.log('inspector:', Inspector)

	let element = DOM.element('div')
	let inspector = new Inspector(element)
	inspector.fulfilled({ hey: [1,2,3,4,5,6,7,7] })
	return html`<div class=inspector>${element}</div>`
</script>
"""

# ╔═╡ 141eb364-0965-11eb-14bd-79afd19a2277
methodswith(typeof(plot(y=[1,2,3])))

# ╔═╡ 94c57264-0956-11eb-011e-6bbbe27456ea
@isdefined z

# ╔═╡ afceec84-0956-11eb-3f99-6b7bb8d030ad
sprint(show, @__MODULE__)

# ╔═╡ b35e562c-0957-11eb-3596-c788f4af8363
fullname(@__MODULE__)

# ╔═╡ 2f363a2c-0957-11eb-071b-974434e9730a
filter(methodswith(typeof(@__MODULE__))) do x
	!startswith(string(x.name), "@")
end

# ╔═╡ 52f9a596-0959-11eb-205d-e19e61b0f543
import Pkg

# ╔═╡ 0e81ff46-0961-11eb-1d6c-f1cd4a6b5391
parentmodule(parentmodule(parentmodule(Pkg.API)))

# ╔═╡ 2507fc3c-095b-11eb-3342-650fa360c5ec
methods(contains)

# ╔═╡ 63505190-095b-11eb-3b69-c1681e37f775
methodswith(AbstractArray)

# ╔═╡ aa6bf68e-095a-11eb-1b32-797bdd330d1f
methodswith(Array)

# ╔═╡ d36e4660-0958-11eb-0eb9-d96e41284c58
ExampleModule = ingredients("./Install.jl")

# ╔═╡ 8ba2ce7c-0959-11eb-366d-414878c5b7e9
getproperty(ExampleModule, Symbol("Install.jl")) == ExampleModule

# ╔═╡ fb30292a-0958-11eb-08af-317ace36be1e
names(ExampleModule, all=true)

# ╔═╡ a7d4751a-0958-11eb-1aa0-db71a30afcbc
names(ExampleModule, imported=true)

# ╔═╡ fbcde7f2-095b-11eb-24e9-c35e6b5ef342
Pkg.Types.PRESERVE_ALL

# ╔═╡ 590b5b48-0961-11eb-2773-fddc3e9b1453
parentmodule(Pkg.Types.PKGMODE_MANIFEST)

# ╔═╡ 05822db6-0958-11eb-2a5b-0d4591de4563
function module_html(io::IO, mod::Module)
	mime = MIME("text/html")
	
	name = fullname(mod)
	all_properties = filter(names(mod, all=true)) do x
		!startswith(string(x), "#")
	end
	imported = names(mod, imported=true)
	exported = names(mod) 
	
	print(io, """<code class="language-julia" style="white-space: pre">""")
	println(io, """module $(join(name, "."))""")
	for property in names(mod, imported=true)
		value = repr(getproperty(mod, property))
		println(io, """	using $(value)""")
	end
	
	println(io)
	
	for property in all_properties
		value = repr(getproperty(mod, property))
		key = string(property)
		prefix = property ∈ exported ? "export " : ""
		println(io, """	$(prefix)$(key) = $(value)""")
	end
	println(io, """end""")

	print(io, """</code>""")
end

# ╔═╡ d45fc768-0961-11eb-2b0e-8dfad03b7733
@which show(stdout, Pkg.Types.PKGMODE_MANIFEST)

# ╔═╡ 222ffa86-0964-11eb-0998-015b0e4d8d4d
typeof(Pkg.Types.PKGMODE_MANIFEST).name.module

# ╔═╡ 0a02880c-0964-11eb-1632-2fdd7c929d18
sprint(show, Pkg.Types.PKGMODE_MANIFEST)

# ╔═╡ 18bd36c8-0958-11eb-32e8-73a756d6faca
begin
	global x = 10
	HTML(sprint(module_html, Pkg))
end

# ╔═╡ ae0daa2e-095c-11eb-31cb-ebdec17cb23a
repr(Pkg.add)

# ╔═╡ 5627952c-095c-11eb-2c24-2b3533d56384
weird_type = typeof(Pkg.redo)

# ╔═╡ 0dcccd10-095c-11eb-3940-2922526d9573
methodswith(typeof(weird_type))

# ╔═╡ 6027b7be-095c-11eb-0cdc-c76c60d0f630
dump(weird_type)

# ╔═╡ 29829e9c-095c-11eb-1c78-f36bf4d3c1a4
typeof(function()
	
	end)

# ╔═╡ fa365d94-095a-11eb-2be2-6fc3e7ca9856
repr(Pkg.redo)

# ╔═╡ fbb94e04-0966-11eb-0e06-77ac6ef2cf57


# ╔═╡ c8a61ae8-0956-11eb-000c-f98ed70bb2cd
# begin
# 	function Base.show(io::IO, mime::MIME"text/html", mod::Module)
# 		name = fullname(mod)
# 		show(io, mime, HTML("""
# 			<code class="language-julia">module $(join(name, "."))</code>
# 		"""))
# 	end
# 	@__MODULE__
# end

# ╔═╡ Cell order:
# ╠═727665fc-0955-11eb-29bf-b9b2cc1505c9
# ╠═ce79af58-0955-11eb-0265-dd381e32f838
# ╠═d1eeb0e0-0958-11eb-0ee8-e99dbcac5c7f
# ╠═760509b6-0956-11eb-0b0d-c7506cf8126b
# ╠═141eb364-0965-11eb-14bd-79afd19a2277
# ╠═94c57264-0956-11eb-011e-6bbbe27456ea
# ╠═afceec84-0956-11eb-3f99-6b7bb8d030ad
# ╠═b35e562c-0957-11eb-3596-c788f4af8363
# ╠═2f363a2c-0957-11eb-071b-974434e9730a
# ╠═0e81ff46-0961-11eb-1d6c-f1cd4a6b5391
# ╠═8ba2ce7c-0959-11eb-366d-414878c5b7e9
# ╠═fb30292a-0958-11eb-08af-317ace36be1e
# ╠═52f9a596-0959-11eb-205d-e19e61b0f543
# ╠═a7d4751a-0958-11eb-1aa0-db71a30afcbc
# ╠═2507fc3c-095b-11eb-3342-650fa360c5ec
# ╠═63505190-095b-11eb-3b69-c1681e37f775
# ╠═aa6bf68e-095a-11eb-1b32-797bdd330d1f
# ╠═d36e4660-0958-11eb-0eb9-d96e41284c58
# ╠═fbcde7f2-095b-11eb-24e9-c35e6b5ef342
# ╠═590b5b48-0961-11eb-2773-fddc3e9b1453
# ╠═05822db6-0958-11eb-2a5b-0d4591de4563
# ╠═d45fc768-0961-11eb-2b0e-8dfad03b7733
# ╠═222ffa86-0964-11eb-0998-015b0e4d8d4d
# ╠═0a02880c-0964-11eb-1632-2fdd7c929d18
# ╠═18bd36c8-0958-11eb-32e8-73a756d6faca
# ╠═0dcccd10-095c-11eb-3940-2922526d9573
# ╠═ae0daa2e-095c-11eb-31cb-ebdec17cb23a
# ╠═5627952c-095c-11eb-2c24-2b3533d56384
# ╠═6027b7be-095c-11eb-0cdc-c76c60d0f630
# ╠═29829e9c-095c-11eb-1c78-f36bf4d3c1a4
# ╠═fa365d94-095a-11eb-2be2-6fc3e7ca9856
# ╠═fbb94e04-0966-11eb-0e06-77ac6ef2cf57
# ╠═c8a61ae8-0956-11eb-000c-f98ed70bb2cd
