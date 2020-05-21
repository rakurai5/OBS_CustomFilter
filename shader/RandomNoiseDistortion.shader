
uniform float GlitchXNoiseRate = 120.0; //1,50
uniform float GlitchXScale = 0.0; //0,1
uniform float GlitchYNoiseRate = 120.0;
uniform float GlitchYScale = 0.0;
uniform float NoiseTiling = 1.0;
uniform float threshold = 0.0;
uniform bool UseCustomNoiseTex = false;
uniform texture2d NoiseTex;
uniform float NoiseTexTiling = 1.0;


uniform string notes ="Rate Range 1-256";



float rand(float2 co) {
	return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float Luminance(float3 rgb)
{
    float3 W = float3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

float4 mainImage(VertData v_in) : TARGET
{   
    float GlitchXNoiseRateC = clamp(GlitchXNoiseRate,1.0,256.0);
	float GlitchYNoiseRateC = clamp(GlitchYNoiseRate,1.0,256.0);
	float thresholdC = clamp(threshold,0.0,1.0);

	float2 noiseUV = frac(v_in.uv*NoiseTiling);
	float2 noisetexUV = frac(v_in.uv*NoiseTexTiling);

	float4 finalColor;

	float4 col0 = image.Sample(textureSampler, v_in.uv);

	float4 ReTime = (( elapsed_time % 3600.0 )).xxxx;
	float div1=256.0/float((int)GlitchXNoiseRateC);
	float div2=256.0/float((int)GlitchYNoiseRateC);
	float4 posterize1 = ( floor( ReTime * div1 ) / div1 );
	float4 posterize2 = ( floor( ReTime * div2 ) / div2 );
	float posx = sin(posterize1 * 8.0);
	float posy = sin(posterize2 * 8.0);
	float randval = frac((rand( posterize1.rg*4.0 )) * 120);
	float a314 = (randval * 0.005) * posx;
	float a315 = (randval * 0.01) * posy;
	float zurex = ((sin(elapsed_time * posx)) * 1.5);
	float zurey = ((sin(elapsed_time * posy)) * 1.5);

	float2 UVGlitch = float2((zurex * a314) * GlitchXScale, (zurey * -a315) * GlitchYScale);
	float2 randnoise = rand(noiseUV);
	UVGlitch *= randnoise;

	float4 AppendUV = 0;

	if(!UseCustomNoiseTex){
	    AppendUV = float4( UVGlitch, 0.0 , 0.0 );
	}
	else{
	    AppendUV = ( NoiseTex.Sample(textureSampler, noisetexUV) * float4( UVGlitch, 0.0 , 0.0 ) );
	}

	float2 temp_output = ( v_in.uv + AppendUV.xy );

	float4 col1 = image.Sample(textureSampler, temp_output);

	float gray = Luminance(col0.rgb);
	gray = step(thresholdC,gray);

	finalColor = lerp(col0,col1,gray);

	return finalColor;
}
