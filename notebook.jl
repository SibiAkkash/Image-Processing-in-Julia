### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 51d657ba-3305-4fa6-93d0-fe75252621b8
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
		"Images",
		"ImageShow",
		"ImageIO", 
		"FileIO", 
		"Colors", 
		"PlutoUI", 
		"ColorVectorSpace",
		"PNGFiles",
		"HypertextLiteral",
		"TestImages",
		"Statistics"
	])
	using Colors, ColorVectorSpace, Images, ImageShow, FileIO
	using PlutoUI
	using HypertextLiteral
end

# ╔═╡ b9f3f3b4-8cd3-464f-91b4-6b6fd36776d8
Pkg.add("PaddedViews")

# ╔═╡ 88ff5b19-9caa-44ff-9b4b-ba91d0fa6da4
Pkg.add("ImageFiltering")

# ╔═╡ 9bc56bb7-195d-494c-8693-dd384eec96ba
using TestImages;

# ╔═╡ e412e8ee-4b82-4314-b320-d7da34ae1899
using PaddedViews;

# ╔═╡ 2e266068-2735-4c2c-8084-5f3502d01ef0
using ImageFiltering;

# ╔═╡ ec05e818-a041-40ae-b6f2-076c40d97210
url = "https://picsum.photos/200/300"

# ╔═╡ 98fc490a-bd8b-4911-8651-133f87c41261
download(url, "random_img.jpg")

# ╔═╡ bdbab508-3798-48b0-81ec-0dc0b99556a4
img = load("random_img.jpg")

# ╔═╡ 9174cb97-9a85-4d60-af92-d96fa988dcec
typeof(img)

# ╔═╡ e07bfff3-ec95-4d9f-9abf-510917058e53
img[100:200, 50:100]

# ╔═╡ 03daf2e9-a9d4-49f4-9969-1944d8bf5ffb
md"Concatenate arrays"

# ╔═╡ f8af5b5b-d9ea-4b52-ad6f-395afc1c9665
[img reverse(img, dims=2)]

# ╔═╡ c865792d-4e86-4928-97f8-bd83413f51c5
new_img = copy(img)

# ╔═╡ e36ba824-f849-4337-b55c-79897e23845c
red = RGB(0.7, 0.2, 0)

# ╔═╡ 8fa0c416-d461-4aaf-9a39-06303508e8f6
for i in 1:100
	for j in 1:100
		new_img[i, j] = red
	end
end

# ╔═╡ 69cd8a1f-1124-44d0-ac5b-3feba3ce258b
new_img

# ╔═╡ fca41319-0542-4aab-86e3-5a031ffc9f28
begin
	new_img2 = copy(img)
	new_img2[1:100, 1:100] .= RGB(0, 1, 0)
	new_img2
end

# ╔═╡ 31515abc-1cfd-4656-81e6-ec5f86967cc1
function redify(color)
	return RGB(color.r, 0.2, 0.2)
end

# ╔═╡ ad408af2-a0a9-49fb-ac2d-b8ddd3af1faf
redify.(img)

# ╔═╡ 5c75b3ce-8d3c-42d4-bc3c-26d4c7fd037a
function invert_pixel(color)
	inverted = RGB(abs(1 - color.r), abs(1 - color.g), abs(1 - color.b))
	return inverted
end

# ╔═╡ 2acb8aff-810b-48e7-8ba7-6cec1687b64d
begin
	p = RGB(0.9, 0.8, 0.7)
	[p invert_pixel(p)]
end

# ╔═╡ 2406d587-29b3-45b3-bf85-6f0a1a685295
begin
	invert_inline(c) = RGB(abs(1-c.r), abs(1-c.g), abs(1-c.b))
	[p invert_inline(p)]
end

# ╔═╡ 21f43419-9019-41f5-b15a-d51f96716f14
md"Image negative"

# ╔═╡ 4f36c547-61fc-419e-b621-76683f9c6e76
begin
	inverted_img = invert_pixel.(img)
	[img inverted_img]
end

# ╔═╡ 6ec82a8f-2851-485a-9fbd-d9576e606471
let
	temp = copy(img)
	temp = RGB(1, 1, 1) .- temp
end

# ╔═╡ b0491200-33ec-40e8-9aeb-ee0024108040
[RGB(i, j, 0) for i in 0:0.9:1, j in 0:0.9:1]

