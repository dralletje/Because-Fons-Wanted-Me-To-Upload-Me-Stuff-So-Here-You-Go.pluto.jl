### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 7be108f3-a357-4497-8beb-59f7aba61436
const var"@skip_as_script" = try Main.PlutoRunner.var"@skip_as_script" catch; (_, _, expr) -> nothing end

# ╔═╡ 1e770a7d-ded0-4c0d-a278-986ebf977c2d
@skip_as_script import PlutoTest

# ╔═╡ 1bf08a4d-0bc1-48e0-919f-d107dd14e7ff
@skip_as_script import MacroTools

# ╔═╡ 2cd6ccdd-1ff0-4a93-b87e-7585061249ca
CanBeInExpression = Any

# ╔═╡ ab7e0a99-c8b2-471c-bb9c-78ccf9b7ec30
@skip_as_script begin
	import HypertextLiteral
	
	PrettyFunctions = Main.eval(:(module PrettyFunctions
		include("./PrettyFunctions.jl")
	end))
	import .PrettyFunctions: prettycolors, PrettyFunctions


	struct CurrentModuleRef
		name::Symbol
	end
	function PrettyFunctions.special_syntax_for_exprs(x::CurrentModuleRef)
		name = PrettyFunctions.special_syntax_for_exprs(QuoteNode(x.name))
		PrettyFunctions.NiceFormattedInterpolation() do io
			print(io, "CurrentModuleRef(")
			print(io, name)
			print(io, ")")
		end
	end
	
	struct MacroGlobalRef
		mod::Module
		expr::CanBeInExpression
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
		show(io, MIME("text/html"), prettycolors(expr, Main))
	end

	PrettyFunctions
end

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

# ╔═╡ 09010362-e1ff-468f-9bd2-fe47bfd31c61
function add_esc_to_macrocalls(expr::Expr)
	if expr.head == :macrocall
		esc(expr)
	else
		Expr(expr.head, add_esc_to_macrocalls.(expr.args)...)
	end
end

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

# ╔═╡ 3588291b-6844-4439-83f2-de1de40daf2e
function turn_macrocalls_into_globalrefs(expr::Expr; expr_mod::Module)
	if expr.head == :escape
		expr
	elseif expr.head == :macrocall
		macro_name = expr.args[begin]

		globalref = if (
			# true ||
			Meta.isexpr(macro_name, :., 2) || 
			macro_name isa Symbol ||
			macro_name isa GlobalRef
		)
			MacroGlobalRef(expr_mod, expr.args[begin])
		else
			error("huh $(typeof(expr.args[begin]))")
		end
		
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

# ╔═╡ 23a42662-1073-4ed5-b4e8-3b19bff7cbc8
md"## Metadata"

# ╔═╡ 08d7ffd1-099b-4073-8d48-a3b6d3d40f5a
Base.@kwdef mutable struct MacroexpandMetadata
	timing::Number=0
	macrocalls::Set{GlobalRef}=Set{Symbol}()
end

# ╔═╡ 0ae8cdc7-2bdf-4e6b-8c58-49fd293f1d70
function current_module_ref_to_my_module(
	expr::Expr,
	mod::Module,
)
	Expr(
		expr.head,
		(
			current_module_ref_to_my_module(arg, mod)
			for arg
			in expr.args
		)...,
	)
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

# ╔═╡ cd774163-e42c-4df9-b25a-a117f0079a73
function recursive_macroexpand1(;
	mod::Module,
	expr::CanBeInExpression,
	metadata::Union{MacroexpandMetadata, Nothing}=nothing
)
	if Meta.isexpr(expr, :macrocall)
		macro_name = expr.args[1]
		linenumbernode = expr.args[begin+1]
		args = expr.args[begin+2:end]
		real_args = [linenumbernode, mod, args...]

		if macro_name isa MacroGlobalRef
			macro_name = Core.eval(macro_name.mod, macro_name.expr)
		end
		macro_function = Core.eval(mod, macro_name)
		
		method = InteractiveUtils.which(
			macro_function,
			Tuple{typeof.(real_args)...},
		)

		if metadata !== nothing
			# ONE DAY: Possibly, ever, add the signature
			push!(
				metadata.macrocalls,
				GlobalRef(method.module, method.name)
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
		
		expanded = turn_macrocalls_into_globalrefs(
			expanded,
			expr_mod=method.module,
		)

		expanded = recursive_macroexpand1(;
			mod=mod,
			expr=expanded,
			metadata=metadata,
		)
		expanded = macrohygiene(expanded)
		expanded = current_module_ref_to_my_module(expanded, method.module)
		expanded
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

# ╔═╡ 10117a26-08a1-4a00-8d39-58b7daed439c
@skip_as_script let
	metadata = MacroexpandMetadata()
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=quote
			@enum X A B C
		end,
		metadata=metadata,
	)
	metadata
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

