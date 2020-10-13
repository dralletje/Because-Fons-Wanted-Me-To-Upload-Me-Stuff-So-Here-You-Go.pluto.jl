### A Pluto.jl notebook ###
# v0.12.2

using Markdown
using InteractiveUtils

# ╔═╡ fa2cef8a-0a21-11eb-3d75-1905af8c0278
@which using .Module

# ╔═╡ a3a22c9a-0788-11eb-05ab-532ae1f6390e
import PlutoUI

# ╔═╡ 887a8b3a-0833-11eb-059b-e9446a947997
import Pkg

# ╔═╡ e3a60806-07e1-11eb-0799-f1657f6c927a
get_installed_package(package_name) = let
	for package in values(Pkg.dependencies())
		if package.name == package_name
			return package
		end
	end
end

# ╔═╡ 8bc09a20-083b-11eb-21c4-a13f9568f036
md"## Package UI"

# ╔═╡ 1be30ee8-0829-11eb-3736-e188f9acf86b
Base.@kwdef struct PackageUI
	package::Pkg.Types.PackageInfo
	using_expression::Expr
	requested_version::Pkg.Types.VersionSpec
	is_pinned::Bool
	did_install::Bool
end

# ╔═╡ 83d2449e-082c-11eb-2135-933a85f6f24c
function Base.show(io::IO, mime::MIME"text/html", package_ui::PackageUI)	
	version = repr(package_ui.package.version)
	# code2 = :(@install $expr v"0.3.1")
	# code = Expr(:macrocall, :@install, expr, v"0.3.1")
	# filter!(code2.args) do node !(node isa LineNumberNode) end
	
	# Cool, julia code generation failed me because of stupid line number nodes.
	# So here I am, concatinating code thank you
	using_string = "$(package_ui.using_expression)"
	code = "@install $(package_ui.using_expression) $(version)"
	
	html_to_show = HTML("""
		<style>
		#container {
			display: flex;
			flex-direction: row;
			align-items: center;
			margin-bottom: 5px;
		}
		#replace-code {
			all: initial;
			border-radius: 10px;
			background-color: #eee;
			padding: 0px 10px;
			transition: all .2s;
		}
		#replace-code:not([disabled]):hover {
			background-color: #aaa;
			cursor: pointer;
		}
		</style>
		
		<code id="container">
			<code class="language-julia">$(using_string)</code>
			<div style="width: 15px"></div>
		
			<button
				id="replace-code"
				$(package_ui.is_pinned ? "disabled" : "")
			>
				<code>
					<div style="display: inline-block">$(version)</div>
					$(!package_ui.is_pinned ? "<span>pin version</span>" : "")
				</code>
			</button>
			<div style="width: 15px"></div>
			$(package_ui.did_install
				? "<span style='color: #610707'>(Just installed)</span>"
				: ""
			)
		</code>
		
		<script>
		let code = `$(code)`;
		let output = currentScript.closest('pluto-output')
		
		let element = output.querySelector('#replace-code')
		element.onclick = () => {
			let codemirror = currentScript.closest('pluto-cell')
				?.querySelector('pluto-input')
				?.querySelector('.CodeMirror')
				?.CodeMirror

			codemirror.getDoc().setValue(code)
			codemirror.focus()
			codemirror.getDoc().setSelection(
				{ line: 0, ch: code.length - $(length(version)) },
				{ line: 0, ch: code.length }
			)
		}
	""")

	show(io, mime, html_to_show)
end

# ╔═╡ ce86b1c8-083b-11eb-2870-f394b552a680
md"### Storybook"

# ╔═╡ e9f6c2ba-0839-11eb-0598-8339ea59aee7
ExampleModule = Pkg.Types.PackageInfo(
	name="DralModule",
	version=v"23.0.0",
	tree_hash=nothing,
	is_direct_dep=false,
	is_pinned=false,
	is_tracking_path=false,
	is_tracking_repo=false,
	is_tracking_registry=false,
	git_revision=nothing,
	git_source=nothing,
	source="",
	dependencies=Dict()
)