# ╔═╡ ffa79434-ac83-49e8-abc0-422ff8012449
md"
### Point operations
##### Image negatives
"

# ╔═╡ 5ea32d3f-b843-489f-9953-1b9fe0159fd9
[img invert_pixel.(img)]

# ╔═╡ 6ee6ac94-a589-485c-bdbb-a02f147fec14
md"
##### Log transformation
"

# ╔═╡ be5aeaca-2e9b-4d6d-a863-894ed1961a8b
function log_transform(c)
	return RGB(2log(1+c.r), 2log(1+c.g), 2log(1+c.b))
end

# ╔═╡ 46a25a81-f6ab-4772-97dc-e614bfb5b5af
[img log_transform.(img)]

# ╔═╡ 128bfb7d-ce3d-4dde-99cf-c391310d0d7b
md"
### Image thresholding
Use the slider to choose a threshold value.  
All the pixels with intensity levels $<$ than the threshold are set to 0 (black). 
All the pixels with intensity levels $\geq$ than the threshold are set to 1 (white).  
"

# ╔═╡ d1e5b56a-03a9-4b7f-af2b-3b0349f83eb0
cameraman = testimage("camera")

# ╔═╡ 93fbc6fa-43ca-4de1-9cc7-37cfe1cb455f
md"Numeric values of each pixel"

# ╔═╡ c0cf30f7-d476-43df-bc66-edd7fb993779
# edges, count = build_histogram(cameraman, 256, minval=0, maxval=255)

# ╔═╡ ecec0fe0-0866-4dcc-866a-f4e3554c7f80
# channelview(cameraman)

# ╔═╡ b6ca20e8-11fe-4bbc-8f3b-58347bab5aa4
md"Threshold slider"

# ╔═╡ 516dbda2-b86f-4872-bdcf-9fc5f66b3596
@bind threshold Slider(0:0.1:1, show_value=true)

# ╔═╡ b2ff30c7-8371-43a0-b1da-66d75cdf39b2
function threshold_img(pixel, thres)
	if pixel < thres
		return Gray(0)
	else
		return Gray(1)
	end
end;

# ╔═╡ 4c885c4f-8f45-40ef-bab6-7e933653440b
[cameraman threshold_img.(cameraman, threshold)]

# ╔═╡ 0b161b67-68c0-4057-94e8-a3d3cf251149
md"
### Bit-plane slicing
"

# ╔═╡ 298c6fd5-730b-4358-9fe8-b9501fd37826
md"""
### Neighborhood Operations
##### Max-neighborhood
"""

# ╔═╡ 64cd7fec-ea56-47ac-8a39-f860c822b3e3
function get_neighbors(input_img, i, j, window_size)
	limit = window_size ÷ 2
	out = []
	for x in -limit:limit
		for y in -limit:limit
			if x == 0 && y == 0
				# dont include the pixel itself
				nothing
			else
				push!(out, input_img[i+x, j+y])			
			end
		end
	end
	return out
end

# ╔═╡ 1f88e842-449f-453b-92bc-c7879e227236
function max_neighbour_filtering(img, window_size)
	h, w = size(img)
	pad = window_size ÷ 2
	padded_img = PaddedView(0, img, (h + pad*2, w + pad*2), (pad+1, pad+1))
	
	output = zeros(Gray, h, w)
	
	for i in 1 + pad : h + pad
		for j in 1 + pad : w + pad
			output[i-pad, j-pad] = maximum(get_neighbors(padded_img,i,j,window_size))
		end
	end
	
	return output
end

# ╔═╡ fbb9c4da-9b49-475f-be59-59b44d17c6f8
md"""
Control window size
"""

# ╔═╡ a8f5c334-a364-4ccd-a4f2-dd00d3feb897
@bind max_neighbour_window_size Slider(3:2:9, show_value=true)

# ╔═╡ e3fe9f4c-b29f-4c31-aa09-af86a334a5f9
begin
	max_filtered = max_neighbour_filtering(cameraman, max_neighbour_window_size)
	[cameraman max_filtered]
end

# ╔═╡ effba953-4734-4bd8-bcfa-e3f3f55d908b
md"""
##### Median neighborhood
"""

