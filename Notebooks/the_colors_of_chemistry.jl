### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ 0c3b0218-2125-447c-802d-405ffc214507
md"""
# The colors of chemistry

This notebook documents my exploration of color theory and its applications to photochemistry. It also shows off the functionality of several Julia packages: Colors.jl for color theory and colorimetry, Unitful.jl for unitful computations, and Gadfly.jl and Plots.jl for graph plotting.

> This is an version of a [(jupyter) notebook](https://jiahao.github.io/julia-blog/2014/06/09/the-colors-of-chemistry.html) by [Jiahao Chen](https://github.com/jiahao) adapted for Pluto and Julia 1.7
"""

# ╔═╡ 95461946-7890-11ec-2f39-95d40be17995
import Colors

# ╔═╡ 372cfd0f-b712-4f56-918e-46728bc0a434
cie1931_380_to_780 = Colors.cie1931_cmf_table[begin+(380-360):begin+(380-360)+400, :]

# ╔═╡ 36107461-eadc-4d2a-9081-faaa8f80f784
Colors.cie_color_match(480)

# ╔═╡ 5fda05d3-dd29-46be-855d-2781397d0354
md"""
As a final check, overlay the approximate Planckian locus with the computed one from the blackbody spectrum. Close enough, maybe?
"""

# ╔═╡ 42755cae-8b2f-462f-a14f-4657b4578336
md"""
## The chemistry of color

With all this machinery in place to process power spectra, we can start to work with some really interesting data from the field of photochemistry. Chemists have measured the spectra of light absorbed and emitted from a large variety of molecules. From this data, it is possible to compute the perceived color of a given molecule.

The spectral data come in several formats which require further processing. The light absorption properties of molecules can be reported in terms of absorbance, optical density, optical cross section, molar extinction coefficient, complex refractive index, etc., which are essentially the logarithm of a normalized transmittance, the ratio of light intensities going through a sample vs. the intensity going in.
"""

# ╔═╡ 32855b26-e855-49ad-ae38-77bdd8ec2391
abstract type Spectrum{Real} end

# ╔═╡ 3f197a16-839f-4ee8-bef1-5d212e4b17ba
struct AbsorbanceSpectrum{T<:Real} <: Spectrum{T}
    λ :: Vector{T}
    ϵ :: Vector{T} # Extinction coefficent, absorption cross-section or the like
end

# ╔═╡ c0ba17f5-a8b0-405f-a3c1-7179d654d8e3
struct TransmissionSpectrum{T<:Real} <: Spectrum{T}
    λ :: Vector{T}
    T :: Vector{T} # Transmission coefficent
end

# ╔═╡ edb50a9e-1673-449c-9555-5eb2f9018214
Base.convert(::Type{TransmissionSpectrum}, S::AbsorbanceSpectrum; cl::Real=0.0001) =
	TransmissionSpectrum(S.λ, exp10.(-S.ϵ*cl)) #Beer-Lambert Law

# ╔═╡ 5266d1f1-43bc-4882-baeb-b6159d3854b9
function Base.convert(::Type{Colors.xyY}, S::TransmissionSpectrum)
    #Calculate convolution of spectrum with XYZ color transfer functions
    color = reduce(+, [0.0; map(abs, diff(S.λ))].*S.T.*map(Colors.cie_color_match, S.λ))
    #Add in any missing parts of the spectrum (extrapolate spectrum from its endpoints)
    if (lolim=floor(minimum(S.λ))) > 380
        color += S.T[1]*reduce(+, map(Colors.cie_color_match, 380:lolim))
    end
    if (hilim=ceil(maximum(S.λ))) < 780
        color += S.T[end]*reduce(+, map(Colors.cie_color_match, hilim:780))
    end
    convert(Colors.xyY, color)
end

# ╔═╡ 2c747ea7-e5cd-43ae-8167-9dd78fd26724
function Base.convert(::Type{Colors.xyY}, S::AbsorbanceSpectrum)
	convert(Colors.xyY, convert(TransmissionSpectrum, S))
end

# ╔═╡ cbca53c4-556e-4d6a-97da-a68fb41ffa6f
#Convert XYZ to normalized xyY (with luminosity Y=1.0)
function normalize0(c::Colors.XYZ)
    d=convert(Colors.xyY, c)
    Colors.xyY(d.x, d.y, 1.0)
end

# ╔═╡ af54005b-4ca5-4a38-b6d3-43ac546d6567
import CSV

# ╔═╡ 7e2287c0-5dc2-426d-8277-861154b37d13
import DelimitedFiles

# ╔═╡ cbb08799-2967-4860-b9eb-e2232323a4b5
function parse_jcampdx(filename)
    #This supports only the uncompressed JCAMP-DX file format
    #which is essentially CSV with a header
    _rawspectrum = DelimitedFiles.readdlm(filename, ',')
	rawspectrum = Matrix{Float64}(_rawspectrum[begin+32:end-1, begin:begin+1])
    #The columns are wavelength (nm) and log10 of molar extinction coefficient (M-1 cm-1)
    AbsorbanceSpectrum(rawspectrum[:,1], exp10.(rawspectrum[:,2]))
end

# ╔═╡ 4a8f061a-e202-41cf-ab5f-0b8020aa07d1
function parse_photochemcad(filename)
	rawspectrum = DelimitedFiles.readdlm(filename, '\t', skipstart=23)
    rawspectrum = reshape(rawspectrum, (length(rawspectrum)÷2,2))
	
    # The columns are wavelength (nm) and molar extinction coefficient (M-1 cm-1)
    AbsorbanceSpectrum(
		rawspectrum[:,1],
    	max.(rawspectrum[:,2], Ref(0.0)), # truncate negative extinctions
	) 
end

# ╔═╡ 4a5da91a-dee4-423b-9995-de9368c702d9
function parse_jdx(input)
	_rawspectrum = DelimitedFiles.readdlm(input, skipstart=30)
	rawspectrum = Matrix{Float64}(_rawspectrum[begin:end-1, begin:begin+1])

	# The columns are wavelength (nm) and absorbance (arbitrary units)
	AbsorbanceSpectrum(rawspectrum[:,1], rawspectrum[:,2])
end

# ╔═╡ cab68da8-e982-4f20-aca4-3b08a0cbb430
azobenzene_absorbance_spectrum = let
	#Download UV-vis spectrum from NIST Chemistry Webbook
	jcampid = "C103333"    #azobenzene
	
	parse_jcampdx(download("http://webbook.nist.gov/cgi/cbook.cgi?JCAMP=$(jcampid)&Index=0&Type=UVVis"))
