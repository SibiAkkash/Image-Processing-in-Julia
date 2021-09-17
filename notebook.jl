### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 51d657ba-3305-4fa6-93d0-fe75252621b8
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
		"CoordinateTransformations",
		"Images",
		"ImageMorphology",
		"ImageIO", 
		"Interpolations",
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
	using Interpolations, CoordinateTransformations
end

# ╔═╡ b3c895eb-552f-4a2f-a46c-5588ceb36928
md"""
## Image processing in Julia


Julia is a flexible dynamic language, appropriate for scientific and numerical computing, with **performance comparable to traditional statically-typed languages**.


JuliaImages hosts the major Julia packages for image processing. Julia is well-suited to image processing because it is a modern and elegant high-level language that is a pleasure to use, while also **allowing you to write "inner loops" that compile to efficient machine code (i.e., it is as fast as C)**. Julia supports multithreading and, through add-on packages, GPU processing.

"""

# ╔═╡ 5e450d7a-9704-4371-831c-83a82a8fc1fb
imresize(load("images/julia.png"), ratio=0.1)

# ╔═╡ 126ed5e7-d15e-409e-929d-c68a87900be2
md"""
---
##### Loading necessary packages
"""

# ╔═╡ 817fc381-dbdd-42aa-be15-2c3743ebf89c
md"""
### Morphological operations
##### m-adjacency
"""

# ╔═╡ f7f1a2e8-afd1-49e1-a2b0-5623cd98c0fc
md"""
2 pixels $P$, $Q$ $\in$ $V$ are m-adjacent if

$1)\hspace{0.5cm} Q \in N_{4}(P)$
$(or)$
$2)\hspace{0.5cm} Q \in N_{8}(P) \hspace{0.5cm} \& \hspace{0.5cm} N_{4}(P) \cap N_{4}(Q) = \emptyset$

This means, if Q is 4-connected to P, they are m-adjacent. Else if Q is 8-connected to P, and, P, Q has no common 4-connected neighbors, they are m-adjacent.

$\hspace{0.5cm} V = (0)$

"""

# ╔═╡ 0fb3abd3-dd3f-4052-8480-2240030dc00a
image = [
			0 1 0 0 0 1 0; 
			1 0 1 0 1 0 1; 
			0 1 0 0 0 1 0; 
			1 0 0 0 1 0 1; 
			0 0 0 1 0 0 0;
			1 0 1 0 1 0 0;
			0 1 0 0 0 1 0
		]

# ╔═╡ 6426a726-5dff-4201-8b90-7cf39f45b218
function n8(img, (i, j))
	out = []
	h, w = size(img)
	steps = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)]
	for p in 1:8
		x, y = steps[p]
		if 1 <= i + x <= w && 1 <= j + y <= h && img[i+x, j+y] == 0
			push!(out, (i+x, j+y))
		end
	end
	return out
end

# ╔═╡ 204c6986-8c2f-42ef-ac4d-effdcd261542
function n4(img, (i, j))
	out = []
	h, w = size(img)
	steps = [(-1, 0), (1, 0), (0, -1), (0, 1)]
	for p in 1:4
		x, y = steps[p]
		if 1 <= i + x <= w && 1 <= j + y <= h && img[i+x, j+y] == 0
			push!(out, (i+x, j+y))
		end
	end
	return out
end

# ╔═╡ fb706db8-bcc1-4676-a9d4-814f448ffa30
function is_m_adj(img, a, b)
	is_4_connected = b in n4(image, a)
	ans = false
	if is_4_connected
		ans = true
	else
		is_8_connected = b in n8(image, a)
		common_neighbors = intersect(n4(image, a), n4(image, b))
		if is_8_connected && size(common_neighbors)[1] == 0
			ans = true
		end
	end
	return ans
end

# ╔═╡ 011fa462-d3ce-4f07-95ab-b96f9266ecec
let
	a = (3, 3)
	b = (4, 4) 
	is_m_adj(image, a, b)
end

# ╔═╡ 24a542b3-45d8-4dc8-ac99-b9ac075c533c
md"""
(3, 3) and (4, 4) are not m-adjacent
"""

