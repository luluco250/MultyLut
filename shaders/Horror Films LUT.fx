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
	#define fLUT_TextureName "Horror Films LUT.png"
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
	ui_items=" Ghost 01\0 Ghost 01_S\0 Ghost 02\0 Ghost 02_S\0 Ghost 03\0 Ghost 03_S\0 Ghost 04\0 Ghost 04_S\0 Ghost 05\0 Ghost 05_S\0 Ghost 06\0 Ghost 06_S\0 Ghost 07\0 Ghost 07_S\0 Ghost 08\0 Ghost 08_S\0 Ghost 09\0 Ghost 09_S\0 Ghost 10\0 Ghost 10_S\0 Haunted 01\0 Haunted 01_S\0 Haunted 02\0 Haunted 02_S\0 Haunted 03\0 Haunted 03_S\0 Haunted 04\0 Haunted 04_S\0 Haunted 05\0 Haunted 05_S\0 Haunted 06\0 Haunted 06_S\0 Haunted 07\0 Haunted 07_S\0 Haunted 08\0 Haunted 08_S\0 Haunted 09\0 Haunted 09_S\0 Haunted 10\0 Haunted 10_S\0 Nightmare 01\0 Nightmare 01_S\0 Nightmare 02\0 Nightmare 02_S\0 Nightmare 03\0 Nightmare 03_S\0 Nightmare 04\0 Nightmare 04_S\0 Nightmare 05\0 Nightmare 05_S\0 Nightmare 06\0 Nightmare 06_S\0 Nightmare 07\0 Nightmare 07_S\0 Nightmare 08\0 Nightmare 08_S\0 Nightmare 09\0 Nightmare 09_S\0 Nightmare 10\0 Nightmare 10_S\0 Supernatural 01\0 Supernatural 01_S\0 Supernatural 02\0 Supernatural 02_S\0 Supernatural 03\0 Supernatural 03_S\0 Supernatural 04\0 Supernatural 04_S\0 Supernatural 05\0 Supernatural 05_S\0 Supernatural 06\0 Supernatural 06_S\0 Supernatural 07\0 Supernatural 07_S\0 Supernatural 08\0 Supernatural 08_S\0 Supernatural 09\0 Supernatural 09_S\0 Supernatural 10\0 Supernatural 10_S\0 Thriller 01\0 Thriller 01_S\0 Thriller 02\0 Thriller 02_S\0 Thriller 03\0 Thriller 03_S\0 Thriller 04\0 Thriller 04_S\0 Thriller 05\0 Thriller 05_S\0 Thriller 06\0 Thriller 06_S\0 Thriller 07\0 Thriller 07_S\0 Thriller 08\0 Thriller 08_S\0 Thriller 09\0 Thriller 09_S\0 Thriller 10\0 Thriller 10_S\0"; 
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
texture texhorrorMultiLUT < source = fLUT_TextureName; > { Width = fLUT_TileSizeXY*fLUT_TileAmount; Height = fLUT_TileSizeXY * fLUT_LutAmount; Format = RGBA8; };
sampler	SamplerMultiLUT { Texture = texhorrorMultiLUT; };

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


technique Horror_Films_LUT
{
	pass MultiLUT_Apply
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_MultiLUT_Apply;
	}
}