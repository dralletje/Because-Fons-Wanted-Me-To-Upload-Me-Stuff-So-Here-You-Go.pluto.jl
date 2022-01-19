### A Pluto.jl notebook ###
# v0.17.3

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

# ╔═╡ 94e75fdf-de64-4150-b154-909b0b8c48b1
md"""
# Javascript (and State) in Pluto
This package gives the ability to use ObservableHQ style javascript cells.
Importing this in a notebook requires JSON3 to be installed:
```julia
import JSON3
module PlutoJavascript require("PlutoJavascript.jl") end
import .PlutoJavascript: @javascript, State
```
"""

# ╔═╡ 9e5078da-50dd-4fe8-a639-b8170605f64e
md"### Javascript basics"

# ╔═╡ 4ffd15b8-55fc-4840-ac6d-427c08b6810d
@bind slider_number html"<input type=range />"

# ╔═╡ 26239200-e1dc-40f5-94d2-608108229768
md"### Observable Import-ish"

# ╔═╡ dff95b2e-06af-4904-9984-d389d7b0e0ce
md"#### Keep the same element for animations and transitions!"

# ╔═╡ 28636b0c-fe8a-487a-8667-3415dfe2342e
@bind is_blue html"<input type=checkbox>"

# ╔═╡ 7017c598-641a-4958-84be-09cd6de58d2b
html"""<style>
.pluto-observablehq-like[pluto-js-renderer="app"] {
	transition: opacity .4s;
	transition-delay: 0.2s;
}
pluto-cell.queued .pluto-observablehq-like[pluto-js-renderer="app"] > *,
pluto-cell.running .pluto-observablehq-like[pluto-js-renderer="app"] > *,
.pluto-observablehq-like[pluto-js-renderer="app"][pluto-js-is-loading] > * {
	opacity: 0.2;
	cursor: wait;
}
"""

# ╔═╡ 7a734e9c-341f-46d9-91a5-1f99d1ba2432
g = 1 + 1

# ╔═╡ c3631b64-f558-4f52-a3a0-6fd020d411b3
y = g + 3

# ╔═╡ 1358d748-fa55-428f-8dd3-b401cca323ef
md"### Toggle between value, element and error"

# ╔═╡ ec8f2ae7-f5d4-40c8-af46-d102a56bace0
@bind app_state html"""<select>
	<option value="element">Element</option>
	<option value="value">Value</option>
	<option value="error">Error</option>
</select>"""

# ╔═╡ 25d7af20-3b31-4c7e-89d7-8470a55ae759
md"#### Fetch and html example"

# ╔═╡ 5360f727-4eb9-4f4f-9694-4148743c6755
md"#### Error flows through javascript"

# ╔═╡ fe0d0426-cdaa-43dd-be06-0d5667f1af14
md"### Component example (with state!)"

# ╔═╡ 8ed3f97d-7360-468f-a457-362b38ca505c
columns = [
	"Column A",
	"Column B",
	"Column C",
]

# ╔═╡ 4989de20-2e6b-4d17-8f20-0a4c9b704c3b
md"""
### Vanilla javascript version of the state listeners
I decided to still use Observable style javascript instead of <script> tags,
because screw <script> tags (and it does automatic show(::MIME"application/javascript) stuff for the bond :D). Easy enough to change back though.
"""

# ╔═╡ 43926f68-7a28-48c8-8cdf-6fcac6e94b63
md"## Appendix"

# ╔═╡ 4d15edb4-f5a2-4766-85ce-96a1519f4a83
import JSON3

# ╔═╡ 969af4f8-22cf-4c48-b282-d7cad9627ed9
import UUIDs

# ╔═╡ 66bb4876-9db3-4061-aa4c-251e67cfb6c8
md"### Javascript"

# ╔═╡ 11de0697-362e-41e9-a443-83cb6bc56b47
"JavascriptRef"
struct JavascriptRef
	id::String
	code::String
end

# ╔═╡ 56eb5717-cc0f-4ba8-970a-878ce0f0310b
struct Javascript
	code::String
end

