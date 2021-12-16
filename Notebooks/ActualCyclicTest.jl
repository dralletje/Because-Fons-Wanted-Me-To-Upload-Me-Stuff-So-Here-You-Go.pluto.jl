### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ d6c760c9-ef91-4295-bfe4-ea2e52eee7bd
begin
	struct B x end
	Base.show(io::IO, ::MIME"text/html", x::B) = print(io, "2")
	B(2)
end

# ╔═╡ f5e255de-c301-44df-98a5-edcb09132e61
begin
	struct A x end
	Base.show(io::IO, ::MIME"image/png", x::Vector{A}) = print(io, "1")
	[A(1), A(1)]
end

# ╔═╡ Cell order:
# ╠═f5e255de-c301-44df-98a5-edcb09132e61
# ╠═d6c760c9-ef91-4295-bfe4-ea2e52eee7bd
