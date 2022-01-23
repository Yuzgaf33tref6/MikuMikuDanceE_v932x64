////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgPointLight.fx ver0.0.2  �_�����G�t�F�N�g(�A�N�Z��,�Z���t�V���h�E����)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �\�t�g�V���h�E�̗L��
#define UseSoftShadow  1  // 0:�Ȃ�, 1:�L��

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define ShadowMapSize  1024   // 512, 1024, 2048, 4096 �̂ǂꂩ�őI��

// �\�t�g�V���h�E�̂ڂ������x
float ShadowBulrPower = 1.0;  // 0.5�`5.0���x�Œ���

// �Z���t�e�̔Z�x
float ShadowDensity = 0.0;  // �傫������قǉe�������Ȃ�

// �A���`�G�C���A�X�ɂ��֊s���̎Օ��딻��΍�
#define UseAAShadow  0   // 0:���Ȃ�, 1:����
// (�֊s���̂�������ڗ��ꍇ�͂�����1�ɂ���Ə�����,�������W���M�[���o��)

// �֊s���o(�[�x)臒l�ݒ�
#define DepthThreshold  1.0


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �����ʒu
float4x4 LightWorldMatrix : WORLD;
static float3 LightPosition = LightWorldMatrix._41_42_43;

// �J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5,0.5) / ViewportSize;
static float2 SampStep = float2(1,1) / ViewportSize;

// �I�t�X�N���[���_�������C�e�B���O�o�b�t�@
texture HgPL_Draw: OFFSCREENRENDERTARGET <
    string Description = "HgPointLight.fx�̃��f���̓_�����I�u�W�F�N�g�`��";
    float2 ViewPortRatio = {1.0, 2.0};
    float4 ClearColor = {0, 0, 0, 1};
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A8R8G8B8" ;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "* = HgPL_Object.fxsub;";
>;
sampler ObjDrawSamp = sampler_state {
    texture = <HgPL_Draw>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#if ShadowMapSize==512
    #define SMAPSIZE_WIDTH   512
    #define SMAPSIZE_HEIGHT  1024
#endif
#if ShadowMapSize==1024
    #define SMAPSIZE_WIDTH   1024
    #define SMAPSIZE_HEIGHT  2048
#endif
#if ShadowMapSize==2048
    #define SMAPSIZE_WIDTH   2048
    #define SMAPSIZE_HEIGHT  4096
#endif
#if ShadowMapSize==4096
    #define SMAPSIZE_WIDTH   4096
    #define SMAPSIZE_HEIGHT  8192
#endif

// �I�t�X�N���[�����I�o�����ʃV���h�E�}�b�v�o�b�t�@
texture HgPL_SMap : OFFSCREENRENDERTARGET <
    string Description = "HgPointLight.fx�̃V���h�E�}�b�v";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    #if UseSoftShadow==1
    string Format = "D3DFMT_G32R32F" ;
    #else
    string Format = "D3DFMT_R32F" ;
    #endif
    bool AntiAlias = false;
    int Miplevels = 0;
    string DefaultEffect = 
        "self = hide;"
        "FloorAssist.x = ..\\���܂�\\���e�΍�\\HgPL_ShadowMapAcs_FA.fxsub;"
        "* = HgPL_ShadowMap.fxsub;";
>;
sampler ShadowMapSamp = sampler_state {
    texture = <HgPL_SMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// �I�t�X�N���[�����[���h���W�o�b�t�@
texture2D HgPL_WPos : OFFSCREENRENDERTARGET <
    string Description = "HgPointLight.fx�̃��f�����W�o�b�t�@";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A32B32G32R32F";
    bool AntiAlias = false;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "HgPointLight.pmx = hide;"
        "* = HgPL_WPosMap.fxsub;";
>;
sampler2D WPosSamp = sampler_state {
    texture = <HgPL_WPos>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// �V���h�E�}�b�v�֘A�̏���

#if UseSoftShadow==1
// �V���h�E�}�b�v�̃T���v�����O�Ԋu
static float2 SMapSampStep = float2(ShadowBulrPower/1024.0f, ShadowBulrPower/2048.0f);

// �V���h�E�}�b�v�̎��ӃT���v�����O1
float4 GetZPlotSampleBase1(float2 Tex, float smpScale)
{
    float2 smpStep = SMapSampStep * smpScale;
    float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex, 0, mipLv)) * 2.0f;
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2(-1,-1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 1,-1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2(-1, 1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 1, 1), 0, mipLv));
    return (Color / 6.0f);
}

// �V���h�E�}�b�v�̎��ӃT���v�����O2
float4 GetZPlotSampleBase2(float2 Tex, float smpScale)
{
    float2 smpStep = SMapSampStep * smpScale;
    float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex, 0, mipLv)) * 2.0f;
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2(-1, 0), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 1, 0), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 0,-1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 0, 1), 0, mipLv));
    return (Color / 6.0f);
}
#endif

#define MSC   0.98  // �}�b�v�k����

