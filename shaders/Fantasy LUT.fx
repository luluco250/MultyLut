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
	#define fLUT_TextureName "Fantasy LUT.png"
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
	ui_items=" Dreamy 01\0 Dreamy 01_S\0 Dreamy 02\0 Dreamy 02_S\0 Dreamy 03\0 Dreamy 03_S\0 Dreamy 04\0 Dreamy 04_S\0 Dreamy 05\0 Dreamy 05_S\0 Dreamy 06\0 Dreamy 06_S\0 Dreamy 07\0 Dreamy 07_S\0 Dreamy 08\0 Dreamy 08_S\0 Dreamy 09\0 Dreamy 09_S\0 Dreamy 10\0 Dreamy 10_S\0 Egyptian 01\0 Egyptian 01_S\0 Egyptian 02\0 Egyptian 02_S\0 Egyptian 03\0 Egyptian 03_S\0 Egyptian 04\0 Egyptian 04_S\0 Egyptian 05\0 Egyptian 05_S\0 Egyptian 06\0 Egyptian 06_S\0 Egyptian 07\0 Egyptian 07_S\0 Egyptian 08\0 Egyptian 08_S\0 Egyptian 09\0 Egyptian 09_S\0 Egyptian 10\0 Egyptian 10_S\0 getnames.bat list.txt LutMate.bat LutMate.exe Magical Forest 01\0 Magical Forest 01_S\0 Magical Forest 02\0 Magical Forest 02_S\0 Magical Forest 03\0 Magical Forest 03_S\0 Magical Forest 04\0 Magical Forest 04_S\0 Magical Forest 05\0 Magical Forest 05_S\0 Magical Forest 06\0 Magical Forest 06_S\0 Magical Forest 07\0 Magical Forest 07_S\0 Magical Forest 08\0 Magical Forest 08_S\0 Magical Forest 09\0 Magical Forest 09_S\0 Magical Forest 10\0 Magical Forest 10_S\0 Pandora 01\0 Pandora 01_S\0 Pandora 02\0 Pandora 02_S\0 Pandora 03\0 Pandora 03_S\0 Pandora 04\0 Pandora 04_S\0 Pandora 05\0 Pandora 05_S\0 Pandora 06\0 Pandora 06_S\0 Pandora 07\0 Pandora 07_S\0 Pandora 08\0 Pandora 08_S\0 Pandora 09\0 Pandora 09_S\0 Pandora 10\0 Pandora 10_S\0 Winter 01\0 Winter 01_S\0 Winter 02\0 Winter 02_S\0 Winter 03\0 Winter 03_S\0 Winter 04\0 Winter 04_S\0 Winter 05\0 Winter 05_S\0 Winter 06\0 Winter 06_S\0 Winter 07\0 Winter 07_S\0 Winter 08\0 Winter 08_S\0 Winter 09\0 Winter 09_S\0 Winter 10\0 Winter 10_S\0"; 
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
texture texFAntasyMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texFAntasyMultiLUT; };

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


technique Fantasy_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}