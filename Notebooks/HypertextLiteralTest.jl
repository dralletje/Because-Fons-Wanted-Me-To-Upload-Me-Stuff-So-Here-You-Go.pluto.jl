### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 1a72b18c-400f-11ec-0bd0-e972dccfcfa8
import PlutoHooks: PlutoHooks, @use_state, @use_ref, @use_task, @use_effect

# ╔═╡ 9ce9ca7d-3db8-4d20-ad5e-c2aca47b1665
import HypertextLiteral as G

# ╔═╡ 68a475ba-f831-4eb3-9799-b101735ce2cb
begin
	PlutoHooks.@use_file_change("../HypertextLiteral.jl/src/interpolate.jl")
	HypertextLiteral = PlutoHooks.@ingredients("../HypertextLiteral.jl/src/HypertextLiteral.jl").HypertextLiteral
end

# ╔═╡ f56a9336-f136-4cc7-8f4c-c073b6fae140
arg = "well-hello-there"

# ╔═╡ e90c89a7-bbc6-47cb-9d9a-50a96a3c9de8
import PlutoUI

# ╔═╡ 7e06db21-3828-43c5-9642-8f77b29abb2d
@bind x html"""<input type=range>"""

# ╔═╡ cb3efe2a-5e17-4273-8e03-17cf86cdc42a
x

# ╔═╡ 8f988181-4279-4e55-a61e-2df98c6cdd8e
@bind aasd PlutoUI.Slider(1:10)

# ╔═╡ a615533d-d20e-4c49-9ab0-eed7bc35623d
aasd

# ╔═╡ dead2ffc-ccee-42e7-843e-998d9283483d
Text(G.@htl("""<script>
x = $(PlutoRunner.publish_to_js("hi"))
"""))

# ╔═╡ d48ab2db-6ce6-4759-9014-7f4f602f7dd9
attrs = Dict(:id => "cell-plot")

# ╔═╡ 243f14a4-ee35-4c38-9e05-6b223af919d8
module PlutoTest include("../PlutoTest.jl/src/notebook.jl") end

# ╔═╡ b3a8891b-9a63-4cf5-b263-79196b3b5f58
struct Step
	state
	next_input
	arg_index
	index_in_arg
end

# ╔═╡ 23222cf1-f523-406a-9f6c-ece2ad1b974b
macro htl_debug(str)
	args = str isa String ? [str] : str.args
	steps = Step[]
	interpolation_error = nothing
	result = nothing
	try
		result = HypertextLiteral.interpolate(
			args,
			callback=function(state, input, arg_index, index_in_arg)
				push!(steps, Step(
					state,
					input,
					arg_index,
					index_in_arg
				))
			end,
		)
	catch error
		interpolation_error = error
	end

	quote
		result = try
			@htl $(str)
		catch error
			error
		end
		create_frames(
			steps=$(steps),
			str=$(QuoteNode(str)),
			interpolation_error=$(interpolation_error),
			result=Text(result),
			# result=nothing,
		)
	end
end

# ╔═╡ 4f348def-4c46-4723-ad7e-06d694c8b071
var"@htl" = HypertextLiteral.var"@htl"

# ╔═╡ c1f823de-672b-4644-a7c9-546254f58b1e
@htl """
<select multiple size=20>
	<option value="hi">#1</option>
	<option value="hi">#1</option>
	<option value="hi">#1</option>
	<option value="hi">#1</option>
"""

