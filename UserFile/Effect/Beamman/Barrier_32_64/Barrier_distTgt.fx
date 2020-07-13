////////////////////////////////////////////////////////////////////////////////////////////////
//
//  full.fx ver1.4
//  �쐬: ���͉��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
float param_Alpha : CONTROLOBJECT < string name = "(self)"; string item = "�����x"; >;

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

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
// �֊s�`��

// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
    // �֊s�F�œh��Ԃ�
    return EdgeColor;
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    /*
    pass DrawEdge {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;

        VertexShader = compile vs_2_0 ColorRender_VS();
        PixelShader  = compile ps_2_0 ColorRender_PS();
    }
    */
}


// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {

}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {

}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float4 ZCalcTex : TEXCOORD0;    // Z�l
    float2 Tex      : TEXCOORD1;    // �e�N�X�`��
    float3 Normal   : TEXCOORD2;    // �@��
    float3 Eye      : TEXCOORD3;    // �J�����Ƃ̑��Έʒu
    float2 SpTex    : TEXCOORD4;	 // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
    float4 LastPos : TEXCOORD5;
};

// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.LastPos = Out.Pos;
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
	// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    return Out;
}
float time : TIME;
// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN) : COLOR
{
    float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
    TexColor.rgb *= 10;
    TexColor.a *= (TexColor.a > 0.5);
    TexColor.a *= (1-param_Alpha);
	return TexColor;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object";> {
    pass DrawObject {
    	CULLMODE = CW;
        VertexShader = compile vs_3_0 BufferShadow_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
}
technique MainTecBS0_ss  < string MMDPass = "object_ss";> {
    pass DrawObject {
    	CULLMODE = CW;
        VertexShader = compile vs_3_0 BufferShadow_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
}