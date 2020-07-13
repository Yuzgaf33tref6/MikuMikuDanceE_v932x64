////////////////////////////////////////////////////////////////////////////////////////////////
//	�|�C���g���C�gSS�p�o�����ʃV���h�E�}�b�v
//	�r�[���}���o
//	�x�[�X
//  ���I�o�����ʊ��}�b�v ver1.0
//  ���͉��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾


float3 CameraPosition : CONTROLOBJECT < string name = "(OffscreenOwner)";>;


// �J�����̌����@1�c���� -1�c�w��
#define CAMERA_DIRECTION   -1

// Z�����̉��s��
#define Z_MAX   1024.0
#define Z_MIN   1.0

static float4x4 ViewMatrix  = {
    CAMERA_DIRECTION, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, CAMERA_DIRECTION, 0,
    -CameraPosition.x*CAMERA_DIRECTION, -CameraPosition.y, -CameraPosition.z*CAMERA_DIRECTION, 1,
};

// ���@�ϊ��s��
float4x4 WorldMatrix              : WORLD;
static float4x4 WorldViewMatrix   = mul(WorldMatrix,ViewMatrix);

//float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
//float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
//float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

////////////////////////////////////////////////////////////////////////////////////////////////
// ���I�o�����ʊ��}�b�v

float4 CalcProj(float4 Pos) {
    float L = length(Pos.xyz);
    Pos.xyz /= L;
    Pos.xy /= Pos.z+1;
    float d = dot(Pos.xy,Pos.xy);
    Pos.z = L + d*d;
    Pos.z = (Pos.z - Z_MIN)/(Z_MAX-Z_MIN);
    Pos.w = 1;
    return Pos;
}
float4 CalcWVP(float4 Pos) {
    return CalcProj( mul(Pos, WorldViewMatrix) );
}


// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {

}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {

}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float2 Tex : TEXCOORD0;
    float Z : TEXCOORD1;    // Z�l
};

// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION,float2 Tex: TEXCOORD0)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = CalcWVP( Pos );
    Out.Z = Out.Pos.z / Out.Pos.w;
    Out.Tex = Tex;
    //Out.Z = length(mul(Pos,WorldMatrix) - CameraPosition);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN) : COLOR
{
	float z = IN.Z;
	float a = MaterialDiffuse.a * tex2D(ObjTexSampler,IN.Tex).a;
	if(a <= 0.9)
	{
		a = 0;
	}
	return float4(z,z,z,a);
}

technique MainTec0 < string MMDPass = "object";> {

}
// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object_ss";> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
