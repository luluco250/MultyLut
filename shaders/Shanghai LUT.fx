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
	#define fLUT_TextureName "Shanghai LUT.png"
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
	ui_items=" Fuzhou 01\0 Fuzhou 01_S\0 Fuzhou 02\0 Fuzhou 02_S\0 Fuzhou 03\0 Fuzhou 03_S\0 Fuzhou 04\0 Fuzhou 04_S\0 Fuzhou 05\0 Fuzhou 05_S\0 Fuzhou 06\0 Fuzhou 06_S\0 Fuzhou 07\0 Fuzhou 07_S\0 Fuzhou 08\0 Fuzhou 08_S\0 Fuzhou 09\0 Fuzhou 09_S\0 Fuzhou 10\0 Fuzhou 10_S\0 Nanjing 01\0 Nanjing 01_S\0 Nanjing 02\0 Nanjing 02_S\0 Nanjing 03\0 Nanjing 03_S\0 Nanjing 04\0 Nanjing 04_S\0 Nanjing 05\0 Nanjing 05_S\0 Nanjing 06\0 Nanjing 06_S\0 Nanjing 07\0 Nanjing 07_S\0 Nanjing 08\0 Nanjing 08_S\0 Nanjing 09\0 Nanjing 09_S\0 Nanjing 10\0 Nanjing 10_S\0 Taikang 01\0 Taikang 01_S\0 Taikang 02\0 Taikang 02_S\0 Taikang 03\0 Taikang 03_S\0 Taikang 04\0 Taikang 04_S\0 Taikang 05\0 Taikang 05_S\0 Taikang 06\0 Taikang 06_S\0 Taikang 07\0 Taikang 07_S\0 Taikang 08\0 Taikang 08_S\0 Taikang 09\0 Taikang 09_S\0 Taikang 10\0 Taikang 10_S\0 Taojiang 01\0 Taojiang 01_S\0 Taojiang 02\0 Taojiang 02_S\0 Taojiang 03\0 Taojiang 03_S\0 Taojiang 04\0 Taojiang 04_S\0 Taojiang 05\0 Taojiang 05_S\0 Taojiang 06\0 Taojiang 06_S\0 Taojiang 07\0 Taojiang 07_S\0 Taojiang 08\0 Taojiang 08_S\0 Taojiang 09\0 Taojiang 09_S\0 Taojiang 10\0 Taojiang 10_S\0 Wukang 01\0 Wukang 01_S\0 Wukang 02\0 Wukang 02_S\0 Wukang 03\0 Wukang 03_S\0 Wukang 04\0 Wukang 04_S\0 Wukang 05\0 Wukang 05_S\0 Wukang 06\0 Wukang 06_S\0 Wukang 07\0 Wukang 07_S\0 Wukang 08\0 Wukang 08_S\0 Wukang 09\0 Wukang 09_S\0 Wukang 10\0 Wukang 10_S\0"; 
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
texture texshanghaiMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texshanghaiMultiLUT; };

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


technique Shanghai_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}