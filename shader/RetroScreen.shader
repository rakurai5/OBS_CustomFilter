uniform float Pixelate = 100.0;
uniform int  Posterize = 1.0;
uniform float Hue = 0.0;
uniform float Saturation = 1.0;

float luminance(float3 rgb)
{
    float3 W = float3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

float3  posterize(float3 color, int power)
{
    float div= 256.0 / power;
    float3 pos = ( floor( color * div ) / div );
    return pos;
}

float3 hsv2rgb(float hue, float saturation, float value)
{
	return ((clamp(abs(frac(hue+float3(0,2,1)/3.)*6.-3.)-1.,0.,1.)-1.)*saturation+1.)*value;
}




float4 mainImage(VertData v_in) : TARGET
{
    float PosterizeC = clamp(Posterize,1.0,256.0);
	float HueC = clamp(Hue,-1.0,1.0);
	float SaturationC = clamp(Saturation,-1.0,1.0);

    float2 uv = v_in.uv;
	float s = Pixelate;
	uv = floor(uv*s)/s;

	float4 base = image.Sample(textureSampler, uv);

	float3 poscol = posterize(base.rgb,PosterizeC); 
	float gray = luminance(poscol);

	float3 hsvcol = hsv2rgb(HueC,SaturationC,gray);



	return float4(hsvcol,base.w);
}