# ╔═╡ 511ad5a6-f913-43de-b73c-d0b91d70aa85
function Base.show(io::IO, ::MIME"application/javascript", js::Javascript)
	print(io, js.code)
end

# ╔═╡ dfc22d15-4dc2-49a5-8153-7b09fe9117a2
embed(js::JavascriptRef) = Javascript(js.code)

# ╔═╡ f3e4cce5-ead1-4644-908a-ef5cf2ee3986
"Show JavascriptRef element"
function Base.show(io::IO, ::MIME"text/html", ref::JavascriptRef)
	print(io, """
		<script id="inspector-patronus">
		// Do pluto_value_registry voodoo
		let ref_id = $(JSON3.write(ref.id))
		window.pluto_value_registry = window.pluto_value_registry || {}
		
		// I'd throw an error here directly, but I want to show it in a nice
		// observable inspector, so I keep my mouth shut until just before
		// I'm actually going to execute the script, and then I'm not going to 😈
		let is_already_on_the_dom = window.pluto_value_registry[ref_id]?.on_the_dom === true
		if (window.pluto_value_registry[ref_id] == null) {
			let defered = {}
			let promise = new Promise((resolve, reject) => {
				defered.resolve = resolve
				defered.reject = reject
			})
			defered.promise = promise
			window.pluto_value_registry[ref_id] = defered
		}
		window.pluto_value_registry[ref_id].on_the_dom = true
		let ref_promise = window.pluto_value_registry[ref_id] 
		invalidation.then(() => {
			delete window.pluto_value_registry[ref_id]
		})
		
		let widget_container = this
		if (widget_container == null) {
			widget_container = html`<span
				class="pluto-observablehq-like"
				pluto-js-renderer="none"
				style="display: contents"
			></span>`
			Object.defineProperties(widget_container, {
				value: {
					set: function(value) {
						if (this.firstElementChild != null) {
							this.firstElementChild.value = value
						}
					},
					get: function() {
						return this.firstElementChild?.value
					},
				},
			})
		}
		widget_container.setAttribute("pluto-js-is-loading", "")
		
		// So I can check for invalidation after await'ing the value
		let is_invalidated = false
		invalidation.then(() => {
			is_invalidated = true
		})
		// Straight out of Pluto source
		let execute_dynamic_function = async ({ environment, code }) => {
			// single line so that we don't affect line numbers in the stack trace
			const wrapped_code = `"use strict"; return (async () => {\${code}})()`
			let { ["this"]: this_value, ...args } = environment
			let arg_names = Object.keys(args)
			let arg_values = Object.values(args)
			const result = await Function(...arg_names, wrapped_code).bind(this_value)(...arg_values)
			return result
		}
		
		// "inspector" or "app"
		let renderer = widget_container.getAttribute("pluto-js-renderer")
		let previous_value = widget_container.previous_value
		
		let spawn_inspector = async () => {
			if (renderer === "inspector" && widget_container.observablehq_inspector_instance != null) {
				return widget_container.observablehq_inspector_instance
			}
		
			let inspector_container = DOM.element('span')
			let shadow = inspector_container.attachShadow({mode: 'open'});
			shadow.innerHTML = `
				<link rel="stylesheet" href="https://unpkg.com/@observablehq/inspector@3.2.2/src/style.css">
				<style>
					/* Inspector CSS uses :root, but apparently that isn't good enough
						for shadow dom 🤷‍♂️ */
					:host {
					  --syntax_normal: #1b1e23;
					  --syntax_comment: #a9b0bc;
					  --syntax_number: #20a5ba;
					  --syntax_keyword: #c30771;
					  --syntax_atom: #10a778;
					  --syntax_string: #008ec4;
					  --syntax_error: #ffbedc;
					  --syntax_unknown_variable: #838383;
					  --syntax_known_variable: #005f87;
					  --syntax_matchbracket: #20bbfc;
					  --syntax_key: #6636b4;
					  --mono_fonts: 82%/1.5 Menlo, Consolas, monospace;
					}
					/* For some, weird reason, this rule isn't 
						in the open source version */
					.observablehq--caret {
					  margin-right: 4px;
					  vertical-align: baseline;
					}
					/* Makes the whole inspector flow like text */
					.observablehq--inspect {
						display: inline;
					}
					#inspect {
						font-family: var(--mono_fonts);
					}
					/* Add a gimmicky javascript logo */
					.observablehq--inspect.observablehq--collapsed > a::before,
					.observablehq--inspect:not(.observablehq--collapsed)::before,
					.observablehq--running::before {
						all: initial;
						content: 'JS';
						color: #323330;
						background-color: #F0DB4F;
						display: inline-block;
						padding-left: 4px;
						padding-right: 4px;
						padding-top: 3px;
						padding-bottom: 2px;
						margin-right: 5px;
						font-size: 14px;
						font-family: 'Roboto Mono';
						font-weight: bold;
						margin-bottom: 3px;
					}
				</style>
				<span id="inspect">
				</span>
			`
			let {Inspector} = await import("https://unpkg.com/@observablehq/inspector@3.2.2/src/index.js?module")
			let inspector = new Inspector(shadow.querySelector('#inspect'))
		
			widget_container.setAttribute("pluto-js-renderer", "inspector")
			widget_container.replaceChildren(inspector_container)
			widget_container.observablehq_inspector_instance = inspector
			return inspector
		}
		try {
			if (is_already_on_the_dom) {
				throw new Error("It's not yet possible to render a JavascriptRef to the same page at multiple places at the same time.")
			}
		
			let value = await execute_dynamic_function({
				environment: {
					"this": widget_container.previous_value,
					invalidation: invalidation,
					getPublishedObject: getPublishedObject,
					DOM: DOM,
					Files: Files,
					Generators: Generators,
					Promises: Promises,
					now: now,
					svg: svg,
					html: html,
					require: require,
				},
				code: $(JSON3.write(ref.code)),
			})
			if (is_invalidated) return
			ref_promise.resolve(value)
			widget_container.previous_value = value
			// Don't show HTMLElement inside inspector, because it will
			// be rendered inside the shadow dom, and I don't like that (yet?)
			if (value instanceof HTMLElement) {		
				widget_container.setAttribute("pluto-js-renderer", "app")
				if (value !== previous_value) {
					widget_container.replaceChildren(value)
					// Not sure if this should be in or outside of this `if`
					value.addEventListener("input", () => {
						widget_container.dispatchEvent(new Event("input"))
					})
					widget_container.dispatchEvent(
						new Event("input")
					)
				}
			} else {
				let inspector = await spawn_inspector()
				inspector.fulfilled(value)
			}
		} catch (error) {
			if (is_invalidated) return
			// Hide "uncaught promise" warning in the browser
			// ref_promise.promise.catch(() => {})
		
			ref_promise.reject(error)
			widget_container.previous_value = null
		
			let inspector = await spawn_inspector()
			inspector.rejected(error)
		} finally {
			widget_container.removeAttribute("pluto-js-is-loading")
		}
		
		return widget_container;
		</script>
	""")