# ╔═╡ f441f57d-b2d7-462b-a604-a6cd6450e6c9
function median_neighbour_filtering(img, window_size)
	h, w = size(img)
	pad = window_size ÷ 2
	padded_img = PaddedView(0, img, (h + pad*2, w + pad*2), (pad+1, pad+1))
	
	output = zeros(Gray, h, w)
	
	for i in 1 + pad : h + pad
		for j in 1 + pad : w + pad
			output[i-pad, j-pad] = median(get_neighbors(padded_img,i,j,window_size))
		end
	end
	
	return output
end

# ╔═╡ ba0b747a-ef09-408d-beb2-2064cee09ae3
function med_n(img, window_size)
	h, w = size(img)
	pad = window_size ÷ 2
	padded_img = PaddedView(0, img, (h + pad*2, w + pad*2), (pad+1, pad+1))
	
	output = zeros(Gray, h, w)
	
	for i in 1 + pad : h + pad
		for j in 1 + pad : w + pad
			output[i-pad, j-pad] = median(padded_img[i-pad:i+pad, j-pad:+j+pad])
		end
	end
	return output
end

# ╔═╡ fe88767b-a729-4d45-8a54-69626e7905cc
begin
	original_image = load("lenna.jpg")
	noisy_image = load("lenna-noise.jpg")
	[noisy_image med_n(noisy_image, 3)]
end

# ╔═╡ e8a8535e-c0e5-4a90-85f2-0ae05cd32c0f
md"""
Control window size
"""

# ╔═╡ 9ad5dbfb-5230-4d87-ad45-9629c97580a7
@bind median_neighbour_window_size Slider(3:2:9, show_value=true)

# ╔═╡ 67345307-71b1-411c-856c-f5c1cdfe9dd6
begin
	median_filtered = median_neighbour_filtering(cameraman, median_neighbour_window_size)
	[cameraman median_filtered]
end

# ╔═╡ 2e6f08c0-f6d2-4e21-9cd8-02b18ef1bcf2
kernel = Kernel.gaussian((1, 1))

# ╔═╡ b45751f8-cb2b-4208-b02f-dd159029a1ea
kernel[-2,0]

# ╔═╡ 877da570-cb9c-4e25-ab57-5fcb93eec202
function correlate(img, kernel)
	out = copy(img)
	h, w = size(out)
	kernel_size = size(kernel)
	limit = kernel_size[1] ÷ 2
	
	padded_img = PaddedView(0, img, (h + limit*2, w + limit*2), (limit+1, limit+1))
	padded_img
	# output image coordinates: original dimensions 	
	for x in 1 + limit : h + limit
		for y in 1 + limit : h + limit
			temp_sum = 0
			# kernel coordinates
			for i in -limit:limit
				for j in -limit:limit
					temp_sum += kernel[i,j] * padded_img[x+i, y+j]
				end
			end
		
			out[x-limit][y-limit] = temp_sum
				
		end
	end
	
	return out[x][y]
end

# ╔═╡ fed19b2b-3cd6-4510-a47a-c48adcb5434a
# correlate(cameraman, kernel)

# ╔═╡ 8f2f56f3-6764-4274-817e-41a013b860bb
# begin
# 	a = [x for x in 1:5]
# 	b = [y for y in 10:10:50]
# 	ele_mul = a .* b
# 	total = sum(ele_mul)
# end

# ╔═╡ e045ba79-53bc-4c30-a19f-a161072083b9
# using Statistics;

# ╔═╡ ae8d1c5b-5b28-4e94-a619-c759de9e85bd
# begin
# 	t1 = zeros(2, 3)
# 	t2 = ones(2, 3) / 2
# 	t1 + t2
# end

# ╔═╡ 86471aae-d3e7-4142-b0bb-fe50c0ce6016
# max_neighborhood(img, i, j) = maxfinite(img[i-1:i+1, j-1:j+1])

