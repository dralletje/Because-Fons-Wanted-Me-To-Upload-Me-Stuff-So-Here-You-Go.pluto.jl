### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ 3ee27562-4f01-4c55-b715-89df824ca460
begin
	import Pkg

	Pkg.activate(tempdir())

	Pkg.develop(path=expanduser("~/Projects/Pluto.jl"))
	Pkg.add("JSON3")
	Pkg.add("HypertextLiteral")
	Pkg.add("HTTP")
end

# ╔═╡ cc326d5f-75ea-42c6-84c5-982b93fd49f0
module PlutoHooks
	include(expanduser("~/Projects/PlutoHooks.jl/src/notebook.jl"))
end

# ╔═╡ 01729118-448e-4aaf-bb36-c8d100f3259b
import Pluto

# ╔═╡ 4fd6155f-4fc2-4934-867e-537d533a4f88
import JSON3

# ╔═╡ af26e4df-1d1d-4c5e-b76b-fce5e10dcb07
import HypertextLiteral: @htl

# ╔═╡ d48cc1cf-c440-4292-8777-53a2d5dde75b
import HTTP

# ╔═╡ 4242a473-d856-4e3d-9858-7f6d8ae9b089
PORT = 9999

# ╔═╡ 5276f73a-450c-41dd-a849-b0242528e24c
options = Pluto.Configuration.from_flat_kwargs(
	workspace_use_distributed=false,
	require_secret_for_access=false,
	require_secret_for_open_links=false,
	port=PORT,
	launch_browser=false,
	dismiss_update_notification=true,

	# TODO Mimic cli arguments this Pluto instance was started with
	# .... Actually, no, we are doing `workspace_use_distributed=false` anyway
	# .... so there is no new julia instance at all.
)

# ╔═╡ 582ed0d0-55da-4285-a099-a69ea337e6fb
pluto_session = Pluto.ServerSession(options=options)

# ╔═╡ bf0b3875-9657-4555-836b-93d1883a1db1
function open_notebook(file)::Pluto.Notebook
	try
		Pluto.SessionActions.open(pluto_session, file)
	catch error
		if error isa Pluto.SessionActions.NotebookIsRunningException
			error.notebook
		else
			rethrow(error)
		end
	end
end

# ╔═╡ 9fab59bf-c8fd-45ca-8557-a544a7674a76
running_notebook = open_notebook("./AddAttributes.jl")

# ╔═╡ 670d4db9-444e-46a9-b763-40c991fb5308
import Random

# ╔═╡ 0c0fcb02-9226-4e07-9fcc-f25c2b3624af
struct NotDefinedHuh end

# ╔═╡ a518de44-5f2b-48f9-9122-415bf4040715
begin
	struct VariableSelector
		keep_variable::Function
	end
	function (selector::VariableSelector)(x)
		selector.keep_variable(x)
	end
end

# ╔═╡ 57ac4638-138b-48f3-9d22-dc3b0ce8ce6d
function convert(::Type{VariableSelector}, x::Function)
	VariableSelector(x)
end

# ╔═╡ bc3026ac-19f2-4287-bdc2-703216c4b6c8
function convert(::Type{VariableSelector}, x::Vector{Symbol})
	VariableSelector() do (symbol, value)
		symbol ∈ x
	end
end

# ╔═╡ 746a2c99-7246-4a7c-9766-ebeb14fa63e5
macro use_notebook_values(notebook_in_notebook_expr)
	quote
		@use_notebook_values((_ -> true), $(esc(notebook_in_notebook_expr)))
	end
end

# ╔═╡ 342132a4-4c29-4ff8-9db4-ecff8f6fb571
macro use_notebook_values2(selector_expr, notebook_in_notebook_expr)
	quote
		notebook_in_notebook = $(esc(notebook_in_notebook_expr))
		selector = convert(VariableSelector, $(esc(selector_expr)))
		
		session = notebook_in_notebook.session
		notebook = notebook_in_notebook.notebook

		current_values, set_new_deps = @PlutoHooks.use_state(
			filter(selector, get_all_cell_outputs(notebook_in_notebook))
		)
		
		@PlutoHooks.use_deps([get_all_cell_outputs, Random, notebook_in_notebook]) do
			@PlutoHooks.use_task([]) do
				last_deps = filter(selector, get_all_cell_outputs(notebook_in_notebook))
				while true
					sleep(1)
					new_deps = filter(selector, get_all_cell_outputs(notebook_in_notebook))

					@info "!!!" new_deps last_deps new_deps != last_deps
					
					if new_deps != last_deps
						last_deps = new_deps
						set_new_deps(new_deps)
					end
				end
			end
			
			current_values
		end
	end
end

