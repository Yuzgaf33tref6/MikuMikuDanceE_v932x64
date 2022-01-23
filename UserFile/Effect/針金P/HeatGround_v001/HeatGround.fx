////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HeatGround.fx ver0.0.1  �z�����������G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define UseHDR  0   // HDR�����_�����O�̗L��
// 0 : �ʏ��256�K���ŏ���
// 1 : ���Ɠx�������̂܂܏���

#ifndef MIKUMIKUMOVING
// ��MME�g�p���̂ݕύX(MMM��UI�R���g���[�����ύX��)

// �z���Ɋւ���p�����[�^
float HeightMax = 30.0;       // �h�炬���N����ő卂��
float HeightGrad = 0.05;      // �J��������̐��������ɑ΂���h�炬�ő卂���̌X��
float LengthMin = 40.0;       // ���܊J�n�ʒu�̍ŋߖT����
float RayLengthMax = 250.0;   // ���܊J�n�ʒu�����΂����C�̍ő勗��
float DistFreq = 1.0;         // �h�炬�ׂ̍���
float DistSpeed = 0.05;       // �h�炬�̑���

// �������Ɋւ���p�����[�^
float MirrorFreq = 0.005;    // ���ʂ̗h�炬�ׂ���
float MirrorFreqSpeed = 0.3; // ���ʂ̗h�炬����
float MirrorDirec = 0.1;     // �������͈�,���ʉ����郌�C�̊p�x(�ő�l�����߂�Tr�Œ���)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#else
// MMM�p�����[�^

// �z���Ɋւ���p�����[�^
float DistPower <
   string UIName = "�z������";
   string UIHelp = "�傫������Ɨh�炬���������Ȃ�";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 1.0 );

float MirrorDirec <
   string UIName = "�������͈�";
   string UIHelp = "���ʉ����郌�C�̐����ʂɑ΂���p�x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 0.3;
> = float( 0.05 );

float heightMax <
   string UIName = "�z���h�炬��";
   string UIHelp = "�h�炬���N����ő卂��";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100.0;
> = float( 30.0 );

float HeightGrad <
   string UIName = "�z���h�炬�X��";
   string UIHelp = "�J��������̐��������ɑ΂���h�炬�ő卂���̌X��";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.05 );

float LengthMin <
   string UIName = "�z���J�n����";
   string UIHelp = "���܊J�n�ʒu�̍ŋߖT����";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 200.0;
> = float( 40.0 );

float RayLengthMax <
   string UIName = "�z���ő勗��";
   string UIHelp = "���܊J�n�ʒu�����΂����C�̍ő勗��";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 9999.0;
> = float( 250.0 );

float DistFreq <
   string UIName = "�z���ׂ���";
   string UIHelp = "�傫������Ɨh�炬���ׂ����Ȃ�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );

float DistSpeed <
   string UIName = "�z������";
   string UIHelp = "�傫������Ɨh�炬�������Ȃ�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.05 );

// �������Ɋւ���p�����[�^
float MirrorFreq <
   string UIName = "�������ׂ���";
   string UIHelp = "�傫������Ɨh�炬���ׂ����Ȃ�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 0.1;
> = float( 0.005 );

float MirrorFreqSpeed <
   string UIName = "����������";
   string UIHelp = "�傫������Ɨh�炬�������Ȃ�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 0.2 );

#endif

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

float time : TIME;

float AcsY : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;


float4x4 ViewMatrix     : VIEW;
float4x4 ProjMatrix     : PROJECTION;
float4x4 ViewProjMatrix : VIEWPROJECTION;

// �J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

#define LOOP_COUNT  8   // ���C�̐[�x����̃T���v�����O��

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5,0.5) / ViewportSize;
static float2 SampStep1 = float2(2,2) / ViewportSize;

#define DEPTH_FAR   5000.0f  // �[�x�ŉ��l

#ifndef MIKUMIKUMOVING
    static float heightMax = HeightMax + AcsY;   // �h�炬���N����ő卂��
    static float DistPower = AcsSi * 0.1f;       // �z������
    #define OFFSCREEN_NORMAL  "Heat_Normal.fxsub"
    #define OFFSCREEN_POSDEP  "Heat_PosDepth.fxsub"
#else
    #define OFFSCREEN_NORMAL  "Heat_NormalMMM.fxsub"
    #define OFFSCREEN_POSDEP  "Heat_PosDepthMMM.fxsub"
#endif


// �I�t�X�N���[���@���}�b�v
texture HeatNormalRT: OFFSCREENRENDERTARGET <
    string Description = "HeatGround.fx�̖@���}�b�v";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0, 0 ,0, 1};
    float ClearDepth = 1.0;
    string Format = "D3DFMT_X8R8G8B8" ;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "* =" OFFSCREEN_NORMAL ";";
