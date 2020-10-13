### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 21aa63b4-0c23-11eb-0ebb-617178938fe3
using Base.Iterators

# ╔═╡ d65f7716-0c2a-11eb-1f1c-d5568b99720e
md"""
# Experimenting with Debuggers in Pluto

- [Infiltrator.jl](https://github.com/JuliaDebug/Infiltrator.jl)
- [Traceur.jl](https://github.com/JunoLab/Traceur.jl)
"""

# ╔═╡ dac8df7c-0c16-11eb-0833-c50d8d9b0498
module Dral include("./Base.jl") end

# ╔═╡ a4332ad4-0c1c-11eb-3120-2fb65b3cc187
Dral.DarkmodePlus

# ╔═╡ 08b6a126-0c17-11eb-0aa0-59d4360b05b6
Dral.DarkMode.enable()

# ╔═╡ 1b2b5c3e-0c17-11eb-02ed-c536510a3f7d
import .Dral: @add

# ╔═╡ 90f56658-0c17-11eb-0f6e-7345b310ab59
@add using JuliaInterpreter v"0.8.0"

# ╔═╡ b40bd5da-0c19-11eb-2701-4de773cf900e
@add using Plots v"1.6.3"

# ╔═╡ c99b7f28-0c1a-11eb-1969-d9c57af12df7
md"""
## Plots
"""

# ╔═╡ ce71e304-0c19-11eb-28a2-093ac14ece2d
@elapsed plot(1:10)

# ╔═╡ 1473fd94-0c18-11eb-32ea-fb44024cd60a
@elapsed @interpret plot(1:10)

# ╔═╡ 4a8db5d2-0c1a-11eb-21bd-3355f9636949
md"""
## factorial of big number
"""

# ╔═╡ 33112ac4-0c1a-11eb-236c-1d549aa94ed6
@elapsed factorial(big(1000)) * 1e0

# ╔═╡ 45ba3d7a-0c1a-11eb-14e3-5736e7046673
@elapsed @interpret factorial(big(1000)) * 1e0

# ╔═╡ 5d564320-0c1d-11eb-1dda-65ffc4be71fe
md"""
## Using breakpoints
"""

# ╔═╡ 66adf9de-0c24-11eb-3e4a-f3ca3845654f
function variables(frame::JuliaInterpreter.Frame)
	vars = Dict()
	for (key, value) in zip(frame.framecode.src.slotnames, frame.framedata.locals)
		if !startswith(string(key), "#") &&  value isa Some
			vars[key] = value.value
		end
	end
	
	vars
end

# ╔═╡ 1e6cb8a6-0c27-11eb-0a99-3157d364fba1
finish_quicly = JuliaInterpreter.enter_call(function ()
	x = 10
	y = 20
	map((x) -> x * 2, [1,2,3])
	@bp
	z = 30
	x = 40
	return 50
end)

# ╔═╡ 2812330e-0c27-11eb-12b8-af0dd0ce76b9
JuliaInterpreter.finish_and_return!(finish_quicly)

# ╔═╡ 5073acac-0c29-11eb-0a2d-b3c57c5f1a0e
function debug(f)	
	Channel(1) do ch
		put!(ch, nothing)
		result = f() do locals
			put!(ch, locals)
		end
		put!(result)
	end
end

# ╔═╡ 23909e36-0c29-11eb-0b3d-9f8089386dd9
func = debug() do breakpoint
	x = 10
	while true
		x = x + 1
		breakpoint(Base.@locals())
	end
	return 20
end

# ╔═╡ 6d4bfe12-0c2e-11eb-2627-21f288282987
task = @async take!(func)

# ╔═╡ b9e8bb66-0c2e-11eb-3b2b-29a0b01e8316
task.result[:x]

# ╔═╡ 345a6e26-0c2f-11eb-0c9d-a1adadf4fe28
md"---"

