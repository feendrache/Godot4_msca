class_name MSCAPaletteSwaps

func change_image_colors(image, old_palette, new_palette, debug_text = "") -> Image:
	if image != null:
		# Get the size of the image
		var image_width = image.get_width()
		var image_height = image.get_height()
		var new_image = Image.create(image_width, image_height, false, Image.FORMAT_RGBA8)

		# Iterate over the pixel data
		for x in range(image_width):
			for y in range(image_height):
				var color = image.get_pixel(x,y)
				#print(color)
				if color.a > 0:
					var pos_in_palette = get_pos_in_palette(old_palette,color)
					if pos_in_palette != -1 && new_palette.size() > pos_in_palette:
						new_image.set_pixel(x,y,new_palette[pos_in_palette])
					else:
						new_image.set_pixel(x,y,color)
		return new_image
	return null

func create_html_palette_from_image(image) ->Array:
	var palette = create_palette_from_image(image)
	return color_to_html_palette(palette)

func color_to_html_palette(palette) -> Array:
	var html_palette = []
	for p in palette:
		if p is Color: html_palette.append("#"+p.to_html(true))
		else: html_palette.append(p)
	return html_palette

func html_to_color_palette(palette) -> Array:
	var color_palette = []
	for p in palette:
		if p is Color: color_palette.append(p)
		else: color_palette.append(Color(p))
	return color_palette

func create_palette_from_image(image) ->Array:
	if image == null: return []
	var palette:Array
	# Get the size of the image
	var image_width = image.get_width()
	var image_height = image.get_height()

	
	# Iterate over the pixel data
	for y in range(image_height):
		for x in range(image_width):
			var color = image.get_pixel(x,y)
			if color.a > 0:
				if !palette.has(color):
					palette.append(color)
	return palette

func create_palette_from_texture(node_texture) ->Array:
	return create_palette_from_image(node_texture.get_image())

func get_pos_in_palette(palette, color)->int:
	var pos = 0
	var found:bool
	for c in palette:
		if c is String: c = Color(c)
		if c.r == color.r && c.g == color.g && color.b == color.b: return pos
		pos = pos + 1
	return -1

func get_combined_image(img1, img2)->Image:
	var size1 = img1.get_size()
	var size2 = img2.get_size()
	var new_size = Vector2(size1.x+size2.x,size1.y)
	var combined = img1.get_image()
	combined.resize(new_size.x, new_size.y)
	combined.blend_rect(img1.get_image(),Rect2i(Vector2i.ZERO,size1),Vector2i(0,0))
	combined.blend_rect(img2.get_image(),Rect2i(Vector2i.ZERO,size2),Vector2i(size1.x,0))
	return combined
