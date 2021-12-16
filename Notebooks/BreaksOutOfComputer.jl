### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ 7ce1cd5c-3973-11ec-1fc0-5f616da25589
function breaks_out_of_computer()
	found_index = findfirst(stacktrace()) do x
		contains(string(x.func), "function_wrapped_cell")
	end
	found_index === nothing
end

# ╔═╡ b259bdc0-6bf0-4e3d-ba85-76e4729e10fd
does_fake_assignment_break_out_of_computer = begin
	if false
		x = 10
	end
	breaks_out_of_computer()
end

# ╔═╡ ee45ef33-42e5-4a7b-85c4-3e97d0ce1208
does_anonymous_function_break_out_of_computer = begin
	function()

	end
	breaks_out_of_computer()
end

# ╔═╡ b3a7f7ed-5aca-414a-aca5-c6c2e248417d
does_fake_reference_break_out_of_computer = begin
	if false
		x
	end
	breaks_out_of_computer()
end

# ╔═╡ 0c909b20-4f37-4aad-aa82-9b85a22636de
does_function_macro_break_out_of_computer = begin
	@X()
	breaks_out_of_computer()
end

# ╔═╡ c53ef045-43e9-4799-b729-763146456953
function should_be(expected)
	function(actual)
		if actual == expected
			Text("$actual == $expected")
		else
			Text("!! $actual != $expected !!")
		end
	end
end

# ╔═╡ 4df20cdb-9afb-472c-a12b-9fc6617e991c
does_named_function_break_out_of_computer = begin
	function X()

	end
	breaks_out_of_computer()
end |> should_be(true)

# ╔═╡ 322197d4-fd58-4e9e-8ea1-cc525e778c61
module Wow
      export c
      c(x::String) = "🐟"
  end

# ╔═╡ da2b2f92-226a-4cbb-b962-d23c7ba21894
macro identity(x)
	x
end

# ╔═╡ c31a8078-ca77-45a8-94e3-10664a21d599


# ╔═╡ f7cbd3f6-395e-4aaa-93fa-1a9758ad0091
murders = @macroexpand begin
	import .Wow: c as g
	function g(x::Int) 
		x
	end
	g
end

# ╔═╡ e8fdd6aa-8758-42fb-8e35-ba5b419c0e15
murders.args[6]

# ╔═╡ d74da0df-1906-430f-b746-9b7723713e51
begin
  import .Wow: c
  c(x::Int) = x
	# c
	c
end

# ╔═╡ 3bbc1739-2d73-4a04-92d2-b7b067b028e7
c("i am a ")

# ╔═╡ Cell order:
# ╠═7ce1cd5c-3973-11ec-1fc0-5f616da25589
# ╠═b259bdc0-6bf0-4e3d-ba85-76e4729e10fd
# ╠═ee45ef33-42e5-4a7b-85c4-3e97d0ce1208
# ╠═4df20cdb-9afb-472c-a12b-9fc6617e991c
# ╠═b3a7f7ed-5aca-414a-aca5-c6c2e248417d
# ╠═0c909b20-4f37-4aad-aa82-9b85a22636de
# ╟─c53ef045-43e9-4799-b729-763146456953
# ╠═322197d4-fd58-4e9e-8ea1-cc525e778c61
# ╠═da2b2f92-226a-4cbb-b962-d23c7ba21894
# ╠═c31a8078-ca77-45a8-94e3-10664a21d599
# ╠═f7cbd3f6-395e-4aaa-93fa-1a9758ad0091
# ╠═e8fdd6aa-8758-42fb-8e35-ba5b419c0e15
# ╠═d74da0df-1906-430f-b746-9b7723713e51
# ╠═3bbc1739-2d73-4a04-92d2-b7b067b028e7