>;
sampler NormalMapSmp = sampler_state {
    texture = <HeatNormalRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �I�t�X�N���[���ʒu�E�[�x�}�b�v
texture HeatPosDepRT: OFFSCREENRENDERTARGET <
    string Description = "HeatGround.fx�̈ʒu�E�[�x�}�b�v";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0, 0 ,0, 1};
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A32B32G32R32F";
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "* =" OFFSCREEN_POSDEP ";";
>;
sampler PosDepMapSmp = sampler_state {
    texture = <HeatPosDepRT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


#if UseHDR==0
    #define TEX_FORMAT "D3DFMT_A8R8G8B8"
#else
    #define TEX_FORMAT "D3DFMT_A16B16G16R16F"
    //#define TEX_FORMAT "D3DFMT_A32B32G32R32F"
#endif

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float  ClearDepth  = 1.0;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnTex : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSmp = sampler_state {
    texture = <ScnTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �����_�[�^�[�Q�b�g�̐[�x�X�e���V���o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D3DFMT_D24S8";
>;

// �������`���̌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D RoadMirageTex : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D RoadMirageSmp = sampler_state {
    texture = <RoadMirageTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �m�C�Y�e�N�X�`��
texture2D NoiseTex <
    string ResourceName = "Noise1.png";
    int MipLevels = 0;
>;
sampler NoiseSmp = sampler_state {
    texture = <NoiseTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

// �m�C�Y�@���e�N�X�`��
texture2D NoiseNormalTex <
    string ResourceName = "NoiseNormal.png";
    int MipLevels = 0;
>;
sampler NoiseNormalSmp = sampler_state {
    texture = <NoiseNormalTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Common(float4 Pos : POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���������˖ʒǉ�

float4 PS_RoadMirage( float2 Tex: TEXCOORD0 ) : COLOR0
{
    // ���摜�̃s�N�Z����̃f�[�^
    float3 normal = normalize( tex2D( NormalMapSmp, Tex ).xyz * 2.0f - 1.0f ); // �@��
    float4 Color = tex2D( PosDepMapSmp, Tex );
    float3 wpos = Color.xyz;  // ���[���h���W
    float  dep0 = Color.w;    // �[�x
    float3 eye = normalize(CameraPosition - wpos);  // �J��������
    float  en_cos = dot(eye, float3(0,1,0));  // �����ʂƃJ���������̂Ȃ��p
    float  maxDir = MirrorDirec * AcsTr;

    Color = tex2D( ScnSmp, Tex );  // ���摜�̐F

    // �@����������Ń��C���s�p�ɓ�����ʒu�����ʂɂȂ�
    if((dot(normal, float3(0,1,0)) > 0.99f) && (0.0f < en_cos && en_cos < MirrorDirec) && (dep0 > 0.0f)){

        // ���ˌ�̃��C�̌���
        float3 dirRay =  normalize(float3(0,1,0) * (2.0f * dot(eye, float3(0,1,0))) - eye);
        //float3 dirRay = normal * (2.0f * dot(eye, normal)) - eye;

        // ���C�����Ƀm�C�Y��������
        float2 normalTexCoord = ( wpos.xz * 0.003f + time * MirrorFreqSpeed ) * 0.8f;
        float3 gnormal = normalize( tex2D( NoiseNormalSmp, normalTexCoord ).xyz * 2.0f - 1.0f );
        dirRay = normalize( dirRay + gnormal * MirrorFreq );

        // ���ʂ̔��˗�
        float bordRate = smoothstep(-maxDir, -0.2f*maxDir, -en_cos);  // ���E�t�߂̔��˗�
        bordRate *= smoothstep(0.0f, 0.8f, tex2D( NoiseSmp, wpos.xz / 200.0f + 0.1f * time ).x);  // �m�C�Y�Ŕ��˗����U�炷

        // �T���v�����O�ʒu�����X�Ɋg���Ď�O�ɂ��郂�f�����E��Ȃ��悤�ɂ���
        float ex = pow(1000.0f, 1.0f/float(LOOP_COUNT));
        float depStep = 1.0f;
        [unroll] //���[�v�W�J
        for(int i=1; i<=LOOP_COUNT; i++){
            depStep *= ex;
            float3 posRay = wpos + dirRay * depStep; // ���C�ʒu
            float4 posRayProj = mul( float4(posRay, 1), ViewProjMatrix );
            float2 texCoord = (posRayProj.xy / posRayProj.w * float2(1,-1) + 1.0f) * 0.5f + ViewportOffset; // ���C�ʒu�̃X�N���[�����W
            float dep = tex2D( PosDepMapSmp, texCoord ).w * DEPTH_FAR;
            // �[�x�����C�ʒu�̎�O�ɂ��鎞�͏E��Ȃ�
            if(length(posRay - CameraPosition) < dep){
                Color = lerp( Color, tex2D( ScnSmp, texCoord ), bordRate );
            }
        }
    }

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �z���ɂ��h�炬�ǉ�

float4 PS_HeatHaze( float2 Tex: TEXCOORD0 ) : COLOR0
{
    float4 Color = tex2D( PosDepMapSmp, Tex );
    float3 wpos = Color.xyz;  // ���[���h���W
    float  dep0 = Color.w;    // �[�x
    float3 eye = normalize(wpos - CameraPosition);

    float3 spos = wpos;  // ���܊J�n�ʒu
    float3 epos = wpos;  // ���܏I���ʒu
    if(CameraPosition.y > heightMax){
        float a = CameraPosition.y - heightMax;
        float b = heightMax + HeightGrad * length(CameraPosition.xz - wpos.xz) - wpos.y;
        if(b > 0.0f){
            spos = lerp(CameraPosition, wpos, saturate(a/(a+b)));
            spos += eye * LengthMin;
        }
    }else{
        spos = CameraPosition + eye * LengthMin;
        float a = heightMax - CameraPosition.y;
        float b = wpos.y - heightMax - HeightGrad * length(CameraPosition.xz - wpos.xz);
        if(b > 0.0f){
            float a = heightMax - CameraPosition.y;
            float b = wpos.y - heightMax - HeightGrad * length(CameraPosition.xz - wpos.xz);
            epos = lerp(CameraPosition, wpos, saturate(a/(a+b)));
        }
    }

    // ���C�̋��܂��N���鋗��
    float depHeightMax = heightMax + HeightGrad * length(CameraPosition.xz - (spos.xz+epos.xz)*0.5f);
    float hdep = max(length(epos - CameraPosition) - length(spos - CameraPosition), 0) * saturate((depHeightMax-0.5f*(spos.y+epos.y))/depHeightMax);
    hdep = min(hdep, RayLengthMax);

    // �h�炬�ɂ�郌�C�����␳
    float2 normalTexCoord1 = (Tex + float2( time, time) * DistSpeed) * DistFreq * float2(ViewportSize.x / ViewportSize.y, -1.0f);
    float2 normalTexCoord2 = (Tex + float2(-time, time) * DistSpeed) * DistFreq * float2(ViewportSize.x / ViewportSize.y, -1.0f);
    float  mipLevel = max(3.0f - 0.1f*degrees(2.0f*atan(1.0f/ProjMatrix._22)), 0.0f);
    float3 normal1 = tex2Dlod( NoiseNormalSmp, float4(normalTexCoord1, 0, mipLevel) ).xyz * 2.0f - 1.0f;
    float3 normal2 = tex2Dlod( NoiseNormalSmp, float4(normalTexCoord2, 0, mipLevel) ).xyz * 2.0f - 1.0f;
    float3 normal = normalize(normal1 + normal2);
    float3 dirRay = normalize( lerp(eye, eye+normal*DistPower*0.004f/(mipLevel+1.0f), hdep/RayLengthMax) );

    Color = tex2D( RoadMirageSmp, Tex );  // �h�炬�O�̐F

    if(hdep > 0.0f && dep0 > 0.0f){
        // �T���v�����O�ʒu�����X�Ɋg���Ď�O�ɂ��郂�f�����E��Ȃ��悤�ɂ���
        float ex = pow(RayLengthMax, 1.0f/float(LOOP_COUNT));
        float depStep = 1.0f;
        [unroll] //���[�v�W�J
        for(int i=1; i<=LOOP_COUNT; i++){
            depStep *= ex;
            float3 posRay = spos + dirRay * depStep; // ���C�ʒu
            float4 posRayProj = mul( float4(posRay, 1), ViewProjMatrix );
            float2 texCoord = (posRayProj.xy / posRayProj.w * float2(1,-1) + 1.0f) * 0.5f + ViewportOffset; // ���C�ʒu�̃X�N���[�����W
            // ���C�ʒu�̐[�x(AA�̃u�����h�ʒu���E��Ȃ��悤��4�����`�F�b�N)
            float dep = tex2D( PosDepMapSmp, texCoord ).w * DEPTH_FAR;
            float depL = tex2D( PosDepMapSmp, texCoord+float2(-SampStep1.x,0) ).w * DEPTH_FAR;
            float depR = tex2D( PosDepMapSmp, texCoord+float2( SampStep1.x,0) ).w * DEPTH_FAR;
            float depB = tex2D( PosDepMapSmp, texCoord+float2(0,-SampStep1.x) ).w * DEPTH_FAR;
            float depT = tex2D( PosDepMapSmp, texCoord+float2(0, SampStep1.x) ).w * DEPTH_FAR;
            float lenRay = length(posRay - CameraPosition);
            // �[�x�����C�ʒu�̎�O�ɂ��鎞�͏E��Ȃ�
            if(lenRay < dep && lenRay < depL && lenRay < depR && lenRay < depB && lenRay < depT){
                Color = tex2D( RoadMirageSmp, texCoord );  // ���C�ʒu�̐F
            }
        }
    }

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
    string Script = 
        // �I���W�i���̕`��
        "RenderColorTarget0=ScnTex;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        // ���������˖ʒǉ�
        "RenderColorTarget0=RoadMirageTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=DrawRoadMirage;"
        // �z���ɂ��h�炬�ǉ�
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=DrawHeatHaze;"
        ; >
{
    pass DrawRoadMirage < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_RoadMirage();
    }
    pass DrawHeatHaze < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_HeatHaze();
    }
}



