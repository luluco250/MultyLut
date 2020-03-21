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
	#define fLUT_TextureName "Japan Mood LUT.png"
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
	ui_items=" Aizu 01\0 Aizu 01_S\0 Aizu 02\0 Aizu 02_S\0 Aizu 03\0 Aizu 03_S\0 Aizu 04\0 Aizu 04_S\0 Aizu 05\0 Aizu 05_S\0 Aizu 06\0 Aizu 06_S\0 Aizu 07\0 Aizu 07_S\0 Aizu 08\0 Aizu 08_S\0 Aizu 09\0 Aizu 09_S\0 Aizu 10\0 Aizu 10_S\0 Hokkaido 01\0 Hokkaido 01_S\0 Hokkaido 02\0 Hokkaido 02_S\0 Hokkaido 03\0 Hokkaido 03_S\0 Hokkaido 04\0 Hokkaido 04_S\0 Hokkaido 05\0 Hokkaido 05_S\0 Hokkaido 06\0 Hokkaido 06_S\0 Hokkaido 07\0 Hokkaido 07_S\0 Hokkaido 08\0 Hokkaido 08_S\0 Hokkaido 09\0 Hokkaido 09_S\0 Hokkaido 10\0 Hokkaido 10_S\0 Kamakura 01\0 Kamakura 01_S\0 Kamakura 02\0 Kamakura 02_S\0 Kamakura 03\0 Kamakura 03_S\0 Kamakura 04\0 Kamakura 04_S\0 Kamakura 05\0 Kamakura 05_S\0 Kamakura 06\0 Kamakura 06_S\0 Kamakura 07\0 Kamakura 07_S\0 Kamakura 08\0 Kamakura 08_S\0 Kamakura 09\0 Kamakura 09_S\0 Kamakura 10\0 Kamakura 10_S\0 Kyoto 01\0 Kyoto 01_S\0 Kyoto 02\0 Kyoto 02_S\0 Kyoto 03\0 Kyoto 03_S\0 Kyoto 04\0 Kyoto 04_S\0 Kyoto 05\0 Kyoto 05_S\0 Kyoto 06\0 Kyoto 06_S\0 Kyoto 07\0 Kyoto 07_S\0 Kyoto 08\0 Kyoto 08_S\0 Kyoto 09\0 Kyoto 09_S\0 Kyoto 10\0 Kyoto 10_S\0 Yokohama 01\0 Yokohama 01_S\0 Yokohama 02\0 Yokohama 02_S\0 Yokohama 03\0 Yokohama 03_S\0 Yokohama 04\0 Yokohama 04_S\0 Yokohama 05\0 Yokohama 05_S\0 Yokohama 06\0 Yokohama 06_S\0 Yokohama 07\0 Yokohama 07_S\0 Yokohama 08\0 Yokohama 08_S\0 Yokohama 09\0 Yokohama 09_S\0 Yokohama 10\0 Yokohama 10_S\0"; 
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
texture texJapanMoodMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texJapanMoodMultiLUT; };

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


technique Japan_Mood_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}