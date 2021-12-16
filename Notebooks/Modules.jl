### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 2bf60a92-0a3b-11eb-03ac-d50d2c2456a2
module MyModule_BigExample
using Lib

using BigLib: thing1, thing2
# `as` is available starting julia 1.6
# using BigLib: thing1, thing2, thing3 as t3

import Base.show
# import Base.print as pr

export MyType, foo

struct MyType
    x
end

bar(x) = 2x
foo(a::MyType) = bar(a.x) + 1

show(io::IO, a::MyType) = pr(io, "MyType $(a.x)")
end

# ╔═╡ 41dd66da-0ae4-11eb-2af8-4dc16d5dbc88
module UsingMyModule
	using ..MyModule

	export y

	y = x()
end

# ╔═╡ 5a2bd2c8-0a3d-11eb-3983-31b96185c110
@eval macro $(:module)(let_statement)
	quote
		@module(:Anonymous, $let_statement)
	end
end

# ╔═╡ a4e6b1e4-0a37-11eb-2a79-b3da32e11260
@eval macro $(:module)(module_name, let_statement)
	definition = let_statement.head == :let ? QuoteNode(let_statement.args[2]) : let_statement
	
	quote
		module_name = $(module_name)
		mod = Module(module_name)
		Core.eval(mod, $(definition))
		mod
	end
end

# ╔═╡ 8f2b829c-0a32-11eb-3a93-f99abb5b0c51
overwrite_modules = Dict{Symbol, Module}(
	:Lib => @module(:Lib, let
		export x, y
		x = 10
		y = 20
	end),
	:BigLib => @module(:BigLib, let
		thing1 = "THING 1"
		thing2 = "THING 2"
	end)
)

# ╔═╡ 3d06e788-0a28-11eb-2349-59445af634e5
function Base.require(into::Module, mod::Symbol)
	try
		if mod in keys(overwrite_modules)
			return overwrite_modules[mod]
		end
	catch e end
	
    uuidkey = Base.identify_package(into, String(mod))

	if uuidkey === nothing
        throw("Module $(String(mod)) not found")
    end
	
    if Base._track_dependencies[]
        push!(Base._require_dependencies, (into, binpack(uuidkey), 0.0))
    end
    return Base.require(uuidkey)
end

# ╔═╡ d6e29b62-0aec-11eb-1875-ab6b1dc3a340
channel = Channel()

# ╔═╡ 1dda704e-0aed-11eb-110e-7fec7fb5ce1f


# ╔═╡ 10fa8ab2-0aed-11eb-09a3-ab6f64857523
array, task = let
	array = []
	task = @async let
		push!(array, 10)
		for x in channel
			push!(array, x)
		end
	end
	array, task
end

# ╔═╡ 410626c6-0aed-11eb-3ec6-e3a1a3ed1479
put!(channel, 20)

# ╔═╡ 9f926d9e-0aed-11eb-20cb-cbb591bc4e7c
task.state

# ╔═╡ 334cba22-0aed-11eb-1fbe-8566263f6c47
array

# ╔═╡ b6cc0af2-0a24-11eb-0db6-89611405f9d3
md"""
# [Modules](@id modules)

Modules in Julia are separate variable workspaces, i.e. they introduce a new global scope. They
are delimited syntactically, inside `module Name ... end`. Modules allow you to create top-level
definitions (aka global variables) without worrying about name conflicts when your code is used
together with somebody else's. Within a module, you can control which names from other modules
are visible (via importing), and specify which of your names are intended to be public (via exporting).

The following example demonstrates the major features of modules. It is not meant to be run, but
is shown for illustrative purposes:
"""

# ╔═╡ 26327b5e-0a3b-11eb-149f-3d14a722b188
md"""
Note that the style is not to indent the body of the module, since that would typically lead to whole files being indented.
"""

# ╔═╡ 7c1b4b0e-0ab0-11eb-31f8-01a90b9d632c
module MyModule

export x, y

x() = "x"
y() = "y"
p() = "p"

end

# ╔═╡ 7e602c4c-0ae5-11eb-240c-016b13e60c7e
MyModule.eval

# ╔═╡ 87c42826-0ae6-11eb-2ad7-ef15da27c29d
nameof(MyModule)

# ╔═╡ 48ccc14c-0a3e-11eb-17c3-8bba1750d5b0
function module_html(io::IO, mod::Module)
	mime = MIME("text/html")
	
	smallname = nameof(mod)
	name = fullname(mod)
	
	all_properties = filter(names(mod, all=true)) do property
		!startswith(string(property), "#") &&
		property ≠ :eval &&
		property ≠ :include &&
		!(property == smallname && getproperty(mod, property) == mod)

	end
	exported = names(mod) ∩ all_properties
	imports_without_self = setdiff(names(mod, imported=true) ∩ all_properties, exported)
	print(io, """<code class="language-julia" style="white-space: pre">""")
	println(io, """module $(join(name, "."))""")
	
	for property in imports_without_self
		value = repr(getproperty(mod, property))
		println(io, """	using $(value)""")
	end
	if length(imports_without_self) > 0
		println(io)
	end
	
	if length(exported) ≠ 0
		println(io, """	export $(join(exported, ", "))""")
		println(io)
	end
	
	for property in all_properties
		value = repr(getproperty(mod, property))
		key = string(property)
		println(io, """	$(key) = $(value)""")
	end
	println(io, """end""")

	print(io, """</code>""")
end

# ╔═╡ d8bb43b2-0a3d-11eb-0fd6-c9c6ac865427
function Base.show(io::IO, mime::MIME"text/html", mod::Module)
	module_html(io, mod)
end

# ╔═╡ b575ecdc-0ae6-11eb-13e7-c3586822cea7
module_html(IOBuffer(), MyModule)

# ╔═╡ Cell order:
# ╟─5a2bd2c8-0a3d-11eb-3983-31b96185c110
# ╟─a4e6b1e4-0a37-11eb-2a79-b3da32e11260
# ╟─8f2b829c-0a32-11eb-3a93-f99abb5b0c51
# ╠═3d06e788-0a28-11eb-2349-59445af634e5
# ╠═d6e29b62-0aec-11eb-1875-ab6b1dc3a340
# ╠═1dda704e-0aed-11eb-110e-7fec7fb5ce1f
# ╠═10fa8ab2-0aed-11eb-09a3-ab6f64857523
# ╠═410626c6-0aed-11eb-3ec6-e3a1a3ed1479
# ╠═9f926d9e-0aed-11eb-20cb-cbb591bc4e7c
# ╠═334cba22-0aed-11eb-1fbe-8566263f6c47
# ╟─b6cc0af2-0a24-11eb-0db6-89611405f9d3
# ╠═2bf60a92-0a3b-11eb-03ac-d50d2c2456a2
# ╟─26327b5e-0a3b-11eb-149f-3d14a722b188
# ╠═7c1b4b0e-0ab0-11eb-31f8-01a90b9d632c
# ╠═7e602c4c-0ae5-11eb-240c-016b13e60c7e
# ╠═41dd66da-0ae4-11eb-2af8-4dc16d5dbc88
# ╠═d8bb43b2-0a3d-11eb-0fd6-c9c6ac865427
# ╠═87c42826-0ae6-11eb-2ad7-ef15da27c29d
# ╠═b575ecdc-0ae6-11eb-13e7-c3586822cea7
# ╠═48ccc14c-0a3e-11eb-17c3-8bba1750d5b0
