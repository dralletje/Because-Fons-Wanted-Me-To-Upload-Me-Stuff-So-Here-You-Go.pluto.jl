### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 7be108f3-a357-4497-8beb-59f7aba61436
# const var"@skip_as_script" = try Main.PlutoRunner.var"@skip_as_script" catch; (_, _, expr) -> nothing end

# ╔═╡ 8d62a0e2-23b3-4708-81c8-9ffce184c18a
macro skip_as_script(expr)
	Expr(:toplevel, esc(expr))
end

# ╔═╡ 1bf08a4d-0bc1-48e0-919f-d107dd14e7ff
@skip_as_script import MacroTools

# ╔═╡ 43937e7f-8dbd-4a38-93b2-9a959bfbb2db
@skip_as_script import PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4: @from_gist

# ╔═╡ 2cd6ccdd-1ff0-4a93-b87e-7585061249ca
CanBeInExpression = Any

# ╔═╡ 8f9a760a-3953-48d0-998b-d2d597b7be06
md"""
## Custom macro hygiene

So... macrohygiene is quite enigmatic. I figured that I could write my own version,
but while doing so... I figured that I couldn't. So I'm trying to abuse the normal
macroexpansion now, but doing some grooming so macroexpand1 works more like I want.
"""

# ╔═╡ 80242fec-de87-4a01-9f47-83a67c47b244
md"""
The order of the method definitions reflects the order in which we apply them
to the expression returned from the naked macro function.
"""

# ╔═╡ f8435694-b240-4743-9178-8d227b35a8fb
md"""
#### 1. Add esc to macrocalls

The first problem is that julia removes `\$(esc(..))`s around macrocalls when they're
returned from inside a macro. So, macros that return `:(@isdefined(:x))` and `esc(:(@isdefined(:x)))` respectively, will yield different results when ran, but the **exact same** result when `@macroexpand`-ed.

To solve this, I _just_ wrap every macrocall in another `esc(..)`. Turns out julia only removes one `esc(..)`. So by wrapping it once, julia can remove the wrapping and we'll be left with the original, actually returned expression.
"""

# ╔═╡ 1b66a2a5-c350-4b81-ac79-443d019a9016
add_esc_to_macrocalls(anything::CanBeInExpression) = anything

# ╔═╡ 040bfc04-e61a-43e3-84bd-8cd551ea343c
md"""
#### 2. Julia macrohygiene as a function

To simulate the processing julia performs on the AST returned from a macro, we call a macro! Specifically, we call `@identity`, which I defined to return the AST it gets unaltered. By wrapping our expression with `@identity(..)` and then macroexpanding only one level, we get our expression "cleaned up" like julia would do if normally returned from a macro. 
"""

# ╔═╡ 019264df-0fa0-4f7f-b9a9-d129ed84e714
module ModuleWithJustIdentity
	macro identity(expr)
		expr
	end
end

# ╔═╡ 46fee4ac-430a-42f1-87ff-319df163580d
native_macrohygiene(expr) = macroexpand(
	recursive=false,
	ModuleWithJustIdentity,
	:(@identity $expr),
)

# ╔═╡ 31c95f82-b24a-4570-ab04-96f2b523e8cf
md"""
#### 3. Wrap macrocalls in GlobalRef()s

So this caused me a lot of headaches, once of the reasons recursive `@macroexpand1` doesn't yield the same way AST as `@macroexpand` is because macro are treated very differently by the macrohygiene. Where normal (unescaped) variable names get bound to the module that defines the macro (if your macro returns `:(x)`, it will actually return `:(\$(ModuleYourMacroIsIn).x)`), it doesn't do so for returning macro calls (`:(@my_macro)` will yield `:(@my_macro)`, unaltered).

This is a problem for when we want to execute the macro. We need to find this sub-macro in the module that the parent macro was in.. but there is no way for us to find what module that was in. So before I return the expression, I wrap the macrocalls in the same way that normal variables are wrapped, with a `GlobalRef(::Module, ::Symbol)`. This allows the next `@my_macroexpand1` to find the macro and call it.

Important here is that we honer `esc(..)`s, so when we find an `:escape`-node, we don't continue that part of the tree. This way, that macro will bind to the "parent module" (ehh).

> TODO: Make this wrap them in `CurrentModuleRef`? Or like `MacroCurrentModuleRef`?
"""

# ╔═╡ f6705b45-c055-474f-8595-716346fdcf0c
struct MacroGlobalRef
	mod::Module
	expr::CanBeInExpression
end

# ╔═╡ 3588291b-6844-4439-83f2-de1de40daf2e
function turn_macrocalls_into_globalrefs(expr::Expr; expr_mod::Module)
	if expr.head == :escape
		expr
	elseif expr.head == :macrocall
		macro_name = expr.args[begin]

		globalref = MacroGlobalRef(expr_mod, expr.args[begin])
		
		Expr(
			:macrocall,
			globalref,
			expr.args[begin+1:end]...,
		)
	else
		Expr(
			expr.head, 
			map(expr.args) do arg
				turn_macrocalls_into_globalrefs(arg, expr_mod=expr_mod)
			end...
		)
	end
