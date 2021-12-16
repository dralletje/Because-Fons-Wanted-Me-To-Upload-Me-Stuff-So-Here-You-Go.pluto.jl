### A Pluto.jl notebook ###
# v0.17.2

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

# ╔═╡ eb3ed747-69a1-4163-837a-483a07215019
@bind z html"<input type=range>"

# ╔═╡ 4a53cbae-5446-11ec-051a-ef8f9d166824
x = 10

# ╔═╡ f354ef70-1d19-4483-85f8-0b6db97fdf70
y = 60

# ╔═╡ Cell order:
# ╠═eb3ed747-69a1-4163-837a-483a07215019
# ╠═4a53cbae-5446-11ec-051a-ef8f9d166824
# ╠═f354ef70-1d19-4483-85f8-0b6db97fdf70
