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
	#define fLUT_TextureName "Osaka LUT.png"
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
	ui_items=" Castle 01\0 Castle 01_S\0 Castle 02\0 Castle 02_S\0 Castle 03\0 Castle 03_S\0 Castle 04\0 Castle 04_S\0 Castle 05\0 Castle 05_S\0 Castle 06\0 Castle 06_S\0 Castle 07\0 Castle 07_S\0 Castle 08\0 Castle 08_S\0 Castle 09\0 Castle 09_S\0 Castle 10\0 Castle 10_S\0 Dotonbori 01\0 Dotonbori 01_S\0 Dotonbori 02\0 Dotonbori 02_S\0 Dotonbori 03\0 Dotonbori 03_S\0 Dotonbori 04\0 Dotonbori 04_S\0 Dotonbori 05\0 Dotonbori 05_S\0 Dotonbori 06\0 Dotonbori 06_S\0 Dotonbori 07\0 Dotonbori 07_S\0 Dotonbori 08\0 Dotonbori 08_S\0 Dotonbori 09\0 Dotonbori 09_S\0 Dotonbori 10\0 Dotonbori 10_S\0 Kuromon 01\0 Kuromon 01_S\0 Kuromon 02\0 Kuromon 02_S\0 Kuromon 03\0 Kuromon 03_S\0 Kuromon 04\0 Kuromon 04_S\0 Kuromon 05\0 Kuromon 05_S\0 Kuromon 06\0 Kuromon 06_S\0 Kuromon 07\0 Kuromon 07_S\0 Kuromon 08\0 Kuromon 08_S\0 Kuromon 09\0 Kuromon 09_S\0 Kuromon 10\0 Kuromon 10_S\0 Orange St 01\0 Orange St 01_S\0 Orange St 02\0 Orange St 02_S\0 Orange St 03\0 Orange St 03_S\0 Orange St 04\0 Orange St 04_S\0 Orange St 05\0 Orange St 05_S\0 Orange St 06\0 Orange St 06_S\0 Orange St 07\0 Orange St 07_S\0 Orange St 08\0 Orange St 08_S\0 Orange St 09\0 Orange St 09_S\0 Orange St 10\0 Orange St 10_S\0 Tempozan 01\0 Tempozan 01_S\0 Tempozan 02\0 Tempozan 02_S\0 Tempozan 03\0 Tempozan 03_S\0 Tempozan 04\0 Tempozan 04_S\0 Tempozan 05\0 Tempozan 05_S\0 Tempozan 06\0 Tempozan 06_S\0 Tempozan 07\0 Tempozan 07_S\0 Tempozan 08\0 Tempozan 08_S\0 Tempozan 09\0 Tempozan 09_S\0 Tempozan 10\0 Tempozan 10_S\0"; 
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
texture texOsakaMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texOsakaMultiLUT; };

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


technique Osaka_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}