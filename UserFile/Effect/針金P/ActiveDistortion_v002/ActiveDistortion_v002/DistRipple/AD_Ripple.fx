////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Ripple.fx ��Ԙc�݃G�t�F�N�g(�g��̏Ռ��g���ۂ��G�t�F�N�g,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#ifdef MIKUMIKUMOVING
float RippleTime < // �g��i�s�x
   string UIName = "�g��i�s�x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );
#endif

float Amplitude < // �g��U��
   string UIName = "�g��U��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 2.0 );

float AmpRate < // �U���ψʔ�
   string UIName = "�U���ψʔ�";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float WaveCount < // �g��̐�
   string UIName = "�g��̐�";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 2.0 );

float FreqRate < // �g�䂪�L����̈撆�̔g��̂��銄��
   string UIName = "�g�䊄��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.01;
   float UIMax = 2.0;
> = float( 1.0 );


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define DEPTH_FAR    5000.0f   // �[�x�ŉ��l

#define PAI 3.14159265f   // ��

// ���W�ϊ��s��
float4x4 WorldMatrix     : WORLD;
float4x4 ProjMatrix          : PROJECTION;
float4x4 WorldViewMatrix     : WORLDVIEW;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

// �J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;


////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifndef MIKUMIKUMOVING
    float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
    #define rippleTime  AcsTr
    #define GET_WVPMAT(p) (WorldViewProjMatrix)
#else
    #define rippleTime  RippleTime
    #define GET_WVPMAT(p) (MMM_IsDinamicProjection ? mul(WorldViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : WorldViewProjMatrix)
#endif

////////////////////////////////////////////////////////////////////////////////////////////////

// �g��ψʗ�
float CalcZ(float R)
{
    float minLen1 = - FreqRate+(FreqRate+1)*rippleTime;
    float minLen2 = - FreqRate*0.2f+(FreqRate+1)*rippleTime;
    float maxLen  = (FreqRate+1.0f)*rippleTime;

    float z = -0.05f * Amplitude * (cos(2.0f*PAI*(WaveCount*R/FreqRate - WaveCount*(FreqRate+1)/FreqRate*rippleTime))-1.0f);
    z *= smoothstep(minLen1, minLen2, R) * step(R, maxLen);
    z *= smoothstep(-1.0f, -0.2f, -R);
    z *= 1.0f - R;

    return z;
}

// �g��ψʌ��z
float CalcGrad(float R)
{
    float z0 = CalcZ( R - 1.0f / 128.0f );
    float z1 = CalcZ( R + 1.0f / 128.0f );
    return (z1-z0)*64.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �@���E�[�x�`��

struct VS_OUTPUT {
    float4 Pos    : POSITION;   // �ˉe�ϊ����W
    float3 Normal : TEXCOORD0;  // �@��
    float4 VPos   : TEXCOORD1;  // �r���[���W
};

// ���_�V�F�[�_
VS_OUTPUT VS_Object( float4 Pos : POSITION )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    float R = length(Pos.xy);

    Pos.z = CalcZ(R) * AmpRate;
    float grad = CalcGrad(R);

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_WVPMAT(Pos) );

    // �J�������_�̃��[���h�r���[�ϊ�
    Out.VPos = mul( Pos, WorldViewMatrix );

    // �@���̃J�������_�̃��[���h�r���[�ϊ�
    float3 Normal = float3(grad*Pos.x/R, grad*Pos.y/R, -1);
    Out.Normal = normalize( Normal );

    return Out;
}

//�s�N�Z���V�F�[�_
float4 PS_Object(VS_OUTPUT IN) : COLOR
{
    // �@��(0�`1�ɂȂ�悤�␳)
    float3 Normal = (IN.Normal + 1.0f) / 2.0f;

    // �[�x(0�`DEPTH_FAR��0.5�`1.0�ɐ��K��)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
}

///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

// �I�u�W�F�N�g�`��(�Z���t�V���h�E�Ȃ�)
technique DepthTec1 < string MMDPass = "object"; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}

// �I�u�W�F�N�g�`��(�Z���t�V���h�E����)
technique DepthTecSS1 < string MMDPass = "object_ss"; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
//�G�b�W�E�n�ʉe�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

