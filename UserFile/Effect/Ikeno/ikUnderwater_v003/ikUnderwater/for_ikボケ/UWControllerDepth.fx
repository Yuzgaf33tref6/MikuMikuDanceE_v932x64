////////////////////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////////////////////

#include "../Settings.fxsub"
#include "../Commons.fxsub"


// �Ȃɂ��Ȃ��`�悵�Ȃ��ꍇ�́A�w�i�܂ł̋���
// �����M��ꍇ�Aik�{�P.fx�̓����l���ύX����K�v������B
#define FAR_DEPTH		1000

// ���ʂ̍ő勗��
#define FAR_WATER_Z		(1000.0)


float4x4 matVP			: VIEWPROJECTION;
float4x4 matInvP		: PROJECTIONINVERSE;

float3 CameraDirection : DIRECTION < string Object = "Camera"; >;

////////////////////////////////////////////////////////////////////////////////////////////////
//

struct VS_OUTPUT
{
	float4 Pos			: POSITION;
	float4 VPos			: TEXCOORD0;
};

VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	float2 uv = (Tex.xy * 2.0 - 1.0);

	float3 v = CameraDirection;
	float3 front = length(v.xz) < 1e-3 ? float3(0,0,1) : normalize(float3(v.x,0,v.z));
	float3 right = normalize(cross(float3(0,1,0), front));

	float3 wpos = CameraPosition;
	wpos.y = WaveObjectPosition.y;
	wpos += (uv.x * right + front * uv.y) * (FAR_WATER_Z * 1.2);

	Out.Pos = mul(float4(wpos, 1), matVP);
//	Out.Pos.x = uv.x * 1.05 * Out.Pos.w;

//	Out.VPos = mul(float4(wpos, 1), matV);
	Out.VPos = mul(Out.Pos, matInvP);

	return Out;
}

float4 PS_DrawWaterPlane(VS_OUTPUT IN) : COLOR
{
	float distance = length(IN.VPos.xyz);
	return float4(distance / FAR_DEPTH, 0, 0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique SpotLight < string MMDPass = "object"; >
{
	pass DrawWaterPlane {
		CULLMODE = NONE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_DrawWaterPlane();
	}
}

technique SpotLightShadow < string MMDPass = "object_ss"; >
{
	pass DrawWaterPlane {
		CULLMODE = NONE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_DrawWaterPlane();
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////