end;

# ╔═╡ 3da48b70-6f5a-440b-84c7-167aae2b7ac9
"Render javascript for state"
function Base.show(io::IO, ::MIME"application/javascript", ref::JavascriptRef)
	print(io, """(await (() => {
		window.pluto_value_registry = window.pluto_value_registry || {}
		let ref_id = $(JSON3.write(ref.id))
		if (window.pluto_value_registry[ref_id] == null) {
			// No promise/defered, so we put out own there
			let defered = {}
			let promise = new Promise((resolve, reject) => {
				defered.resolve = resolve
				defered.reject = reject
			})
			defered.promise = promise
			window.pluto_value_registry[ref_id] = defered
		}
				
		return window.pluto_value_registry[ref_id].promise
	})())
	""")
end;

# ╔═╡ 3dc4c309-e8b4-4265-b325-7fa3ebc2ac40
"Same as javascript but no mime"
function Base.show(io::IO, ref::JavascriptRef)
	show(io, MIME("application/javascript"), ref)
end;

# ╔═╡ eeae3d5a-adcd-4641-adea-2c39b92ea26f
function expression_to_string(expr)
	repr(expr)
end

# ╔═╡ e4d22957-7020-42bd-8a1f-162c3757502f
function expression_to_string(expr::Symbol)
	string(expr)
