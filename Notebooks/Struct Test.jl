### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ ebad6c04-0bf3-11eb-034e-69a8e4c6dc5a
using PlotlyJS

# ╔═╡ fa79030e-0bf0-11eb-14ff-33e567c100d9
module FileWithStruct include("./file_with_struct.jl") end

# ╔═╡ 1e09dcf8-0bf1-11eb-01e5-9ff7e55f0b18
sprint(dump, FileWithStruct.X) |> Text

# ╔═╡ d4bc1b34-0bf4-11eb-176c-27d1f38ca19b
md"---"

# ╔═╡ 8e1651e4-0bf5-11eb-0a45-4dfaa86ee167
PlotlyJS.SyncPlot

# ╔═╡ 47efab90-0bf8-11eb-0bc5-4b0d4bd05761
first = RGBX(190 / 255, 171 / 255, 105 / 255)

# ╔═╡ 5d1a0358-0bf8-11eb-2b27-ed37aa561de2
later = RGBX(105 / 255, 85 / 255, 16 / 255)

# ╔═╡ 7c0735ce-0bf8-11eb-1d08-a92a49a58521
normalize_hue(first)

# ╔═╡ 4785e858-0bf4-11eb-2007-d3fdc4c8c7ec
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ fc79ab1a-0bf3-11eb-3b85-a1e0180866f9
var"@install" = ingredients("./Install.jl").var"@install"

# ╔═╡ c6213da8-0c07-11eb-03cf-c3fa481c68eb
@install using JuliaInterpreter

# ╔═╡ ce093700-0c07-11eb-3ca8-21a69774f4e0
JuliaInterpreter.@interpret 1 + 1

# ╔═╡ 4396731c-0bf8-11eb-1873-6b7d8b013682
@install using Colors

# ╔═╡ 3d1704d8-0bf4-11eb-2005-a19debb10791
@install import WebIO

# ╔═╡ 1f609462-0bf5-11eb-0fe8-89f5a31c36b9
WebIO.render(plot(rand(10)))

# ╔═╡ 3b236b34-0bf5-11eb-2d2e-9787e97145ea
methods(WebIO.render)

# ╔═╡ 588b5d94-0bf5-11eb-1bd1-0702a919d96d
sprint(dump, WebIO.render("hey")) |> Text

# ╔═╡ ebaf2bac-0bf3-11eb-0129-8f5541aeca9a
syncplot = plot(rand(10))

# ╔═╡ e0acbba2-0bf3-11eb-38b4-434dc328ad3b
sprint(show, MIME("application/prs.juno.plotpane+html"), syncplot)

# ╔═╡ 7c36805c-0bf5-11eb-3b65-af1c1af12242
typeof(syncplot) === PlotlyJS.SyncPlot

# ╔═╡ c644bc9e-0bf4-11eb-0c31-7df9a74b9a64
WebIO.render

# ╔═╡ fa1fa22a-0bee-11eb-152c-7f8bcd610a69
refine(a, N) = constructor(a) * N


# ╔═╡ f61707ae-0bee-11eb-1b4b-57c6b59b5fb3
begin
	constructor(a) = a
	constructor(a, N) = refine(constructor(a), N)
end


# ╔═╡ Cell order:
# ╠═fa79030e-0bf0-11eb-14ff-33e567c100d9
# ╠═1e09dcf8-0bf1-11eb-01e5-9ff7e55f0b18
# ╠═f61707ae-0bee-11eb-1b4b-57c6b59b5fb3
# ╠═fa1fa22a-0bee-11eb-152c-7f8bcd610a69
# ╠═c6213da8-0c07-11eb-03cf-c3fa481c68eb
# ╠═ce093700-0c07-11eb-3ca8-21a69774f4e0
# ╟─d4bc1b34-0bf4-11eb-176c-27d1f38ca19b
# ╠═8e1651e4-0bf5-11eb-0a45-4dfaa86ee167
# ╠═e0acbba2-0bf3-11eb-38b4-434dc328ad3b
# ╠═4396731c-0bf8-11eb-1873-6b7d8b013682
# ╠═47efab90-0bf8-11eb-0bc5-4b0d4bd05761
# ╠═5d1a0358-0bf8-11eb-2b27-ed37aa561de2
# ╠═7c0735ce-0bf8-11eb-1d08-a92a49a58521
# ╠═1f609462-0bf5-11eb-0fe8-89f5a31c36b9
# ╠═3b236b34-0bf5-11eb-2d2e-9787e97145ea
# ╠═588b5d94-0bf5-11eb-1bd1-0702a919d96d
# ╠═4785e858-0bf4-11eb-2007-d3fdc4c8c7ec
# ╠═fc79ab1a-0bf3-11eb-3b85-a1e0180866f9
# ╠═ebad6c04-0bf3-11eb-034e-69a8e4c6dc5a
# ╠═3d1704d8-0bf4-11eb-2005-a19debb10791
# ╠═ebaf2bac-0bf3-11eb-0129-8f5541aeca9a
# ╠═7c36805c-0bf5-11eb-3b65-af1c1af12242
# ╠═c644bc9e-0bf4-11eb-0c31-7df9a74b9a64
