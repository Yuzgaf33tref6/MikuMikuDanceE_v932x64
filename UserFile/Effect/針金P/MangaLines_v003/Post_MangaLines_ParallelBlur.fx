////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Post_MangaLines_ParallelBlur.fx ver0.0.3  ���楃A�j���̌��ʐ��G�t�F�N�g(���s��,�|�X�g�t�F�N�g��,�w�i�u���[�t��)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

int LineCount = 87;       // ���ʐ��̖{��
float LineThick = 0.5;    // ���ʐ��̊����
float LineAlpha = 0.7;    // ���ʐ��̍ő哧�ߒl
float PosParam = 0.65;    // ��蕪���p�����[�^(0�ŋϓ�,1�ɋ߂Â��قǊO���ɂ�蕪������)
float AreaScale = 1.0;    // ���ʐ����`�悳���͈�(���S�ʒu�ύX�Ō��ʐ��O�[�������鎞�͂�����傫������)
float3 LineColor = {0.0, 0.0, 0.0}; // ���ʐ��F(RBG)

float BlurPower = 8.0;      // �w�i�u���[���x
float LineBlurPower = 2.0;  // ���ʐ������u���[���x
float NoiseRate = 0.5;      // �w�i�u���[�̃m�C�Y�t����(0�`1)
float NoiseScale = 0.5;     // �w�i�u���[�̃m�C�Y�X�P�[��

int SeedThick = 9;     // �����Ɋւ��闐���V�[�h
int SeedPos = 14;      // �z�u�Ɋւ��闐���V�[�h
int SeedAnime = 78;    // �A�j���[�V�����Ɋւ��闐���V�[�h


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define PAI 3.14159265f   // ��

bool flagCenterControl   : CONTROLOBJECT < string name = "CentetControl.pmx"; >;
float4x4 CenterControlMat  : CONTROLOBJECT < string name = "CentetControl.pmx"; string item = "�Z���^�["; >;
static float2 CenterCtrlRzVec = flagCenterControl ? normalize(CenterControlMat._11_12) : float2(1,0); // Z����]�x�N�g��

float AcsX  : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsZ  : CONTROLOBJECT < string name = "(self)"; string item = "Z"; >;
float AcsRx : CONTROLOBJECT < string name = "(self)"; string item = "Rx"; >;
float AcsRz : CONTROLOBJECT < string name = "(self)"; string item = "Rz"; >;
float AcsRy : CONTROLOBJECT < string name = "(self)"; string item = "Ry"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float xAlpha = saturate( 1.0f - degrees(AcsRx) );

float time : Time;

int LineIndex;

// ���W�ϊ��s��
float4x4 ViewProjMatrix : VIEWPROJECTION;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f)/ViewportSize;

static float R = length( float2( ViewportSize.x/ViewportSize.y, 1.0f) )*AreaScale;  // ��ʑΊp�������ƍ����̔�

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0.0, 0.0, 0.0, 1.0};
float  ClearDepth  = 1.0;

#ifndef MIKUMIKUMOVING
    #define TEX_FORMAT  "D3DFMT_A8"
#else
    #define TEX_FORMAT  "D3DFMT_A8R8G8B8"
#endif

// �ڂ��������̏d�݌W���F
//    �K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//    (WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
#define  WT_0  0.0920246
#define  WT_1  0.0902024
#define  WT_2  0.0849494
#define  WT_3  0.0768654
#define  WT_4  0.0668236
#define  WT_5  0.0558158
#define  WT_6  0.0447932
#define  WT_7  0.0345379

int BlurCount = 3;  // �u���[���x����������
int BlurIndex;      // �u���[���x���������񐔂̃J�E���^

// �u���[�p�T���v�����O�Ԋu
static float2 SampStep = float2(BlurPower, BlurPower) / ViewportSize / pow(6.0f, BlurIndex);

// ���C���m�C�Y�e�N�X�`��
texture2D NoiseTex <
    string ResourceName = "LineNoise.png";
