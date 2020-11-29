### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 9d5dbf52-13c0-11eb-162a-41dc82bb5f55
macro identity(args...)
	if length(args) == 1
		return QuoteNode(args[1])
	else
		args
	end
end

# ╔═╡ d5452038-13e6-11eb-26e3-71764517e068
export @identity

# ╔═╡ 8bc62e58-17e6-11eb-346a-b7796d0016d7
[1,2,3,4]

# ╔═╡ f3af9180-1787-11eb-2e9c-51abef29184d
sprint(Base.show_default, 2)

# ╔═╡ a89a4d24-13e6-11eb-00f2-f1aa5600c740
md"## Inspect"

# ╔═╡ 4f856156-1783-11eb-136a-43820190b2ae
PlutoTree = MIME"application/vnd.pluto.tree+object"

# ╔═╡ 953995d4-13e1-11eb-1209-b7d426b492cb
struct Inspect{T} value::T end

# ╔═╡ bd8db864-1784-11eb-2896-33b3eb389e7e
Inspect(:(Base.:*(a::Number, b::T) where {T <: Unit} = T(a * b[])))

# ╔═╡ 5a9ec27a-13e2-11eb-05fc-751e20b8734c
function Base.getindex(subject::Inspect)
	subject.value
end

# ╔═╡ 12486e4a-24e0-11eb-133a-612ae63f8958
function AsPlutoTree(value)

end

# ╔═╡ 1a9e2922-13e2-11eb-1640-c7c1a971d870
macro inspect(ex)
	quote
		Inspect($(esc(ex)))
	end
end

# ╔═╡ 9527a1ae-13c0-11eb-2f74-994f4de7ce4e
export Inspect, @inspect

# ╔═╡ 9ccfd8ba-13e1-11eb-1aa6-77572ba8feac
function Base.show(io::IO, mime::MIME"text/plain", value::Inspect)
	Base.dump(io, value[])
end

# ╔═╡ a3de3f8a-1782-11eb-0420-e31dbd05cc69
function Base.show(io::IO, mime::PlutoTree, value::Inspect)
	tree_io = IOContext(io, :showtree => true)
	if showable(mime, value[])
		show(tree_io, mime, value[])
	else
		Main.PlutoRunner.show_struct(tree_io, value[])
	end
end

# ╔═╡ 1d5e4df4-17f7-11eb-27ce-692a782a86d4
struct X 
	a
end

# ╔═╡ 2172da4a-17f7-11eb-2d39-6b06f849cdce
X(10)

# ╔═╡ 49361c5e-1789-11eb-30fe-ebaa85faf07d
Inspect(:(1 + 1))

# ╔═╡ a98fb686-178a-11eb-037a-b52ebff337de
import UUIDs

# ╔═╡ 35a41280-178a-11eb-243b-099a70d64cbc
# begin
# 	uniqueid = UUIDs.uuid4()
# 	HTML("""
# 		<style>
# 		/*#$(uniqueid) {
# 			font-size: initial;
# 		}*/
# 		pluto-output.rich_output #unique-$(uniqueid) pre {
# 			margin-block-start: initial;
# 			margin-block-end: initial;
# 			display: block;
# 			padding: initial;
# 			border-radius: initial;
# 			background-color: initial;
# 			color: initial;
# 		}
# 		</style>

# 		<div id=unique-$(uniqueid)>
# 			$(AsPlutoTree([1,2,3,4]))
# 		</div>
# 	""")
# end

# ╔═╡ ba958504-13c1-11eb-336e-0dc37772a070
md"## DisplayOnly"

# ╔═╡ bded9948-13c2-11eb-0f3c-1d47f8526f99
function displayonly(m::Module)
	if isdefined(m, :PlutoForceDisplay)
		return m.PlutoForceDisplay
	else
		isdefined(m, :PlutoRunner) && parentmodule(m) == Main
	end
end

# ╔═╡ dfe9156c-13c1-11eb-333e-75461dd8ab5b
macro displayonly(ex) displayonly(__module__) ? esc(ex) : nothing end

# ╔═╡ bfe1babc-13e6-11eb-3699-a53560a5df95
export @displayonly

# ╔═╡ d3200a34-1783-11eb-1b50-ab06c477a164
md"## PlutoWidget"

# ╔═╡ d320c1c2-1783-11eb-0c27-9547e6da5b1e
Base.@kwdef struct PlutoWidget
	html::HTML
	default::Any
end

# ╔═╡ d7e7cfca-1783-11eb-39d4-4b0fdd6b6648
export PlutoWidget

# ╔═╡ d3285108-1783-11eb-1d30-49ea22a860d1
function Base.show(io::IO, mime::MIME"text/html", widget::PlutoWidget)
	show(io, mime, widget.html)
end

# ╔═╡ d32a8fcc-1783-11eb-0ecd-b71ebd3106bb
Base.get(widget::PlutoWidget) = widget.default

# ╔═╡ Cell order:
# ╠═d5452038-13e6-11eb-26e3-71764517e068
# ╠═9d5dbf52-13c0-11eb-162a-41dc82bb5f55
# ╠═8bc62e58-17e6-11eb-346a-b7796d0016d7
# ╠═bd8db864-1784-11eb-2896-33b3eb389e7e
# ╠═f3af9180-1787-11eb-2e9c-51abef29184d
# ╟─a89a4d24-13e6-11eb-00f2-f1aa5600c740
# ╠═9527a1ae-13c0-11eb-2f74-994f4de7ce4e
# ╠═4f856156-1783-11eb-136a-43820190b2ae
# ╠═953995d4-13e1-11eb-1209-b7d426b492cb
# ╠═5a9ec27a-13e2-11eb-05fc-751e20b8734c
# ╠═12486e4a-24e0-11eb-133a-612ae63f8958
# ╟─1a9e2922-13e2-11eb-1640-c7c1a971d870
# ╠═9ccfd8ba-13e1-11eb-1aa6-77572ba8feac
# ╠═a3de3f8a-1782-11eb-0420-e31dbd05cc69
# ╠═1d5e4df4-17f7-11eb-27ce-692a782a86d4
# ╠═2172da4a-17f7-11eb-2d39-6b06f849cdce
# ╠═49361c5e-1789-11eb-30fe-ebaa85faf07d
# ╠═a98fb686-178a-11eb-037a-b52ebff337de
# ╠═35a41280-178a-11eb-243b-099a70d64cbc
# ╟─ba958504-13c1-11eb-336e-0dc37772a070
# ╠═bfe1babc-13e6-11eb-3699-a53560a5df95
# ╟─bded9948-13c2-11eb-0f3c-1d47f8526f99
# ╟─dfe9156c-13c1-11eb-333e-75461dd8ab5b
# ╟─d3200a34-1783-11eb-1b50-ab06c477a164
# ╠═d7e7cfca-1783-11eb-39d4-4b0fdd6b6648
# ╟─d320c1c2-1783-11eb-0c27-9547e6da5b1e
# ╟─d3285108-1783-11eb-1d30-49ea22a860d1
# ╟─d32a8fcc-1783-11eb-0ecd-b71ebd3106bb
