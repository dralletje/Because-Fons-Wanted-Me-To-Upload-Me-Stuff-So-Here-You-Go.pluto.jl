### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 2b19a632-139f-11eb-357e-d5458c7cf647
md"# Meta.@lower and @code_lowered"

# ╔═╡ 40ba8faa-139f-11eb-273c-739e6265410e
function sum_this_thrice(x)
	sum([x,x,x])
end

# ╔═╡ 0634da6a-13a8-11eb-0bea-a76d4960b1bf
md"""Small function that we are going to be inspecting throughout this notebook"""

# ╔═╡ 867d553c-139f-11eb-346d-357b60437c88
md"## Meta.@lower

Shows the expression it is given, in lowered form.
Does not at all look at what is actually being returned by the functions.
There is no type checking, no multiple-dispatch magic. Everything you see is just derived from the code you've written."

# ╔═╡ a55ed0b0-13a0-11eb-1070-bdc31b1b81b7
md"### Simple call"

# ╔═╡ 45da54f0-139f-11eb-26c0-6f83cfb74ef1
Meta.@lower sum_this_thrice(3)

# ╔═╡ a16ff8be-13a0-11eb-3411-331bc2a8a60d
md"You can see that, all we get is what we already knew: We call sum\_this\_thrice with the argument 3. Sure, but this isn't giving us too much new insight in what is actually happening, we can't peek into sum\_this\_thrice"

# ╔═╡ d6191692-13a0-11eb-216f-359939c4cfc6
md"### Nested expressions"

# ╔═╡ e6b1580a-13a0-11eb-3ca6-35b712381c0b
Meta.@lower [1, 2, 3 + 4, factorial(5 + 3)] * [3]

# ╔═╡ ff0cdb54-13a0-11eb-1234-0be80166177f
md"""You'll notice that the main thing `Meta.@lower` gives us here, is the "untangled" version of our code. Every "thing" that runs is put on it's own line and given it's own name, or rather number (`%1`, `%2`, `%3`, ...)"""

# ╔═╡ 3348669a-13a1-11eb-3a44-6d7d2e41a0ef
md"### Branches and conditionals"

# ╔═╡ 41c6a63c-13a1-11eb-2af5-717eb74fcd73
Meta.@lower if rand() < 0.5
	if time() % 16 == 0
		:what_are_the_odds
	else
		:better_luck_next_time
	end
else
	:not_even_close
end

# ╔═╡ b7bd3ba8-13a1-11eb-256d-b3b39613ea7b
md"""Here some of the more impressive transformations are visible. `Meta.@lower` takes all the branches that are possible and flattens them into a list of goto statements. The numbers on the far left, `1 ─`, `2 ─`, are the points the code can "jump to" with a `goto #x if not %y` statement.

I have no idea what the lines starting with `@` denote, so I assume you can ignore those.
"""

# ╔═╡ 87b7ee02-13a2-11eb-269d-1b7d6f44437e
md"### Going Meta on Meta"

# ╔═╡ a3195780-13a2-11eb-01f6-cd6774478524
md"I figured, maybe we can find out more about how `Meta.@lower` works, by `Meta.@lower`-ing on itself!"

# ╔═╡ dbd2fd40-139f-11eb-0675-b761e4aa09b3
Meta.@lower Meta.@lower(1 + 1)

# ╔═╡ 2c5f97e6-13a0-11eb-06c2-f3ce18237eb1
md"""It does "expand" the macro, and we can see that the macro "just" takes the expression we put in, wraps it in a QuoteNode (to prevent it from executing) and gives it to the plain function `Meta.lower()`.

However, we don't see any internals of `Meta.lower` here.."""

# ╔═╡ 9e9109ae-13a2-11eb-0e40-57d3105046ec
Meta.@lower Meta.lower(:(1 + 1))

# ╔═╡ 0624878c-13a3-11eb-2ea5-619306eeeb5c
md"""Even if we try to lower the `Meta.lower` call, we still just get a more expressive way of saying `Meta.lower(:(1 + 1))`. To go deeper, we need `@code_lowered`."""

# ╔═╡ 8c298f2c-13a4-11eb-3def-ab22b7206dc7
md"### Read more"

