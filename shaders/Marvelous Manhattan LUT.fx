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
	#define fLUT_TextureName "Marvelous Manhattan LUT.png"
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
	ui_items=" Bryant 01\0 Bryant 01_S\0 Bryant 02\0 Bryant 02_S\0 Bryant 03\0 Bryant 03_S\0 Bryant 04\0 Bryant 04_S\0 Bryant 05\0 Bryant 05_S\0 Bryant 06\0 Bryant 06_S\0 Bryant 07\0 Bryant 07_S\0 Bryant 08\0 Bryant 08_S\0 Bryant 09\0 Bryant 09_S\0 Bryant 10\0 Bryant 10_S\0 Central 01\0 Central 01_S\0 Central 02\0 Central 02_S\0 Central 03\0 Central 03_S\0 Central 04\0 Central 04_S\0 Central 05\0 Central 05_S\0 Central 06\0 Central 06_S\0 Central 07\0 Central 07_S\0 Central 08\0 Central 08_S\0 Central 09\0 Central 09_S\0 Central 10\0 Central 10_S\0 get names.bat Harlem 01\0 Harlem 01_S\0 Harlem 02\0 Harlem 02_S\0 Harlem 03\0 Harlem 03_S\0 Harlem 04\0 Harlem 04_S\0 Harlem 05\0 Harlem 05_S\0 Harlem 06\0 Harlem 06_S\0 Harlem 07\0 Harlem 07_S\0 Harlem 08\0 Harlem 08_S\0 Harlem 09\0 Harlem 09_S\0 Harlem 10\0 Harlem 10_S\0 list.txt Pineapple 01\0 Pineapple 01_S\0 Pineapple 02\0 Pineapple 02_S\0 Pineapple 03\0 Pineapple 03_S\0 Pineapple 04\0 Pineapple 04_S\0 Pineapple 05\0 Pineapple 05_S\0 Pineapple 06\0 Pineapple 06_S\0 Pineapple 07\0 Pineapple 07_S\0 Pineapple 08\0 Pineapple 08_S\0 Pineapple 09\0 Pineapple 09_S\0 Pineapple 10\0 Pineapple 10_S\0 Times Square 01\0 Times Square 01_S\0 Times Square 02\0 Times Square 02_S\0 Times Square 03\0 Times Square 03_S\0 Times Square 04\0 Times Square 04_S\0 Times Square 05\0 Times Square 05_S\0 Times Square 06\0 Times Square 06_S\0 Times Square 07\0 Times Square 07_S\0 Times Square 08\0 Times Square 08_S\0 Times Square 09\0 Times Square 09_S\0 Times Square 10\0 Times Square 10_S\0"; 
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
texture texMArMAnMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texMArMAnMultiLUT; };

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


technique Marvelous_Manhattan_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}