

//�w�i�F RGBA�e�F0�`1
const float4 BackColor
<
   string UIName = "BackColor";
   string UIWidget = "Color";
   string UIHelp = "�w�i�F";
   bool UIVisible =  true;
> = float4( 0, 0, 0, 0 );

//�������x
float AfterGlowPower <
   string UIName = "AfterGlowPower";
   string UIWidget = "Slider";
   string UIHelp = "�������x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2;
> = 1.0;

// �ڂ����͈�
float AL_Extent <
   string UIName = "AL_Extent";
   string UIWidget = "Slider";
   string UIHelp = "�����ڂ����͈�";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 0.002;
> = 0.002;

float AfterGlowAttenuation <
   string UIName = "Attenuation";
   string UIWidget = "Slider";
   string UIHelp = "����";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 10;
> = 1;

// ���[�V�����u���[�p�����[�^ //////////////////////////////////////////////

// �ڂ������x(�傫����������ƎȂ��o�܂�)
float DirectionalBlurStrength <
   string UIName = "DirBlur";
   string UIWidget = "Slider";
   string UIHelp = "���[�V�����u���[�ڂ������x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 4.0;
> = 1.0;

//���x�̏���l
float VelocityLimit <
   string UIName = "VelocityLimit";
   string UIWidget = "Slider";
   string UIHelp = "���x�̏���l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 0.5;
> = 0.12;

//���x�̉����l
float VelocityUnderCut <
   string UIName = "VelocityUnder";
   string UIWidget = "Slider";
   string UIHelp = "���x�̉����l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 0.02;
> = 0.006;


//������̃T���v�����O��
#define SAMP_NUM   8


///////////////////////////////////////////////////////////////////////////////////



float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


bool ParentEnable : CONTROLOBJECT < string name = "TrueCameraLX.x"; >; 

float4x4 matWorld : CONTROLOBJECT < string name = "(self)"; >; 
static float pos_x = matWorld._41;
static float pos_y = matWorld._42;
static float pos_z = matWorld._43;

// ��]
float3 rot : CONTROLOBJECT < string name = "(self)"; string item = "Rxyz"; >;

//����
float ftime : TIME <bool SyncInEditMode = false;>;



