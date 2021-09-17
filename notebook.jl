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
		"CoordinateTransformations",
		"Images",
		"ImageMorphology",
		"ImageIO", 
		"FileIO",  
		"PlutoUI", 
		"PNGFiles",
		"HypertextLiteral",
		"TestImages",
		"Statistics",
		"PaddedViews",
		"ImageFiltering"
	])
	using Images, ImageMorphology, ColorVectorSpace, PaddedViews, TestImages, FileIO
	using PlutoUI
	using HypertextLiteral
	using Statistics
end

# ╔═╡ ce6f6f97-1c33-4426-94bd-e8e55d2a7fbc
Pkg.add("Interpolations")

# ╔═╡ 9cfac619-cf98-4276-aec8-75d32e6f4f81
using Interpolations;

# ╔═╡ b5c2d0c2-6001-4e17-9a58-d394cfa25090
using CoordinateTransformations;

# ╔═╡ b3c895eb-552f-4a2f-a46c-5588ceb36928
md"""
## Image processing basics
"""

# ╔═╡ 126ed5e7-d15e-409e-929d-c68a87900be2
md"""
##### Loading necessary packages
(This might take some time to load)
"""

# ╔═╡ ae17bd41-7958-4c1c-919c-ba63fc8b32a4
base_path = "https://raw.githubusercontent.com/SibiAkkash/Image-Processing-in-Julia/main/images"

# ╔═╡ ec05e818-a041-40ae-b6f2-076c40d97210
# let
# 	url = "https://picsum.photos/200/300"
# 	download(url, "random_img.jpg")
# 	img = load("random_img.jpg")
# end

# ╔═╡ c4e69a41-35e2-4532-b6a7-0ec268de433e
img = testimage("lighthouse")

# ╔═╡ 9174cb97-9a85-4d60-af92-d96fa988dcec
typeof(img)

# ╔═╡ 03daf2e9-a9d4-49f4-9969-1944d8bf5ffb
md"Concatenate arrays"

# ╔═╡ 5c75b3ce-8d3c-42d4-bc3c-26d4c7fd037a
function invert_pixel(color)
	return RGB(abs(1 - color.r), abs(1 - color.g), abs(1 - color.b))
end

# ╔═╡ 2acb8aff-810b-48e7-8ba7-6cec1687b64d
begin
	p = RGB(0.9, 0.8, 0.7)
	[p invert_pixel(p)]
end

# ╔═╡ ffa79434-ac83-49e8-abc0-422ff8012449
md"
### Point operations
Point operations are transformations on each pixel of the image.
##### Image negatives

"

# ╔═╡ 6ec82a8f-2851-485a-9fbd-d9576e606471
let
	temp = copy(img)
	inverted_img = RGB(1, 1, 1) .- temp
	[img inverted_img]
end

# ╔═╡ 6ee6ac94-a589-485c-bdbb-a02f147fec14
md"""
##### Log transformation
"""

# ╔═╡ 77f0d940-acd1-4a6b-b5cc-9477342ea4ba
let
	log = download("$base_path/log_transform.png", "log_transform.png")
	log_transform = load("log_transform.png")
end

# ╔═╡ 29d364af-d96e-450b-97b1-bcc5a312b30b
md"""
As we can see from the above plot, the log transformation maps the darker intensities(0 to L/4) to a wider range (0 to 3L/4).

Conversely, the higher input values are compressed to a narrower range.  

**This has the effect of brightening the dark pixels, while compressing the brighter pixels.**
"""

# ╔═╡ be5aeaca-2e9b-4d6d-a863-894ed1961a8b
function log_transform(pixel)
	return RGB(2log(1+pixel.r), 2log(1+pixel.g), 2log(1+pixel.b))
end;

# ╔═╡ 46a25a81-f6ab-4772-97dc-e614bfb5b5af
[img log_transform.(img)]

# ╔═╡ 75b4d785-96df-4990-952e-9130db058eae
md"""
_Original image (left), Log-transformed image (right)_
"""

# ╔═╡ 128bfb7d-ce3d-4dde-99cf-c391310d0d7b
md"
##### Image thresholding
* All the pixels with intensity levels $<$ than the threshold are set to 0 (black).
* All the pixels with intensity levels $\geq$ than the threshold are set to 1 (white).  
"

