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
	#define fLUT_TextureName "Cross Process LUT.png"
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
	ui_items=" Grape 01\0 Grape 01_S\0 Grape 02\0 Grape 02_S\0 Grape 03\0 Grape 03_S\0 Grape 04\0 Grape 04_S\0 Grape 05\0 Grape 05_S\0 Grape 06\0 Grape 06_S\0 Grape 07\0 Grape 07_S\0 Grape 08\0 Grape 08_S\0 Grape 09\0 Grape 09_S\0 Grape 10\0 Grape 10_S\0 Maroon 01\0 Maroon 01_S\0 Maroon 02\0 Maroon 02_S\0 Maroon 03\0 Maroon 03_S\0 Maroon 04\0 Maroon 04_S\0 Maroon 05\0 Maroon 05_S\0 Maroon 06\0 Maroon 06_S\0 Maroon 07\0 Maroon 07_S\0 Maroon 08\0 Maroon 08_S\0 Maroon 09\0 Maroon 09_S\0 Maroon 10\0 Maroon 10_S\0 Midnight 01\0 Midnight 01_S\0 Midnight 02\0 Midnight 02_S\0 Midnight 03\0 Midnight 03_S\0 Midnight 04\0 Midnight 04_S\0 Midnight 05\0 Midnight 05_S\0 Midnight 06\0 Midnight 06_S\0 Midnight 07\0 Midnight 07_S\0 Midnight 08\0 Midnight 08_S\0 Midnight 09\0 Midnight 09_S\0 Midnight 10\0 Midnight 10_S\0 Pine 01\0 Pine 01_S\0 Pine 02\0 Pine 02_S\0 Pine 03\0 Pine 03_S\0 Pine 04\0 Pine 04_S\0 Pine 05\0 Pine 05_S\0 Pine 06\0 Pine 06_S\0 Pine 07\0 Pine 07_S\0 Pine 08\0 Pine 08_S\0 Pine 09\0 Pine 09_S\0 Pine 10\0 Pine 10_S\0 Turquoise 01\0 Turquoise 01_S\0 Turquoise 02\0 Turquoise 02_S\0 Turquoise 03\0 Turquoise 03_S\0 Turquoise 04\0 Turquoise 04_S\0 Turquoise 05\0 Turquoise 05_S\0 Turquoise 06\0 Turquoise 06_S\0 Turquoise 07\0 Turquoise 07_S\0 Turquoise 08\0 Turquoise 08_S\0 Turquoise 09\0 Turquoise 09_S\0 Turquoise 10\0 Turquoise 10_S\0"; 
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
texture texCrossProcMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texCrossProcMultiLUT; };

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


technique Cross_Process_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}