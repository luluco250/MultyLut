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
	#define fLUT_TextureName "Night Magic.png"
#endif
#ifndef fLUT_TileSizeXY
	#define fLUT_TileSizeXY 32
#endif
#ifndef fLUT_TileAmount
	#define fLUT_TileAmount 32
#endif
#ifndef fLUT_LutAmount
	#define fLUT_LutAmount 129
#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform int fLUT_LutSelector < 
	ui_type = "combo";
	ui_min= 0; ui_max=16;
	ui_items=" Boyle S\0 Boyle V\0 Boyle\0 Busby S\0 Busby V\0 Busby\0 Canora S\0 Canora V\0 Canora\0 Cardston S\0 Cardston V\0 Cardston\0 Chatfield S\0 Chatfield V\0 Chatfield\0 Davidson S\0 Davidson V\0 Davidson\0 Denare S\0 Denare V\0 Denare\0 Earls S\0 Earls V\0 Earls\0 Edson S\0 Edson V\0 Edson\0 Fedorah S\0 Fedorah V\0 Fedorah\0 Granisle S\0 Granisle V\0 Granisle\0 Hinton S\0 Hinton V\0 Hinton\0 Kahntah S\0 Kahntah V\0 Kahntah\0 Kelsey S\0 Kelsey V\0 Kelsey\0 Kinney S\0 Kinney V\0 Kinney\0 Kinosis S\0 Kinosis V\0 Kinosis\0 Kuldo S\0 Kuldo V\0 Kuldo\0 Lutose S\0 Lutose V\0 Lutose\0 Manning S\0 Manning V\0 Manning\0 Manson S\0 Manson V\0 Manson\0 Margie S\0 Margie V\0 Margie\0 Nakusp S\0 Nakusp V\0 Nakusp\0 Namu S\0 Namu V\0 Namu\0 Nelson S\0 Nelson V\0 Nelson\0 Notigi S\0 Notigi V\0 Notigi\0 Paddle S\0 Paddle V\0 Paddle\0 Perryvale S\0 Perryvale V\0 Perryvale\0 Pingle S\0 Pingle V\0 Pingle\0 Rosetown S\0 Rosetown V\0 Rosetown\0 Shellbrook S\0 Shellbrook V\0 Shellbrook\0 Smithers S\0 Smithers V\0 Smithers\0 Spiritwood S\0 Spiritwood V\0 Spiritwood\0 Sundance S\0 Sundance V\0 Sundance\0 Surrey S\0 Surrey V\0 Surrey\0 Terrace S\0 Terrace V\0 Terrace\0 Tisdale S\0 Tisdale V\0 Tisdale\0 Topley S\0 Topley V\0 Topley\0 Vega S\0 Vega V\0 Vega\0 Vermilion S\0 Vermilion V\0 Vermilion\0 Vimy S\0 Vimy V\0 Vimy\0 Weir S\0 Weir V\0 Weir\0 Westlock S\0 Westlock V\0 Westlock\0 Zama S\0 Zama V\0 Zama\0";
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
texture texNMMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texNMMultiLUT; };

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


technique Night_Magic_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}