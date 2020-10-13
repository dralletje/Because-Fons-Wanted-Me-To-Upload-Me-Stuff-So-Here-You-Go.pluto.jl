### A Pluto.jl notebook ###
# v0.11.0

using Markdown
using InteractiveUtils

# ╔═╡ 14d12d08-0895-11eb-2702-1d199f991dd1
# begin 
#	result = @install using PyPlot v"2.9.0"
#	pygui(false)
#	result
# end

# ╔═╡ 767853b8-08c4-11eb-1442-ff46ef596c6a
# children(m::Module) =
#   filter(x->isa(x, Module) && x ≠ m, map(x->m.(x), names(m, all=true)))

# ╔═╡ 9e746246-08b3-11eb-136b-cf58f50ddbe3
# begin
# 	PyPlot.isjulia_display[] = true
# 	plt."ioff"()
# end

# ╔═╡ 20fcf940-08b8-11eb-19a2-67998f9048c5


# ╔═╡ 98f9f62c-089e-11eb-0c8f-336e68d9f887
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

# ╔═╡ 74e8e5f6-0894-11eb-272c-fb54ec1e6976
Install = ingredients("./Install.jl")

# ╔═╡ a4ab429e-089f-11eb-04cc-871436a7a70c
var"@install" = Install.var"@install"

# ╔═╡ dbee9c1c-08b4-11eb-3313-abe79674304a
@which displayable(MIME("image/png"))

# ╔═╡ a9184288-08b5-11eb-2220-91fc6a7828f2
displayable(MIME("image/png"))

# ╔═╡ b866ce9e-08b5-11eb-1238-079c2b67b7d5
Base.Multimedia.displays

# ╔═╡ 1f59fe86-08c3-11eb-0531-87433e04c82c
const ipy_mime = [
    "application/vnd.dataresource+json",
    ["application/vnd.vegalite.v$n+json" for n in 4:-1:2]...,
    ["application/vnd.vega.v$n+json" for n in 5:-1:3]...,
    "application/vnd.plotly.v1+json",
    "text/html",
    "text/latex",
    "image/svg+xml",
    "image/png",
    "image/jpeg",
    "text/plain",
    "text/markdown",
    "application/javascript"
]

# ╔═╡ 768fca7e-08c3-11eb-0eab-d51eb6ad3e8b
display_queue = []

# ╔═╡ 3e7f9c0e-08c5-11eb-1f67-3ddf20f9599b
display_queue

# ╔═╡ d32e5eb8-08c4-11eb-0f4d-71a84cee709b
children(m::Module) = begin
	symbols = names(m, all=true, imported=true)
	values = map(symbols) do symbol getproperty(m, symbol) end
	filter(values) do x isa(x, Module) end
end

# ╔═╡ 4e1cde90-08c7-11eb-310a-b7bf6fb474d0
collect(pairs(Base.loaded_modules))

# ╔═╡ 4ed1b912-08c9-11eb-05d6-0bfe5bc9fbc9
Type{T}

# ╔═╡ 42602ace-08c9-11eb-3998-1bf107193e9b
supertype(DataType)

# ╔═╡ abc5433c-08c9-11eb-358a-bbf3082d72f3
typeof(Int64)

# ╔═╡ b09c2a06-08c9-11eb-0d17-3d0eda8b2c34
typeof(UInt8)

# ╔═╡ b5c4c512-08c9-11eb-30cb-2f60038384ce
typeof(Int)

# ╔═╡ eb9d4ed8-08c8-11eb-0849-f14a23a3fbac
methodswith(DataType)

# ╔═╡ 78476436-08c4-11eb-1ad4-158767bc6f4a
children(@__MODULE__)

# ╔═╡ d20102fc-08c4-11eb-37c1-112b9bb61bf5
children(Main)

# ╔═╡ cd9e984c-08c3-11eb-18cf-dd7c03d896d0
display([RGBX(0,0,0), RGBX(0,0,0), RGBX(0,0,0)])

# ╔═╡ 5600c55e-08b3-11eb-1e95-c90e2d031b49
@which pygui(false)

# ╔═╡ 30a85aa2-08b7-11eb-3163-dde5c7181e49
Base.Multimedia.displays

# ╔═╡ c369e69e-08b7-11eb-00e7-c16eec8d30ec
struct PlutoDisplay <: AbstractDisplay end

# ╔═╡ d413191a-08c2-11eb-1bd1-6341e104e1a2
before = for mime in ipy_mime
    @eval begin
		function display(d::PlutoDisplay, ::MIME{Symbol($mime)}, x)
			push!(display_queue, x)
        end

        displayable(d::PlutoDisplay, ::MIME{Symbol($mime)}) = true
    end
end

# ╔═╡ 41cf731a-08b7-11eb-2edf-015bbaa3383f
begin 
	before;
	@install using PyPlot v"2.9.0"
end

# ╔═╡ 27d1172a-08a3-11eb-0579-cdaf1e04bcb6
PyPlot.version

# ╔═╡ d10b9c96-08c3-11eb-1d2c-794a7f2c4dfd
begin 
	before;
	@install using Images
end