# ╔═╡ ddf3ddab-f590-4059-bd51-79146c1e709b
let
	a = (1, 1)
	b = (2, 2) 
	is_m_adj(image, a, b)
end

# ╔═╡ 63ac29f3-fbf4-4459-9c50-32e8d62961a2
md"""
(1, 1) and (2, 2) are m-adjacent
"""

# ╔═╡ d6137613-4fbd-4100-a54f-b1f6411a3b6e
md"""
---
"""

# ╔═╡ c4e69a41-35e2-4532-b6a7-0ec268de433e
img = testimage("lighthouse")

# ╔═╡ 9174cb97-9a85-4d60-af92-d96fa988dcec
typeof(img)

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
load("images/log_transform.png")

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
* All the pixels with intensity levels $\geq$ than the threshold are set to 1 (white).  "

# ╔═╡ d1e5b56a-03a9-4b7f-af2b-3b0349f83eb0
cameraman = testimage("camera")

# ╔═╡ 93fbc6fa-43ca-4de1-9cc7-37cfe1cb455f
md"**Numeric values of each pixel**"

# ╔═╡ 9e62068a-c14b-47a4-95e2-7b3149a0389a
channelview(cameraman)

# ╔═╡ b2ff30c7-8371-43a0-b1da-66d75cdf39b2
threshold_img(pixel, thres) = pixel < thres ? Gray(0) : Gray(1);

# ╔═╡ 4c885c4f-8f45-40ef-bab6-7e933653440b
[cameraman threshold_img.(cameraman, 0.5) threshold_img.(cameraman, 0.1)]

# ╔═╡ 36288155-8162-48ba-bafc-c671111ef685
md"""
_Original image, threshold = $0.5$, threshold = $0.1$ (left to right)_
"""

# ╔═╡ 0b161b67-68c0-4057-94e8-a3d3cf251149
md"""
##### Bit-plane slicing
Each pixel in an image has a bit-depth(the number of bits used to store the intensity value). Each bit of the pixel contributes to the full image. **When we decompose the image into its bit-planes, we can see the relative importance of each plane to the final image.** The higher order bit planes give the visually significant data in the image, the lower order planes give subtle intensity information. 

"""

# ╔═╡ 585a6a44-ea90-42aa-ad12-bd0857986051
imresize(load("images/bit-plane-slicing.png"), ratio=0.8)

# ╔═╡ 858a0016-1868-4244-9b39-c9eee8e8528b
md"""

In Julia, `reinterpret(gray(pixel))` gives us the value of a pixel.
**To get the contribution of a pixel to a given bit plane(n), we have to check whether its $n^{th}$ bit is set.** If the $n^{th}$ bit is set, it will _contribute_ to the $n^{th}$ bit-plane of the image.

To check if the $n^{th}$ bit of a pixel is set, compute: 
$pixel$ $\&$ ($1 \ll n$). 
The mask ($1 \ll n$)  gives us a number with the $n^{th}$ bit set and all other bits $0$ (Left shifting $1$, $n$ times). If the bitwise-and of $1 \ll n$ and $pixel$ is $0$, it means the $n^{th}$ pixel is unset.

"""

# ╔═╡ 31451725-591d-44fa-a230-b385d522a8da
function bit_plane_transform(pixel, bit_plane)
	value = reinterpret(gray(pixel))
	is_bit_set = value & (1 << (bit_plane - 1))
	factor = is_bit_set == 0 ? 0 : 1
	return Gray(factor)
end;

# ╔═╡ 1f53c41b-8c44-4c3e-854e-ff269271092c
begin
	airplane = Gray.(testimage("airplane"))
	bit_planes = [bit_plane_transform.(airplane, n) for n in 1:8]
end;

# ╔═╡ a700b387-3896-467e-ae2a-c641ba6b6e82
[airplane bit_planes[8] bit_planes[7]]

# ╔═╡ cd2883a5-66c5-4984-ab67-9e67d9123f0a
md"""
_Original image, $8^{th}$ bit-plane, $7^{th}$ bit-plane (left to right)._
"""