end

# ╔═╡ d7c12348-0aa2-44c4-81c3-87ebcd1779ee
function expression_to_string(with_linenums::Expr)
	expr = Base.remove_linenums!(deepcopy(with_linenums))
	if Meta.isexpr(expr, :block, 1)
		expression_to_string(expr.args[1])
	else
		result = repr(expr)
		if startswith(result, ":")
			result[begin+1:end]
		else
			result
		end
	end
end

# ╔═╡ d02097f4-8fb9-452e-8862-dcb4dc20b090
"""
    wrap_javascript_in_pluto_shell(code::String)
Wrap javascript code in <script> tags, add the code to share the value between
cells in javascript, and render with Observable inspector.
"""
function wrap_javascript_in_pluto_shell(code::AbstractString)
	uuid = string(UUIDs.uuid4())
	JavascriptRef(uuid, code)
end

# ╔═╡ ad490316-621c-44e4-8644-7caec7d72f28
macro javascript(cell::String)
	wrap_javascript_in_pluto_shell; # For Pluto dependency graph
	
	trimmed = strip(cell)
	if startswith(trimmed, "{") && endswith(trimmed, "}")
		wrap_javascript_in_pluto_shell(trimmed[begin+1:end-1])
	else
		wrap_javascript_in_pluto_shell("return $(cell)")
	end
end

# ╔═╡ 10255d34-fcf2-4fb6-9e10-e32eb9df7dd6
macro javascript(expr::Expr)
	wrap_javascript_in_pluto_shell; # For Pluto dependency graph
	if !Meta.isexpr(expr, :string) throw("Mehh") end
	
	expression_parts = expr.args
	
	is_expression = true
	_begin = firstindex(expression_parts)
	if (
		expression_parts[_begin] isa String &&
		startswith(strip(expression_parts[_begin]), "{") &&
		expression_parts[end] isa String &&
		endswith(strip(expression_parts[end]), "}")
	)
		expression_parts[_begin] = expression_parts[_begin][_begin+1:end]
		expression_parts[end] = expression_parts[end][_begin:end-1]
		is_expression = false
	end

	
	expression_parts_with_staticness = map(expr.args) do arg
		is_static = arg isa String
		:((
			is_static=$(is_static),
			value=$(esc(arg)),
			name=$(is_static ? nothing : expression_to_string(arg))
		))
	end
	
	quote
		expression_parts = [$(expression_parts_with_staticness...)]
		is_expression = $(is_expression)

		string_parts = []
		variables_to_load = Dict{String,Any}()
		for (is_static, part, name) in expression_parts
			if is_static
				push!(string_parts, part)
			else
				name_safe = JSON3.write(name)
				push!(string_parts, "deps[$(name_safe)]")
				if showable(MIME("application/javascript"), part)
					variables_to_load[name_safe] = repr(MIME("application/javascript"), part)
				elseif showable(MIME("application/json"), part)
					# TODO Make JSON not load as javascript, but with JSON.parse
					variables_to_load[name_safe] = repr(MIME("application/json"), part)
				else
					# TODO Make JSON not load as javascript, but with JSON.parse
					# variables_to_load[name_safe] = JSON3.write(part)
					variables_to_load[name_safe] = PlutoRunner.publish_to_js(part)
				end
			end
		end
		
		preload = map(collect(variables_to_load)) do variable_to_load
			(name, load_str) = variable_to_load
			"""
			try {
				deps[$name] = $load_str
			} catch (error) {
				throw new ReferenceError(`\${$name} is not defined`)
			}
			"""
		end
		preload_block = """
			let deps = {}
			$(join(preload, "\n"))
		"""
		
		if is_expression
			wrap_javascript_in_pluto_shell("""
				$(preload_block)
				return ($(string_parts...))
			""")
		else
			wrap_javascript_in_pluto_shell("""
				$(preload_block)
				$(string_parts...)
			""")
		end
	end
