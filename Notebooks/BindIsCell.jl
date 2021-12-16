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

# ╔═╡ 6849f47c-268d-11eb-130e-1b9935661978
module DralBase include("./Base.jl") end

# ╔═╡ 8281f9ea-268d-11eb-2ec9-fd1b4217a0dd
import .DralBase: @identity, Inspect

# ╔═╡ 790251cc-268a-11eb-1fe5-bfd21b036586
macro cell(expr)
	QuoteNode(expr)
end

# ╔═╡ 4d9702a0-268a-11eb-1319-3b2c9503d259
Clock(interval) = @cell begin
	@bind time Channel() do output
		t = 0
		while true
			put!(output, t)
			sleep(interval)
			t = t + 1
		end
	end
	time
end

# ╔═╡ 88cefa7c-268c-11eb-3b81-a9927cfef471
Inspect(Clock(10))

# ╔═╡ ff474736-268c-11eb-2e63-8d6eef6f531b
md"## Find definitions"

# ╔═╡ eeeeeeb8-268d-11eb-1223-a597b8e9c9d3
struct Unprocessed end

# ╔═╡ 0a6bbc86-268e-11eb-337f-9d8d1b9775d8
function find_definitions(::LineNumberNode)
	[]
end

# ╔═╡ 20f4fa22-268d-11eb-2812-db23b79fae93
function find_definitions(expr::Expr)
	if expr.head === :block
		vcat(find_definitions.(expr.args)...)
	else
		[Unprocessed()]
	end
end

# ╔═╡ f965df50-268d-11eb-08f5-a3323a325645
find_definitions(@cell() do x
		x = 10
		y = 20
	end)

# ╔═╡ 89a5b61e-268e-11eb-26bd-73bae7ed0ce0
Inspect(@identity() do x
	x1 = 10
	y1 = 20
end)

# ╔═╡ 21d12602-2690-11eb-2362-310963ca28a9
begin
	bond = @bind x html"""<input type=range />"""
	z = x
	bond
end

# ╔═╡ 34b54de4-2743-11eb-2d91-ebd153239983


# ╔═╡ 4a90fa0e-2690-11eb-3dbd-29082109a7db
z

# ╔═╡ 4dd288d4-2690-11eb-0983-07719df7517b
x

# ╔═╡ cdecbdec-268c-11eb-25e2-15987a4fcefa
md"""## Visit"""

# ╔═╡ cd27983c-268c-11eb-16ee-41b2cdfa17d8
struct Remove end


# ╔═╡ d6c03f66-268c-11eb-1959-0f0cb110f841
function visit(fn, something)
	visit(fn, something, [])
end

# ╔═╡ e042752c-268c-11eb-054d-714cf9c4557f
function visit(fn, expr::Expr, stack)
	substack = [expr, stack...]
	args = []
	for arg in expr.args
		result = visit(fn, arg, substack)
		if result isa Remove 
			nothing
		else
			push!(args, result)
		end
	end
	fn(Expr(expr.head, args...), substack)
end


# ╔═╡ e50cd608-268c-11eb-112e-f146cc820297
function visit(fn, something, stack)
	fn(something, stack)
end


# ╔═╡ ed3c32c2-268c-11eb-08f2-cf5aaa2f0996
function remove_line_nodes(expr)
	visit(expr) do expr, (parent,)
		if expr isa LineNumberNode
			if parent.head == :block
				Remove()
			else
				nothing
			end
		else
			expr
		end
	end
end


# ╔═╡ Cell order:
# ╠═6849f47c-268d-11eb-130e-1b9935661978
# ╠═8281f9ea-268d-11eb-2ec9-fd1b4217a0dd
# ╠═790251cc-268a-11eb-1fe5-bfd21b036586
# ╠═4d9702a0-268a-11eb-1319-3b2c9503d259
# ╠═88cefa7c-268c-11eb-3b81-a9927cfef471
# ╟─ff474736-268c-11eb-2e63-8d6eef6f531b
# ╠═eeeeeeb8-268d-11eb-1223-a597b8e9c9d3
# ╟─0a6bbc86-268e-11eb-337f-9d8d1b9775d8
# ╠═20f4fa22-268d-11eb-2812-db23b79fae93
# ╠═f965df50-268d-11eb-08f5-a3323a325645
# ╠═89a5b61e-268e-11eb-26bd-73bae7ed0ce0
# ╠═21d12602-2690-11eb-2362-310963ca28a9
# ╠═34b54de4-2743-11eb-2d91-ebd153239983
# ╠═4a90fa0e-2690-11eb-3dbd-29082109a7db
# ╠═4dd288d4-2690-11eb-0983-07719df7517b
# ╟─cdecbdec-268c-11eb-25e2-15987a4fcefa
# ╟─cd27983c-268c-11eb-16ee-41b2cdfa17d8
# ╟─d6c03f66-268c-11eb-1959-0f0cb110f841
# ╟─e042752c-268c-11eb-054d-714cf9c4557f
# ╟─e50cd608-268c-11eb-112e-f146cc820297
# ╟─ed3c32c2-268c-11eb-08f2-cf5aaa2f0996
