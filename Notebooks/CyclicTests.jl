### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ 3ca40150-48e5-4c02-9647-32cb0a53e215
begin
	import Pkg
	Pkg.activate("../Pluto.jl")
	import Pluto
end

# ╔═╡ a2f1a836-d4b3-4650-ae21-33a565459147
module X
	include("../Pluto.jl/src/runner/PlutoRunner.jl")
	include("../Pluto.jl/src/analysis/ExpressionExplorer.jl")
end

# ╔═╡ 1e1be74e-8558-4f30-a272-c12c8b6fca95
module Wow
      export c
      c(x::String) = "🐟"
  end

# ╔═╡ 5ca22ffe-ea1b-411a-922c-67f2e6a5d9ee
stacktrace()

# ╔═╡ 378a52cd-b8c3-40c4-a19a-dbdef9d3cb24
macro identity(x)
	x
end

# ╔═╡ f17d83a8-81cf-42a3-a172-4eba1a1cceb8
murders = @macroexpand begin
	import .Wow: c as g
	function g(x::Int) 
		x
	end
	g
end

# ╔═╡ 9f80752b-5f4a-48b5-9c5e-60008b91c420
import UUIDs

# ╔═╡ 1c36449d-135d-4f87-b0fa-a882c6c4a5ee
x = UUIDs.uuid4()

# ╔═╡ 371d3e7c-2df8-4e45-9fc2-12ccc9403e44
X.PlutoRunner.try_macroexpand(@__MODULE__, x, murders)

# ╔═╡ 409528e1-60ec-4131-bfa1-41ef98f72401
X.PlutoRunner.cell_expanded_exprs[x]

# ╔═╡ 954e6fdc-1496-4610-af04-2080a74595cc
begin
        import .Wow: c
        function c(x::Int)
            x
        end
        c
    end

# ╔═╡ c0b8d2e6-7444-4303-bfd8-aea25a8e5a14
c("i am a ")

# ╔═╡ Cell order:
# ╠═3ca40150-48e5-4c02-9647-32cb0a53e215
# ╠═a2f1a836-d4b3-4650-ae21-33a565459147
# ╠═1e1be74e-8558-4f30-a272-c12c8b6fca95
# ╠═5ca22ffe-ea1b-411a-922c-67f2e6a5d9ee
# ╠═378a52cd-b8c3-40c4-a19a-dbdef9d3cb24
# ╠═f17d83a8-81cf-42a3-a172-4eba1a1cceb8
# ╠═9f80752b-5f4a-48b5-9c5e-60008b91c420
# ╠═1c36449d-135d-4f87-b0fa-a882c6c4a5ee
# ╠═371d3e7c-2df8-4e45-9fc2-12ccc9403e44
# ╠═409528e1-60ec-4131-bfa1-41ef98f72401
# ╠═954e6fdc-1496-4610-af04-2080a74595cc
# ╠═c0b8d2e6-7444-4303-bfd8-aea25a8e5a14
