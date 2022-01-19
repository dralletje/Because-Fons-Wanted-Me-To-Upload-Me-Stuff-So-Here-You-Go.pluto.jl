### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ e55ea6f0-4323-11ec-1084-1d4d52a1a43d
"""
    regex_escape(s::AbstractString)
Sanitize a string to make it safe for use in regular expression pattern construction. Any
regular expression metacharacters are escaped along with whitespace.
# Examples
```jldoctest
julia> regex_escape("Bang!")
"Bang\\!"
julia> regex_escape("  ( [ { . ? *")
"\\ \\ \\(\\ \\[\\ \\{\\ \\.\\ \\?\\ \\*"
julia> regex_escape("/^[a-z0-9_-]{3,16}\$/")
"/\\^\\[a\\-z0\\-9_\\-\\]\\{3,16\\}\\\$/"
```
"""
function regex_escape(s::AbstractString)
    res = replace(s, r"([()[\]{}?*+\-|^\$\\.&~#\s=!<>|:])" => s"\\\1")
    replace(res, "\0" => "\\0")
end

# ╔═╡ de84fde6-d96d-46b0-9bb0-d757ee3801a2
function interpolate_regex(str::AbstractString)
	regex_escape(str)
end

# ╔═╡ 2d80e96b-f0e5-4ad9-8598-aec107f91289


# ╔═╡ f745d6e8-777b-445b-9eb6-0e96d63b6256
function interpolate_regex(regex::Regex)
	regex.pattern
end

# ╔═╡ 5dbe703b-edd8-44e8-9f7c-7420f631a5f0
macro regex(str)
	if str isa String
		return var"@regex"(__source__, __module__, Expr(:string, str))
	end

	parts = []
	for part in str.args
		if part isa String
			push!(parts, part)
		else
			push!(parts, :(interpolate_regex($(esc(part)))))
		end
	end
	:(Regex($(Expr(:string, parts...))))
end

# ╔═╡ 456e25b8-fce3-471c-bdc2-7069cd3580f3
1 + 1 + 1 + 1

# ╔═╡ e0b844d7-de3e-4027-8622-3a7e2a0ecf9a
bb = "asd"

# ╔═╡ 19bb530f-1f8f-4971-8a38-5a9b583af14d
r = @regex "aa $(bb)"

# ╔═╡ cace33e5-7d9b-4508-9df5-aa415524cf22
@regex "aa$(bb)c\\wc"

# ╔═╡ f5c71333-c1cb-499a-9b34-ad59defb5c69
@regex "aabb"

# ╔═╡ cd52f2cf-3f42-4d1e-80a7-575dadaa0453
sprint(dump, :("aa$(bb)cc")) |> Text

# ╔═╡ Cell order:
# ╟─e55ea6f0-4323-11ec-1084-1d4d52a1a43d
# ╠═de84fde6-d96d-46b0-9bb0-d757ee3801a2
# ╠═2d80e96b-f0e5-4ad9-8598-aec107f91289
# ╠═f745d6e8-777b-445b-9eb6-0e96d63b6256
# ╠═5dbe703b-edd8-44e8-9f7c-7420f631a5f0
# ╠═456e25b8-fce3-471c-bdc2-7069cd3580f3
# ╠═e0b844d7-de3e-4027-8622-3a7e2a0ecf9a
# ╠═19bb530f-1f8f-4971-8a38-5a9b583af14d
# ╠═cace33e5-7d9b-4508-9df5-aa415524cf22
# ╠═f5c71333-c1cb-499a-9b34-ad59defb5c69
# ╠═cd52f2cf-3f42-4d1e-80a7-575dadaa0453