# ╔═╡ 04a3bc5a-512a-44ca-887f-3afbdafe12e1
macro _use_notebook_values(selector_expr, notebook_in_notebook_expr)
	quote
		notebook_in_notebook = $(esc(notebook_in_notebook_expr))
		selector = convert(VariableSelector, $(esc(selector_expr)))
		
		session = notebook_in_notebook.session
		notebook = notebook_in_notebook.notebook
		
		@PlutoHooks.use_deps([get_all_cell_outputs, Random, notebook_in_notebook]) do
			current_values, set_new_deps = @PlutoHooks.use_state(
				filter(selector, get_all_cell_outputs(notebook_in_notebook))
			)

			error, set_error = @PlutoHooks.use_state(nothing)
			if error !== nothing
				throw(error)
			end
			
			@PlutoHooks.use_task([]) do
				# TODO Try connecting a bunch of times

				# TODO Connect "locally" (in the tests)
				HTTP.WebSockets.open("ws://localhost:$PORT") do ws
					# Initialize connection
					write(ws, Pluto.pack(Dict(
						:body => Dict(),
						:client_id => Random.randstring(6),
						:notebook_id => string(notebook.notebook_id),
						:request_id => Random.randstring(6),
						:type => "connect",
					)))
		
					set_new_deps_debounced = debounce(set_new_deps, 0.5)
					last_deps = current_values
					while !eof(ws)
						@info "eof" eof ws
						# I don't actually care what we get send,
						# we just care SOMETHING happened
						readavailable(ws)
						
						new_deps = filter(selector, get_all_cell_outputs(notebook_in_notebook))

						@info "!!!" new_deps last_deps new_deps != last_deps
						
						if new_deps != last_deps
							last_deps = new_deps
							set_new_deps_debounced(new_deps)
						end
					end
				end
			end
		
			current_values
		end
	end
end

# ╔═╡ 3634a658-333f-456c-8568-6769b40d4926
function debounce(fn, time)
	task_ref = Ref{Task}(Task() do; end)
	
	return (args...) -> begin
		if istaskstarted(task_ref[]) && !istaskdone(task_ref[])
			Base.schedule(
				task_ref[],
				InterruptException(),
				error=true,
			)
		end

		task_ref[] = Task() do
			sleep(time)
			fn(args...)
		end
		schedule(task_ref[])
	end
end

# ╔═╡ fb8dfb2c-8df2-47f4-8d0e-3e90416108d3
pluto_running_task = @PlutoHooks.use_deps([pluto_session]) do
	task = @PlutoHooks.use_task([pluto_session]) do
		sleep(1)
		Pluto.run(pluto_session)
	end
end

# ╔═╡ 61f82db1-cfc6-495f-8f48-06361327c34d
is_running_pluto = !istaskdone(pluto_running_task)

# ╔═╡ 5a274516-0240-432b-b6ce-4423b4b15fce
session_notebook = (pluto_session, running_notebook)

# ╔═╡ ac7800ec-003b-44bd-96ef-5e52ad71dc1f
macro use_timer(timeout_expr)
	quote
		timeout = $(esc(timeout_expr))
		@PlutoHooks.use_deps([timeout]) do
			last_time, set_time = @PlutoHooks.use_state(time())
			@PlutoHooks.use_task([]) do
				while true
					sleep(timeout)
					set_time(time())
				end
			end
			last_time
		end
	end
end

# ╔═╡ e8a5f077-a633-45e5-ba4d-d24fff24ccf4
struct NotebookInNotebook
	session::Pluto.ServerSession
	notebook::Pluto.Notebook
end

# ╔═╡ bc8e82cb-7ba6-43a7-8d33-cb5bb9bda1f8
function get_all_cell_outputs(notebook_in_notebook::NotebookInNotebook)
	notebook = notebook_in_notebook.notebook
	session = notebook_in_notebook.session
	
	i_guess = [
		Iterators.flatten(
			Iterators.map(notebook.topology.nodes) do (key, value)
				value.definitions
			end
		)...
	]

	Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), quote
		Dict($(map(i_guess) do symbol
			:($(QuoteNode(symbol)) => @isdefined($symbol) ? $symbol : $NotDefinedHuh())
		end...))
	end)
end

# ╔═╡ 4564a893-5333-4173-bd43-ff4f786aa2de
function pluto_iframe(notebook_in_notebook::NotebookInNotebook)
	session = notebook_in_notebook.session
	notebook = notebook_in_notebook.notebook
	
	port = session.options.server.port
	@htl """
	<iframe
		src="http://localhost:$port/edit?id=$(string(notebook.notebook_id))"
		style="
			border: none;
			width: 100%;
		"
	    allow="accelerometer; ambient-light-sensor; autoplay; battery; camera; display-capture; document-domain; encrypted-media; execution-while-not-rendered; execution-while-out-of-viewport; fullscreen; geolocation; gyroscope; layout-animations; legacy-image-formats; magnetometer; microphone; midi; navigation-override; oversized-images; payment; picture-in-picture; publickey-credentials-get; sync-xhr; usb; wake-lock; screen-wake-lock; vr; web-share; xr-spatial-tracking"
        allowfullscreen
	></iframe>
	
	<script id="huh">
	let iframeref = currentScript.parentElement.querySelector('iframe')
	
	let iframeDocument = iframeref.contentWindow.document
	/** Grab the <script> tag for the iframe content window resizer
	 * @type {HTMLScriptElement} */
	let original_script_element = document.querySelector("#iframe-resizer-content-window-script")
	// Clone it into the iframe document, so we have the exact same script tag there
	let iframe_resizer_content_script = iframeDocument.importNode(original_script_element)
	// Fix the `src` so it isn't relative to the iframes url, but this documents url
	iframe_resizer_content_script.src = new URL(iframe_resizer_content_script.src, original_script_element.baseURI).toString()
	iframeDocument.head.appendChild(iframe_resizer_content_script)
	
	// Apply iframe resizer from the host side
	new Promise((resolve) => iframe_resizer_content_script.addEventListener("load", () => resolve()))
	// @ts-ignore
	window.iFrameResize({ checkOrigin: false }, iframeref)
	</script>
	"""
