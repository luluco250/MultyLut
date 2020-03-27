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
	#define fLUT_TextureName "Influencer LUT.png"
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
	ui_items=" Black 01\0 Black 01_S\0 Black 02\0 Black 02_S\0 Black 03\0 Black 03_S\0 Black 04\0 Black 04_S\0 Black 05\0 Black 05_S\0 Black 06\0 Black 06_S\0 Black 07\0 Black 07_S\0 Black 08\0 Black 08_S\0 Black 09\0 Black 09_S\0 Black 10\0 Black 10_S\0 Cupcake 01\0 Cupcake 01_S\0 Cupcake 02\0 Cupcake 02_S\0 Cupcake 03\0 Cupcake 03_S\0 Cupcake 04\0 Cupcake 04_S\0 Cupcake 05\0 Cupcake 05_S\0 Cupcake 06\0 Cupcake 06_S\0 Cupcake 07\0 Cupcake 07_S\0 Cupcake 08\0 Cupcake 08_S\0 Cupcake 09\0 Cupcake 09_S\0 Cupcake 10\0 Cupcake 10_S\0 Desert 01\0 Desert 01_S\0 Desert 02\0 Desert 02_S\0 Desert 03\0 Desert 03_S\0 Desert 04\0 Desert 04_S\0 Desert 05\0 Desert 05_S\0 Desert 06\0 Desert 06_S\0 Desert 07\0 Desert 07_S\0 Desert 08\0 Desert 08_S\0 Desert 09\0 Desert 09_S\0 Desert 10\0 Desert 10_S\0 Santorini 01\0 Santorini 01_S\0 Santorini 02\0 Santorini 02_S\0 Santorini 03\0 Santorini 03_S\0 Santorini 04\0 Santorini 04_S\0 Santorini 05\0 Santorini 05_S\0 Santorini 06\0 Santorini 06_S\0 Santorini 07\0 Santorini 07_S\0 Santorini 08\0 Santorini 08_S\0 Santorini 09\0 Santorini 09_S\0 Santorini 10\0 Santorini 10_S\0 Stoic 01\0 Stoic 01_S\0 Stoic 02\0 Stoic 02_S\0 Stoic 03\0 Stoic 03_S\0 Stoic 04\0 Stoic 04_S\0 Stoic 05\0 Stoic 05_S\0 Stoic 06\0 Stoic 06_S\0 Stoic 07\0 Stoic 07_S\0 Stoic 08\0 Stoic 08_S\0 Stoic 09\0 Stoic 09_S\0 Stoic 10\0 Stoic 10_S\0"; 
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
texture texInflMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texInflMultiLUT; };

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


technique Influencer_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}