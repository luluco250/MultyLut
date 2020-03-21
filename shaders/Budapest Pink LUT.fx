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
	#define fLUT_TextureName "Budapest Pink LUT.png"
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
	ui_items=" Budapest 01\0 Budapest 01_S\0 Budapest 02\0 Budapest 02_S\0 Budapest 03\0 Budapest 03_S\0 Budapest 04\0 Budapest 04_S\0 Budapest 05\0 Budapest 05_S\0 Budapest 06\0 Budapest 06_S\0 Budapest 07\0 Budapest 07_S\0 Budapest 08\0 Budapest 08_S\0 Budapest 09\0 Budapest 09_S\0 Budapest 10\0 Budapest 10_S\0 Checkpoint 19 01\0 Checkpoint 19 01_S\0 Checkpoint 19 02\0 Checkpoint 19 02_S\0 Checkpoint 19 03\0 Checkpoint 19 03_S\0 Checkpoint 19 04\0 Checkpoint 19 04_S\0 Checkpoint 19 05\0 Checkpoint 19 05_S\0 Checkpoint 19 06\0 Checkpoint 19 06_S\0 Checkpoint 19 07\0 Checkpoint 19 07_S\0 Checkpoint 19 08\0 Checkpoint 19 08_S\0 Checkpoint 19 09\0 Checkpoint 19 09_S\0 Checkpoint 19 10\0 Checkpoint 19 10_S\0 Gustave 01\0 Gustave 01_S\0 Gustave 02\0 Gustave 02_S\0 Gustave 03\0 Gustave 03_S\0 Gustave 04\0 Gustave 04_S\0 Gustave 05\0 Gustave 05_S\0 Gustave 06\0 Gustave 06_S\0 Gustave 07\0 Gustave 07_S\0 Gustave 08\0 Gustave 08_S\0 Gustave 09\0 Gustave 09_S\0 Gustave 10\0 Gustave 10_S\0 Mendl 01\0 Mendl 01_S\0 Mendl 02\0 Mendl 02_S\0 Mendl 03\0 Mendl 03_S\0 Mendl 04\0 Mendl 04_S\0 Mendl 05\0 Mendl 05_S\0 Mendl 06\0 Mendl 06_S\0 Mendl 07\0 Mendl 07_S\0 Mendl 08\0 Mendl 08_S\0 Mendl 09\0 Mendl 09_S\0 Mendl 10\0 Mendl 10_S\0 Once Ritzy 01\0 Once Ritzy 01_S\0 Once Ritzy 02\0 Once Ritzy 02_S\0 Once Ritzy 03\0 Once Ritzy 03_S\0 Once Ritzy 04\0 Once Ritzy 04_S\0 Once Ritzy 05\0 Once Ritzy 05_S\0 Once Ritzy 06\0 Once Ritzy 06_S\0 Once Ritzy 07\0 Once Ritzy 07_S\0 Once Ritzy 08\0 Once Ritzy 08_S\0 Once Ritzy 09\0 Once Ritzy 09_S\0 Once Ritzy 10\0 Once Ritzy 10_S\0"; 
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
texture texBudaPinkMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texBudaPinkMultiLUT; };

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


technique Budapest_Pink_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}