# ╔═╡ 62f6850c-0839-11eb-0b36-0b97f2ee7222
PackageUI(
	package=ExampleModule,
	using_expression=:(using DralModule),
	requested_version=Pkg.Types.VersionSpec("*"),
	is_pinned=false,
	did_install=false
)

# ╔═╡ 14bb901a-083b-11eb-097f-cd08388fa6a7
PackageUI(
	package=ExampleModule,
	using_expression=:(using DralModulePinned),
	requested_version=Pkg.Types.VersionSpec("*"),
	is_pinned=true,
	did_install=false
)

# ╔═╡ 2745ac02-083b-11eb-301d-fdf4d4949b6f
PackageUI(
	package=ExampleModule,
	using_expression=:(using DralModuleJustInstalled),
	requested_version=Pkg.Types.VersionSpec("*"),
	is_pinned=true,
	did_install=true
)

# ╔═╡ 891bc5f8-083e-11eb-00b1-9346f059de59
md"## Examples"

# ╔═╡ b6ed98e8-083c-11eb-14ed-459868c941ef
md"## \`@if let ...` guard macro"

# ╔═╡ 37d00362-0839-11eb-3461-d9564d262cb4
md"""
## Macro ast-match helpers
"""

# ╔═╡ 089b16b0-0783-11eb-3ec8-ef5071806c14
function mis_match(needle, haystack)
	throw("Mismatch `$needle` vs `$haystack`")
end

# ╔═╡ b8b9a124-07d3-11eb-0ea8-f3d4992f0c1e
get_simple_spread_placeholder(expr) = let
	if expr.head == :$ && expr.args[1] isa Expr && expr.args[1].head === :...
		expr.args[1].args[1]
	else
		nothing
	end
end

# ╔═╡ bd5c86e0-0785-11eb-2ce7-3d080703b4ab
function get_spread_placeholder(expr)
	if !(expr isa Expr) return nothing end

	placeholder = get_simple_spread_placeholder(expr)
	if placeholder ≠ nothing
		return placeholder
	else
		if length(expr.args) == 1
			return get_spread_placeholder(expr.args[1])
		else
			return nothing
		end
	end
end

# ╔═╡ dac9b488-07d4-11eb-3053-b5ce252db39e
is_spread_placeholder(expr) = get_spread_placeholder(expr) ≠ nothing

# ╔═╡ 7cef8b20-07d5-11eb-1ce1-75822d44f6ab
flatten_spread_placeholder(expr) = let
	if !is_spread_placeholder(expr)
		expr
	else
		name = get_simple_spread_placeholder(expr)
		if name ≠ nothing
			Expr(:$, name)
		else
			Expr(
				flatten_spread_placeholder(expr.head),
				map(flatten_spread_placeholder, expr.args)...
			)
		end
	end		
end

# ╔═╡ 9fd5ccbe-0780-11eb-333e-81ea08ac8f81
function match(needle, haystack, result=Dict())
	if !(haystack isa Expr)
		if needle ≠ haystack
			mis_match(needle, haystack)
		end
		return result
	end
	
	if haystack isa Expr && haystack.head == :$
		result[haystack.args[1]] = needle
		return result
	end
	
	if !(needle isa Expr)
		mis_match(needle, haystack)
	end
	
	if haystack.head ≠ needle.head
		mis_match(needle, haystack)
	end
	
	haystacks = filter(haystack.args) do x !(x isa LineNumberNode) end
	needles = filter(needle.args) do x !(x isa LineNumberNode) end
	
	needles = if !isempty(haystacks) &&  is_spread_placeholder(haystacks[end])
		name = get_spread_placeholder(haystacks[end])
		required_length = length(haystacks) - 1

		sub_haystack = flatten_spread_placeholder(haystacks[end])
		rest_match = needles[(required_length + 1):end]
		result[name] = map(rest_match) do sub_needle
			match(sub_needle, sub_haystack)[name]
		end
		
		if length(needle.args) < required_length
			mis_match(needles, haystacks)
		end
		needles[1:required_length]
	else
		if length(needles) ≠ length(haystacks)
			mis_match(needles, haystacks)
		end
		needles
	end

	for (needle_arg, haystack_arg) in zip(needles, haystacks)
		match(needle_arg, haystack_arg, result)
	end
	return result
end