end

# ╔═╡ cd75771c-45c6-48d1-92da-08daee544144
turn_macrocalls_into_globalrefs(anything; expr_mod::Module) = anything

# ╔═╡ 70cb4b1f-cac1-4af5-bf9b-245a00362eb0
md"""
#### 4. Transform GlobalRef to CurrentModuleRef

Remember in the previous step where I said

> if your macro returns `:(x)`, it will actually return `:($(ModuleYourMacroIsIn).x))`

That is a very useful feature, but our `@identity` macro that we used for native macrohygiene, was in the module `ModuleWithJustIdentity`. So now we go over all the `GlobalRefs` to unbind them from any module so we can easily re-bind them to the correct module later. This makes it possibly to re-bind the macroexpansion to a new module without re-expanding.

> TODO: Run this before wrapping the macrocalls? As macro calls now use `MacroGlobalRef` instead of `GlobalRef`, there is no reason this should come later.
"""

# ╔═╡ f652e6cd-e4da-409d-b2aa-ea73b6b202ed
struct CurrentModuleRef
	name::Symbol
end

# ╔═╡ ab7e0a99-c8b2-471c-bb9c-78ccf9b7ec30
@skip_as_script begin	
@from_gist("https://gist.github.com/dralletje/48b253aeb035b8dc437a106315a3fba0") do
	import PlutoNotebook_Gist_dralletje_PrettyExpr_v5 as PrettyFunctions
end

	function PrettyFunctions.special_syntax_for_exprs(x::CurrentModuleRef)
		name = PrettyFunctions.special_syntax_for_exprs(QuoteNode(x.name))
		PrettyFunctions.NiceFormattedInterpolation() do io
			print(io, "CurrentModuleRef(")
			print(io, name)
			print(io, ")")
		end
	end
	
	function PrettyFunctions.special_syntax_for_exprs(x::MacroGlobalRef)
		mod = PrettyFunctions.special_syntax_for_exprs(x.mod)
		expr = PrettyFunctions.special_syntax_for_exprs(x.expr)
		PrettyFunctions.NiceFormattedInterpolation() do io
			print(io, "MacroGlobalRef(")
			print(io, mod)
			print(io, ", ")
			print(io, expr)
			print(io, ")")
		end
	end

	function Base.show(io::IO, ::MIME"text/html", expr::Expr)
		show(io, MIME("text/html"), PrettyFunctions.PrettyExpr(expr, Main))
	end

	PrettyFunctions
end

# ╔═╡ 8d6ce65c-e3f2-46af-9d0b-84f841ed78bf
function turn_globalref_into_current_module_ref(globalref::GlobalRef; mod::Module)
	if globalref.mod == mod
		CurrentModuleRef(globalref.name)
	else
		globalref
	end
end

# ╔═╡ a3d87a5c-a6e9-42a5-9c8f-1258ef3c13a4
function turn_globalref_into_current_module_ref(expr::Expr; mod::Module)
	Expr(
		expr.head,
		(
			turn_globalref_into_current_module_ref(arg, mod=mod)
			for arg
			in expr.args
		)...
	)
end

# ╔═╡ 4f592462-7633-41dd-bbbe-577fef35a38b
turn_globalref_into_current_module_ref(anything; mod::Module) = anything

# ╔═╡ 23a42662-1073-4ed5-b4e8-3b19bff7cbc8
md"## Recursive macroexpand1"

# ╔═╡ 08d7ffd1-099b-4073-8d48-a3b6d3d40f5a
Base.@kwdef mutable struct MacroexpandMetadata
	timing::Number=0
	macrocalls::Set{Method}=Set{Method}()
end

# ╔═╡ db41cb1e-c571-4741-8757-c68cc68c32b7
function current_module_ref_to_my_module(
	current_module_ref::CurrentModuleRef,
	mod::Module,
)
	GlobalRef(mod, current_module_ref.name)
end

# ╔═╡ 3e6fa1e2-8d38-4f7f-81ff-ee1a15f7a7d9
current_module_ref_to_my_module(anything, mod::Module) = anything

# ╔═╡ 1006ce8b-4a4e-4ab0-a8d6-678f573eed3e
macro recursive_macroexpand1(expr)
	quote
		RecursiveMacroExpand.recursive_macroexpand1(
			mod=$(__module__),
			expr=$(QuoteNode(expr))
		)
	end
end

# ╔═╡ 0d6b080d-0a60-4468-96ea-0936f136612f
struct MacroExpansionException <: Exception
	expr
	previous_error
end

