//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Multi-LUT shader, using a texture atlas with multiple LUTs
// by Otis / Infuse Project.
// Based on Marty's LUT shader 1.0 for ReShade 3.0
// Copyright © 2008-2016 Marty McFly
// Converted by TheGordinho 
// Thanks to kingeric1992 and Matsilagi for the tools
// Thanks to Fernando Souza from blackmagicdesign.com for converting the https://gmic.eu/color_presets/ to .cube 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef fLUT_TextureName
	#define fLUT_TextureName "Instant Pro LUT.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 64
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 64
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 67
#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform int fLUT_LutSelector < 
	ui_type = "combo";
	ui_min= 0; ui_max=16;
	ui_items="fuji_fp-100c\0fuji_fp-100c_+++\0fuji_fp-100c_++\0fuji_fp-100c_++_alt\0fuji_fp-100c_+\0fuji_fp-100c_--\0fuji_fp-100c_-\0fuji_fp-100c_cool\0fuji_fp-100c_cool_++\0fuji_fp-100c_cool_+\0fuji_fp-100c_cool_--\0fuji_fp-100c_cool_-\0fuji_fp-100c_negative\0fuji_fp-100c_negative_+++\0fuji_fp-100c_negative_++\0fuji_fp-100c_negative_++_alt\0fuji_fp-100c_negative_+\0fuji_fp-100c_negative_--\0fuji_fp-100c_negative_-\0fuji_fp-3000b\0fuji_fp-3000b_+++\0fuji_fp-3000b_++\0fuji_fp-3000b_+\0fuji_fp-3000b_--\0fuji_fp-3000b_-\0fuji_fp-3000b_hc\0fuji_fp-3000b_negative\0fuji_fp-3000b_negative_+++\0fuji_fp-3000b_negative_++\0fuji_fp-3000b_negative_+\0fuji_fp-3000b_negative_--\0fuji_fp-3000b_negative_-\0fuji_fp-3000b_negative_early\0polaroid_665\0polaroid_665_++\0polaroid_665_+\0polaroid_665_--\0polaroid_665_-\0polaroid_665_negative\0polaroid_665_negative_+\0polaroid_665_negative_-\0polaroid_665_negative_hc\0polaroid_669\0polaroid_669_+++\0polaroid_669_++\0polaroid_669_+\0polaroid_669_--\0polaroid_669_-\0polaroid_669_cold\0polaroid_669_cold_+\0polaroid_669_cold_--\0polaroid_669_cold_-\0polaroid_690\0polaroid_690_++\0polaroid_690_+\0polaroid_690_--\0polaroid_690_-\0polaroid_690_cold\0polaroid_690_cold_++\0polaroid_690_cold_+\0polaroid_690_cold_--\0polaroid_690_cold_-\0polaroid_690_warm\0polaroid_690_warm_++\0polaroid_690_warm_+\0polaroid_690_warm_--\0polaroid_690_warm_-\0"; 
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
texture texProMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texProMultiLUT; };

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


technique Instant_PRO_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}