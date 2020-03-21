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
	#define fLUT_TextureName "Santorini LUT.png"
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
	ui_items=" Beach 01\0 Beach 01_S\0 Beach 02\0 Beach 02_S\0 Beach 03\0 Beach 03_S\0 Beach 04\0 Beach 04_S\0 Beach 05\0 Beach 05_S\0 Beach 06\0 Beach 06_S\0 Beach 07\0 Beach 07_S\0 Beach 08\0 Beach 08_S\0 Beach 09\0 Beach 09_S\0 Beach 10\0 Beach 10_S\0 Blue 01\0 Blue 01_S\0 Blue 02\0 Blue 02_S\0 Blue 03\0 Blue 03_S\0 Blue 04\0 Blue 04_S\0 Blue 05\0 Blue 05_S\0 Blue 06\0 Blue 06_S\0 Blue 07\0 Blue 07_S\0 Blue 08\0 Blue 08_S\0 Blue 09\0 Blue 09_S\0 Blue 10\0 Blue 10_S\0 Honeymoon 01\0 Honeymoon 01_S\0 Honeymoon 02\0 Honeymoon 02_S\0 Honeymoon 03\0 Honeymoon 03_S\0 Honeymoon 04\0 Honeymoon 04_S\0 Honeymoon 05\0 Honeymoon 05_S\0 Honeymoon 06\0 Honeymoon 06_S\0 Honeymoon 07\0 Honeymoon 07_S\0 Honeymoon 08\0 Honeymoon 08_S\0 Honeymoon 09\0 Honeymoon 09_S\0 Honeymoon 10\0 Honeymoon 10_S\0 Sunset 01\0 Sunset 01_S\0 Sunset 02\0 Sunset 02_S\0 Sunset 03\0 Sunset 03_S\0 Sunset 04\0 Sunset 04_S\0 Sunset 05\0 Sunset 05_S\0 Sunset 06\0 Sunset 06_S\0 Sunset 07\0 Sunset 07_S\0 Sunset 08\0 Sunset 08_S\0 Sunset 09\0 Sunset 09_S\0 Sunset 10\0 Sunset 10_S\0 Wedding 01\0 Wedding 01_S\0 Wedding 02\0 Wedding 02_S\0 Wedding 03\0 Wedding 03_S\0 Wedding 04\0 Wedding 04_S\0 Wedding 05\0 Wedding 05_S\0 Wedding 06\0 Wedding 06_S\0 Wedding 07\0 Wedding 07_S\0 Wedding 08\0 Wedding 08_S\0 Wedding 09\0 Wedding 09_S\0 Wedding 10\0 Wedding 10_S\0"; 
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
texture texSantoMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texSantoMultiLUT; };

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


technique Santorini_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}