# ╔═╡ a695643e-0782-11eb-33e0-6bb1874bdd28
macro match_ast(needle, haystack)
	try
		match(needle, haystack)
	catch
		nothing
	end
end

# ╔═╡ cf1d1e28-080a-11eb-1cc7-fd19c79a2520
match_ast(needle, haystack) = try match(needle, haystack) catch e nothing end

# ╔═╡ 78f6d762-083e-11eb-0017-3749142cbbbf
md"### Macro developer tools"

# ╔═╡ daacc1b6-0775-11eb-07c8-63634bbce0c4
macro identity(args...)
	if length(args) == 1
		return :($args[1])
	else
		args
	end
end

# ╔═╡ 3925ed9c-078c-11eb-0933-ffa8499bc055
parse_using_or_import_expression(expr, version_expression) = let
	simple_module = something(
		match_ast(expr, @identity(using $module_name)),
		match_ast(expr, @identity(import $module_name)),
		Some(nothing)
	)
	# match2 = match_ast(version_expression, @identity($version:$(imports...)))
	# if simple_module ≠ nothing && match2 ≠ nothing
	# 	return (
	# 		module_name=simple_module[:module_name],
	# 		version=match2[:version],
	# 		expr=(quote using $(simple_module[:module_name]): $(match2[:imports]...) end).args[2]
	# 	)
	# end

	if simple_module ≠ nothing
		return (module_name=simple_module[:module_name], version=version_expression, expr=expr)
	end
	
	using_with_specific = something(
		match_ast(expr, @identity(using $module_name: $(imports...))),
		match_ast(expr, @identity(import $module_name: $(imports...))),
		Some(nothing)
	)
	
	if using_with_specific ≠ nothing
		return (
			module_name=using_with_specific[:module_name],
			version=version_expression,
			expr=expr
		)
	end
		
	throw("Couldn't parse using")
end

# ╔═╡ df33c54a-0770-11eb-2ba5-2f90a2555cfe
begin
	PackageUI; parse_using_or_import_expression; get_installed_package;
	
	macro install(using_expr, version_string=nothing)		
		module_name, version_string, expr = parse_using_or_import_expression(using_expr, version_string)
		
		package_name = String(module_name)
		if (
			version_string isa Expr
			&& version_string.head == :macrocall
			&& version_string.args[1] == Symbol("@v_str")
		)
			actual_string = version_string.args[3]
			version_string = :(Pkg.Types.VersionSpec($actual_string))
		end

		return quote
			let
				import Pkg
				package_name = $package_name
				version_string = $(version_string == nothing) || $(version_string) == nothing ? nothing : $(version_string)
				
				versionspec = if version_string == nothing
					Pkg.Types.VersionSpec()
				else
					Pkg.Types.VersionSpec(version_string)
				end
				
				package = get_installed_package(package_name)
								
				did_install = if package == nothing || !in(package.version, versionspec)
					Pkg.add(name=package_name, version=versionspec)
					true
				elseif !package.is_direct_dep
					Pkg.add(name=package_name, version=package.version)
					true
				else
					false
				end
					
				$expr
				
				PackageUI(
					did_install = did_install,
					is_pinned = version_string ≠ nothing,
					requested_version = versionspec,
					package = get_installed_package(package_name),
					using_expression = $(expr |> QuoteNode)
				)
			end
		end
	end
end

# ╔═╡ b8759090-0776-11eb-2765-1b0922961a36
@install using JSServe: Session, evaljs, linkjs v"0.6"

# ╔═╡ fd67c304-07e8-11eb-3067-0b4d25f33da2
@install using JSServe: @js_str, onjs, Button, Slider, Asset v"0.6"

# ╔═╡ cb1f8ac6-07e8-11eb-245d-cd62d8164575
@install using WGLMakie v"0.2.9"

# ╔═╡ 60c25e86-07ea-11eb-1c63-531fd4f227d8
@install using AbstractPlotting v"0.12.9"

# ╔═╡ 5280ac06-07ea-11eb-16ec-c5bd11c3aa2b
@install using JSServe: DOM v"0.6.9"

# ╔═╡ 93c75e2a-0776-11eb-1868-3987a1158a9b
@install using Observables v"0.3.1"

