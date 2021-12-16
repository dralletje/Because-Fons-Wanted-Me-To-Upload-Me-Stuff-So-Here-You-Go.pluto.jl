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

# ╔═╡ 12646b76-c509-4176-af9c-ba1820c9c410
all_component_modules = [
	"accordion",
	"breadcrumb",
	"button",
	"checkbox",
	"code-snippet",
	"combo-box",
	"content-switcher",
	"copy-button",
	"data-table",
	"date-picker",
	"dropdown",
	"file-uploader",
	"floating-menu",
	"form",
	"inline-loading",
	"input",
	"link",
	"list",
	"loading",
	"modal",
	"multi-select",
	"notification",
	"number-input",
	"overflow-menu",
	"pagination",
	"progress-indicator",
	"radio-button",
	"search",
	"select",
	"skeleton-placeholder",
	"skeleton-text",
	"skip-to-content",
	"slider",
	"structured-list",
	"tabs",
	"tag",
	"textarea",
	"tile",
	"toggle",
	"tooltip",
	"ui-shell",
]

# ╔═╡ 3a732a7a-32df-4442-90ae-ab95829512c7
html"""<div style="height: 100px"></div>"""

# ╔═╡ bb7f433c-ae3f-4781-9ebe-413dbe9e2e8d
html"""<div style="height: 100px"></div>"""

# ╔═╡ 5333a52d-9270-44fb-9061-d7a4f1010fb1
html"""<div style="height: 100px"></div>"""

# ╔═╡ 236f034f-5ce3-47e9-8e72-15286c7d90ab
html"""<div style="height: 100px">"""

# ╔═╡ 0cfdff2d-72d7-46ec-94ff-24a71b36a489
html"""<div style="height: 100px">"""

# ╔═╡ 0157bc6d-d239-40fc-a37d-7b07908d4cf9
html"""<div style="height: 100px">"""

# ╔═╡ ca0c9b92-fcc5-4f47-a808-5f85e8bb6009
html"""<div style="height: 100px">"""

# ╔═╡ 59e507ca-60ca-423c-84ee-898482ba2508


# ╔═╡ 31070cd5-a38f-414f-88c4-c9b41fcb3013
struct WebComponentValue

end

# ╔═╡ e4a6d6aa-3ba1-4451-8069-72b472f58149
struct WebComponentType
	values::Dict{Symbol,Any}
end

# ╔═╡ 65642e4d-2508-44f7-9122-c679a22b0c07
function Base.getproperty(types::WebComponentType, property::Symbol)
	values = getfield(types, :values)
	@assert haskey(values, property) """
		Value $(property) not found on WebComponents
	"""
	return values[property]
end

# ╔═╡ 56c7bfbf-c6f7-498d-8689-d4c24ed2e5ef
INPUT_SIZE = WebComponentType(Dict(
	:small => :sm,
	:regular => :lg,
	:large => :lg,
	:extra_large => :xl
))

# ╔═╡ 7543283f-6f61-408c-a14d-87e1a10ab13e
begin
	struct X
	
	end
	function X()

	end
end

# ╔═╡ f416dceb-eff0-4595-993c-d5bbc4ff0eef
X.asd

# ╔═╡ fc73aba3-47ac-4094-a47a-18af2a50e543
INPUT_SIZE.small

# ╔═╡ 16ac91e4-8030-471a-b1ce-16110d6b5d65
function type_to_julia(type_name)
	if type_name == :boolean
		Bool
	elseif type_name == :number
		Number
	elseif type_name == :string
		String
	else
		Any
	end
end

# ╔═╡ f89d1714-1dae-4a46-99b5-52d87d2e8616
md"# Appendix"

# ╔═╡ f54ad4c7-eb54-4f4a-8580-73520410bcba
import Downloads

# ╔═╡ 652334c7-c91e-4918-b061-4e8fc684c5ad
custom_elements_json = sprint() do io
	Downloads.request(
		"https://unpkg.com/carbon-web-components@1.18.0/custom-elements.json",
		output=io
	)
end;

# ╔═╡ 50baae26-50a3-4aab-8279-e185bdf2871f
import JSON3

# ╔═╡ 4c9fcd46-51a7-4487-90dc-30c2fad8fd75
import StructTypes

# ╔═╡ 7fcc8e05-7e62-488d-be48-35687c79159e
import PlutoUI

# ╔═╡ 0b11dd72-4542-4f9d-85f9-8c7d29d0a155
import AbstractPlutoDingetjes: Bonds

# ╔═╡ b1991783-ed72-457e-a82c-4144f6cad506
import HypertextLiteral: @htl