# ╔═╡ d1e5b56a-03a9-4b7f-af2b-3b0349f83eb0
cameraman = testimage("camera")

# ╔═╡ 93fbc6fa-43ca-4de1-9cc7-37cfe1cb455f
md"Numeric values of each pixel"

# ╔═╡ 9e62068a-c14b-47a4-95e2-7b3149a0389a
# channelview(cameraman)

# ╔═╡ b6ca20e8-11fe-4bbc-8f3b-58347bab5aa4
md"Threshold slider"

# ╔═╡ 516dbda2-b86f-4872-bdcf-9fc5f66b3596
@bind threshold Slider(0:0.1:1, default=0.5, show_value=true)

# ╔═╡ b2ff30c7-8371-43a0-b1da-66d75cdf39b2
threshold_img(pixel, thres) = pixel < thres ? Gray(0) : Gray(1);

# ╔═╡ 4c885c4f-8f45-40ef-bab6-7e933653440b
[cameraman threshold_img.(cameraman, threshold)]

# ╔═╡ 0b161b67-68c0-4057-94e8-a3d3cf251149
md"""
##### Bit-plane slicing
Each pixel in an image has a bit-depth(the number of bits used to store the intensity value). Each bit of the pixel contributes to the full image. **When we decompose the image into its bit-planes, we can see the relative importance of each plane to the final image.** The higher order bit planes give the visually significant data in the image, the lower order planes give subtle intensity information. 

"""

# ╔═╡ 585a6a44-ea90-42aa-ad12-bd0857986051
begin
	bp = download("$base_path/bit-plane-slicing.png", "bit-plane-slicing.png")
	imresize(load("bit-plane-slicing.png"), ratio=0.8)
end

# ╔═╡ 858a0016-1868-4244-9b39-c9eee8e8528b
md"""

In Julia, `reinterpret(gray(pixel))` gives us the value of a pixel.
**To get the contribution of a pixel to a given bit plane(n), we have to check whether its $n^{th}$ bit is set.** If the $n^{th}$ bit is set, it will _contribute_ to the $n^{th}$ bit-plane of the image.

To check if the $n^{th}$ bit of a pixel is set, compute: 
$pixel$ $\&$ ($1 \ll n$). 
The mask ($1 \ll n$)  gives us a number with the $n^{th}$ bit set and all other bits $0$ (Left shifting $1$, $n$ times). If the bitwise-and of $1 \ll n$ and $pixel$ is $0$, it means the $n^{th}$ is unset.


(Try changing the sllider below to change the bit plane)
"""

# ╔═╡ 99bcdb22-8a93-404d-8e61-c25213a407b3
@bind bit_plane_number Slider(1:8, default=7, show_value=true)

# ╔═╡ 31451725-591d-44fa-a230-b385d522a8da
function bit_plane_transform(pixel, bit_plane)
	value = reinterpret(gray(pixel))
	is_bit_set = value & (1 << (bit_plane - 1))
	factor = is_bit_set == 0 ? 0 : 1
	return Gray(factor)
end;

# ╔═╡ 1f53c41b-8c44-4c3e-854e-ff269271092c
let
	img = Gray.(testimage("airplane"))
	bit_plane = bit_plane_transform.(img, bit_plane_number)
	[img bit_plane]
end

# ╔═╡ 3d14bd45-68cc-4a68-9316-da6479a04ec8
md"""
---
"""