# ╔═╡ 7ca81b16-e913-458d-b165-ba5c3a689044
md"# Tests"

# ╔═╡ e935b968-3fb0-4eaa-9e3b-9a1fcacc1afd
@skip_as_script all_names(mod) = names(mod; all=true)

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

# ╔═╡ 49843809-d697-4e78-87be-304f2def84a9
import Test

# ╔═╡ f5319a95-62d6-4ed2-a21b-50458c0229f9
@skip_as_script module Infuriating
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
with_esc = @macroexpand1(Infuriating.@child_macro_with_esc)

# ╔═╡ cd0c563f-7ca8-4ee6-b60a-b9dae50eb4bb
without_esc = @macroexpand1(Infuriating.@child_macro_without_esc)

# ╔═╡ 1c49e0b3-7ed6-4d64-b26e-360447055919
md"""
But how am I **EVER** supposed understand any if these return the same code,
but behave differently???? Why don't they return a GlobalRef'd macro???
"""

# ╔═╡ f3a0ee6f-bf14-424a-b1ff-b036e14d4e3c
they_return_the_exact_same_code = with_esc.args[1] == without_esc.args[1]

# ╔═╡ 700e98fc-6e7a-4ec0-b2e7-3532e09c784d
Core.eval(Infuriating, with_esc)

# ╔═╡ 7864d859-9571-4fdd-bf6e-b02de7bd6ee9
PlutoTest.@test @macroexpand(Infuriating.@child_macro_with_esc())

# ╔═╡ 8d813848-b969-44b4-98b2-b9593edef620
Infuriating.@child_macro_without_esc()

# ╔═╡ c707a7cb-45ff-4831-b98a-318511e64c5d
md"---"

# ╔═╡ 792a1c5d-d3c1-4183-83a1-a90c1406e03f
let
	child_macro_with_esc = Infuriating.var"@child_macro_with_esc"
	child_macro_with_esc(LineNumberNode(1), @__MODULE__)
end

# ╔═╡ 543f91b6-acd8-4175-8f57-40abc3af22ec
let
	child_macro_without_esc = Infuriating.var"@child_macro_without_esc"
	child_macro_without_esc(LineNumberNode(1), @__MODULE__)
end

# ╔═╡ 9f29f17b-cbb6-4530-b965-b82cccd95b95
md"## Enum Macro"

# ╔═╡ 18f19d85-68f4-4bb6-9f56-57c1cac36006
enum_macro = :(@enum X A B C);

# ╔═╡ b7c985fd-9ced-413c-a3ec-bf4bfd7cdef1
all_names(run_in_module(
	naive_recursive_macroexpand1(@__MODULE__(), enum_macro)
))

# ╔═╡ 9b6eb3aa-4eee-42c8-a752-e6d918650054
mod = @__MODULE__()

# ╔═╡ 4ef5a91f-8d43-4e55-b0dd-78458adb7ca5
all_names(run_in_module(
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=enum_macro,
	)
))

# ╔═╡ 95c15420-3c92-47c5-85a8-552f4998782c
all_names(run_in_module(
	macroexpand(@__MODULE__(), enum_macro)
))

# ╔═╡ 79b8a520-659f-4df0-9613-7b43aa051e43
md"## Nested Macros in different modules"

# ╔═╡ e804faa4-7f31-4ef5-9a6f-8069f0c3b562
call_parent = :(WithParentAndChildMacros.@parent());

# ╔═╡ 6cb11615-26b2-41a4-b687-d27b7b6bc769
module WithParentAndChildMacros
	macro child()
		esc(:(x = 1))
	end
	macro parent()
		quote @child() end
	end
end

# ╔═╡ 0ad3529f-b89e-4848-963c-dbd135bf5930
md"---"

# ╔═╡ f2b07423-29ed-4fec-97b0-0a0c577e3b9e
all_names(run_in_module(
	naive_recursive_macroexpand1(@__MODULE__(), call_parent)
))

# ╔═╡ 7d9c93b4-ce41-47f1-88b7-afa5336fcc0c
all_names(run_in_module(
	macroexpand(@__MODULE__(), call_parent),
))

# ╔═╡ ee8720a6-93df-4fe8-ab46-51e33c10e5cd
all_names(run_in_module(
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=call_parent,
	)
))