# ╔═╡ 07ae7def-a666-4135-8071-bdafd37bd34a
# Hide (;) this to make sure we don't get the script from here accidentally
carbon_component_script_tags_rtl = map(all_component_modules) do filename
	@htl("""
	<script type="module" src="https://unpkg.com/carbon-web-components@1.18.0/dist/$(filename).rtl.min.js"></script>
	""")
end;

# ╔═╡ af0c392c-1701-48ee-ad85-c8e9b70be35f
# Hide (;) this to make sure we don't get the script from here accidentally
carbon_component_script_tags = map(all_component_modules) do filename
	@htl("""
	<script type="module" src="https://unpkg.com/carbon-web-components@1.18.0/dist/$(filename).min.js"></script>
	""")
end;

# ╔═╡ 45ca76f5-c0e9-4ae5-aa90-8c01f47d797b
# module HTLWrapper include("../HypertextLiteral.jl/src/HypertextLiteral.jl") end

# ╔═╡ 5020de04-a1da-4c86-91d9-5a22c626851b
# import .HTLWrapper.HypertextLiteral: @htl

# ╔═╡ db50e990-6ae5-4153-8fc1-277bbb0012b9
md"## Experimentation with input collections"

# ╔═╡ 25a10b4d-c242-4f34-9381-ed77d2016d61
function Form(html_element)
	@htl """
	<form>
		$(html_element)
	</form>
	<script>
	const form = currentScript.parentNode.querySelector('form');
	const elements = form.querySelectorAll("[name]")

	form.value = {}
	
	let update_value = () => {
		for (let element of elements) {
			let name = element.getAttribute('name')
			let value = element.value ?? element.checked
			if (form.value[name] !== value) {
				form.value[name] = value
			}
		}
		form.dispatchEvent(new CustomEvent('input'))
	}

	for (let element of elements) {
		element.addEventListener('input', () => {
			update_value()
		})
	}
	
	update_value()
	</script>
	"""
end

# ╔═╡ 8efdc229-a5a2-477e-8062-5f19cae6f15b
function ValueOnBlur(element)
	@htl """
	<form>
		$(element)
	</form>
	<script>
	const form = currentScript.parentElement.querySelector('form');
	const element = form.querySelector(":scope > *:not(script, style)")

	let update_value = () => {
		const value = element.value
		if (form.value !== value) {
			form.value = value
			form.dispatchEvent(new CustomEvent('input'))
		}
	}

	form.addEventListener('mouseup', () => {
		update_value()
	});
	form.addEventListener('focusout', () => {
		update_value()
	});

	update_value()
	</script>
	"""
end

# ╔═╡ b588be88-712e-4aac-be57-d392e49772e2
function FormDataOnBlur(element)
	@htl """
	<form>
		$(element)
	</form>
	<script>
	const form = currentScript.parentElement.querySelector('form');
	const element = form.querySelector(":scope > *:not(script, style)")

	const name = element.name ?? "default"
	element.name = name

	let update_value = () => {
		const formData = new FormData(form);
		const value = formData.get(name)
		if (form.value !== value) {
			form.value = value
			form.dispatchEvent(new CustomEvent('input'))
		}
	}

	form.addEventListener('mouseup', () => {
		update_value()
	});
	form.addEventListener('focusout', () => {
		update_value()
	});

	update_value()
	</script>
	"""
end

# ╔═╡ 3160b6ff-8498-4be3-a721-6ca27b68e57e
function AsClickCounter(element)
	@htl """
	<dral-as-counter>
		<template shadowroot=open>
			<slot id="clickable"></slot>
			<script>
				let root = currentScript.getRootNode()
				let element = root.querySelector('#clickable')
				root.host.value = 0

				element.addEventListener('click', (event) => {
					event.preventDefault()
					root.host.value = root.host.value + 1
					root.host.dispatchEvent(new CustomEvent('input'))
				})
			</script>
		</template>
		$element
	</dral-as-counter>
	"""
end

# ╔═╡ 6e045783-daa8-49ce-a20d-94a3603fb51b
md"## Universal Widget"

# ╔═╡ d3dcea53-62e7-4fc0-8308-9c5d95d4e37b
begin
	Base.@kwdef struct Widget
		element
		with_default=missing
		transform_value=(x -> x)
	end
	function Widget(transform_value_fn::Function, element; with_default=missing)
		Widget(
			element=element,
			transform_value=transform_value_fn,
			with_default=with_default,
		)
	end
	function Widget(element; with_default=missing, transform_value=(x -> x))
		Widget(
			element=element,
			transform_value=transform_value,
			with_default=with_default,
		)
	end
end

# ╔═╡ 85f37d25-7207-454d-87c9-c7fa8925836c
function Bonds.initial_value(widget::Widget)
	widget.with_default
end

# ╔═╡ 4bdb9643-3bae-4d7d-8681-bcbf5cb41f8b
function Bonds.transform_value(widget::Widget, value_from_javascript)
	widget.transform_value(value_from_javascript)
