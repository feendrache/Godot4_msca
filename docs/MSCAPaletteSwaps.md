# Palette Swaps or: the Swapper

This class provides some helper for palette swapping

## change_image_colors
This function actually creates a new image where all the colors of the base ramp are swapped with the colors of the new ramp. 

This will only function when you provide the original image with the base ramps set on it and it will return a new Image 

Please be aware that this is quite time consuming when used in game, the FarmerSpriteCustomizer uses this function to create the baked Spritesheets you get out of it

### create_palette_from_image
It takes an image and iterates over all pixels row by row to get all colors out of it and gives back an array of these colors

### create_palette_from_texture
Use this if you want to get the palette from a Texture

### create_html_palette_from_image
Gets the colors out of an image and returns them as HTML color values

### color_to_html_palette
Turn color values to html-color values

### html_to_color_palette
Turn html-color values to colors

### get_pos_in_palette
provide a palette and a color and this function will give you the position in the palette

### get_combined_image
This bakes two images together so you have only one.
