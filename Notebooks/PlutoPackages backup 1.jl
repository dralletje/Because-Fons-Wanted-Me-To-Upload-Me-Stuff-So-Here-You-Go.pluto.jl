### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 169b7cf5-e220-43e9-8041-6d22936bb5bd
import Pkg

# ╔═╡ 0694a9ac-4640-46a1-acf2-df19ad234af6
import Logging

# ╔═╡ c7ce73fa-9ec8-4603-b26a-29d6f7ca0aae


# ╔═╡ dcec2b45-59d9-4833-9857-a638064b9568
module PlutoNotebooks
	macro url_str(url)
		"hi"
	end
end

# ╔═╡ d9a969a4-73f1-4fea-a9af-a85070951c3e
Base.wrap_string

# ╔═╡ be4068f9-95a2-42f0-8024-22d342e93389
Pkg.Registry.update()

# ╔═╡ 6e548819-f868-4d01-b830-e3ba447d28db
import PlutoNotebook_Gist_dralletje_PlutoJavascript_v3 as PlutoJavascript

# ╔═╡ 5c5750b9-eaa6-43ef-9a33-84b822d88ef4
@importnotebook ""

# ╔═╡ da33c543-9b64-4564-b0ff-4221eb63d8f9
@which Base.Experimental.@sync begin end

# ╔═╡ d6d990aa-d45c-40b8-8222-f07403dc2357
Ctx.@contextvar cvar2 = 1

# ╔═╡ c82b5956-ea2d-4c7a-b571-73fef3320828
function grandchild()
	cvar2[]
end

# ╔═╡ d215b333-c675-488f-b362-b2064e1c7480


# ╔═╡ eb251973-0d63-4038-8099-e1ebb29bc49e
grandchild()

# ╔═╡ 5887aebb-d10f-4da7-8053-f83edab3629f
Logging.with_logger

# ╔═╡ d583bcfb-8b84-4324-ae25-18c578a751b4
Ctx.with_context(cvar2 => 2) do
	grandchild() * 4
end

# ╔═╡ Cell order:
# ╠═0694a9ac-4640-46a1-acf2-df19ad234af6
# ╠═c7ce73fa-9ec8-4603-b26a-29d6f7ca0aae
# ╠═dcec2b45-59d9-4833-9857-a638064b9568
# ╠═d9a969a4-73f1-4fea-a9af-a85070951c3e
# ╠═169b7cf5-e220-43e9-8041-6d22936bb5bd
# ╠═be4068f9-95a2-42f0-8024-22d342e93389
# ╠═6e548819-f868-4d01-b830-e3ba447d28db
# ╠═5c5750b9-eaa6-43ef-9a33-84b822d88ef4
# ╠═da33c543-9b64-4564-b0ff-4221eb63d8f9
# ╠═d6d990aa-d45c-40b8-8222-f07403dc2357
# ╠═c82b5956-ea2d-4c7a-b571-73fef3320828
# ╠═d215b333-c675-488f-b362-b2064e1c7480
# ╠═eb251973-0d63-4038-8099-e1ebb29bc49e
# ╠═5887aebb-d10f-4da7-8053-f83edab3629f
# ╠═d583bcfb-8b84-4324-ae25-18c578a751b4
