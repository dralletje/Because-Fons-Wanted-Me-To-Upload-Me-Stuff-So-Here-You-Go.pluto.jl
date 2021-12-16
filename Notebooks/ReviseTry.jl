### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 822a0094-4176-4bc8-b6fb-4d97f981df6c
prrrt(str) = include(str)

# ╔═╡ ff4dc939-b363-4a97-a616-ce66ce89ee05
macro X(expr)
	quote include($expr) end
end

# ╔═╡ 986c3012-3c98-11ec-2ca2-6d677ce168f9
prrrt("./ReviseChild.jl")

# ╔═╡ Cell order:
# ╠═ff4dc939-b363-4a97-a616-ce66ce89ee05
# ╠═822a0094-4176-4bc8-b6fb-4d97f981df6c
# ╠═986c3012-3c98-11ec-2ca2-6d677ce168f9