end

# ╔═╡ ca0ebf01-e620-4029-a583-376859de7384
js_string = @javascript "`hey`"

# ╔═╡ 3ea4d132-2d69-497e-a1d9-71bdb1ca9ac5
js_number = @javascript "10"

# ╔═╡ 1b3d8ce9-0b9d-4f02-8e2c-2c5a4d560a3b
js_function = @javascript "(a, b, c) => {}"

# ╔═╡ 7b23a041-bbe7-4e47-a264-0db20366422a
js_array = @javascript "[1, 2, 3, 4]"

# ╔═╡ b7b8d9f4-48e7-4444-8388-8c670fb37458
js_async = @javascript """{
	await new Promise((resolve) => setTimeout(resolve, 5000))
	let response = await fetch(`https://jsonplaceholder.typicode.com/todos/1`)
	return await response.json()
}"""

# ╔═╡ 47f01cfa-9ace-4762-a27d-9b724aa63f70
js_syntax_error = @javascript "{"

# ╔═╡ ef202964-5ed9-49ff-a749-c3aa91799f3e
md"### React dependencies and utils"

# ╔═╡ c1ab37f5-5bcd-4f86-b986-900ebde9e4b1
react_require_prod = @javascript """require.alias({
  react: "react@17/umd/react.development.js",
  "react-dom": "react-dom@17/umd/react-dom.development.js"
})"""

# ╔═╡ 3353d69f-45ff-4d46-88c2-924e3ee6b5d7
function skip_as_script(m::Module)
	if isdefined(m, :PlutoForceDisplay)
		return m.PlutoForceDisplay
	else
		isdefined(m, :PlutoRunner) && parentmodule(m) == Main
	end
end

# ╔═╡ c5b75129-fd6c-44f3-aeee-fa366e0839dc
macro skip_as_script(ex) skip_as_script(__module__) ? esc(ex) : nothing end

# ╔═╡ 186079ef-487e-4065-a546-e775c7ee45ba
md"### State"

# ╔═╡ 812212dd-71e9-4789-9f99-de8d7107626d
begin
	"""
		@bind name State(key, initial_value)
	"""
	struct State
		name::String
		initial_value::Any
		javascript_ref::JavascriptRef

		function State(name::String, initial_value::Any)
			javascript_ref = @javascript """{
				// Possibly use `this`?
				let element = html`<dral-state-component>
					<code
						style="pointer-events: none; user-select: none;"
						class="language-julia"
					>State("\${$(name)}")</code>
				</dral-state-component>`
				element.setAttribute("name", $(name))
				element._value = $(initial_value)
				Object.defineProperties(element, {
				  value: {
					set: function(value) {
						this._value = value
						this.dispatchEvent(new Event("change"))
					},
					get: function() {
						return this._value
					}
				  },
				})
				return element
			}"""
			new(name, initial_value, javascript_ref)
		end
	end
	
	Base.get(state::State) = state.initial_value
	
	function Base.show(io::IO, mime::MIME"text/html", state::State)
		show(io, mime, state.javascript_ref)
	end
	
	function Base.show(io::IO, mime::MIME"application/javascript", state::State)
		show(io, mime, state.javascript_ref)
	end
	
	function Base.showable(::MIME"application/javascript", bond::Main.PlutoRunner.Bond)
		return bond.element isa State
	end
	
	function Base.show(io::IO, mime::MIME"application/javascript", bond::Main.PlutoRunner.Bond)
		# Add a generic type to PlutoRunner.Bond?
		Base.showable(mime, bond) || throw("Right now, only State() bonds can do JS")
		show(io, mime, bond.element)
	end
end

# ╔═╡ 2cd025ca-c646-4ad2-88ed-7bb3a8eb4c5f
export @javascript, State

# ╔═╡ 4fee059b-b327-463b-ba4b-1c495a899ae4
js_dict_with_references = @javascript """({
	number: $js_number,
	nested: { object: "with", some: "key" },
})"""

