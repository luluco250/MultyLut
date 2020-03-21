//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Multi-LUT shader, using a texture atlas with multiple LUTs
// by Otis / Infuse Project.
// Based on Marty's LUT shader 1.0 for ReShade 3.0
// Copyright © 2008-2016 Marty McFly
// Converted by TheGordinho 
// Thanks to kingeric1992 and Matsilagi for the tools
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "Infrared Vibes LUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 32
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 32
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 100
#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform int fLUT_LutSelector < 
	ui_type = "combo";
	ui_min= 0; ui_max=16;
	ui_items=" Aero 01\0 Aero 01_S\0 Aero 02\0 Aero 02_S\0 Aero 03\0 Aero 03_S\0 Aero 04\0 Aero 04_S\0 Aero 05\0 Aero 05_S\0 Aero 06\0 Aero 06_S\0 Aero 07\0 Aero 07_S\0 Aero 08\0 Aero 08_S\0 Aero 09\0 Aero 09_S\0 Aero 10\0 Aero 10_S\0 Canary 01\0 Canary 01_S\0 Canary 02\0 Canary 02_S\0 Canary 03\0 Canary 03_S\0 Canary 04\0 Canary 04_S\0 Canary 05\0 Canary 05_S\0 Canary 06\0 Canary 06_S\0 Canary 07\0 Canary 07_S\0 Canary 08\0 Canary 08_S\0 Canary 09\0 Canary 09_S\0 Canary 10\0 Canary 10_S\0 Pink 01\0 Pink 01_S\0 Pink 02\0 Pink 02_S\0 Pink 03\0 Pink 03_S\0 Pink 04\0 Pink 04_S\0 Pink 05\0 Pink 05_S\0 Pink 06\0 Pink 06_S\0 Pink 07\0 Pink 07_S\0 Pink 08\0 Pink 08_S\0 Pink 09\0 Pink 09_S\0 Pink 10\0 Pink 10_S\0 Roses 01\0 Roses 01_S\0 Roses 02\0 Roses 02_S\0 Roses 03\0 Roses 03_S\0 Roses 04\0 Roses 04_S\0 Roses 05\0 Roses 05_S\0 Roses 06\0 Roses 06_S\0 Roses 07\0 Roses 07_S\0 Roses 08\0 Roses 08_S\0 Roses 09\0 Roses 09_S\0 Roses 10\0 Roses 10_S\0 Skies 01\0 Skies 01_S\0 Skies 02\0 Skies 02_S\0 Skies 03\0 Skies 03_S\0 Skies 04\0 Skies 04_S\0 Skies 05\0 Skies 05_S\0 Skies 06\0 Skies 06_S\0 Skies 07\0 Skies 07_S\0 Skies 08\0 Skies 08_S\0 Skies 09\0 Skies 09_S\0 Skies 10\0 Skies 10_S\0"; 
	ui_label = "The LUT to use";
	
> = 0;

uniform float fLUT_AmountChroma <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "LUT chroma amount";
	ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;

uniform float fLUT_AmountLuma <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "LUT luma amount";
	ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "ReShade.fxh"
texture texIfrvMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texIfrvMultiLUT; };

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void PS_MultiLUT_Apply(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
	float4 color = tex2D(ReShade::BackBuffer, texcoord.xy);
	float2 texelsize = 1.0 / fLUT_TileSizeXY;
	texelsize.x /= fLUT_TileAmount;

	float3 lutcoord = float3((color.xy*fLUT_TileSizeXY-color.xy+0.5)*texelsize.xy,color.z*fLUT_TileSizeXY-color.z);
	lutcoord.y /= fLUT_LutAmount;
	lutcoord.y += (float(fLUT_LutSelector)/ fLUT_LutAmount);
	float lerpfact = frac(lutcoord.z);
	lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;

	float3 lutcolor = lerp(tex2D(SamplerMultiLUT, lutcoord.xy).xyz, tex2D(SamplerMultiLUT, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);

	color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) * 
	            lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);

	res.xyz = color.xyz;
	res.w = 1.0;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


technique Infrared_Vibes_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}