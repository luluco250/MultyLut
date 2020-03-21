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
	#define fLUT_TextureName "Mens Fashion LUT.png"
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
	ui_items=" Analog 01\0 Analog 01_S\0 Analog 02\0 Analog 02_S\0 Analog 03\0 Analog 03_S\0 Analog 04\0 Analog 04_S\0 Analog 05\0 Analog 05_S\0 Analog 06\0 Analog 06_S\0 Analog 07\0 Analog 07_S\0 Analog 08\0 Analog 08_S\0 Analog 09\0 Analog 09_S\0 Analog 10\0 Analog 10_S\0 Breathe 01\0 Breathe 01_S\0 Breathe 02\0 Breathe 02_S\0 Breathe 03\0 Breathe 03_S\0 Breathe 04\0 Breathe 04_S\0 Breathe 05\0 Breathe 05_S\0 Breathe 06\0 Breathe 06_S\0 Breathe 07\0 Breathe 07_S\0 Breathe 08\0 Breathe 08_S\0 Breathe 09\0 Breathe 09_S\0 Breathe 10\0 Breathe 10_S\0 Copper 01\0 Copper 01_S\0 Copper 02\0 Copper 02_S\0 Copper 03\0 Copper 03_S\0 Copper 04\0 Copper 04_S\0 Copper 05\0 Copper 05_S\0 Copper 06\0 Copper 06_S\0 Copper 07\0 Copper 07_S\0 Copper 08\0 Copper 08_S\0 Copper 09\0 Copper 09_S\0 Copper 10\0 Copper 10_S\0 Crema 01\0 Crema 01_S\0 Crema 02\0 Crema 02_S\0 Crema 03\0 Crema 03_S\0 Crema 04\0 Crema 04_S\0 Crema 05\0 Crema 05_S\0 Crema 06\0 Crema 06_S\0 Crema 07\0 Crema 07_S\0 Crema 08\0 Crema 08_S\0 Crema 09\0 Crema 09_S\0 Crema 10\0 Crema 10_S\0 Vintage 01\0 Vintage 01_S\0 Vintage 02\0 Vintage 02_S\0 Vintage 03\0 Vintage 03_S\0 Vintage 04\0 Vintage 04_S\0 Vintage 05\0 Vintage 05_S\0 Vintage 06\0 Vintage 06_S\0 Vintage 07\0 Vintage 07_S\0 Vintage 08\0 Vintage 08_S\0 Vintage 09\0 Vintage 09_S\0 Vintage 10\0 Vintage 10_S\0"; 
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
texture texMFSMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texMFSMultiLUT; };

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


technique Mans_Fashion_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}