# ╔═╡ d9420313-31d0-4785-a9f8-32e71b0edcdb
move_slider_to_see_changes = @javascript "({ number: $slider_number })"

# ╔═╡ f4af25a0-8003-4b0a-9ea0-a37a4017d8f6
ObservableCell(url, cell; kwargs...) = @javascript """{
	const div = html`<div></div>`
	const { Runtime, Inspector } = await import("https://cdn.jsdelivr.net/npm/@observablehq/runtime@4/dist/runtime.js")
	const { default: define } = await import($url)
	const runtime = new Runtime()
	const main =  runtime.module(define, name => {
	  if (name === $cell) return new Inspector(div);
	});
	console.log('main:', main)
	let entries = $(Dict(kwargs...))
	console.log('entries:', entries)
	for (let [key, value] of Object.entries(entries)) {
		main.redefine(key, value)
	}
	return div
}"""


# ╔═╡ 9b682047-6561-447d-8a3e-6b63bb6bd69a
ObservableCell(
	"https://api.observablehq.com/d/cb23c66017d6052f@285.js?v=3",
	"chart",
	data=[1,2,6,9,1,10,11,5]
)

# ╔═╡ 0ee7c824-4230-4f2e-b51d-97e2fd990efa
@javascript """{
	let element = this || html`
		<div style="
			width: 100px;
			height: 100px;
			transition: all 1s;
		">
	`
	await new Promise((resolve) => setTimeout(resolve, 1000))
console.log(':::')
	element.style.backgroundColor = $(is_blue) ? "blue" : "cyan"
	return element
}"""

# ╔═╡ 90f81a53-aff3-464d-b30a-1b641eedbba9
@javascript """{
	await new Promise((resolve) => setTimeout(resolve, 2000))
	if ($(app_state) == "element") {
		return html`<div style="
			padding: 3px 16px;
			background-color: #eee;
			border-radius: 5px;
		">Here is an HTML element for you</div>`
	} else if ($(app_state) == "value") {
		return "Here is a value for ya!"
	} else if ($(app_state) == "error") {
		throw new Error("Here is an error for you :O")
	}
}"""

# ╔═╡ a60606d9-6bf6-41db-a716-723f1e9e5c48
derived_from_async = @javascript """
	html`
		<article>
			<b>\${$js_async.title}</b>
			<p>\${$js_async.completed ? "Complete" : "Not Complete"}</p>
		</article>
	`
"""

# ╔═╡ e0218257-3f8b-4bf4-88bb-8550045dfcb5
derived_from_syntax_error = @javascript "$(js_syntax_error)"

# ╔═╡ 65be5d23-b64d-4f3f-85b5-44d588dbb435
bond = @bind state State("my_number", Dict(
	:be_enabled => true,
	:period_column => "",
	:sequence_column => "",
))

# ╔═╡ 929f8963-aefa-4830-a3cf-cd3deae1dc8c
state

# ╔═╡ 4c0303b3-dc4f-4514-9c6e-bc70ae368f8b
@javascript """{
	let input = html`<input
		type="text"
		style="width: 100%; font-size: inherit; font-family: inherit;"
	/>`
	let bond = $bond
	// Show and keep in sync with the bond balue
	input.value = JSON.stringify(bond.value)
	bond.addEventListener('change', () => {
		input.value = JSON.stringify(bond.value)
	})
	// Set state when input is mutated
	input.addEventListener('input', () => {
		try {
			let valid_json = JSON.parse(input.value)
			bond.value = valid_json
			bond.dispatchEvent(new Event('input'))
		} catch (error) {}
	})
	return input
}"""

# ╔═╡ cb636a28-9cac-43b4-af0f-3fada70f1fea
React = @javascript "$react_require_prod('react')"

# ╔═╡ 6620a98d-0e99-4a68-9295-61c4cbc4a55d
useStateElement = @javascript """(element) => {
	let [value, set_value] = $(React).useState(element.value)
	$(React).useEffect(() => {
		let handle = () => {
			set_value(element.value)
		}
		element.addEventListener('change', handle)
		return () => element.removeEventListener('change', handle)
	}, [element, set_value])
	return [value, (new_value) => {
		set_value(new_value)
		element.value = new_value
		element.dispatchEvent(new Event('input'))
	}]
}"""

