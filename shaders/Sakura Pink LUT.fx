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
	#define fLUT_TextureName "Sakura Pink LUT.png"
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
	ui_items=" Bloom 01\0 Bloom 01_S\0 Bloom 02\0 Bloom 02_S\0 Bloom 03\0 Bloom 03_S\0 Bloom 04\0 Bloom 04_S\0 Bloom 05\0 Bloom 05_S\0 Bloom 06\0 Bloom 06_S\0 Bloom 07\0 Bloom 07_S\0 Bloom 08\0 Bloom 08_S\0 Bloom 09\0 Bloom 09_S\0 Bloom 10\0 Bloom 10_S\0 Cherry 01\0 Cherry 01_S\0 Cherry 02\0 Cherry 02_S\0 Cherry 03\0 Cherry 03_S\0 Cherry 04\0 Cherry 04_S\0 Cherry 05\0 Cherry 05_S\0 Cherry 06\0 Cherry 06_S\0 Cherry 07\0 Cherry 07_S\0 Cherry 08\0 Cherry 08_S\0 Cherry 09\0 Cherry 09_S\0 Cherry 10\0 Cherry 10_S\0 Floral 01\0 Floral 01_S\0 Floral 02\0 Floral 02_S\0 Floral 03\0 Floral 03_S\0 Floral 04\0 Floral 04_S\0 Floral 05\0 Floral 05_S\0 Floral 06\0 Floral 06_S\0 Floral 07\0 Floral 07_S\0 Floral 08\0 Floral 08_S\0 Floral 09\0 Floral 09_S\0 Floral 10\0 Floral 10_S\0 Pink 01\0 Pink 01_S\0 Pink 02\0 Pink 02_S\0 Pink 03\0 Pink 03_S\0 Pink 04\0 Pink 04_S\0 Pink 05\0 Pink 05_S\0 Pink 06\0 Pink 06_S\0 Pink 07\0 Pink 07_S\0 Pink 08\0 Pink 08_S\0 Pink 09\0 Pink 09_S\0 Pink 10\0 Pink 10_S\0 Spring 01\0 Spring 01_S\0 Spring 02\0 Spring 02_S\0 Spring 03\0 Spring 03_S\0 Spring 04\0 Spring 04_S\0 Spring 05\0 Spring 05_S\0 Spring 06\0 Spring 06_S\0 Spring 07\0 Spring 07_S\0 Spring 08\0 Spring 08_S\0 Spring 09\0 Spring 09_S\0 Spring 10\0 Spring 10_S\0"; 
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
texture texSPinkMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texSPinkMultiLUT; };

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


technique Sakura_Pink_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}