#pragma once

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Multi-LUT shader, using a texture atlas with multiple LUTs
// by Otis / Infuse Project.
// Based on Marty's LUT shader 1.0 for ReShade 3.0
// Copyright © 2008-2016 Marty McFly
// Converted by TheGordinho
// Thanks to kingeric1992 and Matsilagi for the tools
// Refactored by luluco250
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//#region Preprocessor

#include "ReShade.fxh"
#include "ReShadeUI.fxh"

#if !defined(fLUT_TechniqueName)
    #error "LUT technique name not defined"
#endif

#if !defined(fLUT_LutList)
	#error "LUT list not defined"
#endif

#if !defined(fLUT_TextureName)
    #error "LUT texture name not defined"
#endif

#if !defined(fLUT_TileSizeXY)
    #error "LUT tile size not defined"
#endif

#if !defined(fLUT_TileAmount)
    #error "LUT tile amount not defined"
#endif

#if !defined(fLUT_LutAmount)
    #error "LUT amount not defined"
#endif

#define _JOIN(a, b) a##b

#define fLUT_InternalTextureName _JOIN(fLUT_TechniqueName, _MultiLUTTex)

//#endregion

//#region Uniforms

uniform int fLUT_LutSelector
<
	__UNIFORM_COMBO_INT1

	ui_label = "The LUT to use";
	ui_items = fLUT_LutList;
> = 0;

uniform float fLUT_AmountChroma
<
	__UNIFORM_DRAG_FLOAT1

	ui_label = "LUT chroma amount";
	ui_tooltip =
		"Intensity of color/chroma change of the LUT.\n"
		"\nDefault: 1.0";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.001;
> = 1.0;

uniform float fLUT_AmountLuma
<
	__UNIFORM_DRAG_FLOAT1

	ui_label = "LUT luma amount";
	ui_tooltip =
		"Intensity of luma change of the LUT.\n"
		"\nDefault: 1.0";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.001;
> = 1.0;

//#endregion

//#region Textures

texture fLUT_InternalTextureName <source = fLUT_TextureName;>
{
	Width = fLUT_TileSizeXY * fLUT_TileAmount;
	Height = fLUT_TileSizeXY * fLUT_LutAmount;
};

sampler	MultiLUT
{
	Texture = fLUT_InternalTextureName;
};

//#endregion

//#region Shaders

float4 MainPS(
	float4 pos : SV_POSITION,
	float2 uv : TEXCOORD) : SV_TARGET
{
	float4 color = tex2D(ReShade::BackBuffer, uv);

	float2 texelsize = rcp(fLUT_TileSizeXY);
	texelsize.x /= fLUT_TileAmount;

	float3 lutcoord = float3(
		(color.xy * fLUT_TileSizeXY - color.xy + 0.5) * texelsize,
		color.z * fLUT_TileSizeXY - color.z);

	lutcoord.y /= fLUT_LutAmount;
	lutcoord.y += float(fLUT_LutSelector) / fLUT_LutAmount;

	float lerpfact = frac(lutcoord.z);
	lutcoord.x += (lutcoord.z - lerpfact) * texelsize.y;

	float3 lutcolor = lerp(
		tex2D(MultiLUT, lutcoord.xy).xyz,
		tex2D(MultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)).xyz,
		lerpfact);

	color.rgb =
		lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
	    lerp(length(color.xyz), length(lutcolor.xyz), fLUT_AmountLuma);

	return color;
}

//#endregion

//#region Technique

technique fLUT_TechniqueName
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = MainPS;
	}
}

//#endregion