end;

# ╔═╡ bfb0e02c-379b-4b54-87a6-2d509c7fa811
pentacene_absorbance_spectrum = let
	#Download UV-vis spectrum from NIST Chemistry Webbook
	jcampid = "C135488"     #pentacene
	
	parse_jcampdx(download("http://webbook.nist.gov/cgi/cbook.cgi?JCAMP=$(jcampid)&Index=0&Type=UVVis"))
end;

# ╔═╡ 9bafc1fb-727c-4b09-bd8d-d0a9a02cc28b
#Smooth out A with a simple moving average
function sma(A, n=8)
    B=copy(A)
    avg=sum(A[1:n])/n
    for i=n+1:length(A)
        avg += (A[i] - A[i-n])/n
        B[i] = avg
    end
    B
end

# ╔═╡ 78051bb7-4caf-4898-b40e-efe52486380f
macro math_str(str)
	"``" * str * "``"
end

# ╔═╡ d3229351-678b-4719-9ab3-6cf2982e178f
macro code_str(code_expr)
	quote
		code = $(esc(code_expr))
		code_str(code)
	end
end

# ╔═╡ 776a7f45-1745-4ae2-a964-957737c31243
import Unitful: Unitful, @u_str

# ╔═╡ 4fbc02ee-6018-4955-a0dc-6f86c2622f6a
x̅(λ::Unitful.Length{Int}) = Colors.cie1931_cmf_table[begin+Unitful.ustrip(λ)-360, 1]

# ╔═╡ e2db3fa1-abef-4e47-b163-9b3be50780ec
y̅(λ::Unitful.Length{Int}) = Colors.cie1931_cmf_table[begin+Unitful.ustrip(λ)-360, 2]

# ╔═╡ 3f5ab0d0-b7de-48b3-ba46-6c6f524c1ce7
z̅(λ::Unitful.Length{Int}) = Colors.cie1931_cmf_table[begin+Unitful.ustrip(λ)-360, 3]

# ╔═╡ 11504926-219a-4a29-b370-8c7344a78310
m = u"m"

# ╔═╡ 058294ff-40c1-4992-b5cd-4b5d9062d7c6
K = u"K"

# ╔═╡ 4e7934c9-2443-4a22-99dc-5d0a712d4387
const hc_k  = 0.0143877696*K*m

# ╔═╡ 709881f0-148a-4b40-b277-08374a2a43dd
Trange = 1000K:1000K:9000K

# ╔═╡ 4ac4f213-48cd-48f3-8ef2-900c9c6411a7
T☉ = 5778K #Temperature of the sun

# ╔═╡ 47a3ceca-3f04-4b79-807c-05a93a78dbb1
function planckian_locus(T::Unitful.Temperature)
    T = T / K # Strip out the unit
    x = 1667<=T<=4000 ? -0.2661239e9/T^3-0.2343580e6/T^2+0.8776956e3/T+0.179910 :
        4000<=T<=25000 ? -3.0258469e9/T^3+2.1070379e6/T^2+0.2226347e3/T+0.230390 :
        error("Temperature T=$T exceeds allowed limits of 1667<=T<=25000")
    y = 1667<=T<=2222 ? -1.1063814x^3-1.34811020x^2+2.18555832x-0.20219683 :
        2222<=T<=4000 ? -0.9549476x^3-1.37418593x^2+2.09137015x-0.16748867 :
        4000<=T<=25000 ?  3.0817580x^3-5.87338670x^2+3.75112997x-0.37001483 :
        error("Temperature T=$T exceeds allowed limits of 1667<=T<=25000")
    Colors.xyY(x, y, 1.0)
end

# ╔═╡ faee8eb8-87f6-4d08-87fd-abdb00e5dc40
W = u"W"

# ╔═╡ e50e99aa-27bb-4d36-89f4-7f5d88f721cd
const twohc²= 1.19104287e-16*W*m^2

# ╔═╡ 0a801ae5-4f2a-4454-9d2b-3a72b59aab62
#Power spectrum for blackbody using Planck's law 
planck(λ; T=5778.0K) =
    λ≤0m ? zero(λ)*W*m^-4 : twohc²*λ^-5.0/(exp(hc_k/(λ*T))-1)

# ╔═╡ a2345a6e-4142-4de2-b78a-16a8799f86e3
nm = u"nm"

# ╔═╡ a622e3a6-826a-4900-a4d3-2b88733027bd
X(λ) = sum(x̅.(380nm:1nm:λ))

# ╔═╡ 51ebf9cc-aabd-4b87-bf32-701a87800ce3
Y(λ) = sum(y̅.(380nm:1nm:λ))

# ╔═╡ 9db97697-ea90-40f2-a839-e532163a5a47
Z(λ) = sum(z̅.(380nm:1nm:λ))

# ╔═╡ b307b0d5-6d80-4189-afa9-5371f14cdc33
human_wavelength = 380nm:1nm:780nm

# ╔═╡ b35a6631-5c80-47da-a372-7b52f7cceb3e
Colors.XYZ(x̅(480nm), y̅(480nm), z̅(480nm)) === Colors.cie_color_match(480)

# ╔═╡ 2c0827b8-dc5c-4d09-bf2f-6db88ef44acc
Colors.XYZ(x̅(480nm), y̅(480nm), z̅(480nm))

# ╔═╡ 1497a357-5202-4b31-84d7-c93fd7c6aff3
Base.convert(::Type{Colors.xyY}, T::Unitful.Temperature) = 
	sum(map(380:780) do λ
		Unitful.upreferred(
			planck(λ * nm, T=T)*m^3/W
		) * Colors.cie_color_match(λ)
	end) |> normalize0

# ╔═╡ 2e6b97ea-2516-4562-a53d-89eac059c129
#Convert XYZ to normalized xyY with white balancing
function normalize(c::Colors.XYZ; docorrect::Bool=true)
    d = convert(Colors.xyY, docorrect ?
      Colors.whitebalance(c, Colors.WP_E, Colors.WP_DEFAULT) : c)
    Colors.xyY(d.x, d.y, 1.0)
end

# ╔═╡ 8bd666ad-b434-47b7-954d-bbacab5dbd3f
#Compute a series of transmission spectra scaled to a desired maximum transmission
function calc_transmission(A::AbsorbanceSpectrum; maxTs=1.0:-0.0025:0.0)
    colors = Colors.xyY[]
    spectra = TransmissionSpectrum[]
    for maxT in maxTs
        scalefactor = -log10.(maxT) / minimum(A.ϵ[A.ϵ .> 0])
		if scalefactor == Inf
			continue
		end
		
        T = convert(TransmissionSpectrum, A, cl=scalefactor)
        push!(spectra, T)
        push!(colors, convert(Colors.xyY, T))
    end
    colors, spectra
