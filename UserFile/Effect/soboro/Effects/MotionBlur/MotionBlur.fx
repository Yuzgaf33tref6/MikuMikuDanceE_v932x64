////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ���[�V�����u���[�G�t�F�N�g
//  �쐬: ���ڂ�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^

// �ڂ������x(�傫����������ƎȂ��o�܂�)
float DirectionalBlurStrength
<
   string UIName = "DirectionalBlurStrength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.4 );

//�c������
float LineBlurLength
<
   string UIName = "LineBlurLength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.8 );

//�c���Z��
float LineBlurStrength
<
   string UIName = "LineBlurStrength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );

//���x�̏���l
float VelocityLimit
<
   string UIName = "VelocityLimit";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.12 );

//���x�̉����l
float VelocityUnderCut
<
   string UIName = "VelocityUnderCut";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.006 );

//�V�[���؂�ւ�臒l
float SceneChangeThreshold
<
   string UIName = "SceneChangeThreshold";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100;
> = float( 20 );

//�V�[���؂�ւ��p�x臒l
float SceneChangeAngleThreshold
<
   string UIName = "SceneChangeAngleThreshold";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100;
> = float( 25 );


//�w�i�F
float4 BackColor
<
   string UIName = "BackColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 0, 0, 0, 0 );


//���C���u���[�̉𑜓x��{�ɂ��܂��B1�ŗL���A0�Ŗ���
#define LINEBLUR_QUAD  1

//������̃T���v�����O��
#define SAMP_NUM   9


///////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


//�A���t�@�l�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �X�P�[���l�擾
float scaling : CONTROLOBJECT < string name = "(self)"; >;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;

static float2 ViewportOffset = (float2(0.5,0.5) / ViewportSize);

static float2 BlurSampStep = (float2(DirectionalBlurStrength, DirectionalBlurStrength)/ViewportSize*ViewportSize.y);
static float2 BlurSampStepScaled = BlurSampStep  * scaling * 0.1;





#define VM_TEXFORMAT "A32B32G32R32F"
//#define VM_TEXFORMAT "A16B16G16R16F"

//�[�x�t���x���V�e�B�}�b�v�쐬
texture VelocityRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for MotionBlur.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0.5, 0.5, 1, 0 };
    float ClearDepth = 1.0;
    string Format = VM_TEXFORMAT ;
    bool AntiAlias = false;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "* = VelocityMap.fx;"
        ;
>;

sampler VelocitySampler = sampler_state {
    texture = <VelocityRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};



// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 0;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


//���C���u���[�o�̓o�b�t�@

#if LINEBLUR_QUAD==0
    #define LINEBLUR_GRIDSIZE 128
    #define LINEBLUR_BUFSIZE  256
#else
    #define LINEBLUR_GRIDSIZE 256
    #define LINEBLUR_BUFSIZE  512
    
    int loopindex = 0;
    int loopcount = 4;
    
#endif

texture2D LineBluerDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    string Format = "D24S8";
>;
texture2D LineBluerTex : RENDERCOLORTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
>;
sampler2D LineBluerSamp = sampler_state {
    texture = <LineBluerTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D LineBluerInfoTex : RENDERCOLORTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    int MipLevels = 1;
    string Format = VM_TEXFORMAT;
>;
sampler2D LineBluerInfoSamp = sampler_state {
    texture = <LineBluerInfoTex>;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

//���X�N���[���Q�Ǝ��̃~�b�v���x��
static float ScnMipLevel1 = log2(ViewportSize.y / LINEBLUR_GRIDSIZE) + 0.5;


//�J�����ʒu�̋L�^

#define INFOBUFSIZE 2

float2 InfoBufOffset = float2(0.5 / INFOBUFSIZE, 0.5);

texture CameraBufferMB : RenderDepthStencilTarget <
   int Width=INFOBUFSIZE;
   int Height=1;
    string Format = "D24S8";
>;
texture CameraBufferTex : RenderColorTarget
<
    int Width=INFOBUFSIZE;
    int Height=1;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;

float4 CameraBuffer[INFOBUFSIZE] : TEXTUREVALUE <
    string TextureName = "CameraBufferTex";
>;

//�J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;

//�V�[���؂�ւ����ǂ�������
static bool IsSceneChange = (length(CameraPosition - CameraBuffer[0].xyz) > SceneChangeThreshold)
                            || (dot(CameraDirection, CameraBuffer[1].xyz) < cos(SceneChangeAngleThreshold * 3.14 / 180));


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�t���x���V�e�B�}�b�v�Q�Ɗ֐��Q


#define VELMAP_SAMPLER  VelocitySampler


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
    return MB_VelocityPreparation(tex2D( VELMAP_SAMPLER, Tex ));
}

float MB_GetDepthMap(float2 Tex){
    return tex2D( VELMAP_SAMPLER, Tex ).z;
}

