////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgSpotLight.fx ver0.0.1  �X�|�b�g���C�g�����G�t�F�N�g(�Z���t�V���h�E����)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �\�t�g�V���h�E�̗L��
#define UseSoftShadow  1  // 0:�Ȃ�, 1:�L��

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define ShadowMapSize  1024


// �A���`�G�C���A�X�ɂ��֊s���̎Օ��딻��΍�
#define UseAAShadow  0   // 0:���Ȃ�, 1:����
// (�֊s���̂�������ڗ��ꍇ�͂�����1�ɂ���Ə�����,�������W���M�[���o��)

// �֊s���o(�[�x)臒l�ݒ�
#define DepthThreshold  2.0


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_OBJ    "HgSL_Object.fxsub"
    #define OFFSCREEN_SMAP   "HgSL_ShadowMap.fxsub"
    #define OFFSCREEN_WPOS   "HgSL_WPosMap.fxsub"
    #define SLC_OBJNAME      "(self)"
    static bool flagSLC = true;
#else
    #define OFFSCREEN_OBJ    "HgSL_ObjectMMM.fxsub"
    #define OFFSCREEN_SMAP   "HgSL_ShadowMapMMM.fxsub"
    #define OFFSCREEN_WPOS   "HgSL_WPosMapMMM.fxsub"
    #define SLC_OBJNAME      "HgSpotLight.pmx"
    bool flagSLC : CONTROLOBJECT < string name = SLC_OBJNAME; >;
#endif

// �R���g���[���p�����[�^
float3 BonePos1      : CONTROLOBJECT < string name = SLC_OBJNAME; string item = "�Ǝ˕���"; >;
float MorphLtRadius  : CONTROLOBJECT < string name = SLC_OBJNAME; string item = "�����a"; >;
float MorphSpotDirec : CONTROLOBJECT < string name = SLC_OBJNAME; string item = "�Ǝˊp"; >;
float MorphSdBulr    : CONTROLOBJECT < string name = SLC_OBJNAME; string item = "�e�ڂ���"; >;
float MorphSdDens    : CONTROLOBJECT < string name = SLC_OBJNAME; string item = "�e�Z�x"; >;

// �����ʒu
float3 LightPosition : CONTROLOBJECT < string name = SLC_OBJNAME; string item = "�����ʒu"; >;
// ��������
static float3 LightDirecCenter = flagSLC ? normalize( BonePos1 - LightPosition ) : float3(0,0,1);
// ��������Ɩ����܂ł̊p�x(rad)
static float LightShieldDirection = radians( flagSLC ? lerp(1.0f, 85.0f, saturate(MorphSpotDirec)) : 20.0f );
// �������a
static float LtOrgRadius = flagSLC ? lerp(0.1f, 10.0f, saturate(MorphLtRadius)) : 0.1f;
// �����W�_���W
static float3 LightOrg = LightPosition - LightDirecCenter * LtOrgRadius / tan(LightShieldDirection);
// �\�t�g�V���h�E�̂ڂ������x
static float ShadowBulrPower = flagSLC ? max( lerp(0.0f, 7.5f, MorphSdBulr), 0.0f) : 1.0f;
// �Z���t�e�̔Z�x
static float ShadowDensity = flagSLC ? saturate(1.0f - MorphSdDens) : 0.0;;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5,0.5) / ViewportSize;
static float2 SampStep = float2(1,1) / ViewportSize;


// �I�t�X�N���[���X�|�b�g���C�g�������C�e�B���O�o�b�t�@
texture HgSL_Draw: OFFSCREENRENDERTARGET <
    string Description = "HgSpotLight.fx�̃��f���̃X�|�b�g���C�g�����I�u�W�F�N�g�`��";
    float2 ViewPortRatio = {1.0, 2.0};
    float4 ClearColor = {0, 0, 0, 1};
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A8R8G8B8" ;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "HgSpotLight.pmx = hide;"
        "* =" OFFSCREEN_OBJ ";";