# ╔═╡ 991dfdad-3ddd-4401-b9ce-649252c88f1c
md"## Call that calls a call"

# ╔═╡ dd996946-2849-47f9-b7bf-652be65d59a1
call_that_calls_a_call = :(NestedParent.@parent());

# ╔═╡ cbf8c46a-7ed3-46cf-9b29-916dd73872f7
module NestedParent
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

# ╔═╡ 58b52715-8895-40d2-b2e7-07abbb2a1a31
all_names(run_in_module(
	naive_recursive_macroexpand1(@__MODULE__(), call_that_calls_a_call)
))

# ╔═╡ 9c487db5-f09d-4ebb-a54a-f1b4cf4c0e1f
all_names(run_in_module(
	macroexpand(@__MODULE__(), call_that_calls_a_call),
))

# ╔═╡ fbcabd02-7aa4-4238-942b-8a3e9d261826
all_names(run_in_module(
	recursive_macroexpand1(
		mod=@__MODULE__(),
		expr=call_that_calls_a_call,
	),
))

# ╔═╡ 141c4505-6bcd-4765-a534-8c33e0cbe597
struct Success
	value
end

# ╔═╡ 29f2082e-21f5-4aa1-bccf-5cae69e47225
struct Failure
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

# ╔═╡ ebea248c-9f66-4dca-8c80-df1ee19289a8
function compare_with_original(expr, mod::Module=@__MODULE__())
	my_expansion = @dotry MacroTools.alias_gensyms(
		recursive_macroexpand1(
			mod=mod,
			expr=expr,
		)
	)

	original_expansion = @dotry MacroTools.alias_gensyms(
		recursive_macroexpand1(
			mod=mod,
			expr=expr,
		)
	)

	if typeof(my_expansion) != typeof(original_expansion)
		false
	elseif my_expansion isa Success
		original_expansion.value == my_expansion.value
	else
		@info "original_expansion.error" original_expansion.error
		@info "my_expansion.error" my_expansion.error
		sprint(showerror, original_expansion.error.error) == sprint(showerror, my_expansion.error.error)
	end
end

# ╔═╡ 46c6c777-dcba-4f6c-abc3-5667d9181467
compare_with_original(enum_macro)

# ╔═╡ bc86cfe6-6570-4297-a247-f6dcf8007b7a
compare_with_original(call_parent)

# ╔═╡ 63f59fdf-4e34-4d42-93cb-ce0660205d74
compare_with_original(call_that_calls_a_call)

# ╔═╡ 93d6246e-fea2-421d-a2d8-db178ed0925d
md"# Explainer"

# ╔═╡ cb677964-6b81-4795-91fa-8bfc0d69b5f8
md"""
## So how does `esc(..)` work inside macros?

This is quite mysterious, specifically if you are, like me, working with macros in macros in macros. The main thing that tips me of is that 
"""

# ╔═╡ 58b818d7-40dd-4c46-9d63-96ff9ced4feb
macro returns_with_esc(x)
	return esc(x)
end

# ╔═╡ 3e82fb3c-d1d9-4ce5-8d46-b0167cf7c067
macro calls_child_with_esc(x)
	quote
		normal($(esc(x)))
		@returns_with_esc($(esc(x)))
	end
end

# ╔═╡ fc2af8ca-1a37-4377-b9da-fedc944f6d14
@macroexpand @calls_child_with_esc(x)

# ╔═╡ 665e7bc0-f112-4e09-896c-198234974d8b
md"## macros aren't consistent"

