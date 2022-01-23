////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ScreenTex.fx ver0.0.4  �e�N�X�`������ʃT�C�Y�ɃX�P�[�����O���ē\��t���܂�
//  �쐬: �j��P( ���͉��P����laughing_man.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
#define UseTex  1                   // 1:�e�N�X�`��, 2:�A�j��GIF�APNG, 3:Screen.bmp�A�j��
#define TexFile  "godray.png"       // ��ʂɓ\��t����e�N�X�`���t�@�C����(�P�F�̏ꍇ�͖���)
#define AnimeStart 0.0              // �A�j��GIF�APNG�̏ꍇ�̃A�j���[�V�����J�n����(�P�ʁF�b)(�A�j��GIF�APNG�ȊO�ł͖���)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////


// MMM UI�R���g���[��
float3 MMMColorKey <      // �J���[�L�[�̐F(RGB�w��)
   string UIName = "�J���[�L�[�̐F";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float3(0.0, 0.0, 0.0);

float MMMThreshold <   // �J���[�L�[��臒l
   string UIName = "�L�[臒l";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );


// �A�N�Z�T���p�����[�^
float3 AcsOffset : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
float AcsR : CONTROLOBJECT < string name = "(self)"; string item = "Rx"; >;
float AcsAlpha : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float3 ColorKey = saturate( AcsOffset );               // �J���[�L�[�̐F(RGB�w��)
static float Threshold = saturate( degrees(AcsR) ) - 0.01f;   // �J���[�L�[��臒l

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

#if(UseTex == 1)
// ��ʂɓ\��t����e�N�X�`��
texture2D screen_tex <
    string ResourceName = TexFile;
>;
sampler2D TexSampler = sampler_state {
    texture = <screen_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif

#if(UseTex == 2)
// ��ʂɓ\��t����A�j���[�V�����e�N�X�`��
texture screen_tex : ANIMATEDTEXTURE <
    string ResourceName = TexFile;
    float Offset = AnimeStart;
>;
sampler TexSampler = sampler_state {
    texture = <screen_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif

#if(UseTex == 3)
// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler TexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif


///////////////////////////////////////////////////////////////////////////////////////////////
// ��ʕ`��

struct VS_OUTPUT
{
    float4 Pos : POSITION;    // �ˉe�ϊ����W
    float2 Tex : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT ScreenTex_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ScreenTex_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    // �e�N�X�`���K�p
    float4 Color = tex2D( TexSampler, Tex );

    // �J���[�L�[����
    float len = length(Color.rgb - saturate(ColorKey+MMMColorKey));
    clip( len - (Threshold + MMMThreshold) );

    Color.a *= AcsAlpha;
    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec < string MMDPass = "object"; > {
    pass DrawObject < string Script= "Draw=Buffer;"; > {
        ZENABLE = false;
        VertexShader = compile vs_1_1 ScreenTex_VS();
        PixelShader  = compile ps_2_0 ScreenTex_PS();
    }
}