# ╔═╡ 76c1dca6-07eb-11eb-1ec0-675e98f7e625
function wrap_let_with_if(let_statement)
	result = match(
		let_statement,
		@identity let $var = $expression
			$(expressions...)
		end
	)
	
	quote
		let $(result[:var]) = $(result[:expression])
			if $(result[:var]) ≠ false && $(result[:var]) ≠ nothing
				$(result[:expressions]...)
			end
		end
	end
end

# ╔═╡ 589aa53a-07eb-11eb-36b1-17657aa7c901
begin
	wrap_let_with_if; @identity(using X) # Try triggering Pluto `using` hoisting
	
	eval(quote
		macro $(:if)(let_statement)
			wrap_let_with_if(let_statement)
		end
	end)
end

# ╔═╡ ebca93fe-07ec-11eb-2be8-33d81143b2da
@if let x = match_ast(
	@identity(7 + 8),
	@identity(7 + $x)
)
	x
end

# ╔═╡ 10116f06-083d-11eb-13d5-3dd805db0b42
@if let x = match_ast(
	@identity(4 + 8),
	@identity(7 + $x)
)
	x
end

# ╔═╡ Cell order:
# ╠═a3a22c9a-0788-11eb-05ab-532ae1f6390e
# ╠═887a8b3a-0833-11eb-059b-e9446a947997
# ╟─df33c54a-0770-11eb-2ba5-2f90a2555cfe
# ╟─3925ed9c-078c-11eb-0933-ffa8499bc055
# ╟─e3a60806-07e1-11eb-0799-f1657f6c927a
# ╠═fa2cef8a-0a21-11eb-3d75-1905af8c0278
# ╟─8bc09a20-083b-11eb-21c4-a13f9568f036
# ╟─1be30ee8-0829-11eb-3736-e188f9acf86b
# ╟─83d2449e-082c-11eb-2135-933a85f6f24c
# ╟─ce86b1c8-083b-11eb-2870-f394b552a680
# ╟─e9f6c2ba-0839-11eb-0598-8339ea59aee7
# ╠═62f6850c-0839-11eb-0b36-0b97f2ee7222
# ╟─14bb901a-083b-11eb-097f-cd08388fa6a7
# ╟─2745ac02-083b-11eb-301d-fdf4d4949b6f
# ╟─891bc5f8-083e-11eb-00b1-9346f059de59
# ╟─b8759090-0776-11eb-2765-1b0922961a36
# ╟─fd67c304-07e8-11eb-3067-0b4d25f33da2
# ╟─cb1f8ac6-07e8-11eb-245d-cd62d8164575
# ╟─60c25e86-07ea-11eb-1c63-531fd4f227d8
# ╟─5280ac06-07ea-11eb-16ec-c5bd11c3aa2b
# ╟─93c75e2a-0776-11eb-1868-3987a1158a9b
# ╟─b6ed98e8-083c-11eb-14ed-459868c941ef
# ╟─76c1dca6-07eb-11eb-1ec0-675e98f7e625
# ╟─589aa53a-07eb-11eb-36b1-17657aa7c901
# ╠═ebca93fe-07ec-11eb-2be8-33d81143b2da
# ╠═10116f06-083d-11eb-13d5-3dd805db0b42
# ╟─37d00362-0839-11eb-3461-d9564d262cb4
# ╟─089b16b0-0783-11eb-3ec8-ef5071806c14
# ╟─7cef8b20-07d5-11eb-1ce1-75822d44f6ab
# ╟─b8b9a124-07d3-11eb-0ea8-f3d4992f0c1e
# ╟─bd5c86e0-0785-11eb-2ce7-3d080703b4ab
# ╟─dac9b488-07d4-11eb-3053-b5ce252db39e
# ╟─9fd5ccbe-0780-11eb-333e-81ea08ac8f81
# ╟─a695643e-0782-11eb-33e0-6bb1874bdd28
# ╟─cf1d1e28-080a-11eb-1cc7-fd19c79a2520
# ╟─78f6d762-083e-11eb-0017-3749142cbbbf
# ╟─daacc1b6-0775-11eb-07c8-63634bbce0c4