>;
sampler ObjDrawSamp = sampler_state {
    texture = <HgSL_Draw>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define SMAPSIZE_WIDTH   ShadowMapSize
#define SMAPSIZE_HEIGHT  ShadowMapSize

// �I�t�X�N���[���V���h�E�}�b�v�o�b�t�@
texture HgSL_SMap : OFFSCREENRENDERTARGET <
    string Description = "HgSpotLight.fx�̃V���h�E�}�b�v";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_G32R32F" ;
    bool AntiAlias = false;
    int Miplevels = 0;
    string DefaultEffect = 
        "self = hide;"
        "HgSpotLight.pmx = hide;"
        "* =" OFFSCREEN_SMAP ";";
>;
sampler ShadowMapSamp = sampler_state {
    texture = <HgSL_SMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// �I�t�X�N���[�����[���h���W�o�b�t�@
texture2D HgSL_WPos : OFFSCREENRENDERTARGET <
    string Description = "HgSpotLight.fx�̃��f�����W�o�b�t�@";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A32B32G32R32F";
    bool AntiAlias = false;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "HgSpotLight.pmx = hide;"
        "* =" OFFSCREEN_WPOS ";";
>;
sampler2D WPosSamp = sampler_state {
    texture = <HgSL_WPos>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


#ifdef MIKUMIKUMOVING
// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

// �e�N�X�`���t�H�[�}�b�g
#define TEX_FORMAT "D3DFMT_A16B16G16R16F"

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �V���h�E�}�b�v�֘A�̏���

// ���C�g�����̃r���[�ϊ��s��
float4x4 GetLightViewMatrix()
{
   // x�������x�N�g��(LightDirecCenter��z�������x�N�g��)
   float3 ltViewX = cross( float3(0.0f, 1.0f, 0.0f), LightDirecCenter ); 
   float3 ltViewY;

   if( any(ltViewX) ){
       // x�������x�N�g���̐��K��
       ltViewX = normalize(ltViewX);
       // y�������x�N�g��
       ltViewY = cross( LightDirecCenter, ltViewX );
   }else{
       // �^��/�^����LightDirecCenter�̕�������v����ꍇ�͓��ْl�ƂȂ�
       ltViewX = float3(1.0f, 0.0f, 0.0f);
       ltViewY = float3(0.0f, 0.0f, -sign(LightDirecCenter.y));
   }

   // �r���[���W�ϊ��̉�]�s��
   float3x3 ltViewRot = { ltViewX.x, ltViewY.x, LightDirecCenter.x,
                          ltViewX.y, ltViewY.y, LightDirecCenter.y,
                          ltViewX.z, ltViewY.z, LightDirecCenter.z };

   return float4x4( ltViewRot[0],  0,
                    ltViewRot[1],  0,
                    ltViewRot[2],  0,
                   -mul( LightOrg, ltViewRot ), 1 );
};

#define Z_NEAR  1.0     // �ŋߒl
#define Z_FAR   1000.0  // �ŉ��l
#define MSC     0.98    // �}�b�v�k����

// ���C�g�����̎ˉe�ϊ�
float4 CalcLightProjPos(float4 VPos)
{
    float vL = MSC / tan(LightShieldDirection);
    float zp = Z_FAR * ( VPos.z - Z_NEAR ) / ( Z_FAR - Z_NEAR );
    return float4(vL*VPos.x, vL*VPos.y, zp, VPos.z);
}

#if UseSoftShadow==1
// �V���h�E�}�b�v�̃T���v�����O�Ԋu
static float2 SMapSampStep = float2(ShadowBulrPower/1024.0f, ShadowBulrPower/1024.0f);

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

// �V���h�E�}�b�v����Z�v���b�g�ǂݎ��
float2 GetZPlot(float2 Tex)
{
    #if UseSoftShadow==1
    float4 Color;
    Color  = GetZPlotSampleBase1(Tex, 1.0f) * 0.508f;
    Color += GetZPlotSampleBase2(Tex, 2.0f) * 0.254f;
    Color += GetZPlotSampleBase1(Tex, 3.0f) * 0.127f;
    Color += GetZPlotSampleBase2(Tex, 4.0f) * 0.063f;
    Color += GetZPlotSampleBase1(Tex, 5.0f) * 0.032f;
    Color += GetZPlotSampleBase2(Tex, 6.0f) * 0.016f;
    #else
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex, 0, 0));
    #endif

    return Color.xy;
}

