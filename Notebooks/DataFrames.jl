### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 99140236-2c65-11eb-100f-7518e532f81c
module DralBase include("./Base.jl") end

# ╔═╡ c6aef70a-2c65-11eb-055d-b7bd72202d48
import .DralBase: @add, @identity

# ╔═╡ cab8d5d2-2c65-11eb-3dd8-c55e985c5693
@add using DataFrames

# ╔═╡ 99caa038-2c6d-11eb-25e6-d1b61f603b41
DataFrame(
	x = rand(1:10, 200),
	y = rand(1:10, 200),
)

# ╔═╡ a9c58f96-2c6d-11eb-15cd-c9100c46a1e7
rand(1:10, 200)

# ╔═╡ e81be7d6-2c65-11eb-3246-0f961322ce45
[
	Dict(:z => 0, :x => 1),
	Dict(:z => -1, :x => 2, :y => 3),
	Dict(:x => 4, :y => 5),
	Dict(:x => 6, :y => 7),
	]

# ╔═╡ 0f3db558-2c66-11eb-0b0f-6da8bde7e3e7
[
	Dict(:x => 1),
	Dict(:x => 2, :y => 3),
	4,
]

# ╔═╡ 1b850c24-2c66-11eb-2497-27b3fcd711a2
struct X
	a
	b
end

# ╔═╡ 187e76dc-2c66-11eb-2899-65c1aa239f49
[
	X(1, 2),
	X(3, 4),
	X(5, 6),
]

# ╔═╡ 8d2ad20a-2c66-11eb-14f0-83641b19a2b5
macro cell(fn)
	
end

# ╔═╡ d02f5c46-2c67-11eb-2420-67a36bdb5bbe
function in_which_cell_was_i_called()
    stack = stacktrace(backtrace())
    filenames = [frame.file for frame in stack]

    from_notebook = filter(f -> occursin("#==#", string(f)), filenames)

    return first(from_notebook)
end

# ╔═╡ 00f8fbf8-2c67-11eb-26db-9d9d7bc85567
@cell() do x
	@hook Ref() 
end

# ╔═╡ d6602456-2c67-11eb-1aef-51543e85fede
in_which_cell_was_i_called() === in_which_cell_was_i_called()

# ╔═╡ 1c3c12dc-2c68-11eb-0a1f-ed3cb23f72c5
cell_memory = Dict{Symbol,Any}()

# ╔═╡ bc2fffd8-2c68-11eb-3e60-d18d7739b7d4
cell_memory[in_which_cell_was_i_called()]

# ╔═╡ 8c73709a-2c68-11eb-335c-e344964c6b93
if haskey(cell_memory, in_which_cell_was_i_called())
	cell_memory[in_which_cell_was_i_called()]
else
	cell_memory[in_which_cell_was_i_called()] = 10
	false
end

# ╔═╡ 0c0c16f4-2c69-11eb-1a36-7b5b2b99d5b9
previous_expression = Ref{Any}(nothing)

# ╔═╡ 1fdaba52-2c69-11eb-2404-ff3f01a46fab
previous_expression

# ╔═╡ 7eb1f458-2c69-11eb-1ba5-cb042f45f6b5
macro value(expr::Expr)
	value = eval(expr)
	quote
		$(value)
	end
end

# ╔═╡ acc5d940-2c69-11eb-1441-5ffc9b40b10c
Ref(nothing) === Ref(nothing)

# ╔═╡ 77b2621e-2c69-11eb-12c7-a7cf3a33eff6
memoized() = @value(Ref(nothing)) 

# ╔═╡ b05c530e-2c69-11eb-25eb-431929bce066
memoized() === memoized()

# ╔═╡ 5caff930-2c6a-11eb-130b-77e9c9f539a0
@bind x html"""<input type=range />"""

# ╔═╡ ed9dc230-2c68-11eb-1b15-4d8e7ffcdf71
begin
	x
	
	result = @value Ref(nothing)
	is_same = result == previous_expression[]
	previous_expression[] = result
	is_same
end

