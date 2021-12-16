### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 2c537d64-46e7-11ec-1fbe-d12cb7d2109b
macro bad()
	error("aaaah")
end

# ╔═╡ 72579005-b9d1-4672-b37e-7844221e6e4e
@bad()

# ╔═╡ ba7c7023-97c3-4045-8c60-d91a535d1550
@macroexpand @bad()

# ╔═╡ Cell order:
# ╠═2c537d64-46e7-11ec-1fbe-d12cb7d2109b
# ╠═72579005-b9d1-4672-b37e-7844221e6e4e
# ╠═ba7c7023-97c3-4045-8c60-d91a535d1550