end

# ╔═╡ 83e45156-019c-45e5-bf94-e22415acd75d
md"## Parsing for CustomElementsManifest"

# ╔═╡ 7c7be84d-4a4b-46b2-bb75-d9b627a1a01f
Nullable{T} = Union{Nothing, T}

# ╔═╡ d00900bb-83bd-4160-bf45-5c32f4f828df
StructTypes.@Struct struct CustomElementAttribute
	name::Symbol
	default::Nullable{String}
	description::String
	type::Symbol
end

# ╔═╡ 720b52d6-708b-440e-a664-c2df55a0cca8
StructTypes.@Struct struct CustomElementProperty
	name::Symbol
	default::Nullable{String}
	description::String
	attribute::Nullable{String}
	type::Nullable{Symbol}
end

# ╔═╡ e2553069-9b9f-4f0f-b734-c478814b526e
StructTypes.@Struct struct CustomElementEvent
	name::Symbol
	description::Nullable{String}
end

# ╔═╡ 3f47037e-376f-4d80-b53f-e9c7af9b14a2
StructTypes.@Struct struct CustomElementCssPart
	name::Symbol
	description::Nullable{String}
end

# ╔═╡ f82774b1-1831-41a5-8e0c-59fa43a4c2c8
StructTypes.@Struct struct CustomElementSlot
	name::Symbol
	description::Nullable{String}
end

# ╔═╡ 58fe02fa-8480-4496-94e0-7601da2a2fc3
StructTypes.@Struct struct CustomElementDefinition
	name::String
	description::String
	attributes::Nullable{Vector{CustomElementAttribute}}
	properties::Nullable{Vector{CustomElementProperty}}
	events::Nullable{Vector{CustomElementEvent}}
	cssParts::Nullable{Vector{CustomElementCssPart}}
	slots::Nullable{Vector{CustomElementSlot}}
end

# ╔═╡ 8ce7fe26-7a44-4636-a174-d66e740ab349
StructTypes.@Struct struct CustomElementsManifest
	version::String
	tags::Vector{CustomElementDefinition}
end

# ╔═╡ 4688e841-3ffc-4c88-b737-e0570a7d694d
custom_elements_manifest = JSON3.read(custom_elements_json, CustomElementsManifest);

# ╔═╡ 84e8674a-eb1f-4ca5-948b-7721e9223ff4
tags = custom_elements_manifest.tags

# ╔═╡ b02485de-99e8-4c11-9937-a48e83a24be0
md"## Text utilities"

# ╔═╡ ab9d89c6-7387-4efb-b998-a9b5ffb688e2
function kebab_to_pascal_case(str)
	join(map(uppercasefirst, split(String(str), "-")), "")
end

# ╔═╡ b2d2adde-cbe6-48e4-8e16-39c40dac4cc8
function kebab_to_snake_case(str)
	join(split(String(str), "-"), "_")
end

# ╔═╡ bd9640a7-a11d-4ecb-bf83-b41f1e1b8a14
function snake_to_kebab_case(str)
	join(split(String(str), "_"), "-")
end

# ╔═╡ 7fe80a5a-e2a4-4eab-b6be-6a56ab3ed2eb
function Slot(; kwargs...)
	if length(kwargs) != 1
		throw(ArgumentError("Slot() takes one keyword argument"))
	end
	snake_key = keys(kwargs)[1]
	kebab_key = snake_to_kebab_case(snake_key)
	value = values(kwargs)[1]

	@htl("""
		<span style="display: contents" slot=$kebab_key>
			$(value)
		</span>
	""")
end

# ╔═╡ d3532d02-5663-4723-85b5-c1b760982ddb
remove_prefix(tag_name) = join(split(tag_name, "-")[begin+1:end], "-")