# ╔═╡ a13db129-0857-4634-92ed-04ad4ee4aaa0
function jl_invoke_julia_macro(
	args::Vector,
	inmodule::Module,
	metadata::Union{Nothing,MacroexpandMetadata},
)
	macro_name = args[begin]
	# As a replacement for the "ctx" variable (which we can't use because
	# we don't do all macroexpansions in one big sweep), we store MacroGlobalRef's
	# in the AST that have a reference to the ctx module for this macro.
	# These will also trigger the right error, mostly UndefVarError(..)
	# TODO Still need something to add the macro stacktrace
	if macro_name isa MacroGlobalRef
		macro_name = Core.eval(macro_name.mod, macro_name.expr)
	end
	macro_function = Core.eval(inmodule, macro_name)
	
	# For some reason some macro calls DONT HAVE A LINE NUMBER NODE??
	# WHAAAT??? WHYYYY?? HOW????
	# Whatever, just adding an empty one
	linenumbernode = args[begin+1]
	if linenumbernode === nothing
		linenumbernode = LineNumberNode(0)
	end

	_args = args[begin+2:end]
	real_args = [linenumbernode, inmodule, _args...]

    try
		# Whats missing here from the original macro stuff is the "world age"
		# stuff... I hope Julia fixes that? Will this break if there is like
		# function definitions in a macro call? 🤷‍♀️
		method = try
			InteractiveUtils.which(
				macro_function,
				Tuple{typeof.(real_args)...},
			)
		catch exception
			throw(MethodError(macro_function, real_args))
		end

		if metadata !== nothing
			push!(
				metadata.macrocalls,
				method, # Contains the module, name and argument types
			)
		end
	
		expanded = if metadata !== nothing
			local_result = nothing
			elapsed = @elapsed local_result = macro_function(real_args...)
			metadata.timing = metadata.timing + elapsed
			local_result
		else
			macro_function(real_args...)
		end

		expanded, method
	catch error
		# TODO stacktrace stuff idk
		rethrow(error)
	end
end

# ╔═╡ 8fedb98f-7112-4b62-bc77-35d379fcd99c
visit_interpolations(fn, anything) = anything

# ╔═╡ 6f65849e-96d8-4fed-a838-378c50ca10e7
function visit_interpolations(fn, expr::Expr)
	# TODO Nested quotes?
	if Meta.isexpr(expr, :$)
		fn(expr)
	else
		Expr(
			expr.head,
			(
				visit_interpolations(fn, arg)
				for arg
				in expr.args
			)...
		)
	end
end

# ╔═╡ 09010362-e1ff-468f-9bd2-fe47bfd31c61
function add_esc_to_macrocalls(expr::Expr)
	if expr.head == :macrocall
		esc(expr)
	elseif expr.head == :quote
		Expr(:quote, visit_interpolations(add_esc_to_macrocalls, expr.args[1]))
	else
		Expr(expr.head, add_esc_to_macrocalls.(expr.args)...)
	end
end

# ╔═╡ 9cb542a7-d161-4d7e-b760-33069333d51f
function macrohygiene(
	expr,
	mod::Module=@__MODULE__,
)
	expr = add_esc_to_macrocalls(expr)
	expanded_expr = native_macrohygiene(expr)
	expanded_expr = turn_macrocalls_into_globalrefs(
		expanded_expr, 
		expr_mod=mod,
	)
	turn_globalref_into_current_module_ref(
		expanded_expr,
		mod=ModuleWithJustIdentity,
	)
end

# ╔═╡ 0ae8cdc7-2bdf-4e6b-8c58-49fd293f1d70
function current_module_ref_to_my_module(
	expr::Expr,
	mod::Module,
)
	if expr.head == :quote
		Expr(:quote, visit_interpolations(expr.args[1]) do interpolation
			current_module_ref_to_my_module(interpolation, mod)
		end)
	else
		Expr(
			expr.head,
			(
				current_module_ref_to_my_module(arg, mod)
				for arg
				in expr.args
			)...,
		)
	end
end