# ╔═╡ cc1737f4-2e38-4115-a299-c2f1d25138c2
function create_frames(; steps, str, interpolation_error, result)
	INTERPOLATION_FILLER = raw"$(..)"

	args = map(str.args) do arg
		if arg isa String
			arg
		else
			INTERPOLATION_FILLER
		end
	end
	
	PlutoTest.frames(map(enumerate(steps)) do (i, step)	
		indent = 0
		for i in 1:(step.arg_index - 1)
			indent = indent + length(args[i])
		end
		indent = if str.args[step.arg_index] isa String
			indent + step.index_in_arg - 1
		else
			indent
		end

		step_size = if str.args[step.arg_index] isa String
			1
		else
			length(INTERPOLATION_FILLER)
		end
			

		indent = indent < 0 ? 0 : indent
		
		G.@htl """<div><template shadowroot=open>
		<style>
		small {
			font-size: 12px;
		}

		dral-error {
			color: red;
		}

		pre {
			font-size: 24px;
			overflow: hidden;
			display: block;
			background: none;
			font-family: JuliaMono;
		}
		</style>
		<pre>
		$(isnothing(interpolation_error) ?
			@htl("""
			<small>$(result)</small>
			""") :
			@htl("""
			<dral-error>ERROR: $(sprint(showerror, interpolation_error))</dral-error>
			"""))

		$(args)
		$(repeat(" ", indent))$(repeat("↑", step_size))
		$(if i < length(steps)
			next_step = steps[i+1]
			if step.state == next_step.state
				G.@htl """
				<small> </small>
				$(string(step.state))
				"""
			else
				G.@htl """
				<small>$(string(step.state)) =></small>
				$(string(next_step.state))
				"""
			end
		else
			if isnothing(interpolation_error)
				G.@htl """
				<small>$(string(step.state)) =></small>
				FIN
				"""
			else
				G.@htl """
				<small>$(string(step.state)) =></small>
				<dral-error>ERROR</dral-error>
				"""
			end
		end)
		</pre>
		</template></div>
		"""
	end)

end

# ╔═╡ 32fc8793-4d1d-428a-9673-4597670b5659
@htl_debug("""<tag value $arg=value>""")

# ╔═╡ fe95a7c6-2c5a-4182-88ba-02cb52661a0c
@htl_debug("""<tag data-$arg=value>""")

# ╔═╡ 792d71c5-473f-400c-9925-de6c22aad911
@htl_debug("""<tag $arg-data=value>""")

# ╔═╡ bcfec2cc-08a8-4ab8-99f3-ad23f19483c6
@htl_debug "<div $(:x => "hi")>"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoHooks = "0ff47ea0-7a50-410d-8455-4348d5de0774"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.2"
PlutoHooks = "~0.0.2"
PlutoUI = "~0.7.18"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0ec322186e078db08ea3e7da5b8b2885c099b393"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.0"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

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

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

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

[[PlutoHooks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "d551bccd095218255fae60ab3305ca4f3e4d2968"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.2"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "57312c7ecad39566319ccf5aa717a20788eb8c1f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.18"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

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
# ╠═1a72b18c-400f-11ec-0bd0-e972dccfcfa8
# ╠═9ce9ca7d-3db8-4d20-ad5e-c2aca47b1665
# ╠═68a475ba-f831-4eb3-9799-b101735ce2cb
# ╠═f56a9336-f136-4cc7-8f4c-c073b6fae140
# ╠═32fc8793-4d1d-428a-9673-4597670b5659
# ╠═c1f823de-672b-4644-a7c9-546254f58b1e
# ╠═e90c89a7-bbc6-47cb-9d9a-50a96a3c9de8
# ╠═7e06db21-3828-43c5-9642-8f77b29abb2d
# ╠═cb3efe2a-5e17-4273-8e03-17cf86cdc42a
# ╠═8f988181-4279-4e55-a61e-2df98c6cdd8e
# ╠═a615533d-d20e-4c49-9ab0-eed7bc35623d
# ╠═dead2ffc-ccee-42e7-843e-998d9283483d
# ╠═fe95a7c6-2c5a-4182-88ba-02cb52661a0c
# ╠═792d71c5-473f-400c-9925-de6c22aad911
# ╠═d48ab2db-6ce6-4759-9014-7f4f602f7dd9
# ╠═bcfec2cc-08a8-4ab8-99f3-ad23f19483c6
# ╠═243f14a4-ee35-4c38-9e05-6b223af919d8
# ╠═23222cf1-f523-406a-9f6c-ece2ad1b974b
# ╠═cc1737f4-2e38-4115-a299-c2f1d25138c2
# ╟─b3a8891b-9a63-4cf5-b263-79196b3b5f58
# ╟─4f348def-4c46-4723-ad7e-06d694c8b071
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