#if UseAAShadow==1
// �A���`�G�C���A�X�u�����h�ʒu�ł͉����̗אڃs�N�Z�����T���v�����O
float2 GetTexCoordAA(float2 Tex0)
{
    // ���ӂ̃��[���h���W�Ɛ[�x
    float Depth0 = tex2D( WPosSamp, Tex0 ).w;
    float DepthL = tex2D( WPosSamp, Tex0+SampStep*float2(-1, 0) ).w;
    float DepthR = tex2D( WPosSamp, Tex0+SampStep*float2( 1, 0) ).w;
    float DepthT = tex2D( WPosSamp, Tex0+SampStep*float2( 0,-1) ).w;
    float DepthB = tex2D( WPosSamp, Tex0+SampStep*float2( 0, 1) ).w;

    // �֊s���ł͉�����Tex���W�ɕ␳
    float DepthMax = Depth0;
    float2 Tex = Tex0;
    if(DepthL - Depth0 > DepthThreshold){
       if( DepthMax < DepthL ){
           DepthMax = DepthL;
           Tex = Tex0 + SampStep * float2(-1, 0);
       }
    }
    if(DepthR - Depth0 > DepthThreshold){
       if( DepthMax < DepthR ){
           DepthMax = DepthR;
           Tex = Tex0 + SampStep * float2( 1, 0);
       }
    }
    if(DepthT - Depth0 > DepthThreshold){
       if( DepthMax < DepthT ){
           DepthMax = DepthT;
           Tex = Tex0 + SampStep * float2( 0,-1);
       }
    }
    if(DepthB - Depth0 > DepthThreshold){
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

    // ���C�g�����̍��W�ϊ�,Z�l�v�Z
    float3 WPos = tex2D( WPosSamp, Tex ).xyz;
    float4 VPos = mul(float4(WPos,1), GetLightViewMatrix());
    float4 PPos = CalcLightProjPos(VPos);
    float z = PPos.z/PPos.w;

    // �V���h�E�}�b�v�e�N�X�`�����W�ɕϊ�
    float2 SMapTex = PPos.xy / PPos.w;
    SMapTex.y = -SMapTex.y;
    SMapTex = (SMapTex + 1.0f) * 0.5f;

    // �Z���t�V���h�E�`��
    if( !any( saturate(SMapTex) - SMapTex ) ) {
        // �V���h�E�}�b�vZ�v���b�g
        float2 zplot = GetZPlot( SMapTex );

        #if UseSoftShadow==1
        // �e������(�\�t�g�V���h�E�L�� VSM:Variance Shadow Maps�@)
        float variance = max( zplot.y - zplot.x * zplot.x, 0.0002f );
        float Comp = variance / (variance + max(z - zplot.x, 0.0f));
        #else
        //  �e������(�\�t�g�V���h�E����)
        float Comp = 1.0 - saturate( max(z - zplot.x, 0.0f)*1500.0f - 0.3f );
        #endif

        // �e�̍���
        Color = lerp(ShadowColor, Color, Comp);
    }

    #ifdef MIKUMIKUMOVING
    float4 Color0 = tex2D( ScnSamp, Tex );
    Color.rgb += Color0.rgb;
    Color.a = Color0.a;
    #endif

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        #ifdef MIKUMIKUMOVING
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        #endif
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            #ifndef MIKUMIKUMOVING
            "ScriptExternal=Color;"
            #endif
            "Pass=PostDraw;"
    ;
> {
    pass PostDraw < string Script= "Draw=Buffer;"; > {
        #ifndef MIKUMIKUMOVING
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        #endif
        VertexShader = compile vs_3_0 VS_Draw();
        PixelShader  = compile ps_3_0 PS_Draw();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