# ╔═╡ cd774163-e42c-4df9-b25a-a117f0079a73
function recursive_macroexpand1(;
	mod::Module,
	expr::CanBeInExpression,
	metadata::Union{MacroexpandMetadata, Nothing}=nothing
)
	if (
		Meta.isexpr(expr, :inert) &&
		Meta.isexpr(expr, :module) &&
		Meta.isexpr(expr, :meta)
	)
		expr
	elseif Meta.isexpr(expr, :quote, 1)
		# The C code now calls "julia-bq-macro" in flisp...
		# But I think we can leave that to our `native-macroexpand`,
		# and just "visit_interpolations" and we'll be fine
		has_any_interpolations = false
		with_interpolations_expanded = visit_interpolations(expr.args[1]) do interpolated_expr
			has_any_interpolations = true
			recursive_macroexpand1(
				mod=mod,
				expr=interpolated_expr,
				metadata=metadata,
			)
		end

		# This transforms interpolated values into a Core._expr call,
		# no idea what that does
		expanded = macrohygiene(esc(Expr(:quote, with_interpolations_expanded)))
		expanded = current_module_ref_to_my_module(expanded, mod)
		expanded
		
	elseif Meta.isexpr(expr, Symbol("hygienic-scope"), 2)
		nested_expr, nested_module = expr.args
		recursive_macroexpand1(
			mod=nested_module,
			expr=nested_expr,
			metadata=metadata,
		)
		
	elseif Meta.isexpr(expr, :macrocall)
		expanded, method = jl_invoke_julia_macro(expr.args, mod, metadata)

		# As alternative to "ctx" we wrap every macrocall with a MacroGlobalRef
		# so we know what module to expand it "in".
		expanded = turn_macrocalls_into_globalrefs(
			expanded,
			expr_mod=method.module,
		)
		
		expanded = try
			expanded = recursive_macroexpand1(;
				mod=mod,
				expr=expanded,
				metadata=metadata,
			)
		catch error
			rethrow(error)
			# throw(MacroExpansionException(expanded, error))
		end

		# Biggest change to the C version is that the C version goes:
		# 1. Expand everything in Julia (with hygiene-scope exprs)
		# 2. Send the whole thing to flisp to do the hygiene
		# Instead, we take a more recursive approach
		# 1. Expand depth first
		# 2. Hygiene those expanded leaves
		# 3. Go to 1
		# This way we can more closely control how the expansion works,
		# and we have a bit more guarantee that nested macros work exactly
		# as a macro would in toplevel code
		expanded = macrohygiene(expanded)
		# macrohygiene leaves "CurrentModuleRef"s around, so we need to make
		# sure those reference the right module.
		expanded = current_module_ref_to_my_module(expanded, method.module)
		expanded

	elseif Meta.isexpr(expr, :do, 2) && Meta.isexpr(expr.args[1], :macrocall)
		# Do expression are parsed very weirdly
		# So we need to check if a do expression has a macrocall as first argument,
		# and if so, move the do-fn as a first argument to the macrocall
		# NOTE This likely behaves different to the latest julia macroexpansion:
		# .... Julia doesn't macrohygiene macrocalls and their arguments, initially
		# .... but when doing `@x(y) do z end` it will macrohygiene the `do` block,
		# .... likely because it isn't *in* the macrocall in the AST 🤦‍♀️
		macrocall = expr.args[begin]
		recursive_macroexpand1(
			mod=mod,
			expr=Expr(
				:macrocall,
				macrocall.args[begin],
				macrocall.args[begin+1],
				expr.args[begin+1],
				macrocall.args[begin+2:end]...,
			),
			metadata=metadata,
		)

	elseif Meta.isexpr(expr, :escape)
		# C has a special case for escape, to "lift up" the ctx on level.
		# I think we don't need that exception here... We just leave it as is?
		# the recursive `macrohygiene` should take care of this?
		# (We still expand the macros inside obviously)
		Expr(
			expr.head,
			(
				recursive_macroexpand1(
					expr=arg,
					mod=mod,
					metadata=metadata,
				)
				for arg
				in expr.args
			)...,
		)
		
	elseif expr isa Expr
		Expr(
			expr.head,
			(
				recursive_macroexpand1(
					expr=arg,
					mod=mod,
					metadata=metadata,
				)
				for arg
				in expr.args
			)...,
		)
	else
		expr
	end
end

# ╔═╡ ce9f51b1-3a7f-4cf7-b103-bdb5c34b77b3
export recursive_macroexpand1

# ╔═╡ 7ca81b16-e913-458d-b165-ba5c3a689044
md"# Tests"

# ╔═╡ 1e770a7d-ded0-4c0d-a278-986ebf977c2d
@skip_as_script import PlutoTest

# ╔═╡ e935b968-3fb0-4eaa-9e3b-9a1fcacc1afd
@skip_as_script all_names(mod) = names(mod; all=true)

# ╔═╡ b77d27a6-6ad1-4eda-a87b-4ac48c1419b0
@skip_as_script function run_in_module(expr)
	mod = Module()
	
	eval_result = Core.eval(mod, expr)
	Core.eval(mod, quote
		eval_result = $(eval_result)
		expr = $(expr)
	end)
	
	mod
end

# ╔═╡ 584a5666-7fdb-47f0-9ed4-4b9307ebe828
function naive_recursive_macroexpand1(mod, expr)
	previous_expr = nothing

	while previous_expr != expr
		previous_expr = expr
		expr = macroexpand(mod, expr, recursive=false)
	end

	expr
end

# ╔═╡ e0f7312c-0dec-479e-ab03-80399e67daa8
md"""
## 1 julia gensym vs 10,000 dral gensyms

Don't uncomment it now, because it will take a while to run,
but you can actually catch a gensym in action outside the macro
that made it, phfew.

Also making 10,000 variable names makes Julia kinda slow?
"""

