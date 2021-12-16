### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ ac0d6de4-407f-11ec-38de-83dd2fd10857
module PlutoHooks
	include("../PlutoHooks.jl/src/notebook.jl")
end

# ╔═╡ bc5ae298-27d3-41b6-ad40-8db1731b17df
PlutoHooks.@ingredients("asd")

# ╔═╡ 7d46c546-d085-49ae-a3f1-626212be8f48
macro use_deps(fn_expr, deps)
	expanded_fn_expr = macroexpand(__module__, esc(fn_expr))

	cell_id_ref = Ref{Any}("hi")

	perfected_fn_expr = Main.PlutoRunner.replace_pluto_properties_in_expr(
		expanded_fn_expr;
		cell_id=:($(cell_id_ref)[]),
		register_cleanup_function=:(@give_me_register_cleanup_function),
		# TODO Right now this just runs the whole cell (with all @with_key's)
		# .... Later I'd ideally have this cache itself and only run when
		# .... this specific key is asked to run again
		rerun_cell_function=:(@give_me_rerun_cell_function),
	)
	
	quote
		$(perfected_fn_expr)()
	end
end

# ╔═╡ 65342d17-37bd-478c-8e80-c0ea2fbbc6de
macro child(x)
	@info "got expression" x
	esc(x)
end

# ╔═╡ 4a2431fa-8097-4eac-8359-24192cd1083f
macro parent(x)
	quote
		@child x
	end
end

# ╔═╡ cd8012b8-629f-4efb-9232-208f99a6c1a0
@macroexpand @parent(x)

# ╔═╡ 46df28e1-5bb6-4b0c-9423-e37f9d1161b1
module Module1
	const x = 20
	macro expand(expr, mod)
		try
			better_expr = macroexpand(mod, expr)
			quote
				$(better_expr)()
			end
		catch load_error
			if (
				load_error isa LoadError &&
				load_error.error isa UndefVarError &&
				# Tbf, what other variable would it be?
				startswith(string(load_error.error.var), "@")
			)
				quote
					if @__MODULE__() != $(__module__)
						error("You most likely forgot to pass in \$(@__MODULE__) into @use_dep")
					else
						$(load_error)
					end
				end
			else
				return load_error
			end
		end
	end

	macro expand(expr)
		quote
			@expand($(expr), $(__module__))
		end
	end
end

# ╔═╡ b77eb363-46e6-46d0-b7c0-2f53024fd1d1
module Module2
	import ..Module1.@expand, ..@use_deps

	const x = 10

	macro ten()
		"from_module_2"
	end

	macro expandme(expr)
		quote
			@expand($(@__MODULE__())) do
				x
			end
		end
	end
end

# ╔═╡ 942aca29-82c8-4e42-b1e6-5e79c1030fc5
# macro ten()
# 	40
# end

# ╔═╡ 8de47efb-4aa2-4e2f-99b8-b6b698f35ba4


# ╔═╡ 02de2381-969f-4784-bab5-8a747c86ed2a
Module2.@expandme begin
	@ten()
end

# ╔═╡ 542f8b25-dd8c-45b1-8ddb-00f17bf5dce5
Module1.@expand begin
	@ten()
end

# ╔═╡ 499054e2-c40e-4a25-93ed-92115ca06aa7
MacroTest.@refers_something_in_this_module

# ╔═╡ Cell order:
# ╠═ac0d6de4-407f-11ec-38de-83dd2fd10857
# ╠═bc5ae298-27d3-41b6-ad40-8db1731b17df
# ╠═7d46c546-d085-49ae-a3f1-626212be8f48
# ╠═65342d17-37bd-478c-8e80-c0ea2fbbc6de
# ╠═4a2431fa-8097-4eac-8359-24192cd1083f
# ╠═cd8012b8-629f-4efb-9232-208f99a6c1a0
# ╠═46df28e1-5bb6-4b0c-9423-e37f9d1161b1
# ╠═b77eb363-46e6-46d0-b7c0-2f53024fd1d1
# ╠═942aca29-82c8-4e42-b1e6-5e79c1030fc5
# ╠═8de47efb-4aa2-4e2f-99b8-b6b698f35ba4
# ╠═02de2381-969f-4784-bab5-8a747c86ed2a
# ╠═542f8b25-dd8c-45b1-8ddb-00f17bf5dce5
# ╠═499054e2-c40e-4a25-93ed-92115ca06aa7