# ╔═╡ 315711f4-a941-4803-b1aa-82f8bba8742a
[bit_planes[6] bit_planes[5] bit_planes[4]]

# ╔═╡ dbd06f30-fc23-4350-ac04-217957953a47
md"""
_$6^{th}$ bit-plane, $5^{th}$ bit-plane, $4^{th}$ bit-plane (left to right)._
"""

# ╔═╡ ac9d1af6-fc97-4a3a-a35f-0741056e35b7
[bit_planes[3] bit_planes[2] bit_planes[1]]

# ╔═╡ a4468550-d09a-4e02-98eb-25d6a0bfec3f
md"""
_$3^{rd}$ bit-plane, $2^{nd}$ bit-plane, $1^{st}$ bit-plane (left to right)._
"""

# ╔═╡ 3d14bd45-68cc-4a68-9316-da6479a04ec8
md"""
---
"""

# ╔═╡ 298c6fd5-730b-4358-9fe8-b9501fd37826
md"""
### Neighborhood Operations
These operations operate on the neighbors of a pixel, as the name suggests. We operate on a $n*n$ neighborhood of pixels in this notebook.
##### Max-neighborhood
For each pixel at coordinates (i, j), the pixel with the maximum intensity among its neighbours is the output pixel. This is non-linear filtering technique, **used to remove low intensity noise in the image**.
"""

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

# ╔═╡ e3fe9f4c-b29f-4c31-aa09-af86a334a5f9
let
	noisy_img = load("images/hip-pepper.jpg")
	denoised = max_neighbour_filtering(noisy_img, 3)
	[noisy_img denoised]
end

# ╔═╡ f001bee6-48b2-4f42-8c91-38de1b1ac09f
md"""
_Noisy image (left), Denoised image (right)_
"""

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