# ╔═╡ ba15a692-526c-477e-8ba9-c5b4998ae145
@skip_as_script macro one_gensymmed_x()
	quote
		catch_me_if_you_can = 10
	end
end

# ╔═╡ 10cfe3c6-2477-4e38-93b3-397a856b2e7d
@skip_as_script macro not_one_but_10_000_gensymmed_x()
	quote
		xs = []
		current = split(gensym("x"), "#")[2]
		$(map(1:10_000) do i
			name = Symbol("#$(i)#catch_me_if_you_can")
			quote
				try
					push!(xs, ($(QuoteNode(name)), $(esc(name))))
				catch; end
			end
		end...)
		xs
	end
end

# ╔═╡ 5c9d767a-22f8-4c11-8ee1-f4bb891b1217
@skip_as_script begin
	@one_gensymmed_x()
	# @not_one_but_10_000_gensymmed_x()
	nothing
end

# ╔═╡ aaf68e7a-2be5-45ea-8325-bc99a3d3d7dd
md"## NO DIFFERENCE WITH ESC"

# ╔═╡ f5319a95-62d6-4ed2-a21b-50458c0229f9
module Infuriating
	macro child()
		esc("WHAT")
	end
	macro child_macro_with_esc()
		esc(:(@child))
	end

	macro child_macro_without_esc()
		:(@child)
	end
end

# ╔═╡ 8c44ad32-7b80-4b10-9f0d-47cefba6cef6
@skip_as_script with_esc = @macroexpand1(Infuriating.@child_macro_with_esc)

# ╔═╡ cd0c563f-7ca8-4ee6-b60a-b9dae50eb4bb
@skip_as_script without_esc = @macroexpand1(Infuriating.@child_macro_without_esc)

# ╔═╡ 1c49e0b3-7ed6-4d64-b26e-360447055919
md"""
But how am I **EVER** supposed understand any if these return the same code,
but behave differently???? Why don't they return a GlobalRef'd macro???
"""

# ╔═╡ f3a0ee6f-bf14-424a-b1ff-b036e14d4e3c
@skip_as_script they_return_the_exact_same_code = with_esc.args[1] == without_esc.args[1]

# ╔═╡ 7864d859-9571-4fdd-bf6e-b02de7bd6ee9
@skip_as_script @macroexpand(Infuriating.@child_macro_with_esc())

# ╔═╡ 8d813848-b969-44b4-98b2-b9593edef620
@skip_as_script Infuriating.@child_macro_without_esc()

# ╔═╡ c707a7cb-45ff-4831-b98a-318511e64c5d
md"---"

# ╔═╡ 792a1c5d-d3c1-4183-83a1-a90c1406e03f
@skip_as_script let
	child_macro_with_esc = Infuriating.var"@child_macro_with_esc"
	child_macro_with_esc(LineNumberNode(1), @__MODULE__)
end

# ╔═╡ 543f91b6-acd8-4175-8f57-40abc3af22ec
@skip_as_script let
	child_macro_without_esc = Infuriating.var"@child_macro_without_esc"
	child_macro_without_esc(LineNumberNode(1), @__MODULE__)
end

# ╔═╡ 8b36bdf8-83c3-45ab-80d5-bc54a5f91d9a
md"## Benchmark Macro"

# ╔═╡ 68ba31fe-0751-462e-99e4-1ae1c4d23cc4
@skip_as_script module BenchmarkModule
	import BenchmarkTools
end

# ╔═╡ d00828b6-9f9a-4279-9acf-b0711afd19b7
@skip_as_script benchmark_ast = quote
	BenchmarkTools.@benchmark @x
end

# ╔═╡ e9e37eb6-c40e-4042-a2f7-14a886469764
md"## :copyast"

# ╔═╡ 8f8442dc-fb9e-4817-95e3-66eb103b19dd
@skip_as_script recursive_macroexpand1(
	mod=ModuleWithJustIdentity,
	expr=quote
		@identity(quote
			quote 10 end
		end)
	end,
)

# ╔═╡ 9f29f17b-cbb6-4530-b965-b82cccd95b95
md"## Enum Macro"

# ╔═╡ 18f19d85-68f4-4bb6-9f56-57c1cac36006
@skip_as_script enum_macro = :(@enum X A B C);

# ╔═╡ b7c985fd-9ced-413c-a3ec-bf4bfd7cdef1
@skip_as_script PlutoTest.@test_throws ErrorException begin
	all_names(run_in_module(
		naive_recursive_macroexpand1(@__MODULE__(), enum_macro)
	))
end

# ╔═╡ 4ef5a91f-8d43-4e55-b0dd-78458adb7ca5
@skip_as_script PlutoTest.@test all_names(run_in_module(
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=enum_macro,
	)
)) == [:A, :B, :C, :X, :anonymous, :eval_result, :expr]