// �o�����ʃV���h�E�}�b�v���Z�v���b�g�ǂݎ��
float2 GetZPlotDP(float3 Vec)
{
    Vec = normalize(Vec);
    bool flagFront = (Vec.z >= 0) ? true : false;

    if ( !flagFront ) Vec.yz = -Vec.yz;
    float2 Tex = Vec.xy * MSC / (1.0f + Vec.z);
    Tex.y = -Tex.y;
    Tex = (Tex + 1.0f) * 0.5f;
    Tex.y = flagFront ? 0.5f*Tex.y : 0.5f*(Tex.y+1.0f) + 1.0f/SMAPSIZE_HEIGHT;

    #if UseSoftShadow==1
    float4 Color;
    Color  = GetZPlotSampleBase1(Tex, 1.0f) * 0.508f;
    Color += GetZPlotSampleBase2(Tex, 2.0f) * 0.254f;
    Color += GetZPlotSampleBase1(Tex, 3.0f) * 0.127f;
    Color += GetZPlotSampleBase2(Tex, 4.0f) * 0.063f;
    Color += GetZPlotSampleBase1(Tex, 5.0f) * 0.032f;
    Color += GetZPlotSampleBase2(Tex, 6.0f) * 0.016f;
    #else
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex,0,0));
    #endif

    return Color.xy;
}

#if UseAAShadow==1
// �A���`�G�C���A�X�u�����h�ʒu�ł͉����̗אڃs�N�Z�����T���v�����O
float2 GetTexCoordAA(float2 Tex0)
{
    // ���ӂ̃��[���h���W�Ɛ[�x
    float Depth0 = distance( tex2D( WPosSamp, Tex0 ).xyz, CameraPosition );
    float DepthL = distance( tex2D( WPosSamp, Tex0+SampStep*float2(-1, 0) ).xyz, CameraPosition );
    float DepthR = distance( tex2D( WPosSamp, Tex0+SampStep*float2( 1, 0) ).xyz, CameraPosition );
    float DepthT = distance( tex2D( WPosSamp, Tex0+SampStep*float2( 0,-1) ).xyz, CameraPosition );
    float DepthB = distance( tex2D( WPosSamp, Tex0+SampStep*float2( 0, 1) ).xyz, CameraPosition );

    // �֊s���ł͉�����Tex���W�ɕ␳
    float DepthMax = Depth0;
    float2 Tex = Tex0;
    if(abs(Depth0 - DepthL) > DepthThreshold){
       if( DepthMax < DepthL ){
           DepthMax = DepthL;
           Tex = Tex0 + SampStep * float2(-1, 0);
       }
    }
    if(abs(Depth0 - DepthR) > DepthThreshold){
       if( DepthMax < DepthR ){
           DepthMax = DepthR;
           Tex = Tex0 + SampStep * float2( 1, 0);
       }
    }
    if(abs(Depth0 - DepthT) > DepthThreshold){
       if( DepthMax < DepthT ){
           DepthMax = DepthT;
           Tex = Tex0 + SampStep * float2( 0,-1);
       }
    }
    if(abs(Depth0 - DepthB) > DepthThreshold){
       if( DepthMax < DepthB ){
           DepthMax = DepthB;
           Tex = Tex0 + SampStep * float2( 0, 1);
       }
    }

    return Tex;
}
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// ���C�e�B���O�`��̉��Z����

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float2 Tex  : TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT VS_Draw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �㉺2��ʂ�Tex���W
    float2 TexUpper = float2(Tex.x, 0.5f*Tex.y);
    float2 TexUnder = float2(Tex.x, 0.5f*(Tex.y+1.0f));

    // ���C�e�B���O�����̐F
    float4 Color = tex2D( ObjDrawSamp, TexUpper );

    // �e�̐F
    float4 ShadowColor0 = float4(Color.rgb*ShadowDensity, Color.a);
    float4 ShadowColor = tex2D( ObjDrawSamp, TexUnder );
    ShadowColor = max(ShadowColor, ShadowColor0);

    // AA�u�����h�ʒu���l������Tex���W��␳
    #if UseAAShadow==1
    Tex = GetTexCoordAA(Tex);
    #endif

    // ���C�g�x�N�g���EZ�l
    float4 ColorPos = tex2D( WPosSamp, Tex );
    float3 LtVec = ColorPos.xyz - LightPosition;
    float z = ColorPos.w;

    // �V���h�E�}�b�vZ�v���b�g
    float2 zplot = GetZPlotDP( LtVec );

    #if UseSoftShadow==1
    // �e������(�\�t�g�V���h�E�L�� VSM:Variance Shadow Maps�@)
    float variance = max( zplot.y - zplot.x * zplot.x, 0.002f );
    float Comp = variance / (variance + max(z - zplot.x, 0.0f));
    #else
    // �e������(�\�t�g�V���h�E����)
    float Comp = 1.0 - saturate( max(z - zplot.x, 0.0f)*1500.0f - 0.3f );
    #endif

    // �e�̍���
    Color = lerp(ShadowColor, Color, Comp);
    Color.rgb *= AcsTr;

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "ScriptExternal=Color;"
            "Pass=PostDraw;"
    ;
> {
    pass PostDraw < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_3_0 VS_Draw();
        PixelShader  = compile ps_3_0 PS_Draw();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
