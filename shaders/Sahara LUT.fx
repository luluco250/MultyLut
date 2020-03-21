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
	#define fLUT_TextureName "Sahara LUT.png"
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
	ui_items=" Exploration 01\0 Exploration 01_S\0 Exploration 02\0 Exploration 02_S\0 Exploration 03\0 Exploration 03_S\0 Exploration 04\0 Exploration 04_S\0 Exploration 05\0 Exploration 05_S\0 Exploration 06\0 Exploration 06_S\0 Exploration 07\0 Exploration 07_S\0 Exploration 08\0 Exploration 08_S\0 Exploration 09\0 Exploration 09_S\0 Exploration 10\0 Exploration 10_S\0 Nomadic 01\0 Nomadic 01_S\0 Nomadic 02\0 Nomadic 02_S\0 Nomadic 03\0 Nomadic 03_S\0 Nomadic 04\0 Nomadic 04_S\0 Nomadic 05\0 Nomadic 05_S\0 Nomadic 06\0 Nomadic 06_S\0 Nomadic 07\0 Nomadic 07_S\0 Nomadic 08\0 Nomadic 08_S\0 Nomadic 09\0 Nomadic 09_S\0 Nomadic 10\0 Nomadic 10_S\0 Oasis 01\0 Oasis 01_S\0 Oasis 02\0 Oasis 02_S\0 Oasis 03\0 Oasis 03_S\0 Oasis 04\0 Oasis 04_S\0 Oasis 05\0 Oasis 05_S\0 Oasis 06\0 Oasis 06_S\0 Oasis 07\0 Oasis 07_S\0 Oasis 08\0 Oasis 08_S\0 Oasis 09\0 Oasis 09_S\0 Oasis 10\0 Oasis 10_S\0 Sand 01\0 Sand 01_S\0 Sand 02\0 Sand 02_S\0 Sand 03\0 Sand 03_S\0 Sand 04\0 Sand 04_S\0 Sand 05\0 Sand 05_S\0 Sand 06\0 Sand 06_S\0 Sand 07\0 Sand 07_S\0 Sand 08\0 Sand 08_S\0 Sand 09\0 Sand 09_S\0 Sand 10\0 Sand 10_S\0 Tribe 01\0 Tribe 01_S\0 Tribe 02\0 Tribe 02_S\0 Tribe 03\0 Tribe 03_S\0 Tribe 04\0 Tribe 04_S\0 Tribe 05\0 Tribe 05_S\0 Tribe 06\0 Tribe 06_S\0 Tribe 07\0 Tribe 07_S\0 Tribe 08\0 Tribe 08_S\0 Tribe 09\0 Tribe 09_S\0 Tribe 10\0 Tribe 10_S\0"; 
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
texture texSahMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texSahMultiLUT; };

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


technique Sahara_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}