# ╔═╡ 63e6e372-b17a-4701-911c-99b76f2e0bc8
md"""
You'd think that `eval(@macroexpand ...)` would always equal just running that expression... turns out, it's not.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MacroTools = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
HypertextLiteral = "~0.9.3"
MacroTools = "~0.5.9"
PlutoTest = "~0.1.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "b7da10d62c1ffebd37d4af8d93ee0003e9248452"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.1.2"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ Cell order:
# ╠═7be108f3-a357-4497-8beb-59f7aba61436
# ╠═1e770a7d-ded0-4c0d-a278-986ebf977c2d
# ╠═1bf08a4d-0bc1-48e0-919f-d107dd14e7ff
# ╟─ab7e0a99-c8b2-471c-bb9c-78ccf9b7ec30
# ╟─2cd6ccdd-1ff0-4a93-b87e-7585061249ca
# ╟─8f9a760a-3953-48d0-998b-d2d597b7be06
# ╟─80242fec-de87-4a01-9f47-83a67c47b244
# ╟─f8435694-b240-4743-9178-8d227b35a8fb
# ╟─09010362-e1ff-468f-9bd2-fe47bfd31c61
# ╟─1b66a2a5-c350-4b81-ac79-443d019a9016
# ╟─040bfc04-e61a-43e3-84bd-8cd551ea343c
# ╟─019264df-0fa0-4f7f-b9a9-d129ed84e714
# ╟─46fee4ac-430a-42f1-87ff-319df163580d
# ╟─31c95f82-b24a-4570-ab04-96f2b523e8cf
# ╟─3588291b-6844-4439-83f2-de1de40daf2e
# ╟─cd75771c-45c6-48d1-92da-08daee544144
# ╟─70cb4b1f-cac1-4af5-bf9b-245a00362eb0
# ╟─8d6ce65c-e3f2-46af-9d0b-84f841ed78bf
# ╟─a3d87a5c-a6e9-42a5-9c8f-1258ef3c13a4
# ╟─4f592462-7633-41dd-bbbe-577fef35a38b
# ╠═9cb542a7-d161-4d7e-b760-33069333d51f
# ╟─23a42662-1073-4ed5-b4e8-3b19bff7cbc8
# ╠═08d7ffd1-099b-4073-8d48-a3b6d3d40f5a
# ╟─0ae8cdc7-2bdf-4e6b-8c58-49fd293f1d70
# ╟─db41cb1e-c571-4741-8757-c68cc68c32b7
# ╟─3e6fa1e2-8d38-4f7f-81ff-ee1a15f7a7d9
# ╟─cd774163-e42c-4df9-b25a-a117f0079a73
# ╠═10117a26-08a1-4a00-8d39-58b7daed439c
# ╟─584a5666-7fdb-47f0-9ed4-4b9307ebe828
# ╠═b77d27a6-6ad1-4eda-a87b-4ac48c1419b0
# ╟─7ca81b16-e913-458d-b165-ba5c3a689044
# ╠═e935b968-3fb0-4eaa-9e3b-9a1fcacc1afd
# ╟─e0f7312c-0dec-479e-ab03-80399e67daa8
# ╟─ba15a692-526c-477e-8ba9-c5b4998ae145
# ╟─10cfe3c6-2477-4e38-93b3-397a856b2e7d
# ╠═5c9d767a-22f8-4c11-8ee1-f4bb891b1217
# ╟─aaf68e7a-2be5-45ea-8325-bc99a3d3d7dd
# ╠═49843809-d697-4e78-87be-304f2def84a9
# ╠═f5319a95-62d6-4ed2-a21b-50458c0229f9
# ╠═8c44ad32-7b80-4b10-9f0d-47cefba6cef6
# ╠═cd0c563f-7ca8-4ee6-b60a-b9dae50eb4bb
# ╟─1c49e0b3-7ed6-4d64-b26e-360447055919
# ╠═f3a0ee6f-bf14-424a-b1ff-b036e14d4e3c
# ╠═700e98fc-6e7a-4ec0-b2e7-3532e09c784d
# ╠═7864d859-9571-4fdd-bf6e-b02de7bd6ee9
# ╠═8d813848-b969-44b4-98b2-b9593edef620
# ╟─c707a7cb-45ff-4831-b98a-318511e64c5d
# ╠═792a1c5d-d3c1-4183-83a1-a90c1406e03f
# ╠═543f91b6-acd8-4175-8f57-40abc3af22ec
# ╟─9f29f17b-cbb6-4530-b965-b82cccd95b95
# ╠═18f19d85-68f4-4bb6-9f56-57c1cac36006
# ╠═b7c985fd-9ced-413c-a3ec-bf4bfd7cdef1
# ╠═9b6eb3aa-4eee-42c8-a752-e6d918650054
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
# ╟─29f2082e-21f5-4aa1-bccf-5cae69e47225
# ╟─2833f5e5-2f7a-4360-9136-6af53e9de5bd
# ╟─ebea248c-9f66-4dca-8c80-df1ee19289a8
# ╟─93d6246e-fea2-421d-a2d8-db178ed0925d
# ╟─cb677964-6b81-4795-91fa-8bfc0d69b5f8
# ╠═58b818d7-40dd-4c46-9d63-96ff9ced4feb
# ╠═3e82fb3c-d1d9-4ce5-8d46-b0167cf7c067
# ╠═fc2af8ca-1a37-4377-b9da-fedc944f6d14
# ╟─665e7bc0-f112-4e09-896c-198234974d8b
# ╟─63e6e372-b17a-4701-911c-99b76f2e0bc8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