end

# ╔═╡ f7b5e83f-01ee-4430-9bcd-5440ac6b9e78
"""
Why is this a macro?? Well, I want to be able to style the output, without turning the result into some different (wrapped) object. Is there an easier way to do this? idk
"""
macro with_background(expr)
	@gensym result
	quote
		$result = $(esc(expr))
		with_background($result)
	end
end

# ╔═╡ 30300f37-362a-4b00-b3e7-0423107c98a8
import Gadfly: Gadfly, Geom, Theme, layer, Guide, Scale

# ╔═╡ 001cb3c2-d912-4c8b-8836-7be8ad1013c2
function Base.show(io::IO, mime::MIME"image/svg+xml", S::AbsorbanceSpectrum)
    show(io, mime, Gadfly.plot(
		Geom.line,
		Guide.xlabel("λ (nm)"),
		Guide.ylabel("Absorbance"),
		x = S.λ,
		y = S.ϵ,
	))
end

# ╔═╡ 1ca29f42-705c-4420-a0d8-f00e05434416
function Base.show(io::IO, mime::MIME"image/svg+xml", S::TransmissionSpectrum)
    show(io, mime, Gadfly.plot(
		Geom.line,
		Guide.xlabel("λ (nm)"),
		Guide.ylabel("Transmittance"),
      	x = S.λ,
		y = S.T
	))
end

# ╔═╡ ab4957ed-1e17-4466-9e62-89c549cb37ea
function Base.show(io::IO, mime::MIME"image/svg+xml", Ss::Vector{TransmissionSpectrum})
    show(io, mime, Gadfly.plot(
		Guide.xlabel("λ (nm)"),
		Guide.ylabel("Transmittance"),
    	[layer(Geom.line, x=S.λ, y=S.T) for S in Ss]...,
	))
end

# ╔═╡ 35b969df-04df-4c2f-a395-59e024dc9d3b
import MarkdownLiteral: @markdown

# ╔═╡ aa5e68d7-e31f-42f8-b431-48fed2901eb9
@markdown """
## Computing white

As a sanity check, I wanted to make sure that projecting a flat power spectrum into the XYZ space produced a white color. This is white in the purely technical sense, of having the same intensity of light at every wavelength.

To do this, we'll have to imbue the XYZ color space with vector space operations; in particular, we want to add and scale vectors. It follows by the definition of the XYZ color space that the usual notions of these operations apply (the color space has no curvature).
<del>These operations are not currently in Colors.jl, but Julia makes it very easy to extend:</del>
These operations are in Colors.jl, so nothing we need to do.
"""

# ╔═╡ 20e44357-8ffa-43dd-bc4b-08b1fec32b6b
@markdown """
Ok, this looks like white. However, there's some built-in assumption on the normalization in Color.jl which I haven't figured out yet, which means that any XYZ(X,Y,Z) for sufficiently positive (X,Y,Z) will render as white.

The easy solution to this is to convert to the xyY color space, where $(math"x") and $(math"y") are (normalized) chromaticity coordinates (such that $(math"x+y+z=1")) and $(math"Y") is the luminosity. Here's what the monochromatic rainbow looks like in this coordinate system:
"""

# ╔═╡ b38d50a2-05a0-45e6-95ac-33effdde6a06
@markdown """
> 🙃 TODO  
> I now have a Gadfly and "Plots" plot for this nice curvy rainbow... They both look different to what it used to in the original notebook.......... 🤷‍♀️
"""

# ╔═╡ 771cd920-c957-413e-9bf2-6c5badf3f431
@markdown """
It is easy to normalize the perceptual color in the xyY coordinate system.
"""

# ╔═╡ 06699d95-72b6-4645-8171-ddcf7a75dcf0
@markdown """
Oops, this isn't white. What's going on?

Turns out that this is a white point issue. The definition I wanted turns out to be the E white point (`Color.WP_E`), whereas the CIE standard uses a different default white point (`Color.WP_DEFAULT`), which is the D65 white point (`Color.WP_D65`, the 'noon daylight' standard used by most displays). Conveniently, `Colors.jl` provides `Color.whitebalance` to correct for the difference in white points. So let's try this again.
"""

# ╔═╡ 1ad418c2-76fb-46d9-a20a-113b7593883e
@markdown """
Ok, this looks white now. We're ready to start visualizing some physical data!
"""

# ╔═╡ 0712f7ab-2eb3-4035-983c-401fb4c83fde
@markdown """
## Blackbody radiation

Perhaps the easiest physically relevant power spectrum to look at is that of blackbody radiation, which is described by Planck's law:

$(math"B_\lambda (T) = \frac{2hc^2}{\lambda^5} \frac{1}{\left(\exp\left(\frac{hc}{kT}\right) - 1\right)}")

The cells below makes use of the Unitful.jl package for defining unitful physical quantities. Those units are explicitly defined at the [end of this notebook](#units).
"""

# ╔═╡ 7e6a4415-9526-47d0-b848-5f074d612b88
@markdown """
Let's look at the computed colors for blackbodies at various temperatures. The code below defines a new conversion function from temperature to an xyY color. (Note: For some reason, I got better results by disabling color correction in normalize. I'm not sure why.)
"""

# ╔═╡ 603cc295-833b-4f14-90f4-8a5b95fe3847
@markdown """
To check the computed color, we can compare our computed color against what is called the Planckian locus, which is the trajectory in the chromaticity space $(math"(x, y)"). There are known approximations using cubic splines as a function of the reciprocal temperature $(math"1/T").

Color.jl also provides a colordiff function which quantifies the distance between two colors using the CIEDE2000 color-difference formula (pdf). (I'm not sure what the units are though.)
"""

# ╔═╡ 2ad1d25c-a3f1-4caf-b904-04dca9e50171
@markdown """
We can reconstruct the transmittance spectrum from the corresponding absorbance spectrum using the Beer-Lambert law:

$(math"T = {10}^{-c l \epsilon} = e^{-\sigma l N}")

where $(math"T") is the transmittance, $(math"\epsilon") is the (decadic) molar extinction coefficent, $(math"c") is the molar concentration of the sample, $(math"l") is the optical path length, the distance light travels in the sample, $(math"\sigma") is the optical cross-section, and $(math"N") is the number concentration of the sample.
"""