# ╔═╡ dd58d5b8-08c8-11eb-20ec-3f6092ee8a0b
fieldnames(PlutoDisplay)

# ╔═╡ 9ace104a-08bc-11eb-0ef4-f107facbf136
pushdisplay(PlutoDisplay())

# ╔═╡ 5d170718-08b8-11eb-1995-d77195e91603
saved_image = Ref(nothing)

# ╔═╡ 080fbeea-08b8-11eb-26ef-4df19a68c26d
function Base.display(::PlutoDisplay, ::MIME"image/png", image)
	saved_image[] = image
end

# ╔═╡ 6799c17c-08bc-11eb-1a7f-29d0579936cc
saved_image

# ╔═╡ f2d81810-08b7-11eb-02ae-0d14a7c6980f
methodswith(TextDisplay)

# ╔═╡ 49f86da4-08c0-11eb-1d0b-bfb2a5738802
typeof(PyPlot)

# ╔═╡ f29a9590-08bb-11eb-2456-a3e2e6df6e59
PyPlot.isjulia_display

# ╔═╡ 297263f6-08bd-11eb-217e-d163a43c0beb
PyPlot.backend

# ╔═╡ 604431fe-08bd-11eb-0846-7ff3c8151512
PyPlot.plt."switch_backend"(false ? backend : "Agg")

# ╔═╡ 58bb9522-0894-11eb-2002-eb2d893d24da
begin
	pygui(false)
	plot(0, 0, "o")
end  # causes segmentation fault

# ╔═╡ 1dae428a-08c2-11eb-298f-57e412a4f136
methods(xdisplayable)

# ╔═╡ Cell order:
# ╟─74e8e5f6-0894-11eb-272c-fb54ec1e6976
# ╟─98f9f62c-089e-11eb-0c8f-336e68d9f887
# ╟─a4ab429e-089f-11eb-04cc-871436a7a70c
# ╠═dbee9c1c-08b4-11eb-3313-abe79674304a
# ╠═a9184288-08b5-11eb-2220-91fc6a7828f2
# ╠═b866ce9e-08b5-11eb-1238-079c2b67b7d5
# ╠═14d12d08-0895-11eb-2702-1d199f991dd1
# ╠═1f59fe86-08c3-11eb-0531-87433e04c82c
# ╠═768fca7e-08c3-11eb-0eab-d51eb6ad3e8b
# ╠═d413191a-08c2-11eb-1bd1-6341e104e1a2
# ╠═767853b8-08c4-11eb-1442-ff46ef596c6a
# ╠═3e7f9c0e-08c5-11eb-1f67-3ddf20f9599b
# ╠═d32e5eb8-08c4-11eb-0f4d-71a84cee709b
# ╠═4e1cde90-08c7-11eb-310a-b7bf6fb474d0
# ╠═dd58d5b8-08c8-11eb-20ec-3f6092ee8a0b
# ╠═4ed1b912-08c9-11eb-05d6-0bfe5bc9fbc9
# ╠═42602ace-08c9-11eb-3998-1bf107193e9b
# ╠═abc5433c-08c9-11eb-358a-bbf3082d72f3
# ╠═b09c2a06-08c9-11eb-0d17-3d0eda8b2c34
# ╠═b5c4c512-08c9-11eb-30cb-2f60038384ce
# ╠═eb9d4ed8-08c8-11eb-0849-f14a23a3fbac
# ╠═78476436-08c4-11eb-1ad4-158767bc6f4a
# ╠═d20102fc-08c4-11eb-37c1-112b9bb61bf5
# ╠═cd9e984c-08c3-11eb-18cf-dd7c03d896d0
# ╠═41cf731a-08b7-11eb-2edf-015bbaa3383f
# ╠═d10b9c96-08c3-11eb-1d2c-794a7f2c4dfd
# ╠═27d1172a-08a3-11eb-0579-cdaf1e04bcb6
# ╠═9e746246-08b3-11eb-136b-cf58f50ddbe3
# ╠═5600c55e-08b3-11eb-1e95-c90e2d031b49
# ╠═30a85aa2-08b7-11eb-3163-dde5c7181e49
# ╠═c369e69e-08b7-11eb-00e7-c16eec8d30ec
# ╠═9ace104a-08bc-11eb-0ef4-f107facbf136
# ╠═5d170718-08b8-11eb-1995-d77195e91603
# ╠═080fbeea-08b8-11eb-26ef-4df19a68c26d
# ╠═6799c17c-08bc-11eb-1a7f-29d0579936cc
# ╠═f2d81810-08b7-11eb-02ae-0d14a7c6980f
# ╠═49f86da4-08c0-11eb-1d0b-bfb2a5738802
# ╠═f29a9590-08bb-11eb-2456-a3e2e6df6e59
# ╠═297263f6-08bd-11eb-217e-d163a43c0beb
# ╠═604431fe-08bd-11eb-0846-7ff3c8151512
# ╠═58bb9522-0894-11eb-2002-eb2d893d24da
# ╠═1dae428a-08c2-11eb-298f-57e412a4f136
# ╠═20fcf940-08b8-11eb-19a2-67998f9048c5
