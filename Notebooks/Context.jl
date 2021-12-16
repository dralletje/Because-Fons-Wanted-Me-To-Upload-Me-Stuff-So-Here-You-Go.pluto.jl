### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 348419d5-f193-4ec3-8ddc-228c58726b72
md"""
## `use_context`
"""

# ╔═╡ f39a6c83-3b5b-48d2-9ff3-b42ce00da7e2
function _create_context_from_varname(varname::Symbol, default::Any)
	mod = Module(gensym("PlutoHooks Context Module"))
	
	Core.eval(mod, quote
		varname = $(QuoteNode(varname))
		default = $(default)
		
		macro varname()
			esc(varname)
		end
		
		macro Consumer()
			quote
				$(esc(_varname))
			end
		end
		
		macro Provider(fn, value)
			quote
				let
					$(esc(_varname)) = $(esc(value))
					$(esc(fn))()
				end
			end
		end
	end)

	mod
end

# ╔═╡ ba00ceb8-3506-466b-901b-19ab13bd1586
function create_context(default)
	varname = gensym("PlutoHooks Context Variable")
	_create_context_from_varname(varname, default)
end

# ╔═╡ 53e21b7a-faf4-4397-9cf4-b7949cf9091d
macro use_context(context_var::Symbol)
	varname_macrocall = esc(:($(context_var).@varname))

	quote
		context_module = $(esc(context_var))

		if $(Expr(:isdefined, varname_macrocall))
			$(varname_macrocall)
		else
			context_module.default
		end
	end
end

# ╔═╡ 795210bc-8078-40b4-9e5a-14d2ac0e14c7
macro use_with_context(fn, pairs...)
	assignments = map(pairs) do pair
		@assert Meta.isexpr(pair, :call, 3)
		@assert pair.args[begin] == :(=>)
		@assert pair.args[begin+1] isa Symbol
		
		context_var = pair.args[begin+1]
		new_value = pair.args[begin+2]

		varname_macrocall = esc(:($(context_var).@varname))
		
		:($(varname_macrocall) = $(esc(new_value)))
	end

	quote
		let
			$(assignments...)
			$(esc(fn))()
		end
	end
end

# ╔═╡ 96b69979-0aed-417c-a7a4-0f0283560086
const PlutoContext = _create_context_from_varname(gensym(), nothing) 

# ╔═╡ 11881693-1587-4d48-8230-40c51c4618e9
macro wrapper()
	quote
		@use_context(PlutoContext)
	end
end

# ╔═╡ 535e254b-b860-42da-ba2e-d443ceff368a
@use_context(PlutoContext)

# ╔═╡ 1bf57ce5-3569-4908-9e1d-7c8fd6e66bba
let
	x = @use_context(PlutoContext)
	y, z = @use_with_context(PlutoContext => 45) do
		_1 = @use_context(PlutoContext)

		_2 = @use_with_context(PlutoContext => 70) do
			@wrapper()
		end

		_1, _2
	end
	(x, y, z)
end

# ╔═╡ 8f2814ea-78a0-464c-8ab0-1fa82d98f4b9
@macroexpand let
	x = @use_context(PlutoContext)
	y, z = @use_with_context(PlutoContext => 45) do
		_1 = @use_context(PlutoContext)

		_2 = @use_with_context(PlutoContext => 70) do
			@wrapper()
		end

		_1, _2
	end
	(x, y, z)
end

# ╔═╡ Cell order:
# ╟─348419d5-f193-4ec3-8ddc-228c58726b72
# ╟─f39a6c83-3b5b-48d2-9ff3-b42ce00da7e2
# ╟─ba00ceb8-3506-466b-901b-19ab13bd1586
# ╠═53e21b7a-faf4-4397-9cf4-b7949cf9091d
# ╠═795210bc-8078-40b4-9e5a-14d2ac0e14c7
# ╠═96b69979-0aed-417c-a7a4-0f0283560086
# ╠═11881693-1587-4d48-8230-40c51c4618e9
# ╠═535e254b-b860-42da-ba2e-d443ceff368a
# ╠═1bf57ce5-3569-4908-9e1d-7c8fd6e66bba
# ╠═8f2814ea-78a0-464c-8ab0-1fa82d98f4b9