# ╔═╡ ded9dcbb-c4e1-4ac3-9c96-c3d19360251d
ReactDOM = @javascript "$react_require_prod('react-dom')"

# ╔═╡ 74940fe8-30a4-4cca-9922-b51bc622b141
jsx = @javascript """
(await require("htm@3/dist/htm.umd.js")).bind($React.createElement)
"""

# ╔═╡ 81b419fc-7a25-42b2-a65f-043f61b5cbc5
BioequivalenceConfig = @javascript """({ element, columns }) => {
	let [value, set_value] = $useStateElement(element)
	
	return $jsx`<div style=\${{ display: 'flex', flexDirection: 'column' }}>
		<div>
			<b>BE Enabled</b>
			<input
				type="checkbox"
				checked=\${value.be_enabled}
				onChange=\${(e) => {
					set_value({
						...value,
						be_enabled: e.target.checked,
					})
				}}
			/>
		</div>
		<select
			placeholder="Period Columns"
			type="text"
			value=\${value.period_column}
			onChange=\${(e) => {
				set_value({
					...value,
					period_column: e.target.value,
				})
			}}
		>
			<option value="">Select Column</option>
			\${columns.map((column) => $jsx`
				<option key=\${column} value=\${column}>\${column}</options>
			`)}
		</select>
	</div>`
}"""

# ╔═╡ 6d2b689d-8d56-4886-99fe-a95372ed0192
render = @javascript """(container, element) => {
  if (element == null) {
    element = container;
    container = null;
  }
  // Used to check specifically for `container == null`, but turns out
  // that doesn't work nicely always with Observable.
  if (!container) {
    container = html`<div class="react-root" style="display: contents"></div>`;
	// TODO Do some stuff to make this work as a input?
	// Maybe even await the Suspense somehow? Would be cool.
  }
  element = typeof element === 'function' ? $jsx`<\${element} />` : element;
  $ReactDOM.render(
    $jsx`
      <\${$React.Suspense} fallback=\${$jsx`<div />`}>
        \${element}
      </\${$React.Suspense}>
    `,
    container
  );
  return container;
}"""

# ╔═╡ 0adb6d8c-d400-4fa0-93f0-e8dad097c4f0
@javascript """{
	return $render($jsx`
		<\${$BioequivalenceConfig}
			element=\${$bond}
			columns=\${$columns}
		/>
	`)
}"""

