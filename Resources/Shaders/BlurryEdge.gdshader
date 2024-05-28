shader_type canvas_item;

uniform vec3 color:source_color;
uniform sampler2D noise:repeat_enable;
uniform float blurIntensity;
uniform float flatColorHeight;
uniform float noiseXSpeed1;
uniform float noiseYSpeed1;
uniform float noiseXSpeed2;
uniform float noiseYSpeed2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float xScroll1 = TIME * noiseXSpeed1;
	float yScroll1 = TIME * noiseYSpeed1;
	vec2 scrollingUV1 = UV + vec2(xScroll1, yScroll1);
	
	float xScroll2 = TIME * noiseXSpeed2;
	float yScroll2 = TIME * noiseYSpeed2;
	vec2 scrollingUV2 = (UV * 2.0) + vec2(xScroll2, yScroll2);
	
	vec4 noiseTexture1 = texture(noise, scrollingUV1);
	vec4 noiseTexture2 = texture(noise, scrollingUV2);
	
	noiseTexture2.r = pow(noiseTexture2.r, 0.4);
	
	float flatBottom = pow(UV.g, 3);
	vec4 finalNoise = noiseTexture1 * noiseTexture2 + flatBottom;
	
	finalNoise.r = pow(finalNoise.r, 1.0);
	
	vec3 colorNoise = noiseTexture1.rbg * noiseTexture2.rgb * flatBottom;
	COLOR.rgb = color + (colorNoise * 0.05);
	COLOR.a = pow(UV.g, blurIntensity) * flatColorHeight * (finalNoise.r);
}
