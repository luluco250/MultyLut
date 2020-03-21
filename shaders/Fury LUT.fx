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
	#define fLUT_TextureName "Fury LUT.png"
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
	ui_items=" Flamethrower 01\0 Flamethrower 01_S\0 Flamethrower 02\0 Flamethrower 02_S\0 Flamethrower 03\0 Flamethrower 03_S\0 Flamethrower 04\0 Flamethrower 04_S\0 Flamethrower 05\0 Flamethrower 05_S\0 Flamethrower 06\0 Flamethrower 06_S\0 Flamethrower 07\0 Flamethrower 07_S\0 Flamethrower 08\0 Flamethrower 08_S\0 Flamethrower 09\0 Flamethrower 09_S\0 Flamethrower 10\0 Flamethrower 10_S\0 Flare 01\0 Flare 01_S\0 Flare 02\0 Flare 02_S\0 Flare 03\0 Flare 03_S\0 Flare 04\0 Flare 04_S\0 Flare 05\0 Flare 05_S\0 Flare 06\0 Flare 06_S\0 Flare 07\0 Flare 07_S\0 Flare 08\0 Flare 08_S\0 Flare 09\0 Flare 09_S\0 Flare 10\0 Flare 10_S\0 Fyre 01\0 Fyre 01_S\0 Fyre 02\0 Fyre 02_S\0 Fyre 03\0 Fyre 03_S\0 Fyre 04\0 Fyre 04_S\0 Fyre 05\0 Fyre 05_S\0 Fyre 06\0 Fyre 06_S\0 Fyre 07\0 Fyre 07_S\0 Fyre 08\0 Fyre 08_S\0 Fyre 09\0 Fyre 09_S\0 Fyre 10\0 Fyre 10_S\0 Nergy 01\0 Nergy 01_S\0 Nergy 02\0 Nergy 02_S\0 Nergy 03\0 Nergy 03_S\0 Nergy 04\0 Nergy 04_S\0 Nergy 05\0 Nergy 05_S\0 Nergy 06\0 Nergy 06_S\0 Nergy 07\0 Nergy 07_S\0 Nergy 08\0 Nergy 08_S\0 Nergy 09\0 Nergy 09_S\0 Nergy 10\0 Nergy 10_S\0 Steel 01\0 Steel 01_S\0 Steel 02\0 Steel 02_S\0 Steel 03\0 Steel 03_S\0 Steel 04\0 Steel 04_S\0 Steel 05\0 Steel 05_S\0 Steel 06\0 Steel 06_S\0 Steel 07\0 Steel 07_S\0 Steel 08\0 Steel 08_S\0 Steel 09\0 Steel 09_S\0 Steel 10\0 Steel 10_S\0"; 
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
texture texFuryMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texFuryMultiLUT; };

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


technique Fury_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}