//The idea and technique is based on the "VHS tape effect" that was originally written by Gaktan. 
//The original shader is available at Shadertoy.

uniform float range = 0.10;
uniform float noiseQuality = 350.0;
uniform float noiseIntensity = 0.005;
uniform float offsetIntensity = 0.01;
uniform float colorOffsetIntensity = 0.25;
uniform float ScanSpeed = 100.0;
uniform float ScanPower = 0.0; //0,1

float rand(float2 co) {
	return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}


float verticalBar(float pos, float uvY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

float4 mainImage(VertData v_in) : TARGET{

	float ScanPowerC = clamp(ScanPower,0.0,1.0);

	float Scan = saturate( ( ( 1.0 - frac( ( v_in.uv.y + ( elapsed_time * ScanSpeed ) ) ) ) + ( 1.0 - (0.0 + (ScanPowerC - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)) ) ) );

    float4 col = 0.0;
    float2 uv = v_in.uv;

	for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = fmod(elapsed_time * i, 1.7);
        float o = sin(1.0 - tan(elapsed_time * 0.24 * i));
    	o *= offsetIntensity/100.0;
        uv.x += verticalBar(d, uv.y, o);
    }

	float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(float2(elapsed_time * 0.00001, uvY));
    uv.x += noise * (noiseIntensity/100.0);

    float2 offsetR = float2(0.006 * sin(elapsed_time), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(elapsed_time * 0.97)), 0.0) * colorOffsetIntensity;
    
    float r = image.Sample(textureSampler, uv + offsetR).r;
    float g = image.Sample(textureSampler, uv + offsetG).g;
    float b = image.Sample(textureSampler, uv).b;
	float a = image.Sample(textureSampler, uv).a;

    col = float4(r, g, b, a) * Scan;

	return col;
}
