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
	#define fLUT_TextureName "Color Pop LUT.png"
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
	ui_items=" Candy 01\0 Candy 01_S\0 Candy 02\0 Candy 02_S\0 Candy 03\0 Candy 03_S\0 Candy 04\0 Candy 04_S\0 Candy 05\0 Candy 05_S\0 Candy 06\0 Candy 06_S\0 Candy 07\0 Candy 07_S\0 Candy 08\0 Candy 08_S\0 Candy 09\0 Candy 09_S\0 Candy 10\0 Candy 10_S\0 Carnival 01\0 Carnival 01_S\0 Carnival 02\0 Carnival 02_S\0 Carnival 03\0 Carnival 03_S\0 Carnival 04\0 Carnival 04_S\0 Carnival 05\0 Carnival 05_S\0 Carnival 06\0 Carnival 06_S\0 Carnival 07\0 Carnival 07_S\0 Carnival 08\0 Carnival 08_S\0 Carnival 09\0 Carnival 09_S\0 Carnival 10\0 Carnival 10_S\0 Destination 01\0 Destination 01_S\0 Destination 02\0 Destination 02_S\0 Destination 03\0 Destination 03_S\0 Destination 04\0 Destination 04_S\0 Destination 05\0 Destination 05_S\0 Destination 06\0 Destination 06_S\0 Destination 07\0 Destination 07_S\0 Destination 08\0 Destination 08_S\0 Destination 09\0 Destination 09_S\0 Destination 10\0 Destination 10_S\0 Dream 01\0 Dream 01_S\0 Dream 02\0 Dream 02_S\0 Dream 03\0 Dream 03_S\0 Dream 04\0 Dream 04_S\0 Dream 05\0 Dream 05_S\0 Dream 06\0 Dream 06_S\0 Dream 07\0 Dream 07_S\0 Dream 08\0 Dream 08_S\0 Dream 09\0 Dream 09_S\0 Dream 10\0 Dream 10_S\0 Sunrise 01\0 Sunrise 01_S\0 Sunrise 02\0 Sunrise 02_S\0 Sunrise 03\0 Sunrise 03_S\0 Sunrise 04\0 Sunrise 04_S\0 Sunrise 05\0 Sunrise 05_S\0 Sunrise 06\0 Sunrise 06_S\0 Sunrise 07\0 Sunrise 07_S\0 Sunrise 08\0 Sunrise 08_S\0 Sunrise 09\0 Sunrise 09_S\0 Sunrise 10\0 Sunrise 10_S\0"; 
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
texture texColPopMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texColPopMultiLUT; };

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


technique Color_Pop_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}