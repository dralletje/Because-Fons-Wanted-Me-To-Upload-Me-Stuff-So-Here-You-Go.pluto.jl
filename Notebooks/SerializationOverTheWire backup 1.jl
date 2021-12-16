### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ 7e613bd2-616a-4687-8af5-a22c7a747d97
import Serialization

# ╔═╡ a901d255-c18c-45ed-9827-afd79246613c
module PlutoHooks include("./PlutoHooks.jl") end

# ╔═╡ f9675ee0-e728-420b-81bd-22e57583c587
import .PlutoHooks: @use_effect, @use_ref, @use_state, @background, @use_memo

# ╔═╡ c9a9a089-037b-4fa8-91b2-980a318faee7
Frames = PlutoHooks.@ingredients("./SerializationLibrary.jl")

# ╔═╡ 0ad4baa4-4a15-49c2-b98d-7eea7bb11578
code = """
import Serialization

# module Frames include("./SerializationLibrary.jl") end

real_stdout = stdout
redirect_stdout(stderr)

# redirect_stderr()

sleep(1)
@info "hi"
println("What!")
sleep(2)
@info "Wow"

while !eof(stdin)
	x = readavailable(stdin)
	write(real_stdout, x)
end
"""

# ╔═╡ f7d14367-27d7-41a5-9f6a-79cf5e721a7d
import PlutoUI

# ╔═╡ ca96e0d5-0904-4ae5-89d0-c1a9187710a1
Base.@kwdef struct PlutoProcess
	process
	stdin
	stdout
	stderr
end

# ╔═╡ b7734627-ba2a-48d8-8fd8-a5c94716da20
function Base.show(io::IO, ::MIME"text/plain", process::PlutoProcess)
	write(io, process_running(process.process) ? "Running" : "Stopped")
end

# ╔═╡ 943740bd-1aa7-4431-b5b7-00f1bd3f0bb5
fieldnames(Base.Process)

# ╔═╡ 6a770c95-e269-4188-b55f-7307239bd87e
juliapath = joinpath(Sys.BINDIR::String, Base.julia_exename())

# ╔═╡ 281b4aab-307a-4d90-9dfb-f422b9567736
process_output = let
	output, set_output = @use_state("")
	
	my_stderr = @use_memo([code]) do 
		Pipe()
	end

	process = @use_memo([code]) do
		open(
			pipeline(`$juliapath --color=yes --startup-file=no -e $code`, stderr=my_stderr),
			read=true,
			write=true,
		)
	end
	@use_effect([process]) do
		return () -> begin
			kill(process)
		end
	end

	# So we re-run the whole thing when the process exists
	_, refresh_state = @use_state(nothing, [process])
	@background begin
		wait(process)
		refresh_state(nothing)
	end

	@background begin
		while !eof(my_stderr)
			new_output = String(readavailable(my_stderr))
			set_output((output) -> begin
				output * new_output
			end)
		end
	end

	pluto_process = @use_memo([process, my_stderr]) do
		PlutoProcess(
			process=process,
			stderr=my_stderr,
			stdin=process.in,
			stdout=process.out,
		)
	end

	PlutoUI.with_terminal(show_value=true) do
		print(output)
		pluto_process
	end
end

# ╔═╡ 4be7e097-72a3-4590-bcfb-a7dacb78159c
process = process_output.value.process;

# ╔═╡ f1b38d06-f1d4-458e-9d48-49b79d919968
processes = begin
	processes_ref = @use_ref([])
	push!(processes_ref[], process)
end;

# ╔═╡ 6346c79b-345e-4350-8fc0-ebee6872fab5
function to_binary(message)
	io = PipeBuffer()
	serialized = Serialization.serialize(io, message)
	read(io)
end

# ╔═╡ 253bd376-168f-4dff-9dec-de8500d53404
function from_binary(message)
	Serialization.deserialize(IOBuffer(message))
end

# ╔═╡ 7eb200df-01fc-4fba-bfe2-937374c7c3a5
MessageLength = Int

# ╔═╡ 07a3ca78-4915-42fb-b25b-fad9361b3ab7
function send_message(stream, message)
	bytes = to_binary(message)
	# bytes = Vector{UInt8}(message)
	message_length = convert(MessageLength, length(bytes))
	# @info "message_length" message_length bytes
	how_long_will_the_message_be = reinterpret(UInt8, [message_length])
	
	_1 = write(stream, how_long_will_the_message_be)
	_2 = write(stream, bytes)

	_1 + _2
	# @info "Write" _1 _2
end

# ╔═╡ 45424040-5cc5-4bc1-bf41-9ce388c90679
send_message(process, Dict(:x => 10))

# ╔═╡ bb84a50e-557f-4e37-8eac-7b642f880bd8
function read_message(stream)
	message_length_buffer = Vector{UInt8}(undef, 8)
	bytesread = readbytes!(stream, message_length_buffer, 8)
	how_long_will_the_message_be = reinterpret(MessageLength, message_length_buffer)[1]
		
	message_buffer = Vector{UInt8}(undef, how_long_will_the_message_be)
	_bytesread = readbytes!(stream, message_buffer, how_long_will_the_message_be)
	
	from_binary(message_buffer)
end

# ╔═╡ d8cff8ed-3bde-46c3-8810-8e3172284bc9
messages = begin
	messages, set_messages = @use_state([], [process])

	@background begin
		while !eof(process)
			x = readavailable(process)
			result = read_message(process)
			set_messages(messages_ -> begin
				[result, messages_...]
			end)
		end
	end
	messages
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Serialization = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[compat]
PlutoUI = "~0.7.16"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

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

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d911b6a12ba974dabe2291c6d450094a7226b372"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╠═7e613bd2-616a-4687-8af5-a22c7a747d97
# ╠═a901d255-c18c-45ed-9827-afd79246613c
# ╠═f9675ee0-e728-420b-81bd-22e57583c587
# ╠═c9a9a089-037b-4fa8-91b2-980a318faee7
# ╠═0ad4baa4-4a15-49c2-b98d-7eea7bb11578
# ╠═f7d14367-27d7-41a5-9f6a-79cf5e721a7d
# ╠═ca96e0d5-0904-4ae5-89d0-c1a9187710a1
# ╠═b7734627-ba2a-48d8-8fd8-a5c94716da20
# ╠═943740bd-1aa7-4431-b5b7-00f1bd3f0bb5
# ╠═281b4aab-307a-4d90-9dfb-f422b9567736
# ╠═6a770c95-e269-4188-b55f-7307239bd87e
# ╠═4be7e097-72a3-4590-bcfb-a7dacb78159c
# ╠═f1b38d06-f1d4-458e-9d48-49b79d919968
# ╠═6346c79b-345e-4350-8fc0-ebee6872fab5
# ╠═253bd376-168f-4dff-9dec-de8500d53404
# ╠═07a3ca78-4915-42fb-b25b-fad9361b3ab7
# ╠═7eb200df-01fc-4fba-bfe2-937374c7c3a5
# ╠═45424040-5cc5-4bc1-bf41-9ce388c90679
# ╠═bb84a50e-557f-4e37-8eac-7b642f880bd8
# ╠═d8cff8ed-3bde-46c3-8810-8e3172284bc9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