float2 MB_GetBlurMapAround(float2 Tex){
    float4 vm, vms;
    const float step = 4.5 / LINEBLUR_BUFSIZE;
    float z0, n = 1;
    
    vms = tex2D( VELMAP_SAMPLER, Tex );
    
    z0 = vms.z;
    
    vm = tex2D( VELMAP_SAMPLER, float2( Tex.x + step, Tex.y ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vm = tex2D( VELMAP_SAMPLER, float2( Tex.x - step, Tex.y ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vm = tex2D( VELMAP_SAMPLER, float2( Tex.x, Tex.y + step ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vm = tex2D( VELMAP_SAMPLER, float2( Tex.x, Tex.y - step ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vms /= n;
    
    return MB_VelocityPreparation(vms);
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�x���V�e�B�}�b�v�ɏ]���������u���[��������

float4 PS_DirectionalBlur( float2 Tex: TEXCOORD0 ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float2 vel = MB_GetBlurMap(Tex);
    
    float4 info;
    float2 step = BlurSampStepScaled * vel / SAMP_NUM;
    float depth, centerdepth = MB_GetDepthMap(Tex) - 0.01;
    
    float bp = saturate(length(vel) * 10);
    
    step *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = Tex + (step * (float)i);
        
        //��O�����܂蓮���Ă��Ȃ���������̃T���v�����O�͎キ
        if(i != 0){
            depth = MB_GetDepthMap(stex);
            e *= max(saturate(length(MB_GetBlurMap(stex)) / 0.02), (depth > centerdepth));
        }
        
        //�T���v�����O
        sum += tex2D( ScnSamp, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
    
}



////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�o�̓o�b�t�@�̏����l�ݒ�


struct PS_OUTPUT_CLB
{
   float4 Color : COLOR0;
   float4 Info  : COLOR1;
};

PS_OUTPUT_CLB PS_ClearLineBluer( float2 Tex: TEXCOORD0 ) {
    
    PS_OUTPUT_CLB OUT = (PS_OUTPUT_CLB)0;
    
    //�A���t�@�l��0�ɂ������X�N���[���摜�Ŗ��߂�
    OUT.Color = tex2D( ScnSamp, Tex );
    OUT.Color.a = 0;
    
    //���C���u���[�Ŏg�p������}�b�v���o��
    OUT.Info.xy = MB_GetBlurMapAround( Tex );
    OUT.Info.z = MB_GetDepthMap( Tex );
    OUT.Info.w = 1;
    
    return OUT;
}


/////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�`��

struct VS_OUTPUT3 {
    float4 Pos: POSITION;
    float4 Color: COLOR0;
    float3 Tex: TEXCOORD0;
    float2 BaseVel : TEXCOORD1;
    
};

VS_OUTPUT3 VS_LineBluer(float4 Pos : POSITION, int index: _INDEX)
{
    VS_OUTPUT3 Out;
    float2 PosEx = Pos.xy;
    bool IsTip = (Pos.x > 0); //���C���̐L�т���[
    
    float findex = Pos.z;
    
#if LINEBLUR_QUAD!=0
    findex += loopindex * (128 * 128);
#endif
    
    float2 findex_xy = float2(findex % LINEBLUR_GRIDSIZE, trunc(findex / LINEBLUR_GRIDSIZE));
    
    float2 TexPos = findex_xy / LINEBLUR_GRIDSIZE;
    float2 ScreenPos = (TexPos * 2 - 1) * float2(1,-1);
    
    //�x���V�e�B�}�b�v�Q��
    float4 VelMap = tex2Dlod( VELMAP_SAMPLER, float4(TexPos, 0, 0) );
    float2 Velocity = MB_VelocityPreparation(VelMap);
    float VelLen = length(Velocity) * alpha1;
    
    Out.BaseVel = Velocity; //PS�ɑ��x��n���B
    
    //���x�x�N�g���Ɣ��Α��Ƀ��C����L�΂�
    Velocity = -Velocity;
    
    //���C����
    PosEx *= (1.0 / LINEBLUR_GRIDSIZE);
    //���C������
    PosEx.x += VelLen * IsTip * LineBlurLength;
    //���C���L����
    PosEx.y *= 1 + 0.2 * IsTip;
    
    //�΂߃��C���͑���
    PosEx.y *= 1 + 0.4 * abs(sin(atan2(Velocity.x, Velocity.y) * 2));
    
    //���C����]
    float2 AxU = normalize(Velocity);
    float2 AxV = float2(AxU.y, -AxU.x);
    
    PosEx = PosEx.x * AxU + PosEx.y * AxV;
    
    //���_�ʒu�ɂ��T���v�����O�ʒu�̃I�t�Z�b�g
    //TexPos += (-Pos.y * AxV) / (LINEBLUR_GRIDSIZE * 2);
    
    //���X�N���[���Q��
    Out.Color = tex2Dlod( ScnSamp, float4(TexPos, 0, ScnMipLevel1) );
    
    //�u���[���x����A���t�@�ݒ�E���C����[�͓�����
    Out.Color.a *= saturate(VelLen * 250) * (1 - IsTip);
    
    Out.Color.a *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    //�o�b�t�@�o��
    Out.Pos.xy = ScreenPos + PosEx;
    Out.Pos.z = 0;
    Out.Pos.w = 1;
    
    //�X�N���[���e�N�X�`�����W
    Out.Tex.xy = (Out.Pos.xy * float2(1,-1) + 1) * 0.5 + (0.5 / LINEBLUR_BUFSIZE);
    Out.Tex.z = VelMap.z; //TEXCOORD0��Z���؂�āA�c���̔�������Z�l��n��
    
    return Out;
}

float4 PS_LineBluer( VS_OUTPUT3 IN ) : COLOR0
{
    
    float4 Info = tex2D( LineBluerInfoSamp, IN.Tex.xy);
    float4 Color = IN.Color;
    
    float BaseZ = Info.z; //���摜��Z
    float AfImZ = IN.Tex.z; //�c����Z
    
    //��O�̃I�u�W�F�N�g��̎c���͉B��
    Color.a *= saturate(1 - (AfImZ - BaseZ) * 200);
    
    float2 vel = Info.xy;
    
    //�w�i�̑��x�x�N�g������v���Ă���Ƃ��͔���
    float vdrate = max(length(vel), length(IN.BaseVel));
    vdrate = (vdrate == 0) ? 0 : (1 / vdrate);
    float VelDif = length(vel - IN.BaseVel) * vdrate;
    Color.a *= saturate(VelDif);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�̍���

VS_OUTPUT VS_MixLineBluer( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + (0.5 / LINEBLUR_BUFSIZE);
    
    return Out;
}

#define LBSAMP LineBluerSamp

float4 PS_MixLineBluer( float2 Tex: TEXCOORD0 ) : COLOR {   
    float2 step = 1.1 / LINEBLUR_BUFSIZE;
    float4 Color = tex2D( LineBluerSamp, Tex);
    
    //������𑜓x�Ȃ̂ŁA�W���M�[�����̂��߂Ɍy���ڂ���
    [unroll] for(int j = -1; j <= 1; j++){
        [unroll] for(int i = -1; i <= 1; i++){
            Color += tex2D( LineBluerSamp, Tex + step * float2(i,j) );
            
        }
    }
    
    Color /= 10;
    
    Color.a *= LineBlurStrength;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�J�����ʒu�̋L�^

VS_OUTPUT VS_CameraBuffer( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + InfoBufOffset;
    
    return Out;
}

float4 PS_CameraBuffer( float4 Tex : TEXCOORD0 ) : COLOR {   
    float4 Color = float4(CameraPosition, 1);
    Color = (Tex.x >= 0.5) ? float4(CameraDirection, 1) : Color;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

// �����_�����O�^�[�Q�b�g�̃N���A�l
//float4 ClearColor = {1,1,1,0};
float4 ClearColor = {0,0,0,0};
float4 ClearColor2 = {0,0,0,0};
float ClearDepth  = 1.0;


technique MotionBlur <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DirectionalBlur;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=LineBluerInfoTex;"
        "RenderDepthStencilTarget=LineBluerDepthBuffer;"
        "ClearSetColor=ClearColor2; Clear=Color;"
        "ClearSetDepth=ClearDepth; Clear=Depth;"
        "Pass=ClearLineBluer;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=;"
        "Clear=Depth;"
        
    #if LINEBLUR_QUAD==0
        //1�񂾂�
        "Pass=DrawLineBluer;"
    #else
        //4��J��Ԃ�
        "LoopByCount=loopcount;"
        "LoopGetIndex=loopindex;"
        "Pass=DrawLineBluer;"
        "LoopEnd=;"
    #endif
         
         
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=MixLineBluer;"
        
        "RenderColorTarget=CameraBufferTex;"
        "RenderDepthStencilTarget=CameraBufferMB;"
        "Pass=DrawCameraBuffer;"
        
    ;
    
> {
    
    
    //�������u���[
    pass DirectionalBlur < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DirectionalBlur();
    }
    
    
    
    //���C���u���[
    pass ClearLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ClearLineBluer();
    }
    
    pass DrawLineBluer < string Script= "Draw=Geometry;"; > {
        AlphaBlendEnable = true;
        AlphaTestEnable = true;
        CullMode = NONE;
        ZEnable = false;
        VertexShader = compile vs_3_0 VS_LineBluer();
        PixelShader  = compile ps_3_0 PS_LineBluer();
    }
    
    pass MixLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = true;
        //AlphaBlendEnable = false;AlphaTestEnable = false;
        
        VertexShader = compile vs_3_0 VS_MixLineBluer();
        PixelShader  = compile ps_3_0 PS_MixLineBluer();
    }
    
    
    
    //�J�����ʒu�ۑ�
    pass DrawCameraBuffer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_CameraBuffer();
        PixelShader  = compile ps_3_0 PS_CameraBuffer();
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////////