# ╔═╡ 9d13a79f-511d-4bdf-a83a-a7abfa7e18a0
@markdown """
The transmission spectrum is a function of light intensity over wavelength, and can therefore be projected directly into the XYZ color space as described in the previous section. (In the code snippet below, I've also included some heuristics to cover possible missing data in the transmission spectrum.)
"""

# ╔═╡ 4b287ba1-7b0f-46a4-8d9a-2a2c3641b4f4
@markdown """
However, this reconstruction requires information about the concentration and thickness of the sample, which is normalized out in most reported data. What we can do here is to explore how the perceived color depends on the concentration. Here I've chosen to vary the concentration factor $(math"cl=\sigma N") by sweeping over the maximal transmittance $(math"T_{max}") in the visible spectrum:

$(math"cl = - \frac{log_{10}(T_{max})}{\epsilon}")

and the computed color can be plotted in the $(math"xy") chromaticity plane as a function of the concentration factor.
"""

# ╔═╡ a238da5d-7bd0-45e3-8310-b16b2ba98eef
@markdown """
Finally, here are some short routines for parsing spectral data.
"""

# ╔═╡ 28aad279-0704-4330-b1db-387a9f346f6f
@markdown """
We are finally ready to start computing colors of molecules! The examples given below reflect (so to speak) a broad spectrum (ha) of molecular species, whose data are available online in several different formats.

I've also included some images of the compounds in question to compare the computed color swatches with pictures of the actual solutions or samples. Again, the color swatches show the entire gamut of colors possible from the given spectra, so each a picture should match a color in the range. (There's also a question about the white balance in each reference picture, which is somewhat of a wildcard.)
"""

# ╔═╡ a75f5189-48ef-4b15-9755-56dbe3e7ab27
@markdown """
## Titanium (III) aqua ion
"""

# ╔═╡ 40170577-1a9b-4ed2-a42d-d8b49ad4a62e
@markdown """
Here is a picture of titanium (III) chloride solution from Wikipedia.

<img
	style="height:300px"
	alt="Titanium (III) chloride solution from Wikipedia"
	src="http://upload.wikimedia.org/wikipedia/commons/c/cd/TiCl3.jpg"
/>
"""

# ╔═╡ 3362582f-cbaf-4286-b626-7378b1dff50d
@markdown """
## Copper (II) aqua ion
"""

# ╔═╡ 0b6ac8eb-9584-4dd5-b89d-f6fd19f18955
@markdown """
I found a particularly nice picture showing the diffusion of copper sulfate through an aqueous solution, showing a color gradient which corresponds very neatly with the gradient shown in the gamut!

<img
	alt="Copper sulfate diffusion"
	src="http://www.nuffieldfoundation.org/sites/default/files/images/Diffusion%20of%20copper%20sulfate%20solution%20in%20water2_2262.jpg"
	style="height: 200px"
/>
"""

# ╔═╡ 81fe97b8-98bd-416e-b82c-2754c786cb35
@markdown """
## Copper(II) chlorophyllin

This chlorophyll derivative is used as an edible dye (food additive E141) to give food the color of fresh leaves. So one would expect this to be a nice shade of green.
"""

# ╔═╡ 95010455-dd25-4075-87c3-b015c383c493
@markdown """
<img
	alt="Chlorophyllin"
	src="https://upload.wikimedia.org/wikipedia/commons/f/f1/M%C3%A9lisse_Feuilles_FR_2013b.jpg"
	style="height: 200px"
/>
"""

# ╔═╡ e9bd00e7-5829-4d89-944b-5f7ab7bb49bb
@markdown """
## Azobenzene

Azobenzene is an azo compound which demonstrates a particular chemical reaction known as photoisomerization.
"""

# ╔═╡ 5b786ac4-354e-483c-b349-4d3570f705b6
@markdown """
## Dichromate [Cr$(math"_2")O$(math"_7")]$(math"^{2-}")
"""

# ╔═╡ 4c5d307c-5624-48de-8cb4-2fb738177515
@markdown """
<img
	src="http://upload.wikimedia.org/wikipedia/commons/b/b6/Ammonium-dichromate-sample.jpg"
	style="height: 200px"
/>
"""

# ╔═╡ ef0f318a-c125-4a13-90fd-c3eb6e2b6b88
@markdown """
## Pentacene
"""

# ╔═╡ 1e61d2af-b6a0-4d86-9382-7054ef646c42
@markdown """
## Rhodamine B
"""

# ╔═╡ 4046ea8e-f859-4bde-af07-da172eb86d53
@markdown """
<img
	src="http://image.made-in-china.com/43f34j00kZOTfIJYhtqc/Solvent-Red-49-Rhodamine-B-Base-.jpg"
	style="height: 200px"
/>
"""

# ╔═╡ b4296e8f-49dd-40b9-bd79-26a8317b4803
@markdown """
## Iodine
"""

# ╔═╡ 1e316df3-9717-4458-83cb-60e873b01620
@markdown """
Here is an image of sublimed elemental iodine, showing off its famous purple color.

<img
	src="http://farm9.staticflickr.com/8372/8457016550_9ee1584914_n.jpg"
	style="height: 200px"
/>

(It's interesting to see how to perceived colors change as a function of concentration - it's common knowledge in photochemistry that perceptual colors may change in this way, and that looking for new structure in the spectrum is the only sure way to detect further chemical reactions which may cause colors to change even more drastically.)
"""

# ╔═╡ e32c92c2-7cf6-416c-a2b2-1e65a06159a1
@markdown "## Appendix"

# ╔═╡ 95e7c896-4d18-4bea-9f78-eb2d41c70b13
@markdown """### Markdown helpers"""

# ╔═╡ 0f6014fc-718d-4eda-b4cd-88f8e05dc900
@markdown "### Units"

# ╔═╡ 916bc0d1-c47b-4a31-b419-f110eefedda3
@markdown """
### with_background :D

Wraps something display-able with a nice "this is transparent" thing so the colors and boundaries are easily visible.
"""

# ╔═╡ c4bdf555-cc99-47fa-be66-d3637e025377
@markdown """### Imports"""

# ╔═╡ 0e4f40e0-521f-421f-af23-671fe2ccc272
import Plots

# ╔═╡ 0d4cd2e9-eb66-4ab6-917e-ead6a09e8c54
let
	plot = Plots.plot(xaxis="λ (nm)", yaxis="Sensitivity", background="transparent")
	Plots.plot!(plot, 360:830, Colors.cie1931_cmf_table[:,1],
		color=Colors.XYZ(1, 0, 0), 
		label="x̅"
	)
	Plots.plot!(plot, 360:830, Colors.cie1931_cmf_table[:,2],
		color=Colors.XYZ(0, 1, 0), 
		label="y̅"
	)
	Plots.plot!(plot, 360:830, Colors.cie1931_cmf_table[:,3],
		color=Colors.XYZ(0, 0, 1), 
		label="z̅"
	)
	plot