# ╔═╡ 79fce9be-13a4-11eb-2ccc-7ff43241da43
@which Meta.@lower 1 + 1

# ╔═╡ 4fd81878-13a4-11eb-3c5e-dfad23bc0027
@which Meta.lower(@__MODULE__, :(1 + 1))

# ╔═╡ 5bcc37b4-13a0-11eb-2f98-65db149f7c4b
md"""## @code_lowered"""

# ╔═╡ 55fcccd6-13a0-11eb-1607-9d77c9264aa1
@code_lowered 1 + 1

# ╔═╡ 5bcc1a9c-13a3-11eb-1a83-0d627ab28f29
Meta.@lower 1 + 1

# ╔═╡ 628773d6-13a3-11eb-252e-2524a0574e4b
md"""
Compare these two results. One of them gives us "Well yeah you did want 1 + 1, so that's what I wrote down", where the other one says "Ahh, but let me show you how the 1 + 1 is made".
"""

# ╔═╡ c15d7930-13a5-11eb-3870-e346fd80e952
md"### Simple call, revisited"

# ╔═╡ d13abebc-13a5-11eb-21e7-054adb669cfb
@code_lowered sum_this_thrice(3)

# ╔═╡ d95d389a-13a5-11eb-1aa9-c7e0868f12ab
md"""
`@code_lowered` actually shows us what is happening in the call. This is a lot more useful when you are testing or inspecting functions throughout your code. Notice how similar this is to running `Meta.@lower` on expression that is inside the function:
"""

# ╔═╡ 1db11d04-13a6-11eb-2309-bf2b477cc95f
Meta.@lower sum([x,x,x])

# ╔═╡ 18cd2884-13a4-11eb-086f-69f18a91a994
md"### To macro or not to macro"

# ╔═╡ 1f029f90-13a4-11eb-0b5c-8d21ff2dbb74
@code_lowered (@code_lowered 1 + 1)

# ╔═╡ d6f67414-13a4-11eb-1d7c-c9cf80c5a87c
md"""
`@code_lowered` is the macro version of `code_lowered`. Instead of "just wrapping the result and passing it code\_lowered", @code\_lowered does quite some stuff. If you look at the documentation for `code_lowered` you see it takes a lot of options that aren't present in `@code_lowered`.

The biggest difference between `Meta.@lower` and `@code_lowered` is that, as you can see above, `@code_lowered` first puts the result through `InteractiveUtils.gen_call_with_extracted_types_and_kwargs`. Now we are entering the jungle of metaprogramming.
"""

# ╔═╡ 41e0e354-13a5-11eb-3a41-014f73ab1fb6
InteractiveUtils.gen_call_with_extracted_types_and_kwargs(@__MODULE__, :code_lowered, [:(1 + 1)])

# ╔═╡ 8562f09a-13a5-11eb-358b-8fff6125eb43
md"""`InteractiveUtils.gen_call_with_extracted_types_and_kwargs` doesn't return a normal result, but it returns **a call** with the results baked in. You can change the `:code_lowered` in the above snippet, and you'll see the call actually change."""

# ╔═╡ 48195bce-13a6-11eb-0d26-ad6dc286bab5
md"### Going lowered on lowered"

# ╔═╡ 2c3ff93e-13a7-11eb-02b3-4745064d683e
@code_lowered :hey + :wow

# ╔═╡ 3959f08e-13a7-11eb-2c4a-e39df9675d75
md"Heads up while playing with @code\_lowered: if it can't find a matching method, it will return an empty `Core.CodeInfo[]`, like above"

# ╔═╡ dab887b0-13a7-11eb-21b4-eb6fa75506cc
md"""What follows here is a undocumented rambling of me just trying things on `code_lowered`."""

# ╔═╡ 1ddc173a-13a7-11eb-2365-a3616b5580fa
code_lowered(sum_this_thrice, Tuple{Int64})

# ╔═╡ 85596814-13a7-11eb-034a-e9f6f2ed92a4
@code_lowered code_lowered(sum_this_thrice, Tuple{Int64})

# ╔═╡ b0e01a70-13a7-11eb-08d3-6319b1518ba2
@code_lowered Base.var"#code_lowered#11"(true, :default, code_lowered, sum_this_thrice, Tuple{Int64})