# ╔═╡ 0e3bbf9e-2c67-11eb-26dc-abbcb88d12e7
anonymous_fn = (x) -> begin
	x + 1
end

# ╔═╡ 8065ae50-2c66-11eb-1a2b-dfa372c9167b
@identity() do x
	x + 1
end

# ╔═╡ b4b42a1a-2c66-11eb-0dba-ed4581f3d2ad
@identity (x) -> begin
	x + 1
end

# ╔═╡ dac0e70e-2c66-11eb-232a-43cf3f87d698
@identity (x, y) -> begin
	x + 1
end

# ╔═╡ f5501764-2c66-11eb-0b12-0f774d22f59f
@identity function(x, y)
	x + 1
end

# ╔═╡ c6d60238-2c66-11eb-1a7d-0b9e813f1f80
without_tuple = (x) -> begin
	x + 1
end

# ╔═╡ cbed1656-2c66-11eb-0e6b-aded8878b511
with_tuple = (x,) -> begin
	x + 1
end

# ╔═╡ d52dd2b4-2c66-11eb-0e9d-fdae9328bb9b
without_tuple(10)

# ╔═╡ eb49c760-2c66-11eb-2afa-3128a3a38a71
with_tuple(10)

# ╔═╡ Cell order:
# ╠═99140236-2c65-11eb-100f-7518e532f81c
# ╠═c6aef70a-2c65-11eb-055d-b7bd72202d48
# ╠═cab8d5d2-2c65-11eb-3dd8-c55e985c5693
# ╠═99caa038-2c6d-11eb-25e6-d1b61f603b41
# ╠═a9c58f96-2c6d-11eb-15cd-c9100c46a1e7
# ╠═e81be7d6-2c65-11eb-3246-0f961322ce45
# ╠═0f3db558-2c66-11eb-0b0f-6da8bde7e3e7
# ╠═1b850c24-2c66-11eb-2497-27b3fcd711a2
# ╠═187e76dc-2c66-11eb-2899-65c1aa239f49
# ╠═8d2ad20a-2c66-11eb-14f0-83641b19a2b5
# ╠═d02f5c46-2c67-11eb-2420-67a36bdb5bbe
# ╠═00f8fbf8-2c67-11eb-26db-9d9d7bc85567
# ╠═d6602456-2c67-11eb-1aef-51543e85fede
# ╠═1c3c12dc-2c68-11eb-0a1f-ed3cb23f72c5
# ╠═bc2fffd8-2c68-11eb-3e60-d18d7739b7d4
# ╠═8c73709a-2c68-11eb-335c-e344964c6b93
# ╠═0c0c16f4-2c69-11eb-1a36-7b5b2b99d5b9
# ╠═1fdaba52-2c69-11eb-2404-ff3f01a46fab
# ╠═7eb1f458-2c69-11eb-1ba5-cb042f45f6b5
# ╠═acc5d940-2c69-11eb-1441-5ffc9b40b10c
# ╠═77b2621e-2c69-11eb-12c7-a7cf3a33eff6
# ╠═b05c530e-2c69-11eb-25eb-431929bce066
# ╠═5caff930-2c6a-11eb-130b-77e9c9f539a0
# ╠═ed9dc230-2c68-11eb-1b15-4d8e7ffcdf71
# ╠═0e3bbf9e-2c67-11eb-26dc-abbcb88d12e7
# ╠═8065ae50-2c66-11eb-1a2b-dfa372c9167b
# ╠═b4b42a1a-2c66-11eb-0dba-ed4581f3d2ad
# ╠═dac0e70e-2c66-11eb-232a-43cf3f87d698
# ╠═f5501764-2c66-11eb-0b12-0f774d22f59f
# ╠═c6d60238-2c66-11eb-1a7d-0b9e813f1f80
# ╠═cbed1656-2c66-11eb-0e6b-aded8878b511
# ╠═d52dd2b4-2c66-11eb-0e9d-fdae9328bb9b
# ╠═eb49c760-2c66-11eb-2afa-3128a3a38a71