end

# ╔═╡ 9b8aca24-538d-4724-b041-feeca77a713e
#Plot trajectory in chromaticity plane
function plot_xy(C::AbstractVector{Colors.xyY})
	# PlutoUI.as_svg(Gadfly.plot(
	# 	x=[c.x for c in C],
	#     y=[c.y for c in C],
	# 	color=C,
	#     # Gadfly.Scale.discrete_color_manual(C...),
	#     Gadfly.Geom.point,
	# 	Gadfly.Theme(key_position=:none),
	# ))

	Plots.scatter(
		[c.x for c in C],
		[c.y for c in C],
		markercolor=C,
		legend=false,
		markerstrokewidth=0,
		background="transparent",
	)
end

# ╔═╡ bb50cddd-541c-4119-9fde-9062265866f1
import PlutoUI

# ╔═╡ d7e84b03-7616-4bcb-933d-4c3f275599b7
PlutoUI.as_svg(Gadfly.plot([λ->planck(λ*nm,T=T)*(1e-9m)^3/W for T in Trange], 0, 2000,
	Guide.xlabel("λ (nm)"),
	Guide.ylabel("spectral radiance, B (W·sr⁻¹·nm⁻³)"),
	color=[string(T) for T in Trange],
))

# ╔═╡ e9744d4a-4381-4a78-aa3a-d024c00fbb8f
import PlutoUI.ExperimentalLayout: embed_display

# ╔═╡ 8a773a45-4e90-4192-9482-eec0474b738f
import Downloads

# ╔═╡ 13495583-b9f5-4e0a-bcce-292da790daec
titanium_III_aqua_ion_absorbance_spectrum = parse_jdx(
	Downloads.download("http://wwwchem.uwimona.edu.jm/spectra/ti3aq.jdx")
);

# ╔═╡ 4dcf9519-6672-4cf6-99a4-8f11363b72b5
copper_II_aqua_ion_absorbance_spectrum = parse_jdx(
	Downloads.download("http://wwwchem.uwimona.edu.jm/spectra/cu2aq.jdx")
);

# ╔═╡ b97920d8-97a5-42c2-9c2a-9f2ee0969261
copper_II_chlorophyllin_absorbance_spectrum = parse_jdx(
	Downloads.download("http://wwwchem.uwimona.edu.jm/spectra/e141.jdx")
);

# ╔═╡ 93d77fbf-53ed-4b25-8b93-f6e68c8a1a39
dichromate_absorbance_spectrum = parse_jdx(
	Downloads.download("http://wwwchem.uwimona.edu.jm/spectra/cr2o7.jdx")
);

# ╔═╡ 4fd9105e-aad7-4978-9bab-dbf57dac1def
rhodamine_b_absorbence_spectrum = let
	A = parse_photochemcad(
		Downloads.download("http://omlc.ogi.edu/spectra/PhotochemCAD/data/009-abs.txt")
	)
	B = copy(A.ϵ)
	B[A.λ .> 600] .= 0 #Zero out some noise
	AbsorbanceSpectrum(A.λ, sma(B))
end;

# ╔═╡ 6fb73758-b478-46cb-a196-13669a46b427
iodine_absorbence_spectrum = let
	#Data source:
	#The MPI-Mainz UV/VIS Spectral Atlas
	#of Gaseous Molecules of Atmospheric Interest
	filename = Downloads.download("http://joseba.mpch-mainz.mpg.de/spectral_atlas_data/cross_sections/Halogens+mixed%20halogens/I2_Tellinghuisen(2011)_308K_390-900nm.txt")
	S = DelimitedFiles.readdlm(filename, skipstart=2)
	AbsorbanceSpectrum(S[:,1], S[:,2])
end;

# ╔═╡ cac91ac1-ecf0-49b3-a5e1-972a7c3e786f
import HypertextLiteral: @htl

# ╔═╡ 5fdc6999-816c-4d51-b989-14e8c442cd96
code_str(code) = @htl """
	<code class="language-julia">$(code)</code>
"""

# ╔═╡ 79a54b9b-8fe0-4f5e-a983-c54d0696a125
md"""
## Color vision and the visible spectrum

Physically speaking, light is radiation in the form of electromagnetic waves, and can therefore be quantified by certain characteristics such as wavelength and amplitude. Color theory studies how such characteristics get translated into a sensory perception, of color.

The human eye supports two types of vision: photoptic vision occurs under bright light, and scotopic vision occurs under dim light. These two modes come from using different types of vision cells, namely cones and rods respectively. Only cones sense color, and are sensitive to light with wavelengths in the range of 350-800 nm. The actual range can vary from person to person.

Color theory focuses mainly on photoptic vision in the 380-780 nm region. Computations for color theory are provided by functions in the Julia package Colors.jl. For example, $(code"Colors.cie_color_match") calculates the perceived color produced by monochromatic light, i.e. light waves of a single, pure wavelength.
"""

# ╔═╡ a7bf2ef5-0029-4dcb-b4a2-24d9a378d1fb
@markdown """
## Raw light power and the XYZ color space

The modern foundations of color theory can be traced back to the CIE 1931 color space model. Building upon centuries of empirical evidence that three coordinates are sufficient to quantify perceived colors, the CIE model defines three basis functions $(math"\overline{x}(\lambda)"), $(math"\overline{y}(\lambda)") and $(math"\overline{z}(\lambda)") over (most of) the visible wavelength range $(code"380nm") $(math"\le\lambda\le") $(code"780nm").

These basis functions define a linear vector space known as the XYZ color space. An arbitrary function $(math"f(\lambda)") has a three-dimensional projection as a vector in this vector space, with components known as tristimulus values that are given by the projections

$(math"
X = \int f(\lambda) \overline{x}(\lambda) d\lambda
")

$(math"
Y = \int f(\lambda) \overline{y}(\lambda) d\lambda
")

$(math"
Z = \int f(\lambda) \overline{z}(\lambda) d\lambda
")

The CIE standard defines the basis functions in discrete tabular form; the raw data for $(math"\overline{x}(\lambda)"), $(math"\overline{y}(\lambda)") and $(math"\overline{z}(\lambda)") are available in $(code"Colors.cie1931_cmf_table[:,i]") for $(code"i=1:3") respectively.

Instead of the earlier mentioned $(code"380nm") to $(code"780nm") range, however, $(code"Colors.cie1931_cmf_table") [is mentioned](https://github.com/JuliaGraphics/Colors.jl/blob/007a8c8628804beb9485fe59d475c2a9e5040b77/src/colormatch.jl#L69) to start at $(code"360nm") and go till $(code"830nm").
"""