end

# ╔═╡ 617cffa7-2775-458c-9b6a-a5675e0d795a
function Base.show(io::IO, mime::MIME"text/html", sub_notebook::NotebookInNotebook)
	show(io, mime, pluto_iframe(sub_notebook))
end

# ╔═╡ bcba6f26-51f4-11ec-010c-03a60f199391
macro use_notebook(filename)
	quote
		filename = $(esc(filename))
		
		notebook = open_notebook(filename)
		
		NotebookInNotebook(pluto_session, notebook)
	end
end

# ╔═╡ c50ae8db-8821-44c7-bbb6-ad97260af461
x = @use_notebook "./inner-notebook.jl"

# ╔═╡ 45a09a00-b362-4a45-b4e2-14be2e8560aa
fakeclient = let
	buffer = IOBuffer()
	client = Pluto.ClientSession(:buffery, buffer)

	🍭 = x.session
	🍭.connected_clients[client.id] = client
	client.connected_notebook = x.notebook

	client
end

# ╔═╡ 8d539551-c407-46f1-b06b-ff478d85dacc
try
	@_use_notebook_values(_ -> true, x)
catch error
	error
end

# ╔═╡ fbffd123-af24-4f35-8edb-d94b17d8a719
get_all_cell_outputs(x)

# ╔═╡ 2baa2b8d-4b95-47da-b260-78270487044b
read(fakeclient.stream)

# ╔═╡ Cell order:
# ╠═3ee27562-4f01-4c55-b715-89df824ca460
# ╠═cc326d5f-75ea-42c6-84c5-982b93fd49f0
# ╠═01729118-448e-4aaf-bb36-c8d100f3259b
# ╠═4fd6155f-4fc2-4934-867e-537d533a4f88
# ╠═af26e4df-1d1d-4c5e-b76b-fce5e10dcb07
# ╠═d48cc1cf-c440-4292-8777-53a2d5dde75b
# ╠═4242a473-d856-4e3d-9858-7f6d8ae9b089
# ╠═5276f73a-450c-41dd-a849-b0242528e24c
# ╠═582ed0d0-55da-4285-a099-a69ea337e6fb
# ╟─bf0b3875-9657-4555-836b-93d1883a1db1
# ╟─9fab59bf-c8fd-45ca-8557-a544a7674a76
# ╠═670d4db9-444e-46a9-b763-40c991fb5308
# ╠═0c0fcb02-9226-4e07-9fcc-f25c2b3624af
# ╟─bc8e82cb-7ba6-43a7-8d33-cb5bb9bda1f8
# ╠═45a09a00-b362-4a45-b4e2-14be2e8560aa
# ╟─a518de44-5f2b-48f9-9122-415bf4040715
# ╟─57ac4638-138b-48f3-9d22-dc3b0ce8ce6d
# ╟─bc3026ac-19f2-4287-bdc2-703216c4b6c8
# ╠═746a2c99-7246-4a7c-9766-ebeb14fa63e5
# ╟─342132a4-4c29-4ff8-9db4-ecff8f6fb571
# ╠═04a3bc5a-512a-44ca-887f-3afbdafe12e1
# ╠═3634a658-333f-456c-8568-6769b40d4926
# ╟─fb8dfb2c-8df2-47f4-8d0e-3e90416108d3
# ╟─61f82db1-cfc6-495f-8f48-06361327c34d
# ╟─5a274516-0240-432b-b6ce-4423b4b15fce
# ╟─ac7800ec-003b-44bd-96ef-5e52ad71dc1f
# ╟─4564a893-5333-4173-bd43-ff4f786aa2de
# ╠═e8a5f077-a633-45e5-ba4d-d24fff24ccf4
# ╠═617cffa7-2775-458c-9b6a-a5675e0d795a
# ╠═bcba6f26-51f4-11ec-010c-03a60f199391
# ╠═8d539551-c407-46f1-b06b-ff478d85dacc
# ╠═fbffd123-af24-4f35-8edb-d94b17d8a719
# ╠═c50ae8db-8821-44c7-bbb6-ad97260af461
# ╠═2baa2b8d-4b95-47da-b260-78270487044b
