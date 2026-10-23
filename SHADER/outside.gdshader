shader_type canvas_item;

uniform int pixel_size = 4; // Adjust for pixel size

void fragment() {
    // Round UVs to create the pixelated grid
    vec2 pix_uv = round(SCREEN_UV * float(pixel_size)) / float(pixel_size);
    COLOR = texture(SCREEN_TEXTURE, pix_uv);
}   