# ╔═╡ aecc5d71-1e4c-42f2-994d-78d5c4cd8f43
function with_background(obj)
	@htl """
	<fancy-background style="white-space: normal">
		<template shadowroot="open">
			<style>
			.background {
				--block-color: lightgray;
				--block-size: 15px;
			
				background-color: black;
				padding: 12px;
				display: inline-block;
				background-color: white;
				background-image:
					linear-gradient(45deg, var(--block-color) 25%, transparent 25%, transparent 75%, var(--block-color) 75%, var(--block-color)),
					linear-gradient(45deg, var(--block-color) 25%, transparent 25%, transparent 75%, var(--block-color) 75%, var(--block-color));
				background-size: var(--block-size) var(--block-size);
				background-position:
					0 0,
					calc(var(--block-size) / 2) calc(var(--block-size) / 2);
			}

			@media (prefers-color-scheme: dark) {
				.background {
					background-color: black;
					--block-color: #444;
				}
			}
			</style>
	
			<div class="background">
				<slot class="hmm" />
			</div>
		</template>

		<div slot>
			$(embed_display(obj))
		</div>
	</fancy-background>
	"""
end

# ╔═╡ 38706b8d-1eb9-41a0-9de8-90f94ef62fa6
@with_background rainbow = [Colors.cie_color_match(λ) for λ=380:1.5:780]

# ╔═╡ 597b79c6-59d4-436f-a2ac-2ffa94db840c
@with_background sum(map(Colors.cie_color_match, 380:780))

# ╔═╡ ff45fce9-97dc-4693-807e-13f0e810bcd1
@with_background rainbowxyY = map(380:780) do λ
	convert(Colors.xyY, Colors.cie_color_match(λ))
end

# ╔═╡ e0242ad5-5614-45cb-a506-380eb2826c79
PlutoUI.as_svg(Gadfly.plot(
	Geom.point,
	Theme(key_position=:none, highlight_width=0 * Gadfly.pt),
	x=[c.x for c in rainbowxyY],
	y=[c.y for c in rainbowxyY],
	color=rainbowxyY,
	Scale.discrete_color_manual(rainbow...),
))

# ╔═╡ 3d8a0de5-fd41-4e36-aafb-9c686309bbb2
Plots.scatter(
	[c.x for c in rainbowxyY],
	[c.y for c in rainbowxyY],
	markercolor=rainbowxyY,
	legend=false,
	markerstrokewidth=0,
	background="transparent",
)

# ╔═╡ f5d75003-d62c-4524-8763-d5358abae28d
#Convolution with flat power spectrum
(
	our_sum = @with_background(
		sum(map(Colors.cie_color_match, 380:780)) |> normalize0
	),
	actual_white = @with_background(Colors.color("white")),
)

# ╔═╡ 9c7d1ef8-b032-4410-9560-e317b66956fe
#Convolution with flat power spectrum
(
	our_sum = @with_background(
		sum(map(Colors.cie_color_match, 380:780)) |> normalize
	),
	actual_white = @with_background(Colors.color("white"))
)

# ╔═╡ 9dc8f185-df7c-4a93-8be1-535fb90e03fa
@with_background blackbodies = Colors.xyY[T for T in 30K:30K:10000K]

# ╔═╡ 47880678-53ee-483a-9b67-7e37d7d155ba
@with_background convert(Colors.xyY, T☉)

# ╔═╡ a84a82ca-2f54-4d98-8718-8f3b39527bda
@with_background sun_approx = planckian_locus(T☉)

# ╔═╡ 0f3d56b0-6087-4e52-93bc-1561b7f8515c
@with_background sun = convert(Colors.xyY, T☉)

# ╔═╡ fd17ffd5-4e9c-476f-aa21-e7e05ba583cf
@with_background locus = map(T -> planckian_locus(T*K), 1667:30:25000)

# ╔═╡ b88c043c-8ddf-45b8-b0a8-f75d037b075c
#XXX plotting issue https://github.com/dcjones/Gadfly.jl/issues/317
PlutoUI.as_svg(Gadfly.plot(
	Guide.xlabel("x"),
	Guide.ylabel("y"),
	layer(Geom.line, x=[c.x for c in blackbodies], y=[c.y for c in blackbodies], Theme(default_color=Colors.color("red"))), 
	layer(Geom.point, x=repeat([sun.x], 2), y=repeat([sun.y], 2), Theme(default_color=Colors.color("red"))),
	layer(Geom.label, x=[sun.x], y=[sun.y], label=["☉"]),

	layer(Geom.line, x=[c.x for c in locus], y=[c.y for c in locus], Theme(default_color=Colors.color("purple"))),
	layer(Geom.point, x=repeat([sun_approx.x], 2), y=repeat([sun_approx.y], 2), Theme(default_color=Colors.color("purple"))),
	layer(Geom.label, x=[sun_approx.x], y=[sun_approx.y], label=["☉ (approx)"]),
))

# ╔═╡ f7288dab-c8f1-4a6f-980d-fd4e678faf14
function showcolors(A::AbsorbanceSpectrum)
    colors, Ts = calc_transmission(A)
    PlutoUI.ExperimentalLayout.grid([
		embed_display(A)                 embed_display(Ts[1:20:end])
		embed_display(plot_xy(colors))   @with_background(embed_display((colors)))
	])
end

# ╔═╡ c4ffd07b-60f7-4bae-ab61-a024fb7e2f8b
showcolors(titanium_III_aqua_ion_absorbance_spectrum)

# ╔═╡ 043ca402-e234-4074-a458-e77a54e65932
showcolors(copper_II_aqua_ion_absorbance_spectrum)

# ╔═╡ ba81901a-ed49-446b-be2e-00edcee3ad15
showcolors(copper_II_chlorophyllin_absorbance_spectrum)

# ╔═╡ d51b7e02-abf8-4958-aca1-12611899a7ed
showcolors(azobenzene_absorbance_spectrum)

# ╔═╡ e78c6a8b-40df-4592-ba02-c5b990d1e2af
showcolors(dichromate_absorbance_spectrum)

# ╔═╡ 87898206-c83b-4ac7-bdb4-d87f36267680
showcolors(pentacene_absorbance_spectrum)

