### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ 4bb629c6-3978-11ec-217a-8f1d762a8295
module PlutoHooks include("./PlutoHooks.jl") end

# ╔═╡ 6b420d82-b1e5-47dc-b6eb-0d4d63d176d9
x = 30

# ╔═╡ b00b7528-280d-4e40-9dc0-107e856abb6a
y = PlutoHooks.@use_ref(x)

# ╔═╡ af0485b3-efde-4e11-a294-5578f8656b9b
module Identity
	macro identity(x)
		QuoteNode(x)
	end
end

# ╔═╡ f38ed18c-0756-4514-8144-73ab91b0c863
PlutoHooks.@use_effect function()

end

# ╔═╡ ba78993a-5557-4d98-9735-8ab71d41ae99
@macroexpand(PlutoHooks.@use_effect(function()
	x
end))

# ╔═╡ Cell order:
# ╠═4bb629c6-3978-11ec-217a-8f1d762a8295
# ╠═6b420d82-b1e5-47dc-b6eb-0d4d63d176d9
# ╠═b00b7528-280d-4e40-9dc0-107e856abb6a
# ╠═af0485b3-efde-4e11-a294-5578f8656b9b
# ╠═f38ed18c-0756-4514-8144-73ab91b0c863
# ╠═ba78993a-5557-4d98-9735-8ab71d41ae99