>;
sampler NoiseSamp = sampler_state {
    texture = <NoiseTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// ���ʐ��`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 0;
    string Format = "D3DFMT_A8R8G8B8" ;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// �u���[�������L�^���邽�߂̃����_�[�^�[�Q�b�gX
texture2D ScnMap3 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp3 = sampler_state {
    texture = <ScnMap3>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// �u���[�������L�^���邽�߂̃����_�[�^�[�Q�b�gX
texture2D ScnMap4 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp4 = sampler_state {
    texture = <ScnMap4>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D24S8";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float2 rotVec)
{
    float x = pos.x * rotVec.x - pos.y * rotVec.y;
    float y = pos.x * rotVec.y + pos.y * rotVec.x;

    return float2(x, y);
}

static float2 RotZVec = Rotation2D( CenterCtrlRzVec, float2(cos(AcsRz), sin(AcsRz)) ); // Z����]�x�N�g��


////////////////////////////////////////////////////////////////////////////////////////////////
// ���S���W
float2 GetCenterPos()
{
    float2 Pos;
    if ( flagCenterControl ){
       float4 centerPos = mul(CenterControlMat[3], ViewProjMatrix);
       Pos.x = centerPos.x / centerPos.w * ViewportSize.x/ViewportSize.y;
       Pos.y = centerPos.y / centerPos.w;
    } else {
       Pos.x = AcsX*ViewportSize.x/ViewportSize.y;
       Pos.y = AcsY;
    }
    return Pos;
}


///////////////////////////////////////////////////////////////////////////////////////
// ���ʐ��`��

struct VS_OUTPUT
{
    float4 Pos   : POSITION;    // �ˉe�ϊ����W
    float2 VPos  : TEXCOORD0;   // ���[�J����A�j���[�V�������W
    float2 Tex   : TEXCOORD1;   // �e�N�X�`�����W
};

// ���_�V�F�[�_
VS_OUTPUT Line_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �����ݒ�
    float rand1 = 0.5f * (0.66f * sin(22.1f * SeedThick * LineIndex) + 0.33f * cos(33.6f * SeedThick * LineIndex) + 1.0f);
    float rand2 = 0.5f * (0.31f * sin(45.3f * SeedPos * LineIndex) + 0.69f * cos(73.4f * SeedPos * LineIndex) + 1.0f);
    float rand3 = 0.5f * (0.38f * sin(55.1f * SeedAnime * LineIndex) + 0.62f * cos(44.4f * SeedAnime * LineIndex) + 1.0f);

    // ���[�J����A�j���[�V�������W
    Out.VPos.x = Pos.x;
    Out.VPos.y = step(0.0, AcsZ)*(2.0f*R+abs(AcsZ))
               - sign(AcsZ)*fmod(lerp(0.0f, 2.0f*(R+abs(AcsZ)), rand3)+time*AcsSi, 2.0f*(R+abs(AcsZ)));

    // ���̑���
    Pos.y *= max((LineThick+degrees(AcsRy)*0.2f)*(0.5+rand1)*(1.0f+Pos.x)*0.1f, 0.3f);

    // ���s���z�u
    float2 Pos0 = float2(-R-0.4*rand2, lerp(-R, R, (float)LineIndex/(float)LineCount) + ((rand2-0.5f) * 1.5f * R / LineCount));
    Pos0.y = sign(Pos0.y)*R*pow(abs(Pos0.y/R), max(1.0f-PosParam, 0.0f));
    Pos.xy += Pos0;

    // ���W��]
    Pos.xy = Rotation2D(Pos.xy, RotZVec);

    // �z�u�ړ�
    Pos.xy += GetCenterPos();

    // �X�N���[�����W�ɕϊ�
    Pos.x *= ViewportSize.y/ViewportSize.x;
    Out.Pos = Pos;

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

struct PS_OUTPUT {
    float4 Color0 : COLOR0;
    float4 Color1 : COLOR1;
};

// �s�N�Z���V�F�[�_
PS_OUTPUT Line_PS( VS_OUTPUT IN )
{
    PS_OUTPUT Out = (PS_OUTPUT)0;

    // ����[���ߒl�ݒ�
    float alpha1 = smoothstep((1.0f-AcsTr)*(1.0f+R), 1.0f+(1.0f-AcsTr)*5.0f, IN.VPos.x)*AcsTr;
    // �A�j���[�V�������ߒl�ݒ�
    float alpha2 = smoothstep(-max(abs(AcsZ),0.0001f), 0.0f, -abs(IN.VPos.x-IN.VPos.y));
    if( abs(AcsZ) < 0.0001f ) alpha2 = 1.0f;
    // �������E���ߒl�ݒ�
    float alpha3 = 1.0f - smoothstep(0.0f, 0.5f, abs(IN.Tex.y-0.5f));

    // ���ʐ��̐F
    Out.Color0 = float4( 1.0f, 1.0f, 1.0f, alpha1*alpha3*LineAlpha );
    Out.Color1 = float4( 1.0f, 1.0f, 1.0f, alpha1*alpha2*alpha3*LineAlpha );

    return Out;
}


///////////////////////////////////////////////////////////////////////////////////////
// �w�i�u���[����

struct VS_OUTPUT2 {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

// ���ʒ��_�V�F�[�_
VS_OUTPUT2 VS_Common(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// �u���[���xX�����ڂ���
float4 PS_passX( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 Color;
    Color  = WT_0 *   tex2D( ScnSamp4, Tex );
    Color += WT_1 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x  , 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x  , 0) ) );
    Color += WT_2 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x*2, 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x*2, 0) ) );
    Color += WT_3 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x*3, 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x*3, 0) ) );
    Color += WT_4 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x*4, 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x*4, 0) ) );
    Color += WT_5 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x*5, 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x*5, 0) ) );
    Color += WT_6 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x*6, 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x*6, 0) ) );
    Color += WT_7 * ( tex2D( ScnSamp4, Tex+float2(SampStep.x*7, 0) ) + tex2D( ScnSamp4, Tex-float2(SampStep.x*7, 0) ) );
    return Color;
}