# ╔═╡ 409e08c9-61e8-4f2f-bc0c-36dd1e157da7
function render_carbon_component(;
	children,
	custom_element_description,
	attributes,
	slots,
	kwargs,
	rtl,
)
	tagname = custom_element_description.name
	tag_without_prefix = remove_prefix(custom_element_description.name)
	event_names = map(something(custom_element_description.events, [])) do event
		event.name
	end
					 
	@htl("""<dral-$tagname-wrapper>
		<!-- Just because I can I'm putting these scripts in a shadowroot -->
		<all-the-carbon-design-scripts>
			<template shadowroot=open>
				<!-- All possible scripts -->
				$(if rtl
					carbon_component_script_tags_rtl
				else
					carbon_component_script_tags
				end)
			</template>
		</all-the-carbon-design-scripts>
		<$(tagname) $(attributes) $(kwargs)>$([
			# This is an array literal so we don't introduce any unnecessary spaces
			children,
			map(collect(slots)) do (slot_name, element)
				slot_name_kebab = snake_to_kebab_case(slot_name)
				if element === nothing
					@htl ""
				else
					# Without any spaces inside the elementbecause a lot of stuff 
					# renders with whitespace-pre
					@htl """
					<span
						style="display: contents"
						slot=$slot_name_kebab
					>$element</span>
					"""
				end
			end,
		])</$(tagname)>
		<script>
			let element = currentScript.previousElementSibling
			let output_element = currentScript.parentNode

			if (element.hasAttribute('name')) {
				output_element.setAttribute('name', element.getAttribute('name'))
				element.removeAttribute('name')
			}

			output_element.value = element.value ?? element.checked
			let event_names = [
				...JSON.parse($(JSON3.write(event_names))),
				"input",
			]
			for (let event_name of event_names) {
				element.addEventListener(event_name, (event) => {
					let value = element.value ?? element.checked
					if (output_element.value !== value) {
						output_element.value = value
						output_element.dispatchEvent(new CustomEvent("input"))
					}
				})
			}
		</script>
	</dral-$tagname-wrapper>""")

end

# ╔═╡ b858f295-fd7e-4234-a11f-cfb3cf92adf5
indent(str; with="    ") = with * join(split(str, "\n"), "\n" * with)

# ╔═╡ 3ec70012-07fc-4a53-9d44-f1a28bca9cd9
indent(str::Nothing; with="    ") = with

# ╔═╡ 491ae155-bb07-4b9c-9119-3bdb0abe171e
function definition_to_doc(tag::CustomElementDefinition)
	fn_name = kebab_to_pascal_case(remove_prefix(tag.name))

	# For now I don't show the events...
	# as there really isn't anything you can do with them now
	# events_description = """
	# $(if !isnothing(tag.events)
	# 	"## Events"
	# else
	# 	""
	# end)
	# $(isnothing(tag.events) ? "" : join(map(tag.events) do event
	# 	"""
	# 	- ```julia
	# 	  $(kebab_to_snake_case(remove_prefix(string(event.name))))
	# 	  ```
	# 	$(indent(event.description, with="  "))
	# 	"""
	# end, "\n\n"))
	# """
	
	"""
	```julia
	$(fn_name)(children::Union{Function,Any}; kwargs...)
	```
	
	Carbon Design $(tag.description)

	$(if !isnothing(tag.attributes)
		"## Kwargs"
	else
		""
	end)
	$(isnothing(tag.attributes) ? "" : join(map(tag.attributes) do attribute
		
		
		type_str = if type_to_julia(attribute.type) == Any
			""
		else
			"::$(type_to_julia(attribute.type))"
		end
	
		"""
		- ```julia
		  $(kebab_to_snake_case(attribute.name))$(type_str) = $(attribute.default)
		  ```
		$(indent(attribute.description, with="  "))
		"""
	end, "\n\n"))

	

	$(if !isnothing(tag.slots)
		first_slot_name = tag.slots[begin].name
		"""
		## Slots

		Slots are also passed in as keyword arguments,
		but can be anything that can render to html
		(`html""`, `md""`, `@htl`, or another Carbon Design component).
		For example:

		```julia
		fn_name($first_slot_name=html"<b>Generic Text<sup>1</sup></b>")
		```

		They can also _just_ be text if you don't need any fancyness.
		"""
	else
		""
	end)
	$(isnothing(tag.slots) ? "" : join(map(tag.slots) do slot
		"""
		- ```julia
		  $(kebab_to_snake_case(slot.name))
		  ```
		$(indent(slot.description, with="  "))
		"""
	end, "\n\n"))

	This was automatically generated from the Carbon Design Web Components manifest.
	"""
end

