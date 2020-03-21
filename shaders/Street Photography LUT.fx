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
	#define fLUT_TextureName "Street Photography LUT.png"
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
	ui_items=" Arcade 01\0 Arcade 01_S\0 Arcade 02\0 Arcade 02_S\0 Arcade 03\0 Arcade 03_S\0 Arcade 04\0 Arcade 04_S\0 Arcade 05\0 Arcade 05_S\0 Arcade 06\0 Arcade 06_S\0 Arcade 07\0 Arcade 07_S\0 Arcade 08\0 Arcade 08_S\0 Arcade 09\0 Arcade 09_S\0 Arcade 10\0 Arcade 10_S\0 Barbershop 01\0 Barbershop 01_S\0 Barbershop 02\0 Barbershop 02_S\0 Barbershop 03\0 Barbershop 03_S\0 Barbershop 04\0 Barbershop 04_S\0 Barbershop 05\0 Barbershop 05_S\0 Barbershop 06\0 Barbershop 06_S\0 Barbershop 07\0 Barbershop 07_S\0 Barbershop 08\0 Barbershop 08_S\0 Barbershop 09\0 Barbershop 09_S\0 Barbershop 10\0 Barbershop 10_S\0 Bookshop 01\0 Bookshop 01_S\0 Bookshop 02\0 Bookshop 02_S\0 Bookshop 03\0 Bookshop 03_S\0 Bookshop 04\0 Bookshop 04_S\0 Bookshop 05\0 Bookshop 05_S\0 Bookshop 06\0 Bookshop 06_S\0 Bookshop 07\0 Bookshop 07_S\0 Bookshop 08\0 Bookshop 08_S\0 Bookshop 09\0 Bookshop 09_S\0 Bookshop 10\0 Bookshop 10_S\0 Corner Store 01\0 Corner Store 01_S\0 Corner Store 02\0 Corner Store 02_S\0 Corner Store 03\0 Corner Store 03_S\0 Corner Store 04\0 Corner Store 04_S\0 Corner Store 05\0 Corner Store 05_S\0 Corner Store 06\0 Corner Store 06_S\0 Corner Store 07\0 Corner Store 07_S\0 Corner Store 08\0 Corner Store 08_S\0 Corner Store 09\0 Corner Store 09_S\0 Corner Store 10\0 Corner Store 10_S\0 Morning 01\0 Morning 01_S\0 Morning 02\0 Morning 02_S\0 Morning 03\0 Morning 03_S\0 Morning 04\0 Morning 04_S\0 Morning 05\0 Morning 05_S\0 Morning 06\0 Morning 06_S\0 Morning 07\0 Morning 07_S\0 Morning 08\0 Morning 08_S\0 Morning 09\0 Morning 09_S\0 Morning 10\0 Morning 10_S\0"; 
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
texture texStreeMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texStreeMultiLUT; };

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


technique Street_Photography_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}