// �u���[���xY�����ڂ���
float4 PS_passY(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color;
    Color  = WT_0 *   tex2D( ScnSamp3, Tex );
    Color += WT_1 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y  ) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y  ) ) );
    Color += WT_2 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y*2) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y*2) ) );
    Color += WT_3 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y*3) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y*3) ) );
    Color += WT_4 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y*4) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y*4) ) );
    Color += WT_5 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y*5) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y*5) ) );
    Color += WT_6 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y*6) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y*6) ) );
    Color += WT_7 * ( tex2D( ScnSamp3, Tex+float2(0, SampStep.y*7) ) + tex2D( ScnSamp3, Tex-float2(0, SampStep.y*7) ) );
    return Color;
}

// �w�i�u���[����
float4 PS_Blur(float2 Tex: TEXCOORD0, uniform sampler2D samp, uniform float blurPower) : COLOR
{
    // �u���[���x�Ƀ��C���m�C�Y�ǉ�
    float2 centerPos = GetCenterPos();
    float2 speed = RotZVec*time * sign(AcsZ) * AcsSi*0.4;
    float2 texCoord = float2(Tex.x*ViewportSize.x/ViewportSize.y, Tex.y) / NoiseScale + float2(speed.x, -speed.y);
    texCoord = Rotation2D( texCoord - float2(centerPos.x, centerPos.y), RotZVec );
    float noisePower = (1.0f-NoiseRate+NoiseRate*tex2D( NoiseSamp, texCoord ).r) * tex2D( ScnSamp4, Tex ).r;
    //return float4(noisePower,noisePower,noisePower,1);

    // �w�i�u���[����
    float2 xySmpStep = float2(RotZVec.x, -RotZVec.y) * SampStep * blurPower * noisePower * LineBlurPower;
    float2 xySmpStepF = clamp(xySmpStep, -blurPower*0.2f/ViewportSize, blurPower*0.2f/ViewportSize);
    float sgn = sign(AcsZ + 0.001f);
    float4 Color;
    Color  = WT_0 *   tex2D( samp, Tex );
    Color += WT_1 * ( tex2D( samp, Tex+sgn*xySmpStep   )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF   )*0.6f );
    Color += WT_2 * ( tex2D( samp, Tex+sgn*xySmpStep*2 )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF*2 )*0.6f );
    Color += WT_3 * ( tex2D( samp, Tex+sgn*xySmpStep*3 )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF*3 )*0.6f );
    Color += WT_4 * ( tex2D( samp, Tex+sgn*xySmpStep*4 )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF*4 )*0.6f );
    Color += WT_5 * ( tex2D( samp, Tex+sgn*xySmpStep*5 )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF*5 )*0.6f );
    Color += WT_6 * ( tex2D( samp, Tex+sgn*xySmpStep*6 )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF*6 )*0.6f );
    Color += WT_7 * ( tex2D( samp, Tex+sgn*xySmpStep*7 )*1.4f + tex2D( samp, Tex-sgn*xySmpStepF*7 )*0.6f );
    return Color;
}

// �X�N���[���o�b�t�@�̍���
float4 PS_Mix(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color = tex2D( ScnSamp, Tex );
    Color.rgb = lerp(Color.rgb, LineColor, tex2D(ScnSamp2, Tex).r * xAlpha);
    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
    string Script = 
        // �I���W�i���̕`��
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"

        // ���ʐ��̌��`��
        "RenderColorTarget0=ScnMap4;"
        "RenderColorTarget1=ScnMap2;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "LoopByCount=LineCount;"
               "LoopGetIndex=LineIndex;"
               "Pass=DrawLines;"
            "LoopEnd=;"
        "RenderColorTarget1=;"

        // �w�i�u���[�͈͐ݒ�̂��߂̂ڂ���
        "LoopByCount=BlurCount;"
            "LoopGetIndex=BlurIndex;"
            "RenderColorTarget0=ScnMap3;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=Gaussian_X;"
            "RenderColorTarget0=ScnMap4;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=Gaussian_Y;"
        "LoopEnd=;"

        // �w�i�u���[����
        "RenderColorTarget0=ScnMap3;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurPass1;"
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurPass2;"

        // �w�i�ƌ��ʐ��̍���
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=MixPass;"
        ;
> {
    pass DrawLines {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_1_1 Line_VS();
        PixelShader  = compile ps_2_0 Line_PS();
    }
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_passX();
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_passY();
    }
    pass BlurPass1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_1_1 VS_Common();
        PixelShader  = compile ps_2_0 PS_Blur(ScnSamp, 60.0);
    }
    pass BlurPass2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_1_1 VS_Common();
        PixelShader  = compile ps_2_0 PS_Blur(ScnSamp3, 10.0);
    }
    pass MixPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_1_1 VS_Common();
        PixelShader  = compile ps_2_0 PS_Mix();
    }
}

