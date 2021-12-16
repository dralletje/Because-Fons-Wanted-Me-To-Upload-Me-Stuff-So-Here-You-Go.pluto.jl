### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 19f83c25-828c-4cf3-9086-9088e51f07f9
import HypertextLiteral: @htl

# ╔═╡ fc30418d-ed9a-4287-be30-ed1fa4ec3fc7
begin
	Base.@kwdef struct PrettyExpr
		expr
		mod::Module=Module()
	end
	PrettyExpr(expr) = PrettyExpr(expr, Module())
end

# ╔═╡ 44b6c357-cabf-491b-8e11-a9bcbf565d36
export PrettyExpr

# ╔═╡ 7ec768ab-ed40-4983-a044-3f9da1637be1
struct NiceFormattedInterpolation
	wrap::Function
end

# ╔═╡ 68b91ddc-358a-48dc-b6dc-64af1d8bb4d2
function Base.show(io::IO, interpolation::NiceFormattedInterpolation)
	print(io, "\$(")
	interpolation.wrap(io)
	print(io, ")")
end

# ╔═╡ dad894b9-61b3-4436-84f1-4e8212169cf4
Base.@kwdef struct DocsMacro
	doc
	binding
end

# ╔═╡ 80fa443e-7c5b-4df2-a514-7b905285dc36
function Base.show_unquoted(
	io::IO,
	docs_macro::DocsMacro,
	indent::Int,
	prec::Int,
	quote_level::Int = 0,
)
	print(io, "\n", " "^indent) # Empty line before docs
	Base.show_unquoted(io, docs_macro.doc, indent, prec, quote_level)
	print(io, "\n", " "^indent)
	Base.show_unquoted(io, docs_macro.binding, indent, prec, quote_level)
end

# ╔═╡ 6eda40f3-5731-47f2-ac53-992a4f60025b
Base.show(io::IO, docsmacro::DocsMacro) = Base.show_unquoted(io, docsmacro)

# ╔═╡ f1ca2770-8e91-4b7a-a0da-2c9255bb734b
move_escape_calls_up(e::Expr) = begin
	args = move_escape_calls_up.(e.args)
	if all(x -> Meta.isexpr(x, :escape, 1), args)
		Expr(:escape, Expr(e.head, (arg.args[1] for arg in args)...))
	else
		Expr(e.head, args...)
	end
end

# ╔═╡ 0d036053-956e-4a85-b780-12c512d75205
move_escape_calls_up(x) = x

# ╔═╡ b0b94cca-6bd6-46d5-a719-bc2e47b12d82
remove_linenums(e::Expr) = if e.head === :macrocall
	Expr(
		e.head,
		(
			x isa LineNumberNode ?
			LineNumberNode(0, nothing) :
			remove_linenums(x)
			for x
			in e.args
		)...,
	)
else
	Expr(e.head, (remove_linenums(x) for x in e.args if !(x isa LineNumberNode))...)
end

# ╔═╡ d32fecab-ce9d-4ef4-9766-50ead35599bd
remove_linenums(x) = x

# ╔═╡ 8ab5385f-8478-4ab5-9aa6-bcadcc998eab
function special_syntax_for_exprs(expr::Expr)
	if expr.head === :escape
		new_expr = special_syntax_for_exprs(expr.args[1])
		NiceFormattedInterpolation() do io
			print(io, "esc(")
			print(io, new_expr)
			print(io, ")")
		end
	elseif expr.head == :toplevel
		new_expr = special_syntax_for_exprs(Expr(:block, expr.args...))
		NiceFormattedInterpolation() do io
			print(io, "toplevel(")
			print(io, new_expr)
			print(io, ")")
		end
	elseif (
		Meta.isexpr(expr, :macrocall, 4) &&
		expr.args[begin] == GlobalRef(Core, Symbol("@doc")) &&
		(expr.args[begin+2] isa String || Meta.isexpr(expr.args[begin+2], :string))
	)
		DocsMacro(
			doc=expr.args[begin+2],
			binding=expr.args[begin+3],
		)
	else
		Expr(expr.head, (special_syntax_for_exprs(x) for x in expr.args)...)
	end
