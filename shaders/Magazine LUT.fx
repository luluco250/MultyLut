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
	#define fLUT_TextureName "Magazine LUT.png"
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
	ui_items=" Collab 01\0 Collab 01_S\0 Collab 02\0 Collab 02_S\0 Collab 03\0 Collab 03_S\0 Collab 04\0 Collab 04_S\0 Collab 05\0 Collab 05_S\0 Collab 06\0 Collab 06_S\0 Collab 07\0 Collab 07_S\0 Collab 08\0 Collab 08_S\0 Collab 09\0 Collab 09_S\0 Collab 10\0 Collab 10_S\0 Grandeur 01\0 Grandeur 01_S\0 Grandeur 02\0 Grandeur 02_S\0 Grandeur 03\0 Grandeur 03_S\0 Grandeur 04\0 Grandeur 04_S\0 Grandeur 05\0 Grandeur 05_S\0 Grandeur 06\0 Grandeur 06_S\0 Grandeur 07\0 Grandeur 07_S\0 Grandeur 08\0 Grandeur 08_S\0 Grandeur 09\0 Grandeur 09_S\0 Grandeur 10\0 Grandeur 10_S\0 Parisian 01\0 Parisian 01_S\0 Parisian 02\0 Parisian 02_S\0 Parisian 03\0 Parisian 03_S\0 Parisian 04\0 Parisian 04_S\0 Parisian 05\0 Parisian 05_S\0 Parisian 06\0 Parisian 06_S\0 Parisian 07\0 Parisian 07_S\0 Parisian 08\0 Parisian 08_S\0 Parisian 09\0 Parisian 09_S\0 Parisian 10\0 Parisian 10_S\0 Sugar Pop 01\0 Sugar Pop 01_S\0 Sugar Pop 02\0 Sugar Pop 02_S\0 Sugar Pop 03\0 Sugar Pop 03_S\0 Sugar Pop 04\0 Sugar Pop 04_S\0 Sugar Pop 05\0 Sugar Pop 05_S\0 Sugar Pop 06\0 Sugar Pop 06_S\0 Sugar Pop 07\0 Sugar Pop 07_S\0 Sugar Pop 08\0 Sugar Pop 08_S\0 Sugar Pop 09\0 Sugar Pop 09_S\0 Sugar Pop 10\0 Sugar Pop 10_S\0 Vintage Summer 01\0 Vintage Summer 01_S\0 Vintage Summer 02\0 Vintage Summer 02_S\0 Vintage Summer 03\0 Vintage Summer 03_S\0 Vintage Summer 04\0 Vintage Summer 04_S\0 Vintage Summer 05\0 Vintage Summer 05_S\0 Vintage Summer 06\0 Vintage Summer 06_S\0 Vintage Summer 07\0 Vintage Summer 07_S\0 Vintage Summer 08\0 Vintage Summer 08_S\0 Vintage Summer 09\0 Vintage Summer 09_S\0 Vintage Summer 10\0 Vintage Summer 10_S\0"; 
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
texture texMGMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texMGMultiLUT; };

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


technique Magazine_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}