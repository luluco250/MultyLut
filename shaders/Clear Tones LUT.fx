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
	#define fLUT_TextureName "Clear Tones LUT.png"
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
	ui_items=" Cinematic 01\0 Cinematic 01_S\0 Cinematic 02\0 Cinematic 02_S\0 Cinematic 03\0 Cinematic 03_S\0 Cinematic 04\0 Cinematic 04_S\0 Cinematic 05\0 Cinematic 05_S\0 Cinematic 06\0 Cinematic 06_S\0 Cinematic 07\0 Cinematic 07_S\0 Cinematic 08\0 Cinematic 08_S\0 Cinematic 09\0 Cinematic 09_S\0 Cinematic 10\0 Cinematic 10_S\0 Copper 01\0 Copper 01_S\0 Copper 02\0 Copper 02_S\0 Copper 03\0 Copper 03_S\0 Copper 04\0 Copper 04_S\0 Copper 05\0 Copper 05_S\0 Copper 06\0 Copper 06_S\0 Copper 07\0 Copper 07_S\0 Copper 08\0 Copper 08_S\0 Copper 09\0 Copper 09_S\0 Copper 10\0 Copper 10_S\0 Filmic 01\0 Filmic 01_S\0 Filmic 02\0 Filmic 02_S\0 Filmic 03\0 Filmic 03_S\0 Filmic 04\0 Filmic 04_S\0 Filmic 05\0 Filmic 05_S\0 Filmic 06\0 Filmic 06_S\0 Filmic 07\0 Filmic 07_S\0 Filmic 08\0 Filmic 08_S\0 Filmic 09\0 Filmic 09_S\0 Filmic 10\0 Filmic 10_S\0 Vibrant 01\0 Vibrant 01_S\0 Vibrant 02\0 Vibrant 02_S\0 Vibrant 03\0 Vibrant 03_S\0 Vibrant 04\0 Vibrant 04_S\0 Vibrant 05\0 Vibrant 05_S\0 Vibrant 06\0 Vibrant 06_S\0 Vibrant 07\0 Vibrant 07_S\0 Vibrant 08\0 Vibrant 08_S\0 Vibrant 09\0 Vibrant 09_S\0 Vibrant 10\0 Vibrant 10_S\0 Vintage 01\0 Vintage 01_S\0 Vintage 02\0 Vintage 02_S\0 Vintage 03\0 Vintage 03_S\0 Vintage 04\0 Vintage 04_S\0 Vintage 05\0 Vintage 05_S\0 Vintage 06\0 Vintage 06_S\0 Vintage 07\0 Vintage 07_S\0 Vintage 08\0 Vintage 08_S\0 Vintage 09\0 Vintage 09_S\0 Vintage 10\0 Vintage 10_S\0"; 
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
texture texClearTonesMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texClearTonesMultiLUT; };

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


technique Clear_Tones_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}