# ╔═╡ e1c51a4b-5ed8-4371-b02a-8d8dc9499721
macro functionify(tag_expr)
	var"render_carbon_component"
	
	tag = Core.eval(__module__, tag_expr)
	
	tag_without_prefix = remove_prefix(tag.name)
	fn_name = Symbol(kebab_to_pascal_case(tag_without_prefix))

	attributes = something(tag.attributes, [])
	slots = something(tag.slots, [])
	# slots_that_are_also_attributes = filter(something(tag.slots, [])) do slot
	# 	matching_attribute = findfirst(attributes) do attribute
	# 		attribute.name == slot.name
	# 	end
	# 	return !isnothing(matching_attribute)
	# end

	attributes_that_arent_also_slots = filter(attributes) do attribute
		isnothing(findfirst(slots) do slot
			slot.name == attribute.name
		end)
	end
	
	attribute_keywords = map(attributes_that_arent_also_slots) do attribute
		attribute_name = Symbol(kebab_to_snake_case(attribute.name))
			
		Type = type_to_julia(attribute.type)

		Expr(:kw, :($(attribute_name)::$(Union{Nothing,Type})), nothing)
	end
	attribute_pairs = map(attributes_that_arent_also_slots) do attribute
		attribute_name = Symbol(kebab_to_snake_case(attribute.name))
		:($(QuoteNode(attribute_name)) => $(attribute_name))
	end

	slot_keywords = map(slots) do slot
		slot_name = Symbol(kebab_to_snake_case(slot.name))

		Expr(:kw, slot_name, nothing)
	end
	@info "slot_keywords" slot_keywords
	slot_pairs = map(slots) do slot
		slot_name = Symbol(kebab_to_snake_case(slot.name))
		:($(QuoteNode(slot_name)) => $(slot_name))
	end
	
	quote
		function $(esc(fn_name))(
			children...;
			rtl=false,
			$(attribute_keywords...),
			$(slot_keywords...),
			kwargs...,
		)
			attributes = Dict($(attribute_pairs...))
			slots = Dict($(slot_pairs...))
			render_carbon_component(
				children=children,
				rtl=rtl,
				custom_element_description=$(tag),
				attributes=attributes,
				slots=slots,
				kwargs=kwargs,
			)
		end
		
		@doc $(definition_to_doc(tag)) $(fn_name)

		export $(fn_name)
	end
end

# ╔═╡ d9202fa0-e183-4c75-b81e-66a34def8993
macro functionify_all(expr)
	var"@functionify"
	
	tags = Core.eval(__module__, expr)
	quote
		$((map(tags) do tag
			esc(:(@functionify $(tag)))
		end)...)
	end
end

# ╔═╡ 0cd36ece-d9de-473a-9dd8-05449f27b444
module CarbonDesign
	import ..@functionify_all
	import ..@functionify
	import ..tags

	@functionify_all(tags)
end

# ╔═╡ e9ec2b6b-3499-4bdc-b110-51779a5557c0
@bind selected_tag Widget(
	CarbonDesign.ComboBox(
		value=tags[1].name,
		map(tags) do tag
			CarbonDesign.ComboBoxItem(
				"$(tag.name)$(isnothing(tag.slots) ? "" : "*")",
				value=tag.name,
			)
		end
	),
	with_default=tags[1],
) do name
	for tag in tags
		if tag.name == name
			return tag
		end
	end
end

# ╔═╡ 985037e8-7884-4143-94e7-abeb28ee81b1
@htl """
$(md"---")

$(Markdown.parse(definition_to_doc(selected_tag)))
"""

# ╔═╡ a4caf210-b253-407d-9c6f-bbd8d4b471d7
@bind counter_button AsClickCounter(
	CarbonDesign.Btn("Hey"; size="sm", kind=:primary)
)

# ╔═╡ d524c82d-e60c-4c37-9aa8-0775daecce2f
counter_button

# ╔═╡ 04dda1b6-d72a-493a-bd51-623de20731b6
@bind carbon_slider CarbonDesign.Slider([
	CarbonDesign.SliderInput()
])

# ╔═╡ 9b96be63-6734-4578-bbc5-e6bde683188f
carbon_slider

# ╔═╡ 46b7e24d-164d-423f-8564-030a62f6efe1
@bind combined_form Form(@htl("""
	$(CarbonDesign.Checkbox(
		name="on",
		label_text="Checkbox!"
	))

	$(CarbonDesign.ComboBox(name="combox", [
		CarbonDesign.ComboBoxItem("Just one option", value="🤷‍♀️")
	]))
"""))

# ╔═╡ 76282f3d-cee3-4714-b9c5-437d15437f51
combined_form

# ╔═╡ dfea5773-a19b-4c4f-91c9-6da48558df8e
@bind combobox Widget(with_default="", CarbonDesign.ComboBox([
	CarbonDesign.ComboBoxItem("Best Animal", value="Red Panda"),
	CarbonDesign.ComboBoxItem("Worst Animal", value="Naked Snail"),
	CarbonDesign.ComboBoxItem("No Opinion", value="Dog"),
]))

# ╔═╡ 238cfebe-92ce-49ce-a8d5-06c6997a1875
combobox

# ╔═╡ f72f4fa4-63ca-40e4-a9df-b5859a531f04
@bind value Widget(
	CarbonDesign.Textarea(
		label_text=md"## Hi",
		helper_text="Some help text",
		placeholder="Ohhhhh"
	),
	with_default="",
)

# ╔═╡ 74c06980-a083-4a39-a33e-43ec70d790c1
value