# ╔═╡ 95c15420-3c92-47c5-85a8-552f4998782c
@skip_as_script PlutoTest.@test all_names(run_in_module(
	macroexpand(@__MODULE__(), enum_macro)
)) == [:A, :B, :C, :X, :anonymous, :eval_result, :expr]

# ╔═╡ 79b8a520-659f-4df0-9613-7b43aa051e43
md"## Nested Macros in different modules"

# ╔═╡ e804faa4-7f31-4ef5-9a6f-8069f0c3b562
@skip_as_script call_parent = :(WithParentAndChildMacros.@parent());

# ╔═╡ 6cb11615-26b2-41a4-b687-d27b7b6bc769
@skip_as_script module WithParentAndChildMacros
	macro child()
		esc(esc(:(x = 1)))
	end
	macro parent()
		quote @child() end
	end
end

# ╔═╡ 0ad3529f-b89e-4848-963c-dbd135bf5930
md"---"

# ╔═╡ 7d9c93b4-ce41-47f1-88b7-afa5336fcc0c
@skip_as_script PlutoTest.@test run_in_module(
	macroexpand(@__MODULE__(), call_parent),
).x == 1

# ╔═╡ ee8720a6-93df-4fe8-ab46-51e33c10e5cd
@skip_as_script PlutoTest.@test run_in_module(
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=call_parent,
	)
).x == 1

# ╔═╡ 991dfdad-3ddd-4401-b9ce-649252c88f1c
md"## Call that calls a call"

# ╔═╡ dd996946-2849-47f9-b7bf-652be65d59a1
@skip_as_script call_that_calls_a_call = :(NestedParent.@parent())

# ╔═╡ cbf8c46a-7ed3-46cf-9b29-916dd73872f7
@skip_as_script module NestedParent
	macro child()
		10
	end

	macro wrapper(expr)
		macroexpand(__module__, expr)
	end

	macro parent()
		quote
			@wrapper begin
				@child()
			end
		end
	end
end

# ╔═╡ 141c4505-6bcd-4765-a534-8c33e0cbe597
@skip_as_script struct Success
	value
end

# ╔═╡ 29f2082e-21f5-4aa1-bccf-5cae69e47225
@skip_as_script struct Failure
	error
end

# ╔═╡ 2833f5e5-2f7a-4360-9136-6af53e9de5bd
macro dotry(expr)
	quote
		try
			Success($(esc(expr)))
		catch error
			Failure(error)
		end
	end
end

# ╔═╡ 02cbe855-d4ab-4829-969a-71ae1e220616
unpack_loaderror(e::LoadError) = unpack_loaderror(e.error)

# ╔═╡ d7c095d0-166c-4220-bd8e-eabff626962d
unpack_loaderror(e) = e

# ╔═╡ eabe8398-d65e-48b5-9ef6-2dff62788dbc
macro catch_loaderror(expr)
	quote
		try
			$(esc(expr))
			nothing
		catch error
			if error isa LoadError
				unpack_loaderror(error)
			else
				rethrow(error)
			end
		end
	end
end

# ╔═╡ f2b07423-29ed-4fec-97b0-0a0c577e3b9e
@skip_as_script PlutoTest.@test @catch_loaderror(run_in_module(
	naive_recursive_macroexpand1(@__MODULE__(), call_parent)
)) == UndefVarError(Symbol("@child"))

# ╔═╡ 58b52715-8895-40d2-b2e7-07abbb2a1a31
@skip_as_script PlutoTest.@test @catch_loaderror(all_names(run_in_module(
	naive_recursive_macroexpand1(@__MODULE__(), call_that_calls_a_call)
))) == UndefVarError(Symbol("@child"))

# ╔═╡ 9c487db5-f09d-4ebb-a54a-f1b4cf4c0e1f
@skip_as_script PlutoTest.@test @catch_loaderror(all_names(run_in_module(
	macroexpand(@__MODULE__(), call_that_calls_a_call),
))) == UndefVarError(Symbol("@child"))

# ╔═╡ fbcabd02-7aa4-4238-942b-8a3e9d261826
@skip_as_script PlutoTest.@test @catch_loaderror(run_in_module(
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=call_that_calls_a_call,
	),
)) == UndefVarError(Symbol("@child"))

# ╔═╡ ebea248c-9f66-4dca-8c80-df1ee19289a8
function compare_with_original(expr, mod::Module=@__MODULE__())
	my_expansion = @dotry MacroTools.alias_gensyms(
		recursive_macroexpand1(
			mod=mod,
			expr=expr,
		)
	)

	original_expansion = @dotry MacroTools.alias_gensyms(
		macroexpand(mod, expr)
	)

	if typeof(my_expansion) != typeof(original_expansion)
		PlutoTest.@test my_expansion == original_expansion
	elseif my_expansion isa Success
		julia_expansion = original_expansion.value
		custom_expansion = my_expansion.value
		PlutoTest.@test julia_expansion == custom_expansion
	else
		PlutoTest.@test sprint(showerror, unpack_loaderror(original_expansion.error)) == sprint(showerror, unpack_loaderror(my_expansion.error))
	end
