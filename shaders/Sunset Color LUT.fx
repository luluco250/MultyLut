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
	#define fLUT_TextureName "Sunset Color LUT.png"
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
	ui_items=" Fiery Orange 01\0 Fiery Orange 01_S\0 Fiery Orange 02\0 Fiery Orange 02_S\0 Fiery Orange 03\0 Fiery Orange 03_S\0 Fiery Orange 04\0 Fiery Orange 04_S\0 Fiery Orange 05\0 Fiery Orange 05_S\0 Fiery Orange 06\0 Fiery Orange 06_S\0 Fiery Orange 07\0 Fiery Orange 07_S\0 Fiery Orange 08\0 Fiery Orange 08_S\0 Fiery Orange 09\0 Fiery Orange 09_S\0 Fiery Orange 10\0 Fiery Orange 10_S\0 Intense 01\0 Intense 01_S\0 Intense 02\0 Intense 02_S\0 Intense 03\0 Intense 03_S\0 Intense 04\0 Intense 04_S\0 Intense 05\0 Intense 05_S\0 Intense 06\0 Intense 06_S\0 Intense 07\0 Intense 07_S\0 Intense 08\0 Intense 08_S\0 Intense 09\0 Intense 09_S\0 Intense 10\0 Intense 10_S\0 Purple 01\0 Purple 01_S\0 Purple 02\0 Purple 02_S\0 Purple 03\0 Purple 03_S\0 Purple 04\0 Purple 04_S\0 Purple 05\0 Purple 05_S\0 Purple 06\0 Purple 06_S\0 Purple 07\0 Purple 07_S\0 Purple 08\0 Purple 08_S\0 Purple 09\0 Purple 09_S\0 Purple 10\0 Purple 10_S\0 Vaporwave 01\0 Vaporwave 01_S\0 Vaporwave 02\0 Vaporwave 02_S\0 Vaporwave 03\0 Vaporwave 03_S\0 Vaporwave 04\0 Vaporwave 04_S\0 Vaporwave 05\0 Vaporwave 05_S\0 Vaporwave 06\0 Vaporwave 06_S\0 Vaporwave 07\0 Vaporwave 07_S\0 Vaporwave 08\0 Vaporwave 08_S\0 Vaporwave 09\0 Vaporwave 09_S\0 Vaporwave 10\0 Vaporwave 10_S\0 Vibrance Boost 01\0 Vibrance Boost 01_S\0 Vibrance Boost 02\0 Vibrance Boost 02_S\0 Vibrance Boost 03\0 Vibrance Boost 03_S\0 Vibrance Boost 04\0 Vibrance Boost 04_S\0 Vibrance Boost 05\0 Vibrance Boost 05_S\0 Vibrance Boost 06\0 Vibrance Boost 06_S\0 Vibrance Boost 07\0 Vibrance Boost 07_S\0 Vibrance Boost 08\0 Vibrance Boost 08_S\0 Vibrance Boost 09\0 Vibrance Boost 09_S\0 Vibrance Boost 10\0 Vibrance Boost 10_S\0"; 
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
texture texSunsetCMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texSunsetCMultiLUT; };

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


technique Sunset_Color_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}