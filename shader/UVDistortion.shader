uniform int Octaves = 4;
uniform float Xdir_Power = 0.00;
uniform float Ydir_Power = 0.00;
uniform float Xdir_DistortionSpeed = 0.08;
uniform float Ydir_DistortionSpeed = 0.03;
uniform float Xdir_ScrollSpeed = 0.00;
uniform float Ydir_ScrollSpeed = 0.00;
uniform float Threshold = 0.0;

uniform string notes ="Octaves Range 0-10";

#define tau 6.2831853
#define PI 3.141592

float random (float2 st){
    return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * (43758.5453123));
}

float noise (float2 st){
	float2 i = floor(st);
    float2 f = frac(st);

    float a = random(i + float2(0.0, 0.0));
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(float2 st){
	float v = 0.0;
    float a = 0.6;

    int OctavesC = clamp(Octaves,0,10);

    for (int i = 0; i < OctavesC; i++)
    {
        v += a * noise(st);
        st = st * 2.0;
        a *= 0.5;
    }

    return v;
}

float4 mainImage(VertData v_in) : TARGET
{
    float ThresholdC = clamp(Threshold,0.0,1.0);

	float2 uv = v_in.uv;
	float2 duv = v_in.uv;

	duv.x += elapsed_time*(Xdir_ScrollSpeed/10.0);
	duv.y += elapsed_time*(Ydir_ScrollSpeed/10.0);

	float2 q = float2(0.0, 0.0);
    q.x = fbm(duv + float2(0.0, 0.0));
    q.y = fbm(duv + float2(1.0, 1.0));
    
    float2 r = float2(0.0, 0.0);
    r.x = fbm(duv + (4.0 * q) + float2(1.7, 9.2) + ((Xdir_DistortionSpeed/10.0) * elapsed_time));
    r.y = fbm(duv + (4.0 * q) + float2(8.3, 2.8) + ((Ydir_DistortionSpeed/10.0) * elapsed_time));

	float f = fbm(duv + 4.0 * r);
    float sf = (f * f * f + (0.45 * f * f) + (0.25 * f) + (0.1 * f));

	duv.x += sf*(Xdir_Power/10.0);
	duv.y += sf*(Ydir_Power/10.0);

	float4 col0 = image.Sample(textureSampler, uv);
	float4 col1 = image.Sample(textureSampler, frac(duv));

	float gray = 0.3 * col0.r + 0.59 * col0.g + 0.11 * col0.b;
	gray = step(ThresholdC,gray);

	float4 col = lerp(col0,col1,gray);


	return col;
}