end

# ╔═╡ be9f360d-fd87-4c64-88c1-b597cfa34044
@skip_as_script compare_with_original(benchmark_ast, BenchmarkModule)

# ╔═╡ 46c6c777-dcba-4f6c-abc3-5667d9181467
@skip_as_script compare_with_original(enum_macro)

# ╔═╡ bc86cfe6-6570-4297-a247-f6dcf8007b7a
@skip_as_script call_parent_is_equal = compare_with_original(call_parent)

# ╔═╡ 63f59fdf-4e34-4d42-93cb-ce0660205d74
@skip_as_script call_that_calls_a_call_is_equal = compare_with_original(call_that_calls_a_call)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
MacroTools = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4 = "b76dd30b-315f-5257-a48f-1ecd7c99085e"
PlutoNotebook_Gist_dralletje_PrettyExpr_v5 = "db0f8c0b-b3dc-5b5a-b085-90fac21b36eb"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"

[compat]
BenchmarkTools = "~1.2.0"
MacroTools = "~0.5.9"
PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4 = "~0.1.0"
PlutoNotebook_Gist_dralletje_PrettyExpr_v5 = "~0.1.0"
PlutoTest = "~0.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoNotebook_Gist_dralletje_ImportPlutoNotebook_v4]]
deps = ["Downloads", "JSON3", "Markdown", "Pkg"]
git-tree-sha1 = "fe07f6a5f963189c3a828e57154b33da4ca3f262"
uuid = "b76dd30b-315f-5257-a48f-1ecd7c99085e"
version = "0.1.0"

[[PlutoNotebook_Gist_dralletje_PrettyExpr_v5]]
deps = ["HypertextLiteral", "Markdown"]
git-tree-sha1 = "05905fb4a21ed7be4c8a01e3b739984528ba4290"
uuid = "db0f8c0b-b3dc-5b5a-b085-90fac21b36eb"
version = "0.1.0"