end

# ╔═╡ 6985c647-1818-4006-9aa2-7afd68d3c04e
special_syntax_for_exprs(x) = x

# ╔═╡ ff424bd3-7e45-4fa4-bf4c-b9305165859a
begin
	function wrap_dot(mod::Module)
	    complete_mod_name = fullname(mod) |> wrap_dot
	end
	function wrap_dot(ref::GlobalRef)
	    complete_mod_name = fullname(ref.mod) |> wrap_dot
	    Expr(:(.), complete_mod_name, QuoteNode(ref.name))
	end
	function wrap_dot(name)
	    if length(name) == 1
	        name[1]
	    else
	        Expr(:(.), wrap_dot(name[1:end-1]), QuoteNode(name[end]))
	    end
	end
end

# ╔═╡ ea3c5b86-180b-4c8a-bb08-f65b1ac4a100
special_syntax_for_exprs(x::GlobalRef) = NiceFormattedInterpolation() do io
		print(io, "GlobalRef(")
		print(io, wrap_dot(x.mod))
		print(io, ", ")
		print(io, special_syntax_for_exprs(QuoteNode(x.name)))
		print(io, ")")
	end

# ╔═╡ f6909968-e578-4a11-9393-aad4f1a0cc87
expr_to_str(expr; mod=@__MODULE__(), alter_for_visibility=false) = let	
	expr = remove_linenums(expr)
	if alter_for_visibility
		expr = move_escape_calls_up(expr)
	end
	expr = special_syntax_for_exprs(expr)
	
	printed = sprint() do io
		Base.print(IOContext(io, :module => mod), expr)
	end
	replace(printed, r"#= line 0 =# ?" => "")
end

# ╔═╡ 0f1411ef-e69d-400e-b649-6b5d956387a6
function Base.show(io::IO, mime::MIME"text/html", expr::PrettyExpr)
	show(io, mime, @htl("""<code-without-background>
		<style>
		code-without-background pre {
			padding: 0 !important;
		}
		code-without-background * {
			background: none !important;
		}
		</style>
		$(Markdown.MD([Markdown.Code("julia", expr_to_str(expr.expr))]))
	</code-without-background>"""))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"
"""

# ╔═╡ Cell order:
# ╠═19f83c25-828c-4cf3-9086-9088e51f07f9
# ╠═44b6c357-cabf-491b-8e11-a9bcbf565d36
# ╠═fc30418d-ed9a-4287-be30-ed1fa4ec3fc7
# ╠═0f1411ef-e69d-400e-b649-6b5d956387a6
# ╠═7ec768ab-ed40-4983-a044-3f9da1637be1
# ╠═68b91ddc-358a-48dc-b6dc-64af1d8bb4d2
# ╠═dad894b9-61b3-4436-84f1-4e8212169cf4
# ╠═80fa443e-7c5b-4df2-a514-7b905285dc36
# ╠═6eda40f3-5731-47f2-ac53-992a4f60025b
# ╟─f1ca2770-8e91-4b7a-a0da-2c9255bb734b
# ╟─0d036053-956e-4a85-b780-12c512d75205
# ╟─b0b94cca-6bd6-46d5-a719-bc2e47b12d82
# ╟─d32fecab-ce9d-4ef4-9766-50ead35599bd
# ╟─8ab5385f-8478-4ab5-9aa6-bcadcc998eab
# ╟─ea3c5b86-180b-4c8a-bb08-f65b1ac4a100
# ╟─6985c647-1818-4006-9aa2-7afd68d3c04e
# ╟─f6909968-e578-4a11-9393-aad4f1a0cc87
# ╟─ff424bd3-7e45-4fa4-bf4c-b9305165859a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
