### A Pluto.jl notebook ###
# v0.12.2

using Markdown
using InteractiveUtils

# ╔═╡ 1116c686-0968-11eb-203e-cfa4f3444b87
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

# ╔═╡ 111836d8-0968-11eb-10a0-5de1234c71be
var"@install" = ingredients("./Install.jl").var"@install"

# ╔═╡ 112eda3a-0968-11eb-31a8-4bd3cc6fe4f7
@install using Gadfly

# ╔═╡ 1142f8f0-0968-11eb-2142-e55b72d4f7a6
struct HTMLDocument
	embedded
end

# ╔═╡ 112ffdfe-0968-11eb-2b3b-31d8a482f551
HTMLDocument(plot(y=[1,2,3]))

# ╔═╡ 1143cfaa-0968-11eb-17d9-e32571b7f5c4
function Base.show(io::IO, mime::MIME"text/html", doc::HTMLDocument)
	println(io, "<html>")
	show(io, mime, doc.embedded)
	println(io, "</html>")
end

# ╔═╡ Cell order:
# ╟─1116c686-0968-11eb-203e-cfa4f3444b87
# ╟─111836d8-0968-11eb-10a0-5de1234c71be
# ╠═112eda3a-0968-11eb-31a8-4bd3cc6fe4f7
# ╠═112ffdfe-0968-11eb-2b3b-31d8a482f551
# ╠═1142f8f0-0968-11eb-2142-e55b72d4f7a6
# ╠═1143cfaa-0968-11eb-17d9-e32571b7f5c4