# ╔═╡ 92f144ca-b2e7-41d1-9f79-ffabf225ef80
showcolors(rhodamine_b_absorbence_spectrum)

# ╔═╡ 5f6b0eb5-40fa-4838-b832-bb3185c8b6da
showcolors(iodine_absorbence_spectrum)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[compat]
CSV = "~0.10.1"
Colors = "~0.12.8"
Gadfly = "~1.3.4"
HypertextLiteral = "~0.9.3"
MarkdownLiteral = "~0.1.1"
Plots = "~1.25.6"
PlutoUI = "~0.7.30"
Unitful = "~1.10.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "fbee070c56e0096dac13067eca8181ec148468e1"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.1"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "c308f209870fdbd84cb20332b6dfaf14bf3387f8"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "6e39c91fb4b84dcb870813c91674bdebb9145895"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.5"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4aff51293dbdbd268df314827b7f409ea57f5b70"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.5"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "9a2695195199f4f20b94898c8a8ac72609e165a4"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.3"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoupledFields]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6c9671364c68c1158ac2524ac881536195b7e7bc"
uuid = "7ad07ef1-bdf2-5661-9d2b-286fd4296dac"
version = "0.2.0"

[[Crayons]]
git-tree-sha1 = "b618084b49e78985ffa8422f32b9838e397b9fc2"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "08f8555cb66936b871dcfdad09a4f89e754181db"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.40"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "4a740db447aae0fbeb3ee730de1afbb14ac798a1"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa22e1ee9e722f1da183eb33370df4c1aeb6c2cd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.1+0"