float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �X�P�[���l�擾
float scalingL0 : CONTROLOBJECT < string name = "(self)"; >;
static float scalingL = scalingL0 * 0.1;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float Aspect = ViewportSize.x / ViewportSize.y;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 OnePx = (float2(1,1)/ViewportSize);

static float2 SampStep = (float2(AL_Extent,AL_Extent)/ViewportSize*ViewportSize.y);


static float2 veloffset = (float2(pos_x, pos_y) / 200 * (1 + pos_z / 100)
                        + float2(
                            sin(ftime * (rot.z + 1) * 5) * 0.001 * rot.x,
                            cos(ftime * (rot.z + 1) * 7) * 0.001 * rot.y
                        ))/ViewportSize*ViewportSize.y;


static float2 MBlurSampStep = (float2(DirectionalBlurStrength, DirectionalBlurStrength)/ViewportSize*ViewportSize.y);
static float2 MBlurSampStepScaled = MBlurSampStep * 1 / SAMP_NUM * 8;


#define AL_TEXFORMAT "D3DFMT_A16B16G16R16F"

////////////////////////////////////////////////////////////////////////////////////
// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

///////////////////////////////////////////////////////////////////////////////////////////////
// �����˃I�u�W�F�N�g�`���

texture AG_EmitterRT: OFFSCREENRENDERTARGET <
    string Description = "EmitterDrawRenderTarget for AfterGlow";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 0;
    string Format = AL_TEXFORMAT;
    string DefaultEffect = 
        "self = hide;"
        "*Luminous.x = hide;"
        "ToneCurve.x = hide;"
        
        //------------------------------------
        //�Z���N�^�G�t�F�N�g�͂����Ŏw�肵�܂�
        
        
        
        //------------------------------------
        
        "*=AL_BlackMask.fxsub"
        //"* = AL_Object.fxsub;" 
    ;
>;


sampler EmitterView = sampler_state {
    texture = <AG_EmitterRT>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

///////////////////////////////////////////////////////////////////////////////////////////////

//�[�x�t���x���V�e�B�}�b�v�쐬
shared texture DVMapDraw: OFFSCREENRENDERTARGET;

sampler DVSampler = sampler_state {
    texture = <DVMapDraw>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};


// ���P�x�������L�^���邽�߂̃����_�[�^�[�Q�b�g
shared texture2D ExternalHighLight : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
    
>;

sampler ExternalHighLightSampler = sampler_state {
    texture = <ExternalHighLight>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};

///////////////////////////////////////////////////////////////////////////////////////////////

// AG�ۑ��p�o�b�t�@
texture2D AfterGlowBuffer : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
    
>;
sampler2D AfterGlowSamp = sampler_state {
    texture = <AfterGlowBuffer>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�t���x���V�e�B�}�b�v�Q�Ɗ֐��Q

#define VELMAP_SAMPLER  DVSampler
#define MB_DEPTH w

//�}�b�v�i�[��񂩂瑬�x�x�N�g���𓾂�
float2 MB_VelocityPreparation(float4 rawvec){
    float2 vel = rawvec.xy - 0.5;
    float len = length(vel);
    vel = max(0, len - VelocityUnderCut) * normalize(vel);
    
    vel = min(vel, float2(VelocityLimit, VelocityLimit));
    vel = max(vel, float2(-VelocityLimit, -VelocityLimit));
    
    return vel;
}

float2 MB_GetBlurMap(float2 Tex){
    return MB_VelocityPreparation(tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ));
}

float MB_GetDepthMap(float2 Tex){
    return tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ).MB_DEPTH;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�g�[���J�[�u�̒���
//�����ł������ǂ��Ȃ��Ă��邩�悭�킩��Ȃ��֐��ɂȂ��Ă��܂������A
//���ƂȂ����܂������Ă���̂ŕ|���Ă�����Ȃ�

float4 ToneCurve(float4 Color){
    float3 newcolor;
    const float th = 0.65;
    newcolor = normalize(Color.rgb) * (th + sqrt(max(0, (length(Color.rgb) - th) / 2)));
    newcolor.r = (Color.r > 0) ? newcolor.r : Color.r;
    newcolor.g = (Color.g > 0) ? newcolor.g : Color.g;
    newcolor.b = (Color.b > 0) ? newcolor.b : Color.b;
    
    Color.rgb = min(Color.rgb, newcolor);
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//AL���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_ALDraw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 , uniform int miplevel) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    #ifdef MIKUMIKUMOVING
    float ofsetsize = 1;
    #else
    float ofsetsize = pow(2, miplevel);
    #endif
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y) * ofsetsize;
    
    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////

//���X�N���[���̍��P�x�����̒��o
float4 PS_AfterGlowDraw( float2 Tex: TEXCOORD0 ) : COLOR0 {
    
    //float4 Color = tex2D(AfterGlowSamp, Tex);
    
    //Color.rgb += tex2D( EmitterView , Tex ).rgb;
    
    
    float e, n = 0;
    float2 stex;
    float4 Color;
    float4 sum = 0;
    float2 vel = MB_GetBlurMap(Tex);
    
    vel += veloffset;
    
    float2 step = MBlurSampStepScaled * vel / SAMP_NUM;
    float depth, centerdepth = MB_GetDepthMap(Tex) - 0.01;
    
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = Tex + (step * (float)i);
        
        //�T���v�����O
        sum += tex2D( EmitterView, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    Color.rgb *= min(2, 1 + length(vel) * 30);
    
    Color.rgb *= alpha1 * AfterGlowPower;
    
    Color.rgb += tex2D( AfterGlowSamp , Tex ).rgb;
    
    
    return Color;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �o�b�t�@�̃R�s�[

float4 PS_AfterGlowCopy( float2 Tex: TEXCOORD0 , uniform sampler2D samp ) : COLOR {   
    
    float2 tex1 = Tex;
    
    tex1 += veloffset;
    
    float4 Color = tex2D(samp, tex1);
    
    Color += tex2D(samp, tex1 + float2(SampStep.x, 0));
    Color += tex2D(samp, tex1 - float2(SampStep.x, 0));
    Color += tex2D(samp, tex1 + float2(0, SampStep.y));
    Color += tex2D(samp, tex1 - float2(0, SampStep.y));
    Color /= 5;
    
    Color *= saturate(1.0 - 1.0 / (1 + AfterGlowAttenuation / scalingL));
    
    Color = ParentEnable ? Color : float4(0,0,0,1);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

// �����_�����O�^�[�Q�b�g�̃N���A�l

float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;


technique AfterGlow <
    string Script = 
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=BackColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=ExternalHighLight;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Depth;"
        "Pass=AfterGlowDraw;"
        
        "RenderColorTarget0=AfterGlowBuffer;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Depth;"
        "Pass=AfterGlowCopy;"
        
    ;
    
> {
    
    
    pass AfterGlowDraw < string Script= "Draw=Buffer;"; > {
        AlphaTestEnable = true;
        AlphaBlendEnable = true;
        
        SRCBLEND = ONE; DESTBLEND = ONE; //���Z����
        
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_AfterGlowDraw();
    }
    
    pass AfterGlowCopy < string Script= "Draw=Buffer;"; > {
        AlphaTestEnable = false;
        AlphaBlendEnable = false;
        
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_AfterGlowCopy(ExternalHighLightSampler);
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////




