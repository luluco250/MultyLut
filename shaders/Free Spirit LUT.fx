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
	#define fLUT_TextureName "Free Spirit LUT.png"
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
	ui_items=" Drift 01\0 Drift 01_S\0 Drift 02\0 Drift 02_S\0 Drift 03\0 Drift 03_S\0 Drift 04\0 Drift 04_S\0 Drift 05\0 Drift 05_S\0 Drift 06\0 Drift 06_S\0 Drift 07\0 Drift 07_S\0 Drift 08\0 Drift 08_S\0 Drift 09\0 Drift 09_S\0 Drift 10\0 Drift 10_S\0 Fly With Me 01\0 Fly With Me 01_S\0 Fly With Me 02\0 Fly With Me 02_S\0 Fly With Me 03\0 Fly With Me 03_S\0 Fly With Me 04\0 Fly With Me 04_S\0 Fly With Me 05\0 Fly With Me 05_S\0 Fly With Me 06\0 Fly With Me 06_S\0 Fly With Me 07\0 Fly With Me 07_S\0 Fly With Me 08\0 Fly With Me 08_S\0 Fly With Me 09\0 Fly With Me 09_S\0 Fly With Me 10\0 Fly With Me 10_S\0 getnames.bat list.txt LutMate.bat LutMate.exe Old Soul 01\0 Old Soul 01_S\0 Old Soul 02\0 Old Soul 02_S\0 Old Soul 03\0 Old Soul 03_S\0 Old Soul 04\0 Old Soul 04_S\0 Old Soul 05\0 Old Soul 05_S\0 Old Soul 06\0 Old Soul 06_S\0 Old Soul 07\0 Old Soul 07_S\0 Old Soul 08\0 Old Soul 08_S\0 Old Soul 09\0 Old Soul 09_S\0 Old Soul 10\0 Old Soul 10_S\0 Somewhere 01\0 Somewhere 01_S\0 Somewhere 02\0 Somewhere 02_S\0 Somewhere 03\0 Somewhere 03_S\0 Somewhere 04\0 Somewhere 04_S\0 Somewhere 05\0 Somewhere 05_S\0 Somewhere 06\0 Somewhere 06_S\0 Somewhere 07\0 Somewhere 07_S\0 Somewhere 08\0 Somewhere 08_S\0 Somewhere 09\0 Somewhere 09_S\0 Somewhere 10\0 Somewhere 10_S\0 Wild Heart 01\0 Wild Heart 01_S\0 Wild Heart 02\0 Wild Heart 02_S\0 Wild Heart 03\0 Wild Heart 03_S\0 Wild Heart 04\0 Wild Heart 04_S\0 Wild Heart 05\0 Wild Heart 05_S\0 Wild Heart 06\0 Wild Heart 06_S\0 Wild Heart 07\0 Wild Heart 07_S\0 Wild Heart 08\0 Wild Heart 08_S\0 Wild Heart 09\0 Wild Heart 09_S\0 Wild Heart 10\0 Wild Heart 10_S\0"; 
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
texture texFreeSpiritMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texFreeSpiritMultiLUT; };

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


technique Free_Spirit_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}