# ╔═╡ 0e8124da-aa1e-4b73-99da-8421c667fdbc
@bind combined_values Form(@htl("""<div>
	$(CarbonDesign.Checkbox(name="x", label_text="Hey"))

	$(CarbonDesign.ComboBox(name="z", [
		CarbonDesign.ComboBoxItem("The Netherlands", value="#1")
		CarbonDesign.ComboBoxItem("United States of America", value="#2")
		CarbonDesign.ComboBoxItem("Denmark", value="#3")
	]))
</div>"""))

# ╔═╡ 81ee28ab-55cb-4c6e-864f-fdf357405efd
combined_values

# ╔═╡ b0facaf1-6430-4881-8047-508094f03bc4
all_uppercase_regex = r"^[A-Z_]+$"

# ╔═╡ 78b5baa0-591b-4898-a276-df0107b0cde8
attribute_types = let
	types = Set{Symbol}()

	for tag in tags
		if !isnothing(tag.attributes)
			for attribute in tag.attributes
				if occursin(all_uppercase_regex, String(attribute.type))
					push!(types, attribute.type)
				end
			end
		end
	end

	types
end

# ╔═╡ c9ea040f-7c0c-42d2-8cde-9e0df02c20f0
md"## All of this, just to pretty print code"

# ╔═╡ 1cc20977-30eb-4c80-97d0-737e52beb5be
struct EscapeExpr
	expr
end

# ╔═╡ e13d531e-96fb-4d00-a69f-96381d99331b
function Base.show(io::IO, val::EscapeExpr)
	print(io, "\$(esc(")
	print(io, val.expr)
	print(io, "))")
end

# ╔═╡ 4881e3fb-d8a8-4b95-aaee-7d638679f69c
function Base.show(io::IO, ::MIME"text/html", widget::Widget)
	element = widget.element isa Function ? widget.element() : widget.element
	Base.show(io, MIME("text/html"), widget.element)
end

# ╔═╡ b4462aab-a781-42ca-bdb9-cd8ef29e4fb9
move_escape_calls_up(e::Expr) = begin
	
	args = move_escape_calls_up.(e.args)
	if all(x -> Meta.isexpr(x, :escape, 1), args)
		Expr(:escape, Expr(e.head, (arg.args[1] for arg in args)...))
	else
		Expr(e.head, args...)
	end
end

# ╔═╡ 93cd60d2-ac30-4612-878f-f21ecf2e252a
move_escape_calls_up(x) = x

# ╔═╡ a44ef63a-7d8c-4a01-8371-0394330b8f96
escape_syntax_to_esc_call(e::Expr) = if e.head === :escape
	EscapeExpr(e.args[1])
else
	Expr(e.head, (escape_syntax_to_esc_call(x) for x in e.args)...)
end

# ╔═╡ 03991328-6382-48b3-882a-9e8cb3eca597
escape_syntax_to_esc_call(x) = x

# ╔═╡ 0cf337f1-b973-4dc3-85fc-ba195a390811
remove_linenums(e::Expr) = if e.head === :macrocall
	Expr(
		e.head,
		(
			x isa LineNumberNode ?
			LineNumberNode(0, nothing) :
			remove_linenums(x)
			for x
			in e.args
		)...,
	)
else
	Expr(e.head, (remove_linenums(x) for x in e.args if !(x isa LineNumberNode))...)
end

# ╔═╡ d55d67e6-5a26-4a35-ba76-e819e0444a68
remove_linenums(x) = x

# ╔═╡ 997343b6-4271-4c7f-a6e4-a99652129bcf
expr_to_str(e, mod=@__MODULE__()) = let	
	printed = sprint() do io
		Base.print(IOContext(io, :module => @__MODULE__), escape_syntax_to_esc_call(move_escape_calls_up(remove_linenums(e))))
	end
	replace(printed, r"#= line 0 =# ?" => "")
end

# ╔═╡ 261972bc-eaec-43f1-85f3-9938d6db418e
prettycolors(e) = @htl("""<code-without-background>
	<style>
	code-without-background pre {
		padding: 0 !important;
	}
	code-without-background * {
		background: none !important;
	}
	</style>
	$(Markdown.MD([Markdown.Code("julia", expr_to_str(e))]))
</code-without-background>""")

# ╔═╡ 9bfea876-2ff7-4888-b91c-e62b16cf516e
md"## Totally unrelated idx-style macro"

# ╔═╡ f9737ee6-92cf-45a0-b464-8c3f9ae6d49a
maybe_getproperty(::Nothing, ::Any) = nothing

# ╔═╡ f3577e55-732a-4381-9be3-ddf04c46278b
maybe_getproperty(obj, sym) = getproperty(obj, sym)

# ╔═╡ 14844df2-5e1c-4cda-bab7-fee55498a823
maybe_getindex(::Nothing, ::Any) = nothing

# ╔═╡ 718fa267-36f4-4438-b8ef-c50791b44738
maybe_getindex(obj, index) = getindex(obj, index)