[[Gadfly]]
deps = ["Base64", "CategoricalArrays", "Colors", "Compose", "Contour", "CoupledFields", "DataAPI", "DataStructures", "Dates", "Distributions", "DocStringExtensions", "Hexagons", "IndirectArrays", "IterTools", "JSON", "Juno", "KernelDensity", "LinearAlgebra", "Loess", "Measures", "Printf", "REPL", "Random", "Requires", "Showoff", "Statistics"]
git-tree-sha1 = "13b402ae74c0558a83c02daa2f3314ddb2d515d3"
uuid = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
version = "1.3.4"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hexagons]]
deps = ["Test"]
git-tree-sha1 = "de4a6f9e7c4710ced6838ca906f81905f7385fd6"
uuid = "a1b4810d-1bce-5fbd-ac56-80944d57a21f"
version = "0.2.0"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "22df5b96feef82434b07327e2d3c770a9b21e023"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "db7393a80d0e5bef70f2b518990835541917a544"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.6"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "5c0eb9099596090bb3215260ceca687b888a1575"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.30"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "37c1631cb3cc36a535105e6d5557864c82cd8c2b"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.0"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "15dfe6b103c2a993be24404124b8791a09460983"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.11"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e08890d19787ec25029113e88c34ec20cac1c91e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.0.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "2ae4fe21e97cd13efd857462c1869b73c9f61be3"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.2"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "bedb3e17cc1d94ce0e6e66d3afa47157978ba404"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.14"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "b95e0b8a8d1b6a6c3e0b3ca393a7a285af47c264"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.10.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─0c3b0218-2125-447c-802d-405ffc214507
# ╠═95461946-7890-11ec-2f39-95d40be17995
# ╟─79a54b9b-8fe0-4f5e-a983-c54d0696a125
# ╠═38706b8d-1eb9-41a0-9de8-90f94ef62fa6
# ╟─a7bf2ef5-0029-4dcb-b4a2-24d9a378d1fb
# ╠═372cfd0f-b712-4f56-918e-46728bc0a434
# ╠═4fbc02ee-6018-4955-a0dc-6f86c2622f6a
# ╠═e2db3fa1-abef-4e47-b163-9b3be50780ec
# ╠═3f5ab0d0-b7de-48b3-ba46-6c6f524c1ce7
# ╠═a622e3a6-826a-4900-a4d3-2b88733027bd
# ╠═51ebf9cc-aabd-4b87-bf32-701a87800ce3
# ╠═9db97697-ea90-40f2-a839-e532163a5a47
# ╠═b307b0d5-6d80-4189-afa9-5371f14cdc33
# ╠═b35a6631-5c80-47da-a372-7b52f7cceb3e
# ╠═2c0827b8-dc5c-4d09-bf2f-6db88ef44acc
# ╠═36107461-eadc-4d2a-9081-faaa8f80f784
# ╠═0d4cd2e9-eb66-4ab6-917e-ead6a09e8c54
# ╟─aa5e68d7-e31f-42f8-b431-48fed2901eb9
# ╠═597b79c6-59d4-436f-a2ac-2ffa94db840c
# ╟─20e44357-8ffa-43dd-bc4b-08b1fec32b6b
# ╠═ff45fce9-97dc-4693-807e-13f0e810bcd1
# ╟─b38d50a2-05a0-45e6-95ac-33effdde6a06
# ╠═e0242ad5-5614-45cb-a506-380eb2826c79
# ╠═3d8a0de5-fd41-4e36-aafb-9c686309bbb2
# ╟─771cd920-c957-413e-9bf2-6c5badf3f431
# ╠═cbca53c4-556e-4d6a-97da-a68fb41ffa6f
# ╠═f5d75003-d62c-4524-8763-d5358abae28d
# ╟─06699d95-72b6-4645-8171-ddcf7a75dcf0
# ╠═2e6b97ea-2516-4562-a53d-89eac059c129
# ╠═9c7d1ef8-b032-4410-9560-e317b66956fe
# ╟─1ad418c2-76fb-46d9-a20a-113b7593883e
# ╟─0712f7ab-2eb3-4035-983c-401fb4c83fde
# ╠═4e7934c9-2443-4a22-99dc-5d0a712d4387
# ╠═e50e99aa-27bb-4d36-89f4-7f5d88f721cd
# ╠═0a801ae5-4f2a-4454-9d2b-3a72b59aab62
# ╠═709881f0-148a-4b40-b277-08374a2a43dd
# ╠═d7e84b03-7616-4bcb-933d-4c3f275599b7
# ╟─7e6a4415-9526-47d0-b848-5f074d612b88
# ╠═1497a357-5202-4b31-84d7-c93fd7c6aff3
# ╠═9dc8f185-df7c-4a93-8be1-535fb90e03fa
# ╠═4ac4f213-48cd-48f3-8ef2-900c9c6411a7
# ╠═47880678-53ee-483a-9b67-7e37d7d155ba
# ╟─603cc295-833b-4f14-90f4-8a5b95fe3847
# ╠═47a3ceca-3f04-4b79-807c-05a93a78dbb1
# ╠═a84a82ca-2f54-4d98-8718-8f3b39527bda
# ╠═0f3d56b0-6087-4e52-93bc-1561b7f8515c
# ╟─5fda05d3-dd29-46be-855d-2781397d0354
# ╠═fd17ffd5-4e9c-476f-aa21-e7e05ba583cf
# ╠═b88c043c-8ddf-45b8-b0a8-f75d037b075c
# ╟─42755cae-8b2f-462f-a14f-4657b4578336
# ╠═32855b26-e855-49ad-ae38-77bdd8ec2391
# ╠═3f197a16-839f-4ee8-bef1-5d212e4b17ba
# ╠═c0ba17f5-a8b0-405f-a3c1-7179d654d8e3
# ╟─001cb3c2-d912-4c8b-8836-7be8ad1013c2
# ╟─1ca29f42-705c-4420-a0d8-f00e05434416
# ╟─ab4957ed-1e17-4466-9e62-89c549cb37ea
# ╟─2ad1d25c-a3f1-4caf-b904-04dca9e50171
# ╠═edb50a9e-1673-449c-9555-5eb2f9018214
# ╟─9d13a79f-511d-4bdf-a83a-a7abfa7e18a0
# ╠═5266d1f1-43bc-4882-baeb-b6159d3854b9
# ╠═2c747ea7-e5cd-43ae-8167-9dd78fd26724
# ╟─4b287ba1-7b0f-46a4-8d9a-2a2c3641b4f4
# ╠═8bd666ad-b434-47b7-954d-bbacab5dbd3f
# ╠═9b8aca24-538d-4724-b041-feeca77a713e
# ╟─a238da5d-7bd0-45e3-8310-b16b2ba98eef
# ╟─cbb08799-2967-4860-b9eb-e2232323a4b5
# ╟─4a8f061a-e202-41cf-ab5f-0b8020aa07d1
# ╟─4a5da91a-dee4-423b-9995-de9368c702d9
# ╠═af54005b-4ca5-4a38-b6d3-43ac546d6567
# ╠═7e2287c0-5dc2-426d-8277-861154b37d13
# ╟─28aad279-0704-4330-b1db-387a9f346f6f
# ╠═f7288dab-c8f1-4a6f-980d-fd4e678faf14
# ╟─a75f5189-48ef-4b15-9755-56dbe3e7ab27
# ╠═13495583-b9f5-4e0a-bcce-292da790daec
# ╟─c4ffd07b-60f7-4bae-ab61-a024fb7e2f8b
# ╠═40170577-1a9b-4ed2-a42d-d8b49ad4a62e
# ╟─3362582f-cbaf-4286-b626-7378b1dff50d
# ╠═4dcf9519-6672-4cf6-99a4-8f11363b72b5
# ╟─043ca402-e234-4074-a458-e77a54e65932
# ╟─0b6ac8eb-9584-4dd5-b89d-f6fd19f18955
# ╟─81fe97b8-98bd-416e-b82c-2754c786cb35
# ╠═b97920d8-97a5-42c2-9c2a-9f2ee0969261
# ╟─ba81901a-ed49-446b-be2e-00edcee3ad15
# ╟─95010455-dd25-4075-87c3-b015c383c493
# ╟─e9bd00e7-5829-4d89-944b-5f7ab7bb49bb
# ╠═cab68da8-e982-4f20-aca4-3b08a0cbb430
# ╟─d51b7e02-abf8-4958-aca1-12611899a7ed
# ╟─5b786ac4-354e-483c-b349-4d3570f705b6
# ╠═93d77fbf-53ed-4b25-8b93-f6e68c8a1a39
# ╟─e78c6a8b-40df-4592-ba02-c5b990d1e2af
# ╟─4c5d307c-5624-48de-8cb4-2fb738177515
# ╟─ef0f318a-c125-4a13-90fd-c3eb6e2b6b88
# ╠═bfb0e02c-379b-4b54-87a6-2d509c7fa811
# ╟─87898206-c83b-4ac7-bdb4-d87f36267680
# ╟─1e61d2af-b6a0-4d86-9382-7054ef646c42
# ╟─9bafc1fb-727c-4b09-bd8d-d0a9a02cc28b
# ╠═4fd9105e-aad7-4978-9bab-dbf57dac1def
# ╟─92f144ca-b2e7-41d1-9f79-ffabf225ef80
# ╟─4046ea8e-f859-4bde-af07-da172eb86d53
# ╟─b4296e8f-49dd-40b9-bd79-26a8317b4803
# ╠═6fb73758-b478-46cb-a196-13669a46b427
# ╟─5f6b0eb5-40fa-4838-b832-bb3185c8b6da
# ╟─1e316df3-9717-4458-83cb-60e873b01620
# ╟─e32c92c2-7cf6-416c-a2b2-1e65a06159a1
# ╟─95e7c896-4d18-4bea-9f78-eb2d41c70b13
# ╟─78051bb7-4caf-4898-b40e-efe52486380f
# ╟─d3229351-678b-4719-9ab3-6cf2982e178f
# ╟─5fdc6999-816c-4d51-b989-14e8c442cd96
# ╟─0f6014fc-718d-4eda-b4cd-88f8e05dc900
# ╠═776a7f45-1745-4ae2-a964-957737c31243
# ╟─11504926-219a-4a29-b370-8c7344a78310
# ╟─058294ff-40c1-4992-b5cd-4b5d9062d7c6
# ╟─faee8eb8-87f6-4d08-87fd-abdb00e5dc40
# ╟─a2345a6e-4142-4de2-b78a-16a8799f86e3
# ╟─916bc0d1-c47b-4a31-b419-f110eefedda3
# ╟─aecc5d71-1e4c-42f2-994d-78d5c4cd8f43
# ╟─f7b5e83f-01ee-4430-9bcd-5440ac6b9e78
# ╟─c4bdf555-cc99-47fa-be66-d3637e025377
# ╠═30300f37-362a-4b00-b3e7-0423107c98a8
# ╠═35b969df-04df-4c2f-a395-59e024dc9d3b
# ╠═0e4f40e0-521f-421f-af23-671fe2ccc272
# ╠═bb50cddd-541c-4119-9fde-9062265866f1
# ╠═e9744d4a-4381-4a78-aa3a-d024c00fbb8f
# ╠═8a773a45-4e90-4192-9482-eec0474b738f
# ╠═cac91ac1-ecf0-49b3-a5e1-972a7c3e786f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