# ╔═╡ 298c6fd5-730b-4358-9fe8-b9501fd37826
md"""
### Neighborhood Operations
These operations operate on the neighbors of a pixel, as the name suggests. We operate on a n*n neighborhood of pixels in this notebook.
##### Max-neighborhood
For each pixel at coordinates (i, j), the pixel with the maximum intensity among its neighbours is the output pixel. This is non-linear filtering technique, **used to remove low intensity noise in the image**.
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
			output[i-pad, j-pad] = maxfinite(padded_img[i-pad:i+pad, j-pad:j+pad])
		end
	end
	
	return output
end;

# ╔═╡ fbb9c4da-9b49-475f-be59-59b44d17c6f8
md"""
Control window size
"""

# ╔═╡ a8f5c334-a364-4ccd-a4f2-dd00d3feb897
@bind max_neighbour_window_size Slider(3:2:9, show_value=true)

# ╔═╡ e3fe9f4c-b29f-4c31-aa09-af86a334a5f9
let
	tmp = download("$base_path/hip-pepper.jpg", "hip-pepper.jpg")
	noisy_img = load("hip-pepper.jpg")
	denoised = max_neighbour_filtering(noisy_img, max_neighbour_window_size)
	[noisy_img denoised]
	# [noisy_img dilate(Gray.(noisy_img))]
end

# ╔═╡ f001bee6-48b2-4f42-8c91-38de1b1ac09f
md"""
_Noisy image (left), Denoised image (right)_
"""

# ╔═╡ 28e6ad2b-9e57-48c1-941d-0e2f7f256e7a
testimg = Gray.(testimage("morphology_test_512"))

# ╔═╡ 086cf49b-6574-4738-aae1-b62881ebf6e9
img_dilate = @. Gray(testimg > 0.9)

# ╔═╡ bf61fd52-623e-41c4-91fb-1a14f7d23f2e
[testimg dilate(testimg)]

# ╔═╡ effba953-4734-4bd8-bcfa-e3f3f55d908b
md"""
##### Median neighborhood
The median filter is a non-linear filtering technique, often **used to remove noise from an image**. This is generally used as a pre-processing step for downstream processes like edge-detection. This is preferred over other filters because it **preserves edges while removing noise.** Its particularly effective for images affected by **speckle noise or salt-and-pepper noise**.
"""

# ╔═╡ ba0b747a-ef09-408d-beb2-2064cee09ae3
function median_neighborhood_filtering(img, window_size)
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
end;

# ╔═╡ e8a8535e-c0e5-4a90-85f2-0ae05cd32c0f
md"""
Control window size
"""

# ╔═╡ 9ad5dbfb-5230-4d87-ad45-9629c97580a7
@bind median_neighbour_window_size Slider(3:2:9, show_value=true)

# ╔═╡ fe88767b-a729-4d45-8a54-69626e7905cc
let
	tmp = download("$base_path/Noise_salt_and_pepper.png", "Noise_salt_and_pepper.png")
	noisy_img = load("Noise_salt_and_pepper.png")
	denoised = median_neighborhood_filtering(noisy_img, 3)
	[noisy_img denoised]
end

# ╔═╡ 22388ef5-f229-4236-9b4d-573dbe23e4e5
md"""
_Image affected by salt-and-pepper noise (left), denoised image (right)_
"""

# ╔═╡ de4d84d3-cc34-4ca4-80dc-d9e96ad73783
md"""
---
"""

# ╔═╡ 877da570-cb9c-4e25-ab57-5fcb93eec202
# function correlate(img, kernel)
# 	out = copy(img)
# 	h, w = size(out)
# 	kernel_size = size(kernel)
# 	limit = kernel_size[1] ÷ 2
	
# 	padded_img = PaddedView(0, img, (h + limit*2, w + limit*2), (limit+1, limit+1))
# 	padded_img
# 	# output image coordinates: original dimensions 	
# 	for x in 1 + limit : h + limit
# 		for y in 1 + limit : h + limit
# 			temp_sum = 0
# 			# kernel coordinates
# 			for i in -limit:limit
# 				for j in -limit:limit
# 					temp_sum += kernel[i,j] * padded_img[x+i, y+j]
# 				end
# 			end
		
# 			out[x-limit][y-limit] = temp_sum
				
# 		end
# 	end
	
# 	return out[x][y]
# end

# ╔═╡ fed19b2b-3cd6-4510-a47a-c48adcb5434a
# correlate(cameraman, kernel)

# ╔═╡ 8f2f56f3-6764-4274-817e-41a013b860bb
# begin
# 	a = [x for x in 1:5]
# 	b = [y for y in 10:10:50]
# 	ele_mul = a .* b
# 	total = sum(ele_mul)
# end

# ╔═╡ ae8d1c5b-5b28-4e94-a619-c759de9e85bd
# begin
# 	t1 = zeros(2, 3)
# 	t2 = ones(2, 3) / 2
# 	t1 + t2
# end

# ╔═╡ 86471aae-d3e7-4142-b0bb-fe50c0ce6016
# max_neighborhood(img, i, j) = maxfinite(img[i-1:i+1, j-1:j+1])

# ╔═╡ 123162f5-7d35-40a7-8737-9ebae29acc93
md"""
### Operations on a set of images
#### Arithmetic Operations
##### Subtraction
"""

# ╔═╡ 1be6533b-be1a-45e2-a56c-18f9cc82ff98
md"""
On the left is a microscopic image of cells. The image has improper illumination, making it hard to make out details. In the middle we have a reference image that has the same illumination variation as the first image.

