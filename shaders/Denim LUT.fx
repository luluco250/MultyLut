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
	#define fLUT_TextureName "Denim LUT.png"
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
	ui_items=" Black 01\0 Black 01_S\0 Black 02\0 Black 02_S\0 Black 03\0 Black 03_S\0 Black 04\0 Black 04_S\0 Black 05\0 Black 05_S\0 Black 06\0 Black 06_S\0 Black 07\0 Black 07_S\0 Black 08\0 Black 08_S\0 Black 09\0 Black 09_S\0 Black 10\0 Black 10_S\0 Construction 01\0 Construction 01_S\0 Construction 02\0 Construction 02_S\0 Construction 03\0 Construction 03_S\0 Construction 04\0 Construction 04_S\0 Construction 05\0 Construction 05_S\0 Construction 06\0 Construction 06_S\0 Construction 07\0 Construction 07_S\0 Construction 08\0 Construction 08_S\0 Construction 09\0 Construction 09_S\0 Construction 10\0 Construction 10_S\0 Forester 01\0 Forester 01_S\0 Forester 02\0 Forester 02_S\0 Forester 03\0 Forester 03_S\0 Forester 04\0 Forester 04_S\0 Forester 05\0 Forester 05_S\0 Forester 06\0 Forester 06_S\0 Forester 07\0 Forester 07_S\0 Forester 08\0 Forester 08_S\0 Forester 09\0 Forester 09_S\0 Forester 10\0 Forester 10_S\0 Peach 01_S\0 Peach 02\0 Peach 02_S\0 Peach 03\0 Peach 03_S\0 Peach 04\0 Peach 04_S\0 Peach 05\0 Peach 05_S\0 Peach 06\0 Peach 06_S\0 Peach 07\0 Peach 07_S\0 Peach 08\0 Peach 08_S\0 Peach 09\0 Peach 09_S\0 Peach 10\0 Peach 10_S\0 Raw 01\0 Raw 01_S\0 Raw 02\0 Raw 02_S\0 Raw 03\0 Raw 03_S\0 Raw 04\0 Raw 04_S\0 Raw 05\0 Raw 05_S\0 Raw 06\0 Raw 06_S\0 Raw 07\0 Raw 07_S\0 Raw 08\0 Raw 08_S\0 Raw 09\0 Raw 09_S\0 Raw 10\0 Raw 10_S\0"; 
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
texture texDenimMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texDenimMultiLUT; };

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


technique Denim_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}