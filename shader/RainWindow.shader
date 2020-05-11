uniform float size = 7.0;
uniform float TimeScale = 1.0;
uniform int PosterizeTime = 1.0;
uniform float Distortion = 1.0;
uniform bool SoftBlur = false;
uniform float Blur = 0.2;
uniform float rotate = 3.0;
uniform int Samples = 40.0;

#define S(a, b, t) smoothstep(a, b, t)

float N21(float2 p){
	p = frac(p*float2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return frac(p.x*p.y);
}

float3 Layer(float2 UV, float t){
	float2 aspect = float2(2,1);
	float2 uv = UV*size*aspect;
	uv.y += t * .25;
	float2 gv = frac(uv)-.5;
	float2 id = floor(uv);

	float n = N21(id); //0 1
	t += n*6.2831;

	float w = UV.y * 10;
	float x = (n - .5)*.8; //-.4 .4
	x += (.4-abs(x)) * sin(3*w)*pow(sin(w), 6)*.45;

	float y = -sin(t+sin(t+sin(t)*.5))*.45;
	y -= (gv.x-x)*(gv.x-x);

	float2 dropPos = (gv-float2(x, y)) / aspect;
	float drop = S(.04, .03, length(dropPos));

	float2 trailPos = (gv-float2(x, t * .25)) / aspect;
	trailPos.y = (frac(trailPos.y * 8)-.5)/8;
	float trail = S(.02, .005, length(trailPos));
	float fogTrail = S(-.05, .05, dropPos.y);
	fogTrail *= S(.5, y, gv.y);
	trail *= fogTrail;
	fogTrail *= S(.05, .04, abs(dropPos.x));
				

	float2 offs = drop*dropPos + trail*trailPos;

	return float3(offs, fogTrail);
}


float4 mainImage(VertData v_in) : TARGET
{
    float DistortionC = clamp(Distortion,-5.0,5.0);
	float BlurC = clamp(Blur,0.0,1.0);
	float PT = clamp(PosterizeTime,1.0,256.0);

    float posT = 256.0/PT;
    float t = (floor(fmod(elapsed_time*TimeScale , 7200) * posT) / posT);

	float2 uv2 = v_in.uv;
    float angle = rotate;
    float2x2 ro = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
    float scale = 1;
    float2 pivot_uv = float2(0.5, 0.5);
    float2 r = (v_in.uv.xy - pivot_uv) * (1 / scale);
    uv2 = mul(ro, r) + pivot_uv;

	float4 col = 0;

	float3 drops = Layer(uv2, t);
	drops += Layer(uv2*1.23+7.54, t);
	drops += Layer(uv2*1.35+1.54, t);
	//drops += Layer(v_in.uv*1.57-7.54, t);
				
	float fade = 1-saturate(fwidth(v_in.uv)*60);

	float blu = BlurC * 5 * (1-drops.z*fade);

	float2 projuv = v_in.uv;
	projuv += drops.xy * DistortionC * fade;
	blu *= 0.01;
				
	float a = N21(v_in.uv)*6.2831;

	for(float i = 0; i < Samples; i++){
		 float2 offs = float2(sin(a), cos(a))*blu;
	     float d = frac(sin((i+1)*546.)*5424.);

		 if(!SoftBlur){
	     d = sqrt(d);
	     }
	     else{
	     d = pow(d, 2);
	     }

         offs *= d;
         col += image.Sample(textureSampler, projuv+offs);
		 a++;
	}
	col /= Samples;

	return col;
}