**Subtrating these 2 images will give an image with uniform illumination.**

This subtraction operation could result in negative values. _In Julia, negative values are clamped to 0, producing a black pixel._ **To avoid negative values, we can add a big constant to the first image**.
"""

# ╔═╡ fd263a3c-4564-4277-b1a7-c513037788d1
let
	tmp = download("$base_path/collenchyma.jpg", "collenchyma.jpg")
	original = load("collenchyma.jpg")
	tmp = download("$base_path/reference.jpg", "reference.jpg")
	reference = load("reference.jpg")
	temp = copy(original)
	# add a constant to avoid negative values
	temp = Gray(109/255) .+ original
	# subtract the reference image from the original image
	better_illumination = temp .- reference
	[original reference better_illumination]
end

# ╔═╡ acfe7a7c-5fa9-4e06-bd27-36787c2ab1ae
md"""
_Original image(left), reference illumination (centre), uniform illumination (right)_
"""

# ╔═╡ 3ec6e5ae-0119-4beb-9681-e19c1e0dc0c9
md"""
##### Multiplication
Each pixel in the output image is the product of the corresponding pixel in the first and second image.
"""

# ╔═╡ 33afa793-3ff9-4964-8dad-55defac879ed
let
	airplane = testimage("airplane")
	radialgradient = download("$base_path/radialgradient.png", "radialgradient.png")
	radialgradient = load("radialgradient.png")
	# hadarmard product -> elementwise product
	temp = airplane .⊙ radialgradient
	[airplane radialgradient temp]
end

# ╔═╡ 6a5e4c6f-0c39-460d-8a71-a8a24d5c5e22
md"""
_Original image(left), Radial gradient (centre), Image product (right)_
"""

# ╔═╡ 925662c4-5ebd-4a26-a8be-9c80dbbfb0b7
md"""
---
"""

# ╔═╡ b2e27047-d19d-47bf-8ebd-6f820b629d71
md"""
##### Logical operations: AND
"""

# ╔═╡ 2329ab22-ff21-4dae-9145-aabe0bca97c0
begin
	cars = download("$base_path/cars.jpg", "cars.jpg")
	circle_mask = download("$base_path/circle-mask.jpg", "circle-mask.jpg")
	cars = imresize(load("cars.jpg"), ratio=0.6)
	circle_mask = imresize(load("circle-mask.jpg"), ratio=0.6)
end;

# ╔═╡ 1fd2b39e-ed9a-43c0-9793-896b0515545e
function bitwise_and(a, b)
	val = reinterpret(gray(a)) & reinterpret(gray(b))
	return Gray(float(val)/255)
end;

# ╔═╡ ea7c0ffc-5a9a-4b01-ab55-29710a253d20
[cars circle_mask bitwise_and.(cars, circle_mask)]

# ╔═╡ f68d4416-40cb-47f5-8fc2-c113f589b67a
md"""
_Original image(left), Mask (centre), AND operation output (right)_
"""

# ╔═╡ 93a381de-6c08-4450-bc54-ffac22d58fc7
md"""
##### Logical operations: OR
"""

# ╔═╡ 9ce779dd-b4fc-42b1-b144-e5dd2cd65161
function bitwise_or(a, b)
	val = reinterpret(gray(a)) | reinterpret(gray(b))
	return Gray(float(val)/255)
end;

# ╔═╡ 5ced9bed-d646-4c61-8580-860e2d7e7c56
[cars circle_mask bitwise_or.(cars, circle_mask)]

# ╔═╡ c7049d45-4559-484a-95ae-afbddd4df88b
md"""
_Original image(left), Mask (centre), OR operation output (right)_
"""

# ╔═╡ f593417e-7c21-46f0-a61a-c8feed53bacd
md"""
---
"""

# ╔═╡ 9867b901-9520-466a-859c-79f133c97c0d
md"""
### Statistical operations
#### Median
"""

# ╔═╡ a1b61e01-c17c-4c5c-b93e-8bf1ab2ea8a9
md"""
Median intensity level in the image ($0-1$ intensity scale)
"""

# ╔═╡ 18890635-5b71-44af-9af1-f092c7b21ed3
[median(channelview(cameraman))]

# ╔═╡ faab4575-9e29-4c66-bc0c-a9b06d76a582
md"""
Median value in image as a pixel
"""

# ╔═╡ 3d5b636a-8b6a-4a20-8541-d1a90a7a867b
median(cameraman)

# ╔═╡ fa2723ec-924f-452f-805a-f519f1e5ce11
md"""
#### Standard deviation
"""

# ╔═╡ 214853e1-8f70-4716-889f-70f067bd3503
std(channelview(cameraman))

# ╔═╡ 3ac33561-1487-4d32-aec4-e6152f57e085
md"""
---
"""

# ╔═╡ 1078d659-cf33-4609-8e49-cfe40debfd82
let
	part = cameraman[50:300, 100:400]
	# interpolation after zooming
	imresize(part, (351, 401), method=BSpline(Linear()))
end

# ╔═╡ fb449373-e438-40c5-9ffc-006b8da4a555
let
	t = Translation(-50, -50)
	translated = warp(cameraman, t, indices_spatial(cameraman), 0)
	[cameraman translated]
end

# ╔═╡ 332901b6-c107-48d0-afd5-a42fd2c384ec
md"""
Up sampling
"""

# ╔═╡ bef4924f-65b9-4bc1-8eff-4c1d19c9946f
imresize(cameraman, (600, 600), method=BSpline(Linear()))

# ╔═╡ Cell order:
# ╟─b3c895eb-552f-4a2f-a46c-5588ceb36928
# ╟─126ed5e7-d15e-409e-929d-c68a87900be2
# ╠═51d657ba-3305-4fa6-93d0-fe75252621b8
# ╠═ae17bd41-7958-4c1c-919c-ba63fc8b32a4
# ╠═ec05e818-a041-40ae-b6f2-076c40d97210
# ╠═c4e69a41-35e2-4532-b6a7-0ec268de433e
# ╠═9174cb97-9a85-4d60-af92-d96fa988dcec
# ╟─03daf2e9-a9d4-49f4-9969-1944d8bf5ffb
# ╠═5c75b3ce-8d3c-42d4-bc3c-26d4c7fd037a
# ╠═2acb8aff-810b-48e7-8ba7-6cec1687b64d
# ╟─ffa79434-ac83-49e8-abc0-422ff8012449
# ╠═6ec82a8f-2851-485a-9fbd-d9576e606471
# ╟─6ee6ac94-a589-485c-bdbb-a02f147fec14
# ╟─77f0d940-acd1-4a6b-b5cc-9477342ea4ba
# ╟─29d364af-d96e-450b-97b1-bcc5a312b30b
# ╠═be5aeaca-2e9b-4d6d-a863-894ed1961a8b
# ╠═46a25a81-f6ab-4772-97dc-e614bfb5b5af
# ╟─75b4d785-96df-4990-952e-9130db058eae
# ╟─128bfb7d-ce3d-4dde-99cf-c391310d0d7b
# ╠═d1e5b56a-03a9-4b7f-af2b-3b0349f83eb0
# ╟─93fbc6fa-43ca-4de1-9cc7-37cfe1cb455f
# ╠═9e62068a-c14b-47a4-95e2-7b3149a0389a
# ╟─b6ca20e8-11fe-4bbc-8f3b-58347bab5aa4
# ╟─516dbda2-b86f-4872-bdcf-9fc5f66b3596
# ╠═b2ff30c7-8371-43a0-b1da-66d75cdf39b2
# ╠═4c885c4f-8f45-40ef-bab6-7e933653440b
# ╟─0b161b67-68c0-4057-94e8-a3d3cf251149
# ╟─585a6a44-ea90-42aa-ad12-bd0857986051
# ╟─858a0016-1868-4244-9b39-c9eee8e8528b
# ╟─99bcdb22-8a93-404d-8e61-c25213a407b3
# ╠═31451725-591d-44fa-a230-b385d522a8da
# ╠═1f53c41b-8c44-4c3e-854e-ff269271092c
# ╟─3d14bd45-68cc-4a68-9316-da6479a04ec8
# ╟─298c6fd5-730b-4358-9fe8-b9501fd37826
# ╟─64cd7fec-ea56-47ac-8a39-f860c822b3e3
# ╠═1f88e842-449f-453b-92bc-c7879e227236
# ╟─fbb9c4da-9b49-475f-be59-59b44d17c6f8
# ╠═a8f5c334-a364-4ccd-a4f2-dd00d3feb897
# ╠═e3fe9f4c-b29f-4c31-aa09-af86a334a5f9
# ╟─f001bee6-48b2-4f42-8c91-38de1b1ac09f
# ╠═28e6ad2b-9e57-48c1-941d-0e2f7f256e7a
# ╠═086cf49b-6574-4738-aae1-b62881ebf6e9
# ╠═bf61fd52-623e-41c4-91fb-1a14f7d23f2e
# ╟─effba953-4734-4bd8-bcfa-e3f3f55d908b
# ╠═ba0b747a-ef09-408d-beb2-2064cee09ae3
# ╟─e8a8535e-c0e5-4a90-85f2-0ae05cd32c0f
# ╠═9ad5dbfb-5230-4d87-ad45-9629c97580a7
# ╠═fe88767b-a729-4d45-8a54-69626e7905cc
# ╟─22388ef5-f229-4236-9b4d-573dbe23e4e5
# ╟─de4d84d3-cc34-4ca4-80dc-d9e96ad73783
# ╠═877da570-cb9c-4e25-ab57-5fcb93eec202
# ╠═fed19b2b-3cd6-4510-a47a-c48adcb5434a
# ╠═8f2f56f3-6764-4274-817e-41a013b860bb
# ╠═ae8d1c5b-5b28-4e94-a619-c759de9e85bd
# ╠═86471aae-d3e7-4142-b0bb-fe50c0ce6016
# ╟─123162f5-7d35-40a7-8737-9ebae29acc93
# ╟─1be6533b-be1a-45e2-a56c-18f9cc82ff98
# ╠═fd263a3c-4564-4277-b1a7-c513037788d1
# ╟─acfe7a7c-5fa9-4e06-bd27-36787c2ab1ae
# ╟─3ec6e5ae-0119-4beb-9681-e19c1e0dc0c9
# ╠═33afa793-3ff9-4964-8dad-55defac879ed
# ╟─6a5e4c6f-0c39-460d-8a71-a8a24d5c5e22
# ╟─925662c4-5ebd-4a26-a8be-9c80dbbfb0b7
# ╟─b2e27047-d19d-47bf-8ebd-6f820b629d71
# ╠═2329ab22-ff21-4dae-9145-aabe0bca97c0
# ╠═1fd2b39e-ed9a-43c0-9793-896b0515545e
# ╠═ea7c0ffc-5a9a-4b01-ab55-29710a253d20
# ╟─f68d4416-40cb-47f5-8fc2-c113f589b67a
# ╟─93a381de-6c08-4450-bc54-ffac22d58fc7
# ╠═9ce779dd-b4fc-42b1-b144-e5dd2cd65161
# ╠═5ced9bed-d646-4c61-8580-860e2d7e7c56
# ╟─c7049d45-4559-484a-95ae-afbddd4df88b
# ╟─f593417e-7c21-46f0-a61a-c8feed53bacd
# ╟─9867b901-9520-466a-859c-79f133c97c0d
# ╟─a1b61e01-c17c-4c5c-b93e-8bf1ab2ea8a9
# ╠═18890635-5b71-44af-9af1-f092c7b21ed3
# ╟─faab4575-9e29-4c66-bc0c-a9b06d76a582
# ╠═3d5b636a-8b6a-4a20-8541-d1a90a7a867b
# ╟─fa2723ec-924f-452f-805a-f519f1e5ce11
# ╠═214853e1-8f70-4716-889f-70f067bd3503
# ╟─3ac33561-1487-4d32-aec4-e6152f57e085
# ╠═ce6f6f97-1c33-4426-94bd-e8e55d2a7fbc
# ╠═9cfac619-cf98-4276-aec8-75d32e6f4f81
# ╠═b5c2d0c2-6001-4e17-9a58-d394cfa25090
# ╠═1078d659-cf33-4609-8e49-cfe40debfd82
# ╠═fb449373-e438-40c5-9ffc-006b8da4a555
# ╟─332901b6-c107-48d0-afd5-a42fd2c384ec
# ╠═bef4924f-65b9-4bc1-8eff-4c1d19c9946f