# ╔═╡ Cell order:
# ╠═51d657ba-3305-4fa6-93d0-fe75252621b8
# ╠═ec05e818-a041-40ae-b6f2-076c40d97210
# ╠═98fc490a-bd8b-4911-8651-133f87c41261
# ╠═bdbab508-3798-48b0-81ec-0dc0b99556a4
# ╠═9174cb97-9a85-4d60-af92-d96fa988dcec
# ╠═e07bfff3-ec95-4d9f-9abf-510917058e53
# ╟─03daf2e9-a9d4-49f4-9969-1944d8bf5ffb
# ╠═f8af5b5b-d9ea-4b52-ad6f-395afc1c9665
# ╠═c865792d-4e86-4928-97f8-bd83413f51c5
# ╠═e36ba824-f849-4337-b55c-79897e23845c
# ╠═8fa0c416-d461-4aaf-9a39-06303508e8f6
# ╠═69cd8a1f-1124-44d0-ac5b-3feba3ce258b
# ╠═fca41319-0542-4aab-86e3-5a031ffc9f28
# ╠═31515abc-1cfd-4656-81e6-ec5f86967cc1
# ╠═ad408af2-a0a9-49fb-ac2d-b8ddd3af1faf
# ╠═5c75b3ce-8d3c-42d4-bc3c-26d4c7fd037a
# ╠═2acb8aff-810b-48e7-8ba7-6cec1687b64d
# ╠═2406d587-29b3-45b3-bf85-6f0a1a685295
# ╟─21f43419-9019-41f5-b15a-d51f96716f14
# ╠═4f36c547-61fc-419e-b621-76683f9c6e76
# ╠═6ec82a8f-2851-485a-9fbd-d9576e606471
# ╠═b0491200-33ec-40e8-9aeb-ee0024108040
# ╟─ffa79434-ac83-49e8-abc0-422ff8012449
# ╠═5ea32d3f-b843-489f-9953-1b9fe0159fd9
# ╟─6ee6ac94-a589-485c-bdbb-a02f147fec14
# ╠═be5aeaca-2e9b-4d6d-a863-894ed1961a8b
# ╠═46a25a81-f6ab-4772-97dc-e614bfb5b5af
# ╟─128bfb7d-ce3d-4dde-99cf-c391310d0d7b
# ╠═9bc56bb7-195d-494c-8693-dd384eec96ba
# ╠═d1e5b56a-03a9-4b7f-af2b-3b0349f83eb0
# ╟─93fbc6fa-43ca-4de1-9cc7-37cfe1cb455f
# ╠═c0cf30f7-d476-43df-bc66-edd7fb993779
# ╠═ecec0fe0-0866-4dcc-866a-f4e3554c7f80
# ╟─b6ca20e8-11fe-4bbc-8f3b-58347bab5aa4
# ╟─516dbda2-b86f-4872-bdcf-9fc5f66b3596
# ╠═b2ff30c7-8371-43a0-b1da-66d75cdf39b2
# ╠═4c885c4f-8f45-40ef-bab6-7e933653440b
# ╟─0b161b67-68c0-4057-94e8-a3d3cf251149
# ╟─298c6fd5-730b-4358-9fe8-b9501fd37826
# ╠═b9f3f3b4-8cd3-464f-91b4-6b6fd36776d8
# ╠═e412e8ee-4b82-4314-b320-d7da34ae1899
# ╠═64cd7fec-ea56-47ac-8a39-f860c822b3e3
# ╠═1f88e842-449f-453b-92bc-c7879e227236
# ╟─fbb9c4da-9b49-475f-be59-59b44d17c6f8
# ╟─a8f5c334-a364-4ccd-a4f2-dd00d3feb897
# ╟─e3fe9f4c-b29f-4c31-aa09-af86a334a5f9
# ╟─effba953-4734-4bd8-bcfa-e3f3f55d908b
# ╠═f441f57d-b2d7-462b-a604-a6cd6450e6c9
# ╠═ba0b747a-ef09-408d-beb2-2064cee09ae3
# ╠═fe88767b-a729-4d45-8a54-69626e7905cc
# ╟─e8a8535e-c0e5-4a90-85f2-0ae05cd32c0f
# ╟─9ad5dbfb-5230-4d87-ad45-9629c97580a7
# ╠═67345307-71b1-411c-856c-f5c1cdfe9dd6
# ╠═88ff5b19-9caa-44ff-9b4b-ba91d0fa6da4
# ╠═2e266068-2735-4c2c-8084-5f3502d01ef0
# ╠═2e6f08c0-f6d2-4e21-9cd8-02b18ef1bcf2
# ╠═b45751f8-cb2b-4208-b02f-dd159029a1ea
# ╠═877da570-cb9c-4e25-ab57-5fcb93eec202
# ╠═fed19b2b-3cd6-4510-a47a-c48adcb5434a
# ╠═8f2f56f3-6764-4274-817e-41a013b860bb
# ╠═e045ba79-53bc-4c30-a19f-a161072083b9
# ╠═ae8d1c5b-5b28-4e94-a619-c759de9e85bd
# ╟─86471aae-d3e7-4142-b0bb-fe50c0ce6016