# ╔═╡ fe88767b-a729-4d45-8a54-69626e7905cc
begin
	noisy_img = load("images/Noise_salt_and_pepper.png")
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
	original = load("images/collenchyma.jpg")
	reference = load("images/reference.jpg")
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
The output looks like a binocular image of an airplane.
"""

# ╔═╡ 33afa793-3ff9-4964-8dad-55defac879ed
let
	airplane = testimage("airplane")
	radialgradient = load("images/radialgradient.png")
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
	cars = imresize(load("images/cars.jpg"), ratio=0.6)
	circle_mask = imresize(load("images/circle-mask.jpg"), ratio=0.6)
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
_Original image(left), mask (centre), AND operation output (right)_
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
Median value as a pixel
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

# ╔═╡ 01a993a9-30fc-47ca-a6a1-9499a0fc7205
md"""
##### Zooming
In zooming, a part of the image is isolated, and interpolated to accomodate the missing pixels.
"""

# ╔═╡ 1078d659-cf33-4609-8e49-cfe40debfd82
let
	part = cameraman[50:300, 100:400]
	# interpolation after zooming
	imresize(part, (351, 401), method=BSpline(Linear()))
end

# ╔═╡ ce1d5083-922d-449c-9e60-8262e6b13223
md"""
##### Translation
A coordinate translation, that pushes each pixel to the right by 50 units, down by 50 units.
"""

# ╔═╡ fb449373-e438-40c5-9ffc-006b8da4a555
let
	t = Translation(-50, -50)
	translated = warp(cameraman, t, indices_spatial(cameraman), 0)
	[cameraman translated]
end

# ╔═╡ 9debde7c-4b6b-4cb3-85a4-605ecdd5be7c
md"""
---
"""

# ╔═╡ 332901b6-c107-48d0-afd5-a42fd2c384ec
md"""
### Image interpolation
##### Up sampling
Upsampling is the increasing of the spatial resolution while keeping the 2D representation of an image. It is typically used for zooming in on a small region of an image, and for eliminating the pixelation effect that arises when a low-resolution image is displayed on a relatively large frame.
"""

# ╔═╡ bef4924f-65b9-4bc1-8eff-4c1d19c9946f
imresize(cameraman, (600, 600), method=BSpline(Linear()))

# ╔═╡ dc75ccaa-25d8-48a8-ad25-cb4825cbbf63
md"""
---
"""

# ╔═╡ Cell order:
# ╟─b3c895eb-552f-4a2f-a46c-5588ceb36928
# ╟─5e450d7a-9704-4371-831c-83a82a8fc1fb
# ╟─126ed5e7-d15e-409e-929d-c68a87900be2
# ╠═51d657ba-3305-4fa6-93d0-fe75252621b8
# ╟─817fc381-dbdd-42aa-be15-2c3743ebf89c
# ╟─f7f1a2e8-afd1-49e1-a2b0-5623cd98c0fc
# ╠═0fb3abd3-dd3f-4052-8480-2240030dc00a
# ╠═6426a726-5dff-4201-8b90-7cf39f45b218
# ╠═204c6986-8c2f-42ef-ac4d-effdcd261542
# ╠═fb706db8-bcc1-4676-a9d4-814f448ffa30
# ╠═011fa462-d3ce-4f07-95ab-b96f9266ecec
# ╟─24a542b3-45d8-4dc8-ac99-b9ac075c533c
# ╠═ddf3ddab-f590-4059-bd51-79146c1e709b
# ╟─63ac29f3-fbf4-4459-9c50-32e8d62961a2
# ╟─d6137613-4fbd-4100-a54f-b1f6411a3b6e
# ╠═c4e69a41-35e2-4532-b6a7-0ec268de433e
# ╠═9174cb97-9a85-4d60-af92-d96fa988dcec
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
# ╠═b2ff30c7-8371-43a0-b1da-66d75cdf39b2
# ╠═4c885c4f-8f45-40ef-bab6-7e933653440b
# ╟─36288155-8162-48ba-bafc-c671111ef685
# ╟─0b161b67-68c0-4057-94e8-a3d3cf251149
# ╟─585a6a44-ea90-42aa-ad12-bd0857986051
# ╟─858a0016-1868-4244-9b39-c9eee8e8528b
# ╠═31451725-591d-44fa-a230-b385d522a8da
# ╠═1f53c41b-8c44-4c3e-854e-ff269271092c
# ╟─a700b387-3896-467e-ae2a-c641ba6b6e82
# ╟─cd2883a5-66c5-4984-ab67-9e67d9123f0a
# ╟─315711f4-a941-4803-b1aa-82f8bba8742a
# ╟─dbd06f30-fc23-4350-ac04-217957953a47
# ╟─ac9d1af6-fc97-4a3a-a35f-0741056e35b7
# ╟─a4468550-d09a-4e02-98eb-25d6a0bfec3f
# ╟─3d14bd45-68cc-4a68-9316-da6479a04ec8
# ╟─298c6fd5-730b-4358-9fe8-b9501fd37826
# ╠═1f88e842-449f-453b-92bc-c7879e227236
# ╠═e3fe9f4c-b29f-4c31-aa09-af86a334a5f9
# ╟─f001bee6-48b2-4f42-8c91-38de1b1ac09f
# ╟─effba953-4734-4bd8-bcfa-e3f3f55d908b
# ╠═ba0b747a-ef09-408d-beb2-2064cee09ae3
# ╠═fe88767b-a729-4d45-8a54-69626e7905cc
# ╟─22388ef5-f229-4236-9b4d-573dbe23e4e5
# ╟─de4d84d3-cc34-4ca4-80dc-d9e96ad73783
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
# ╟─01a993a9-30fc-47ca-a6a1-9499a0fc7205
# ╠═1078d659-cf33-4609-8e49-cfe40debfd82
# ╟─ce1d5083-922d-449c-9e60-8262e6b13223
# ╠═fb449373-e438-40c5-9ffc-006b8da4a555
# ╟─9debde7c-4b6b-4cb3-85a4-605ecdd5be7c
# ╟─332901b6-c107-48d0-afd5-a42fd2c384ec
# ╠═bef4924f-65b9-4bc1-8eff-4c1d19c9946f
# ╟─dc75ccaa-25d8-48a8-ad25-cb4825cbbf63