[[PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "92b8ae1eee37c1b8f70d3a8fb6c3f2d81809a1c5"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═ce9f51b1-3a7f-4cf7-b103-bdb5c34b77b3
# ╠═7be108f3-a357-4497-8beb-59f7aba61436
# ╠═8d62a0e2-23b3-4708-81c8-9ffce184c18a
# ╠═1bf08a4d-0bc1-48e0-919f-d107dd14e7ff
# ╠═43937e7f-8dbd-4a38-93b2-9a959bfbb2db
# ╟─ab7e0a99-c8b2-471c-bb9c-78ccf9b7ec30
# ╟─2cd6ccdd-1ff0-4a93-b87e-7585061249ca
# ╟─8f9a760a-3953-48d0-998b-d2d597b7be06
# ╟─80242fec-de87-4a01-9f47-83a67c47b244
# ╟─f8435694-b240-4743-9178-8d227b35a8fb
# ╠═09010362-e1ff-468f-9bd2-fe47bfd31c61
# ╟─1b66a2a5-c350-4b81-ac79-443d019a9016
# ╟─040bfc04-e61a-43e3-84bd-8cd551ea343c
# ╟─019264df-0fa0-4f7f-b9a9-d129ed84e714
# ╟─46fee4ac-430a-42f1-87ff-319df163580d
# ╟─31c95f82-b24a-4570-ab04-96f2b523e8cf
# ╠═f6705b45-c055-474f-8595-716346fdcf0c
# ╠═3588291b-6844-4439-83f2-de1de40daf2e
# ╟─cd75771c-45c6-48d1-92da-08daee544144
# ╟─70cb4b1f-cac1-4af5-bf9b-245a00362eb0
# ╠═f652e6cd-e4da-409d-b2aa-ea73b6b202ed
# ╟─8d6ce65c-e3f2-46af-9d0b-84f841ed78bf
# ╟─a3d87a5c-a6e9-42a5-9c8f-1258ef3c13a4
# ╟─4f592462-7633-41dd-bbbe-577fef35a38b
# ╠═9cb542a7-d161-4d7e-b760-33069333d51f
# ╟─23a42662-1073-4ed5-b4e8-3b19bff7cbc8
# ╠═08d7ffd1-099b-4073-8d48-a3b6d3d40f5a
# ╠═0ae8cdc7-2bdf-4e6b-8c58-49fd293f1d70
# ╟─db41cb1e-c571-4741-8757-c68cc68c32b7
# ╟─3e6fa1e2-8d38-4f7f-81ff-ee1a15f7a7d9
# ╟─1006ce8b-4a4e-4ab0-a8d6-678f573eed3e
# ╠═0d6b080d-0a60-4468-96ea-0936f136612f
# ╠═a13db129-0857-4634-92ed-04ad4ee4aaa0
# ╠═cd774163-e42c-4df9-b25a-a117f0079a73
# ╟─8fedb98f-7112-4b62-bc77-35d379fcd99c
# ╟─6f65849e-96d8-4fed-a838-378c50ca10e7
# ╟─7ca81b16-e913-458d-b165-ba5c3a689044
# ╠═1e770a7d-ded0-4c0d-a278-986ebf977c2d
# ╟─e935b968-3fb0-4eaa-9e3b-9a1fcacc1afd
# ╟─b77d27a6-6ad1-4eda-a87b-4ac48c1419b0
# ╟─584a5666-7fdb-47f0-9ed4-4b9307ebe828
# ╟─e0f7312c-0dec-479e-ab03-80399e67daa8
# ╟─ba15a692-526c-477e-8ba9-c5b4998ae145
# ╟─10cfe3c6-2477-4e38-93b3-397a856b2e7d
# ╠═5c9d767a-22f8-4c11-8ee1-f4bb891b1217
# ╟─aaf68e7a-2be5-45ea-8325-bc99a3d3d7dd
# ╠═f5319a95-62d6-4ed2-a21b-50458c0229f9
# ╠═8c44ad32-7b80-4b10-9f0d-47cefba6cef6
# ╠═cd0c563f-7ca8-4ee6-b60a-b9dae50eb4bb
# ╟─1c49e0b3-7ed6-4d64-b26e-360447055919
# ╠═f3a0ee6f-bf14-424a-b1ff-b036e14d4e3c
# ╠═7864d859-9571-4fdd-bf6e-b02de7bd6ee9
# ╠═8d813848-b969-44b4-98b2-b9593edef620
# ╟─c707a7cb-45ff-4831-b98a-318511e64c5d
# ╠═792a1c5d-d3c1-4183-83a1-a90c1406e03f
# ╠═543f91b6-acd8-4175-8f57-40abc3af22ec
# ╟─8b36bdf8-83c3-45ab-80d5-bc54a5f91d9a
# ╠═68ba31fe-0751-462e-99e4-1ae1c4d23cc4
# ╟─d00828b6-9f9a-4279-9acf-b0711afd19b7
# ╠═be9f360d-fd87-4c64-88c1-b597cfa34044
# ╟─e9e37eb6-c40e-4042-a2f7-14a886469764
# ╠═8f8442dc-fb9e-4817-95e3-66eb103b19dd
# ╟─9f29f17b-cbb6-4530-b965-b82cccd95b95
# ╠═18f19d85-68f4-4bb6-9f56-57c1cac36006
# ╠═b7c985fd-9ced-413c-a3ec-bf4bfd7cdef1
# ╠═4ef5a91f-8d43-4e55-b0dd-78458adb7ca5
# ╠═95c15420-3c92-47c5-85a8-552f4998782c
# ╠═46c6c777-dcba-4f6c-abc3-5667d9181467
# ╟─79b8a520-659f-4df0-9613-7b43aa051e43
# ╠═e804faa4-7f31-4ef5-9a6f-8069f0c3b562
# ╠═6cb11615-26b2-41a4-b687-d27b7b6bc769
# ╟─0ad3529f-b89e-4848-963c-dbd135bf5930
# ╠═f2b07423-29ed-4fec-97b0-0a0c577e3b9e
# ╠═7d9c93b4-ce41-47f1-88b7-afa5336fcc0c
# ╠═ee8720a6-93df-4fe8-ab46-51e33c10e5cd
# ╠═bc86cfe6-6570-4297-a247-f6dcf8007b7a
# ╟─991dfdad-3ddd-4401-b9ce-649252c88f1c
# ╠═dd996946-2849-47f9-b7bf-652be65d59a1
# ╠═cbf8c46a-7ed3-46cf-9b29-916dd73872f7
# ╠═58b52715-8895-40d2-b2e7-07abbb2a1a31
# ╠═9c487db5-f09d-4ebb-a54a-f1b4cf4c0e1f
# ╠═fbcabd02-7aa4-4238-942b-8a3e9d261826
# ╠═63f59fdf-4e34-4d42-93cb-ce0660205d74
# ╟─141c4505-6bcd-4765-a534-8c33e0cbe597
# ╠═29f2082e-21f5-4aa1-bccf-5cae69e47225
# ╟─2833f5e5-2f7a-4360-9136-6af53e9de5bd
# ╟─02cbe855-d4ab-4829-969a-71ae1e220616
# ╟─d7c095d0-166c-4220-bd8e-eabff626962d
# ╟─eabe8398-d65e-48b5-9ef6-2dff62788dbc
# ╠═ebea248c-9f66-4dca-8c80-df1ee19289a8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
