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
	#define fLUT_TextureName "Nomad LUT.png"
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
	ui_items=" Bridal 01\0 Bridal 01_S\0 Bridal 02\0 Bridal 02_S\0 Bridal 03\0 Bridal 03_S\0 Bridal 04\0 Bridal 04_S\0 Bridal 05\0 Bridal 05_S\0 Bridal 06\0 Bridal 06_S\0 Bridal 07\0 Bridal 07_S\0 Bridal 08\0 Bridal 08_S\0 Bridal 09\0 Bridal 09_S\0 Bridal 10\0 Bridal 10_S\0 Crystal 01\0 Crystal 01_S\0 Crystal 02\0 Crystal 02_S\0 Crystal 03\0 Crystal 03_S\0 Crystal 04\0 Crystal 04_S\0 Crystal 05\0 Crystal 05_S\0 Crystal 06\0 Crystal 06_S\0 Crystal 07\0 Crystal 07_S\0 Crystal 08\0 Crystal 08_S\0 Crystal 09\0 Crystal 09_S\0 Crystal 10\0 Crystal 10_S\0 Nautical 01\0 Nautical 01_S\0 Nautical 02\0 Nautical 02_S\0 Nautical 03\0 Nautical 03_S\0 Nautical 04\0 Nautical 04_S\0 Nautical 05\0 Nautical 05_S\0 Nautical 06\0 Nautical 06_S\0 Nautical 07\0 Nautical 07_S\0 Nautical 08\0 Nautical 08_S\0 Nautical 09\0 Nautical 09_S\0 Nautical 10\0 Nautical 10_S\0 Opal 01\0 Opal 01_S\0 Opal 02\0 Opal 02_S\0 Opal 03\0 Opal 03_S\0 Opal 04\0 Opal 04_S\0 Opal 05\0 Opal 05_S\0 Opal 06\0 Opal 06_S\0 Opal 07\0 Opal 07_S\0 Opal 08\0 Opal 08_S\0 Opal 09\0 Opal 09_S\0 Opal 10\0 Opal 10_S\0 Tribal 01\0 Tribal 01_S\0 Tribal 02\0 Tribal 02_S\0 Tribal 03\0 Tribal 03_S\0 Tribal 04\0 Tribal 04_S\0 Tribal 05\0 Tribal 05_S\0 Tribal 06\0 Tribal 06_S\0 Tribal 07\0 Tribal 07_S\0 Tribal 08\0 Tribal 08_S\0 Tribal 09\0 Tribal 09_S\0 Tribal 10\0 Tribal 10_S\0"; 
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
texture texNomadMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texNomadMultiLUT; };

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


technique Nomad_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}