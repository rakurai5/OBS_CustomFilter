//The idea and technique is based on the "Rainier mood" that was originally written by Zavie. 
//The original shader is available at Shadertoy.

uniform float RippleScale = 15.0;
uniform float RainNormal = 0.15;
uniform float RainSpeed = 0.15;

#define MAX_RADIUS 3

#define HASHSCALE1 .1031
#define HASHSCALE3 float3(.1031, .1030, .0973)

float hash12(float2 p)
{
    float3 p3  = frac(float3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}

float2 hash22(float2 p)
{
	float3 p3 = frac(float3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return frac((p3.xx+p3.yz)*p3.zy);
}


float4 mainImage(VertData v_in) : TARGET
{
    float RainNormalC = clamp(RainNormal,0.0,1.0);

    float2 uv = v_in.uv;
	uv.x *= uv_size.x/uv_size.y;
	uv = uv*RippleScale;
	float2 p0 = floor(uv);

	float2 circles = float2(0.0, 0.0);
    for (int j = -MAX_RADIUS; j <= MAX_RADIUS; ++j)
    {
        for (int k = -MAX_RADIUS; k <= MAX_RADIUS; ++k)
        {
			float2 pi = p0 + float2(k, j);
            float2 hsh = pi;
         
            float2 p = pi + hash22(hsh);

            float t = frac(RainSpeed*elapsed_time + hash12(hsh));
            float2 v = p - uv;
            float d = length(v) - (float(MAX_RADIUS) + 1.)*t;

            float h = 0.001;
            float d1 = d - h;
            float d2 = d + h;
            float p1 = sin(31.*d1) * smoothstep(-0.6, -0.3, d1) * smoothstep(0., -0.3, d1);
            float p2 = sin(31.*d2) * smoothstep(-0.6, -0.3, d2) * smoothstep(0., -0.3, d2);
            circles += 0.5 * normalize(v) * ((p2 - p1) / (2. * h) * (1. - t) * (1. - t));
        }
    }
    circles /= float((MAX_RADIUS*2+1)*(MAX_RADIUS*2+1));

	float intensity = lerp(0.01, RainNormalC/10.0, smoothstep(0.1, 0.3, abs(frac(0.02*elapsed_time + 0.5)*2.-1.)));
	float3 n = float3(circles, sqrt(1. - dot(circles, circles)));
	float2 rippleuv = intensity*n.xy;

	float4 col = image.Sample(textureSampler, v_in.uv+rippleuv);
	return col;
}