# ╔═╡ 2a2f4986-13a4-11eb-2343-a135b2bd19ec
@code_lowered Meta.lower(@__MODULE__, :(1 + 1))

# ╔═╡ 9b94158a-13a3-11eb-27f6-8f6fc3c793ba
@code_lowered [1,2,3]

# ╔═╡ b061f3b2-13a3-11eb-2a68-632a09b2d6af
Meta.@lower [1,2,3]

# ╔═╡ Cell order:
# ╟─2b19a632-139f-11eb-357e-d5458c7cf647
# ╠═40ba8faa-139f-11eb-273c-739e6265410e
# ╟─0634da6a-13a8-11eb-0bea-a76d4960b1bf
# ╟─867d553c-139f-11eb-346d-357b60437c88
# ╟─a55ed0b0-13a0-11eb-1070-bdc31b1b81b7
# ╠═45da54f0-139f-11eb-26c0-6f83cfb74ef1
# ╟─a16ff8be-13a0-11eb-3411-331bc2a8a60d
# ╟─d6191692-13a0-11eb-216f-359939c4cfc6
# ╠═e6b1580a-13a0-11eb-3ca6-35b712381c0b
# ╟─ff0cdb54-13a0-11eb-1234-0be80166177f
# ╟─3348669a-13a1-11eb-3a44-6d7d2e41a0ef
# ╠═41c6a63c-13a1-11eb-2af5-717eb74fcd73
# ╠═b7bd3ba8-13a1-11eb-256d-b3b39613ea7b
# ╟─87b7ee02-13a2-11eb-269d-1b7d6f44437e
# ╟─a3195780-13a2-11eb-01f6-cd6774478524
# ╠═dbd2fd40-139f-11eb-0675-b761e4aa09b3
# ╟─2c5f97e6-13a0-11eb-06c2-f3ce18237eb1
# ╠═9e9109ae-13a2-11eb-0e40-57d3105046ec
# ╟─0624878c-13a3-11eb-2ea5-619306eeeb5c
# ╟─8c298f2c-13a4-11eb-3def-ab22b7206dc7
# ╟─79fce9be-13a4-11eb-2ccc-7ff43241da43
# ╟─4fd81878-13a4-11eb-3c5e-dfad23bc0027
# ╟─5bcc37b4-13a0-11eb-2f98-65db149f7c4b
# ╠═55fcccd6-13a0-11eb-1607-9d77c9264aa1
# ╠═5bcc1a9c-13a3-11eb-1a83-0d627ab28f29
# ╟─628773d6-13a3-11eb-252e-2524a0574e4b
# ╟─c15d7930-13a5-11eb-3870-e346fd80e952
# ╠═d13abebc-13a5-11eb-21e7-054adb669cfb
# ╟─d95d389a-13a5-11eb-1aa9-c7e0868f12ab
# ╠═1db11d04-13a6-11eb-2309-bf2b477cc95f
# ╟─18cd2884-13a4-11eb-086f-69f18a91a994
# ╠═1f029f90-13a4-11eb-0b5c-8d21ff2dbb74
# ╟─d6f67414-13a4-11eb-1d7c-c9cf80c5a87c
# ╠═41e0e354-13a5-11eb-3a41-014f73ab1fb6
# ╠═8562f09a-13a5-11eb-358b-8fff6125eb43
# ╟─48195bce-13a6-11eb-0d26-ad6dc286bab5
# ╠═2c3ff93e-13a7-11eb-02b3-4745064d683e
# ╟─3959f08e-13a7-11eb-2c4a-e39df9675d75
# ╟─dab887b0-13a7-11eb-21b4-eb6fa75506cc
# ╠═1ddc173a-13a7-11eb-2365-a3616b5580fa
# ╠═85596814-13a7-11eb-034a-e9f6f2ed92a4
# ╠═b0e01a70-13a7-11eb-08d3-6319b1518ba2
# ╠═2a2f4986-13a4-11eb-2343-a135b2bd19ec
# ╠═9b94158a-13a3-11eb-27f6-8f6fc3c793ba
# ╠═b061f3b2-13a3-11eb-2a68-632a09b2d6af