# ╔═╡ 64644fd6-0c22-11eb-121c-e5523346fe08
entered_frame = JuliaInterpreter.enter_call() do
	x = 10
	
	y = 20; l = 50
	
	
	return map((x) -> x * 2, [1,2,3])
	z = 30
	x = 40
end

# ╔═╡ e5644f34-0c25-11eb-03e2-ddd9e690b9cb
frameinfo = variables(entered_frame)

# ╔═╡ 0950da26-0c27-11eb-1b80-332ec922f790
entered_frame

# ╔═╡ cf946436-0c30-11eb-215a-0f5b53b1e23b
linetable = entered_frame.framecode.src.linetable

# ╔═╡ 6f4c46f0-0c32-11eb-0c46-19bbc7a12f61
function l() 10 end

# ╔═╡ 6589e4d0-0c32-11eb-1bae-97ff91bf9322
Base.uncompressed_ast(methods(l).ms[1])

# ╔═╡ e5a21db2-0c31-11eb-0960-cb07360b90ca
linetable[entered_frame.pc].line

# ╔═╡ 2f37db20-0c31-11eb-037e-2334e260505b
Core.CodeInfo

# ╔═╡ c4809d2c-0c22-11eb-3c0d-dfc808f2bad7
begin
	debug_command(entered_frame, :se)
	(
		vars = variables(entered_frame),
		line = linetable[entered_frame.pc].line
	)
end

# ╔═╡ Cell order:
# ╠═d65f7716-0c2a-11eb-1f1c-d5568b99720e
# ╠═dac8df7c-0c16-11eb-0833-c50d8d9b0498
# ╠═a4332ad4-0c1c-11eb-3120-2fb65b3cc187
# ╠═08b6a126-0c17-11eb-0aa0-59d4360b05b6
# ╠═1b2b5c3e-0c17-11eb-02ed-c536510a3f7d
# ╠═90f56658-0c17-11eb-0f6e-7345b310ab59
# ╠═b40bd5da-0c19-11eb-2701-4de773cf900e
# ╟─c99b7f28-0c1a-11eb-1969-d9c57af12df7
# ╠═ce71e304-0c19-11eb-28a2-093ac14ece2d
# ╠═1473fd94-0c18-11eb-32ea-fb44024cd60a
# ╟─4a8db5d2-0c1a-11eb-21bd-3355f9636949
# ╠═33112ac4-0c1a-11eb-236c-1d549aa94ed6
# ╠═45ba3d7a-0c1a-11eb-14e3-5736e7046673
# ╟─5d564320-0c1d-11eb-1dda-65ffc4be71fe
# ╠═21aa63b4-0c23-11eb-0ebb-617178938fe3
# ╠═66adf9de-0c24-11eb-3e4a-f3ca3845654f
# ╠═1e6cb8a6-0c27-11eb-0a99-3157d364fba1
# ╠═2812330e-0c27-11eb-12b8-af0dd0ce76b9
# ╟─5073acac-0c29-11eb-0a2d-b3c57c5f1a0e
# ╠═23909e36-0c29-11eb-0b3d-9f8089386dd9
# ╠═6d4bfe12-0c2e-11eb-2627-21f288282987
# ╠═b9e8bb66-0c2e-11eb-3b2b-29a0b01e8316
# ╟─345a6e26-0c2f-11eb-0c9d-a1adadf4fe28
# ╠═64644fd6-0c22-11eb-121c-e5523346fe08
# ╠═e5644f34-0c25-11eb-03e2-ddd9e690b9cb
# ╠═0950da26-0c27-11eb-1b80-332ec922f790
# ╠═cf946436-0c30-11eb-215a-0f5b53b1e23b
# ╠═6f4c46f0-0c32-11eb-0c46-19bbc7a12f61
# ╠═6589e4d0-0c32-11eb-1bae-97ff91bf9322
# ╠═e5a21db2-0c31-11eb-0960-cb07360b90ca
# ╠═2f37db20-0c31-11eb-037e-2334e260505b
# ╠═c4809d2c-0c22-11eb-3c0d-dfc808f2bad7
