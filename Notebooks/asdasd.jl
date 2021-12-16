### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 4c3a1d66-4243-11ec-3e0b-d916d3b2ddbc
1 + 1

# ╔═╡ a9a86983-6902-43d7-a1ff-260139e79ddb


# ╔═╡ 68109e65-6baf-436e-8be2-2655a238932d
module RecursiveMacroExpand
	include("./RecursiveMacroExpand.jl")
end

# ╔═╡ c751ca4c-d1a8-4824-bfb3-0b9319542d04
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

# ╔═╡ 8c40db5c-c115-4fa8-b824-23afe1572177
Base.@isdefined(X)

# ╔═╡ 805823e0-9eed-4e70-8196-b6ed9cbd83c6
X.@child

# ╔═╡ bf0898cf-0083-4a2f-b94b-9368b2a3d6db
metadata = let
	metadata = RecursiveMacroExpand.MacroexpandMetadata()
	RecursiveMacroExpand.recursive_macroexpand1(
		mod=X,
		expr=quote
			@parent()
			Base.@isdefined(a)
		end,
		metadata=metadata,
	)
	metadata
end

# ╔═╡ 77b4acd7-fb56-4dbe-b910-79bc191e97e7
first(metadata.macrocalls).mod

# ╔═╡ 38e7ae0e-ed02-4a80-8b5f-9352480de327
z = map(collect(metadata.macrocalls)) do globalref
	dotted = PlutoRunner.wrap_dot(globalref)
end

# ╔═╡ 6ea5df1e-8639-47bc-9286-68ec36b7216d
z[1].args

# ╔═╡ 3c09834e-e217-4a01-927e-509a662104bd
function PlutoRunner.is_pluto_workspace(s::Symbol)
    startswith(string(s), "workspace#")
end

# ╔═╡ 20abb45d-fcf2-41dd-ae95-7e8499594d6a
metadata.macrocalls

# ╔═╡ ed61853d-7fde-40d0-8cdd-5bd8949a51fd
map(collect(metadata.macrocalls)) do globalref
	name_parts = fullname(globalref.mod)
	i = findfirst(name_parts) do part
		PlutoRunner.is_pluto_workspace(part)
	end

	x = if i === nothing
		PlutoRunner.wrap_dot(globalref)
	else
		PlutoRunner.wrap_dot([
			name_parts[i+1:end]...,
			globalref.name
		])
	end
end

# ╔═╡ Cell order:
# ╠═4c3a1d66-4243-11ec-3e0b-d916d3b2ddbc
# ╠═a9a86983-6902-43d7-a1ff-260139e79ddb
# ╠═68109e65-6baf-436e-8be2-2655a238932d
# ╠═c751ca4c-d1a8-4824-bfb3-0b9319542d04
# ╠═8c40db5c-c115-4fa8-b824-23afe1572177
# ╠═805823e0-9eed-4e70-8196-b6ed9cbd83c6
# ╠═bf0898cf-0083-4a2f-b94b-9368b2a3d6db
# ╠═77b4acd7-fb56-4dbe-b910-79bc191e97e7
# ╠═38e7ae0e-ed02-4a80-8b5f-9352480de327
# ╠═6ea5df1e-8639-47bc-9286-68ec36b7216d
# ╠═3c09834e-e217-4a01-927e-509a662104bd
# ╠═20abb45d-fcf2-41dd-ae95-7e8499594d6a
# ╠═ed61853d-7fde-40d0-8cdd-5bd8949a51fd