# ╔═╡ 8afd3e48-c655-4b02-9c92-92eed0efe9a2
@bind x State("hey", "")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
JSON3 = "~1.9.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "e13a411f59a3f9ad25378b25a40ea08c2ded02e7"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "e36adc471280e8b346ea24c5c87ba0571204be7a"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.7.2"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╟─94e75fdf-de64-4150-b154-909b0b8c48b1
# ╠═2cd025ca-c646-4ad2-88ed-7bb3a8eb4c5f
# ╟─9e5078da-50dd-4fe8-a639-b8170605f64e
# ╠═ca0ebf01-e620-4029-a583-376859de7384
# ╠═3ea4d132-2d69-497e-a1d9-71bdb1ca9ac5
# ╠═1b3d8ce9-0b9d-4f02-8e2c-2c5a4d560a3b
# ╠═7b23a041-bbe7-4e47-a264-0db20366422a
# ╠═4fee059b-b327-463b-ba4b-1c495a899ae4
# ╠═4ffd15b8-55fc-4840-ac6d-427c08b6810d
# ╠═d9420313-31d0-4785-a9f8-32e71b0edcdb
# ╟─26239200-e1dc-40f5-94d2-608108229768
# ╠═f4af25a0-8003-4b0a-9ea0-a37a4017d8f6
# ╠═9b682047-6561-447d-8a3e-6b63bb6bd69a
# ╟─dff95b2e-06af-4904-9984-d389d7b0e0ce
# ╠═28636b0c-fe8a-487a-8667-3415dfe2342e
# ╠═7017c598-641a-4958-84be-09cd6de58d2b
# ╠═0ee7c824-4230-4f2e-b51d-97e2fd990efa
# ╠═7a734e9c-341f-46d9-91a5-1f99d1ba2432
# ╠═c3631b64-f558-4f52-a3a0-6fd020d411b3
# ╟─1358d748-fa55-428f-8dd3-b401cca323ef
# ╠═ec8f2ae7-f5d4-40c8-af46-d102a56bace0
# ╠═90f81a53-aff3-464d-b30a-1b641eedbba9
# ╟─25d7af20-3b31-4c7e-89d7-8470a55ae759
# ╠═b7b8d9f4-48e7-4444-8388-8c670fb37458
# ╠═a60606d9-6bf6-41db-a716-723f1e9e5c48
# ╟─5360f727-4eb9-4f4f-9694-4148743c6755
# ╠═47f01cfa-9ace-4762-a27d-9b724aa63f70
# ╠═e0218257-3f8b-4bf4-88bb-8550045dfcb5
# ╟─fe0d0426-cdaa-43dd-be06-0d5667f1af14
# ╠═6620a98d-0e99-4a68-9295-61c4cbc4a55d
# ╟─8ed3f97d-7360-468f-a457-362b38ca505c
# ╠═81b419fc-7a25-42b2-a65f-043f61b5cbc5
# ╠═65be5d23-b64d-4f3f-85b5-44d588dbb435
# ╠═929f8963-aefa-4830-a3cf-cd3deae1dc8c
# ╠═0adb6d8c-d400-4fa0-93f0-e8dad097c4f0
# ╟─4989de20-2e6b-4d17-8f20-0a4c9b704c3b
# ╠═4c0303b3-dc4f-4514-9c6e-bc70ae368f8b
# ╟─43926f68-7a28-48c8-8cdf-6fcac6e94b63
# ╠═4d15edb4-f5a2-4766-85ce-96a1519f4a83
# ╠═969af4f8-22cf-4c48-b282-d7cad9627ed9
# ╟─66bb4876-9db3-4061-aa4c-251e67cfb6c8
# ╠═11de0697-362e-41e9-a443-83cb6bc56b47
# ╠═56eb5717-cc0f-4ba8-970a-878ce0f0310b
# ╠═511ad5a6-f913-43de-b73c-d0b91d70aa85
# ╠═dfc22d15-4dc2-49a5-8153-7b09fe9117a2
# ╠═f3e4cce5-ead1-4644-908a-ef5cf2ee3986
# ╠═3da48b70-6f5a-440b-84c7-167aae2b7ac9
# ╠═3dc4c309-e8b4-4265-b325-7fa3ebc2ac40
# ╟─eeae3d5a-adcd-4641-adea-2c39b92ea26f
# ╟─e4d22957-7020-42bd-8a1f-162c3757502f
# ╟─d7c12348-0aa2-44c4-81c3-87ebcd1779ee
# ╠═ad490316-621c-44e4-8644-7caec7d72f28
# ╠═10255d34-fcf2-4fb6-9e10-e32eb9df7dd6
# ╟─d02097f4-8fb9-452e-8862-dcb4dc20b090
# ╟─ef202964-5ed9-49ff-a749-c3aa91799f3e
# ╠═c1ab37f5-5bcd-4f86-b986-900ebde9e4b1
# ╠═cb636a28-9cac-43b4-af0f-3fada70f1fea
# ╠═ded9dcbb-c4e1-4ac3-9c96-c3d19360251d
# ╟─74940fe8-30a4-4cca-9922-b51bc622b141
# ╠═6d2b689d-8d56-4886-99fe-a95372ed0192
# ╟─3353d69f-45ff-4d46-88c2-924e3ee6b5d7
# ╟─c5b75129-fd6c-44f3-aeee-fa366e0839dc
# ╟─186079ef-487e-4065-a546-e775c7ee45ba
# ╠═8afd3e48-c655-4b02-9c92-92eed0efe9a2
# ╟─812212dd-71e9-4789-9f99-de8d7107626d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
