texture3D NoiseMap<string ResourceName = "noise.dds";>; 
texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	bool AntiAlias = false;
	string Format = "A2R10G10B10";
>;
texture2D ScnMap2 : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	bool AntiAlias = false;
	string Format = "A2R10G10B10";
>;
sampler ScnSamp = sampler_state {
	texture = <ScnMap>;
	MinFilter = POINT;   MagFilter = POINT;   MipFilter = NONE;
	AddressU  = CLAMP;  AddressV = CLAMP;
};
sampler ScnSamp2 = sampler_state {
	texture = <ScnMap2>;
	MinFilter = POINT;   MagFilter = POINT;   MipFilter = NONE;
	AddressU  = WRAP;  AddressV = WRAP;
};
sampler NoiseMapSamp = sampler_state
{
	texture = NoiseMap;
	MINFILTER = LINEAR; MAGFILTER = LINEAR; ADDRESSU = WRAP; ADDRESSV = WRAP;
};

float time : TIME;
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset  = 0.5 / ViewportSize;
static float2 ViewportOffset2 = 1.0 / ViewportSize;
static float  ViewportAspect  = ViewportSize.x / ViewportSize.y;

float mFilmGrain : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmGrain";>;
float mFilmLineX : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLineX";>;
float mFilmLineY : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLineY";>;
float mFilmLineFadeX : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLineFadeX";>;
float mFilmLineFadeY : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLineFadeY";>;
float mFilmLoop : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLoop";>;
float mFilmLoopX : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLoopX";>;
float mFilmLoopY : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "FilmLoopY";>;
float mDispersion : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "Dispersion";>;
float mDispersionRadius : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "DispersionRadius";>;
float mVignette : CONTROLOBJECT<string name="FilmGrainController.pmx"; string item = "Vignette";>;

float3 Overlay(float3 a, float3 b)
{
	return pow(abs(b), 2.2)<0.5? 2 * a * b : 1.0 - 2 * (1.0 - a) * (1.0 - b);
}

float3 AppleFilmGrain(float3 color, float2 coord, float exposure)
{
	float noiseIntensity = mFilmGrain;
	coord *= 2;
	coord.x *= ViewportSize.x / ViewportSize.y;
	
	float noise = tex3Dlod(NoiseMapSamp, float4(coord, time, 0)).r;
	float exposureFactor = exposure / 2.0;
	exposureFactor = sqrt(exposureFactor);
	float t = lerp(3.5 * noiseIntensity, 1.13 * noiseIntensity, exposureFactor);
	
	return Overlay(color, lerp(0.5, noise, t));
}

float3 AppleFilmLine(float3 color, float2 coord, int2 screenPosition)
{
	float pattenX = floor(mFilmLineX * 50) * 0.4;
	float pattenY = floor(mFilmLineY * 50) * 0.4;
	
	float s1 = fmod(screenPosition.x, pattenX * 2);
	float s2 = fmod(screenPosition.y, pattenY * 2);

	s1 = step(pattenX, s1);
	s2 = step(pattenY, s2);

	s1 = lerp(s1, 1.0, mFilmLineFadeX);
	s2 = lerp(s2, 1.0, mFilmLineFadeY);

	return lerp(0, color, s1 * s2);
}

float3 AppleVignette(float3 color, float2 coord, float inner, float outer)
{
	float L = length(coord * 2 - 1);
	return color * smoothstep(outer, inner, L);
}

float3 AppleDispersion(sampler2D source, float2 coord, float inner, float outer)
{
	float L = length(coord * 2 - 1);
	L = 1 - smoothstep(outer, inner, L);
	float3 color = tex2Dlod(source, float4(coord, 0, 0)).rgb;
	color.g = tex2Dlod(source, float4(coord - ViewportOffset2 * L * (mDispersion * 8), 0, 0)).g;
	color.b = tex2Dlod(source, float4(coord + ViewportOffset2 * L * (mDispersion * 8), 0, 0)).b;
	return color;
}

void FimicGrainVS(
	in float4 Position : POSITION,
	in float4 Texcoord : TEXCOORD0,
	out float2 oTexcoord  : TEXCOORD0,
	out float4 oPosition  : POSITION)
{
	oTexcoord = Texcoord.xy + ViewportOffset.xy;
	oPosition = Position;
}

float4 FimicGrainPS(in float2 coord: TEXCOORD0, in float4 screenPosition : SV_Position) : COLOR
{   
	float3 color = AppleDispersion(ScnSamp, coord, mDispersionRadius, 1 + mDispersionRadius);
	color = AppleFilmGrain(color, coord, 1);
	color = AppleFilmLine(color, coord, screenPosition.xy);
	color = AppleVignette(color, coord, 1.5 - mVignette, 2.5 - mVignette);
	
	return float4(color, 1);
}

float4 FimicLoopPS(in float2 coord: TEXCOORD0, in float4 screenPosition : SV_Position) : COLOR
{
	float2 loop = floor(1 + float2(mFilmLoop + mFilmLoopX, mFilmLoop + mFilmLoopY) * 10);
	return float4(tex2Dlod(ScnSamp2, float4(coord * loop, 0, 0)));
}

float Script : STANDARDSGLOBAL<
	string ScriptOutput = "color";
	string ScriptClass  = "scene";
	string ScriptOrder  = "postprocess";
> = 0.8;

const float4 ClearColor  = float4(0,0,0,0);
const float ClearDepth  = 1.0;

technique FimicGrain <
	string Script = 
	"RenderColorTarget0=;"
	"ClearSetColor=ClearColor;"
	"ClearSetDepth=ClearDepth;"
	
	"RenderColorTarget0=ScnMap;"
	"Clear=Color;"
	"Clear=Depth;"
	"RenderDepthStencilTarget=;"
	"ScriptExternal=Color;"
	
	"RenderColorTarget=ScnMap2;"
	"Pass=FimicGrain;"
	
	"RenderColorTarget=;"
	"Pass=FimicLoop;"
;> {
	pass FimicGrain<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 FimicGrainVS();
		PixelShader  = compile ps_3_0 FimicGrainPS();
	}
	pass FimicLoop<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 FimicGrainVS();
		PixelShader  = compile ps_3_0 FimicLoopPS();
	}
}