# ╔═╡ da38a6b6-de61-4462-af0d-cd91bbe7d043
function map_escape(fn, expr)
	if Meta.isexpr(expr, :escape, 1)
		esc(fn(expr.args[1]))
	else
		fn(expr)
	end
end

# ╔═╡ 7e16ad2a-31ff-45d0-99a6-ea8e80de171b
macro get(expr)
	map_escape(expr) do expr
		if expr isa Expr
			result = if expr.head == :.
				:(maybe_getproperty(
					@get($(esc(expr.args[1]))),
					$(esc(expr.args[2])),
				))
			elseif expr.head == :ref
				:(maybe_getindex(
					@get($(esc(expr.args[1]))),
					$(esc(expr.args[2])),
				))
			else
				esc(expr)
			end
		else
			esc(expr)
		end
	end
end

# ╔═╡ 116533f5-e6e5-4a87-8a7b-cf8c5f5d6647
macro get(exprs...)
	:(something(
		$(map(exprs) do expr
			:(@get($(esc(expr))))
		end...),
	))
end

# ╔═╡ fc747271-0244-4bf5-9caf-23e417a2b329
get_with_get_macro_example = let x = nothing
	@get(x.y[1], [])
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractPlutoDingetjes = "6e696c72-6542-2067-7265-42206c756150"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[compat]
AbstractPlutoDingetjes = "~1.1.0"
HypertextLiteral = "~0.9.2"
JSON3 = "~1.9.2"
PlutoUI = "~0.7.18"
StructTypes = "~1.8.1"
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
# ╠═652334c7-c91e-4918-b061-4e8fc684c5ad
# ╟─12646b76-c509-4176-af9c-ba1820c9c410
# ╠═4688e841-3ffc-4c88-b737-e0570a7d694d
# ╠═84e8674a-eb1f-4ca5-948b-7721e9223ff4
# ╟─78b5baa0-591b-4898-a276-df0107b0cde8
# ╟─3a732a7a-32df-4442-90ae-ab95829512c7
# ╠═e9ec2b6b-3499-4bdc-b110-51779a5557c0
# ╟─985037e8-7884-4143-94e7-abeb28ee81b1
# ╟─bb7f433c-ae3f-4781-9ebe-413dbe9e2e8d
# ╠═a4caf210-b253-407d-9c6f-bbd8d4b471d7
# ╠═d524c82d-e60c-4c37-9aa8-0775daecce2f
# ╟─5333a52d-9270-44fb-9061-d7a4f1010fb1
# ╠═04dda1b6-d72a-493a-bd51-623de20731b6
# ╠═9b96be63-6734-4578-bbc5-e6bde683188f
# ╟─236f034f-5ce3-47e9-8e72-15286c7d90ab
# ╠═46b7e24d-164d-423f-8564-030a62f6efe1
# ╠═76282f3d-cee3-4714-b9c5-437d15437f51
# ╟─0cfdff2d-72d7-46ec-94ff-24a71b36a489
# ╠═dfea5773-a19b-4c4f-91c9-6da48558df8e
# ╠═238cfebe-92ce-49ce-a8d5-06c6997a1875
# ╟─0157bc6d-d239-40fc-a37d-7b07908d4cf9
# ╠═f72f4fa4-63ca-40e4-a9df-b5859a531f04
# ╠═74c06980-a083-4a39-a33e-43ec70d790c1
# ╟─ca0c9b92-fcc5-4f47-a808-5f85e8bb6009
# ╠═0cd36ece-d9de-473a-9dd8-05449f27b444
# ╟─07ae7def-a666-4135-8071-bdafd37bd34a
# ╟─af0c392c-1701-48ee-ad85-c8e9b70be35f
# ╟─d9202fa0-e183-4c75-b81e-66a34def8993
# ╠═491ae155-bb07-4b9c-9119-3bdb0abe171e
# ╠═59e507ca-60ca-423c-84ee-898482ba2508
# ╠═31070cd5-a38f-414f-88c4-c9b41fcb3013
# ╠═e4a6d6aa-3ba1-4451-8069-72b472f58149
# ╠═65642e4d-2508-44f7-9122-c679a22b0c07
# ╠═56c7bfbf-c6f7-498d-8689-d4c24ed2e5ef
# ╠═7543283f-6f61-408c-a14d-87e1a10ab13e
# ╠═f416dceb-eff0-4595-993c-d5bbc4ff0eef
# ╠═fc73aba3-47ac-4094-a47a-18af2a50e543
# ╟─16ac91e4-8030-471a-b1ce-16110d6b5d65
# ╠═7fe80a5a-e2a4-4eab-b6be-6a56ab3ed2eb
# ╟─409e08c9-61e8-4f2f-bc0c-36dd1e157da7
# ╠═e1c51a4b-5ed8-4371-b02a-8d8dc9499721
# ╟─f89d1714-1dae-4a46-99b5-52d87d2e8616
# ╠═f54ad4c7-eb54-4f4a-8580-73520410bcba
# ╠═50baae26-50a3-4aab-8279-e185bdf2871f
# ╠═4c9fcd46-51a7-4487-90dc-30c2fad8fd75
# ╠═7fcc8e05-7e62-488d-be48-35687c79159e
# ╠═0b11dd72-4542-4f9d-85f9-8c7d29d0a155
# ╠═b1991783-ed72-457e-a82c-4144f6cad506
# ╠═45ca76f5-c0e9-4ae5-aa90-8c01f47d797b
# ╠═5020de04-a1da-4c86-91d9-5a22c626851b
# ╟─db50e990-6ae5-4153-8fc1-277bbb0012b9
# ╟─0e8124da-aa1e-4b73-99da-8421c667fdbc
# ╠═81ee28ab-55cb-4c6e-864f-fdf357405efd
# ╟─25a10b4d-c242-4f34-9381-ed77d2016d61
# ╟─8efdc229-a5a2-477e-8062-5f19cae6f15b
# ╟─b588be88-712e-4aac-be57-d392e49772e2
# ╟─3160b6ff-8498-4be3-a721-6ca27b68e57e
# ╟─6e045783-daa8-49ce-a20d-94a3603fb51b
# ╟─d3dcea53-62e7-4fc0-8308-9c5d95d4e37b
# ╟─85f37d25-7207-454d-87c9-c7fa8925836c
# ╟─4bdb9643-3bae-4d7d-8681-bcbf5cb41f8b
# ╟─4881e3fb-d8a8-4b95-aaee-7d638679f69c
# ╟─83e45156-019c-45e5-bf94-e22415acd75d
# ╟─7c7be84d-4a4b-46b2-bb75-d9b627a1a01f
# ╟─d00900bb-83bd-4160-bf45-5c32f4f828df
# ╟─720b52d6-708b-440e-a664-c2df55a0cca8
# ╟─e2553069-9b9f-4f0f-b734-c478814b526e
# ╟─3f47037e-376f-4d80-b53f-e9c7af9b14a2
# ╟─f82774b1-1831-41a5-8e0c-59fa43a4c2c8
# ╟─58fe02fa-8480-4496-94e0-7601da2a2fc3
# ╟─8ce7fe26-7a44-4636-a174-d66e740ab349
# ╟─b02485de-99e8-4c11-9937-a48e83a24be0
# ╟─ab9d89c6-7387-4efb-b998-a9b5ffb688e2
# ╟─b2d2adde-cbe6-48e4-8e16-39c40dac4cc8
# ╟─bd9640a7-a11d-4ecb-bf83-b41f1e1b8a14
# ╟─d3532d02-5663-4723-85b5-c1b760982ddb
# ╟─b858f295-fd7e-4234-a11f-cfb3cf92adf5
# ╟─3ec70012-07fc-4a53-9d44-f1a28bca9cd9
# ╟─b0facaf1-6430-4881-8047-508094f03bc4
# ╟─c9ea040f-7c0c-42d2-8cde-9e0df02c20f0
# ╟─261972bc-eaec-43f1-85f3-9938d6db418e
# ╟─1cc20977-30eb-4c80-97d0-737e52beb5be
# ╟─e13d531e-96fb-4d00-a69f-96381d99331b
# ╟─b4462aab-a781-42ca-bdb9-cd8ef29e4fb9
# ╟─93cd60d2-ac30-4612-878f-f21ecf2e252a
# ╟─a44ef63a-7d8c-4a01-8371-0394330b8f96
# ╟─03991328-6382-48b3-882a-9e8cb3eca597
# ╟─0cf337f1-b973-4dc3-85fc-ba195a390811
# ╟─d55d67e6-5a26-4a35-ba76-e819e0444a68
# ╟─997343b6-4271-4c7f-a6e4-a99652129bcf
# ╟─9bfea876-2ff7-4888-b91c-e62b16cf516e
# ╟─f9737ee6-92cf-45a0-b464-8c3f9ae6d49a
# ╟─f3577e55-732a-4381-9be3-ddf04c46278b
# ╟─14844df2-5e1c-4cda-bab7-fee55498a823
# ╟─718fa267-36f4-4438-b8ef-c50791b44738
# ╟─da38a6b6-de61-4462-af0d-cd91bbe7d043
# ╟─7e16ad2a-31ff-45d0-99a6-ea8e80de171b
# ╟─116533f5-e6e5-4a87-8a7b-cf8c5f5d6647
# ╟─fc747271-0244-4bf5-9caf-23e417a2b329
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
