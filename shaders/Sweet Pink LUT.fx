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
	#define fLUT_TextureName "Sweet Pink LUT.png"
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
	ui_items=" Avleen 01\0 Avleen 01_S\0 Avleen 02\0 Avleen 02_S\0 Avleen 03\0 Avleen 03_S\0 Avleen 04\0 Avleen 04_S\0 Avleen 05\0 Avleen 05_S\0 Avleen 06\0 Avleen 06_S\0 Avleen 07\0 Avleen 07_S\0 Avleen 08\0 Avleen 08_S\0 Avleen 09\0 Avleen 09_S\0 Avleen 10\0 Avleen 10_S\0 Cerys 01\0 Cerys 01_S\0 Cerys 02\0 Cerys 02_S\0 Cerys 03\0 Cerys 03_S\0 Cerys 04\0 Cerys 04_S\0 Cerys 05\0 Cerys 05_S\0 Cerys 06\0 Cerys 06_S\0 Cerys 07\0 Cerys 07_S\0 Cerys 08\0 Cerys 08_S\0 Cerys 09\0 Cerys 09_S\0 Cerys 10\0 Cerys 10_S\0 Chloe 01\0 Chloe 01_S\0 Chloe 02\0 Chloe 02_S\0 Chloe 03\0 Chloe 03_S\0 Chloe 04\0 Chloe 04_S\0 Chloe 05\0 Chloe 05_S\0 Chloe 06\0 Chloe 06_S\0 Chloe 07\0 Chloe 07_S\0 Chloe 08\0 Chloe 08_S\0 Chloe 09\0 Chloe 09_S\0 Chloe 10\0 Chloe 10_S\0 Inara 01\0 Inara 01_S\0 Inara 02\0 Inara 02_S\0 Inara 03\0 Inara 03_S\0 Inara 04\0 Inara 04_S\0 Inara 05\0 Inara 05_S\0 Inara 06\0 Inara 06_S\0 Inara 07\0 Inara 07_S\0 Inara 08\0 Inara 08_S\0 Inara 09\0 Inara 09_S\0 Inara 10\0 Inara 10_S\0 Jamelia 01\0 Jamelia 01_S\0 Jamelia 02\0 Jamelia 02_S\0 Jamelia 03\0 Jamelia 03_S\0 Jamelia 04\0 Jamelia 04_S\0 Jamelia 05\0 Jamelia 05_S\0 Jamelia 06\0 Jamelia 06_S\0 Jamelia 07\0 Jamelia 07_S\0 Jamelia 08\0 Jamelia 08_S\0 Jamelia 09\0 Jamelia 09_S\0 Jamelia 10\0 Jamelia 10_S\0"; 
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
texture texSwPkMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texSwPkMultiLUT; };

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


technique Sweet_Pink_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}