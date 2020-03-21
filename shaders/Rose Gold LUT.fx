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
	#define fLUT_TextureName "Rose Gold LUT.png"
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
	ui_items=" Kors 01\0 Kors 01_S\0 Kors 02\0 Kors 02_S\0 Kors 03\0 Kors 03_S\0 Kors 04\0 Kors 04_S\0 Kors 05\0 Kors 05_S\0 Kors 06\0 Kors 06_S\0 Kors 07\0 Kors 07_S\0 Kors 08\0 Kors 08_S\0 Kors 09\0 Kors 09_S\0 Kors 10\0 Kors 10_S\0 Lily 01\0 Lily 01_S\0 Lily 02\0 Lily 02_S\0 Lily 03\0 Lily 03_S\0 Lily 04\0 Lily 04_S\0 Lily 05\0 Lily 05_S\0 Lily 06\0 Lily 06_S\0 Lily 07\0 Lily 07_S\0 Lily 08\0 Lily 08_S\0 Lily 09\0 Lily 09_S\0 Lily 10\0 Lily 10_S\0 Melrose 01\0 Melrose 01_S\0 Melrose 02\0 Melrose 02_S\0 Melrose 03\0 Melrose 03_S\0 Melrose 04\0 Melrose 04_S\0 Melrose 05\0 Melrose 05_S\0 Melrose 06\0 Melrose 06_S\0 Melrose 07\0 Melrose 07_S\0 Melrose 08\0 Melrose 08_S\0 Melrose 09\0 Melrose 09_S\0 Melrose 10\0 Melrose 10_S\0 Nixon 01\0 Nixon 01_S\0 Nixon 02\0 Nixon 02_S\0 Nixon 03\0 Nixon 03_S\0 Nixon 04\0 Nixon 04_S\0 Nixon 05\0 Nixon 05_S\0 Nixon 06\0 Nixon 06_S\0 Nixon 07\0 Nixon 07_S\0 Nixon 08\0 Nixon 08_S\0 Nixon 09\0 Nixon 09_S\0 Nixon 10\0 Nixon 10_S\0 Olivia 01\0 Olivia 01_S\0 Olivia 02\0 Olivia 02_S\0 Olivia 03\0 Olivia 03_S\0 Olivia 04\0 Olivia 04_S\0 Olivia 05\0 Olivia 05_S\0 Olivia 06\0 Olivia 06_S\0 Olivia 07\0 Olivia 07_S\0 Olivia 08\0 Olivia 08_S\0 Olivia 09\0 Olivia 09_S\0 Olivia 10\0 Olivia 10_S\0"; 
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
texture texRGLMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texRGLMultiLUT; };

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


technique Rose_Gold_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}