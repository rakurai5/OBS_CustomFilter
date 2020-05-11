uniform bool SoftBlur = false;
uniform float Blur = 0.2;
uniform int Samples = 40.0;

float N21(float2 p){
	p = frac(p*float2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return frac(p.x*p.y);
}

float4 mainImage(VertData v_in) : TARGET
{
	float BlurC = clamp(Blur,0.0,1.0);

	float4 col = 0;

	float blu = BlurC * 5.0;
	float2 projuv = v_in.uv;

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