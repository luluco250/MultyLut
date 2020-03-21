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
	#define fLUT_TextureName "Tropical LUT.png"
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
	ui_items=" Brandi 01\0 Brandi 01_S\0 Brandi 02\0 Brandi 02_S\0 Brandi 03\0 Brandi 03_S\0 Brandi 04\0 Brandi 04_S\0 Brandi 05\0 Brandi 05_S\0 Brandi 06\0 Brandi 06_S\0 Brandi 07\0 Brandi 07_S\0 Brandi 08\0 Brandi 08_S\0 Brandi 09\0 Brandi 09_S\0 Brandi 10\0 Brandi 10_S\0 Danni 01\0 Danni 01_S\0 Danni 02\0 Danni 02_S\0 Danni 03\0 Danni 03_S\0 Danni 04\0 Danni 04_S\0 Danni 05\0 Danni 05_S\0 Danni 06\0 Danni 06_S\0 Danni 07\0 Danni 07_S\0 Danni 08\0 Danni 08_S\0 Danni 09\0 Danni 09_S\0 Danni 10\0 Danni 10_S\0 Kali 01\0 Kali 01_S\0 Kali 02\0 Kali 02_S\0 Kali 03\0 Kali 03_S\0 Kali 04\0 Kali 04_S\0 Kali 05\0 Kali 05_S\0 Kali 06\0 Kali 06_S\0 Kali 07\0 Kali 07_S\0 Kali 08\0 Kali 08_S\0 Kali 09\0 Kali 09_S\0 Kali 10\0 Kali 10_S\0 Nikki 01\0 Nikki 01_S\0 Nikki 02\0 Nikki 02_S\0 Nikki 03\0 Nikki 03_S\0 Nikki 04\0 Nikki 04_S\0 Nikki 05\0 Nikki 05_S\0 Nikki 06\0 Nikki 06_S\0 Nikki 07\0 Nikki 07_S\0 Nikki 08\0 Nikki 08_S\0 Nikki 09\0 Nikki 09_S\0 Nikki 10\0 Nikki 10_S\0 Tobi 01\0 Tobi 01_S\0 Tobi 02\0 Tobi 02_S\0 Tobi 03\0 Tobi 03_S\0 Tobi 04\0 Tobi 04_S\0 Tobi 05\0 Tobi 05_S\0 Tobi 06\0 Tobi 06_S\0 Tobi 07\0 Tobi 07_S\0 Tobi 08\0 Tobi 08_S\0 Tobi 09\0 Tobi 09_S\0 Tobi 10\0 Tobi 10_S\0"; 
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
texture texTropMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texTropMultiLUT; };

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


technique Tropical_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}