////////////////////////////////////////////////////////////////////////////////////////////////
//
//  �[�x���x���V�e�B�}�b�v�o�̓G�t�F�N�g
//  ����F���ڂ�
//  MME 0.27���K�v�ł�
//  �����E���p�Ƃ����R�ł�
//
////////////////////////////////////////////////////////////////////////////////////////////////


// �w�i�܂œ��߂�����臒l��ݒ肵�܂�
float TransparentThreshold = 0.6;

// ���ߔ���Ƀe�N�X�`���̓��ߓx���g�p���܂��B1�ŗL���A0�Ŗ���
#define TRANS_TEXTURE  1

////////////////////////////////////////////////////////////////////////////////////////////////

float DepthLimit = 2000;

#define SCALE_VALUE 4


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 WorldViewMatrix          : WORLDVIEW;
float4x4 ProjectionMatrix         : PROJECTION;

bool use_texture;  //�e�N�X�`���̗L��

//�}�j���A���t�H�[�J�X�̎g�p
bool UseMF : CONTROLOBJECT < string name = "ManualFocus.x"; >;
float MFScale : CONTROLOBJECT < string name = "ManualFocus.x"; >;

//�e���f����Tr�l
float alpha1 : CONTROLOBJECT < string name = "(OffscreenOwner)"; string item = "Tr"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;



//���ŋ����̎擾
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;
float3 ControlerPos  : CONTROLOBJECT < string name = "(OffscreenOwner)"; >;
static float3 FocusVec = ControlerPos - CameraPosition;
static float FocusLength = UseMF ? (3.5 * MFScale) : (length(FocusVec));

//�œ_���J�����̔w�ʂɂ��邩�ǂ���
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;
static bool BackOut = (dot(CameraDirection, normalize(FocusVec)) < 0) && !UseMF;


#if TRANS_TEXTURE!=0
    // �I�u�W�F�N�g�̃e�N�X�`��
    texture ObjectTexture: MATERIALTEXTURE;
    sampler ObjTexSampler = sampler_state
    {
        texture = <ObjectTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
    };
    
    
    // MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
    sampler MMDSamp0 : register(s0);
    sampler MMDSamp1 : register(s1);
    sampler MMDSamp2 : register(s2);
    
#endif



//�Ƃ肠����6�����_�܂�
#define VPBUF_WIDTH  256
#define VPBUF_HEIGHT 256

//���_���W�o�b�t�@�T�C�Y
static float2 VPBufSize = float2(VPBUF_WIDTH, VPBUF_HEIGHT);

static float2 VPBufOffset = float2(0.5 / VPBUF_WIDTH, 0.5 / VPBUF_HEIGHT);


//���_���Ƃ̃��[���h���W���L�^
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=VPBUF_WIDTH;
   int Height=VPBUF_HEIGHT;
    string Format = "D24S8";
>;
texture VertexPosBufTex : RenderColorTarget
<
    int Width=VPBUF_WIDTH;
    int Height=VPBUF_HEIGHT;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;
sampler VertexPosBuf = sampler_state
{
   Texture = (VertexPosBufTex);
   ADDRESSU = Clamp;
   ADDRESSV = Clamp;
   MAGFILTER = Point;
   MINFILTER = Point;
   MIPFILTER = None;
};
texture VertexPosBufTex2 : RenderColorTarget
<
    int Width=VPBUF_WIDTH;
    int Height=VPBUF_HEIGHT;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;
sampler VertexPosBuf2 = sampler_state
{
   Texture = (VertexPosBufTex2);
   ADDRESSU = Clamp;
   ADDRESSV = Clamp;
   MAGFILTER = Point;
   MINFILTER = Point;
   MIPFILTER = None;
};


//���[���h�r���[�ˉe�s��Ȃǂ̋L�^

#define INFOBUFSIZE 8

float2 InfoBufOffset = float2(0.5 / INFOBUFSIZE, 0.5);

texture DepthBufferMB : RenderDepthStencilTarget <
   int Width=INFOBUFSIZE;
   int Height=1;
    string Format = "D24S8";
>;
texture MatrixBufTex : RenderColorTarget
<
    int Width=INFOBUFSIZE;
    int Height=1;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;

float4 MatrixBufArray[INFOBUFSIZE] : TEXTUREVALUE <
    string TextureName = "MatrixBufTex";
>;

//�O�t���[���̃��[���h�r���[�ˉe�s��
static float4x4 lastMatrix = float4x4(MatrixBufArray[0], MatrixBufArray[1], MatrixBufArray[2], MatrixBufArray[3]);


//����
float ftime : TIME<bool SyncInEditMode=true;>;
float stime : TIME<bool SyncInEditMode=false;>;

//�o���t���[�����ǂ���
//�O��Ăяo������0.5s�ȏ�o�߂��Ă������\���������Ɣ��f
static float last_stime = MatrixBufArray[4].x;
static bool Appear = (abs(last_stime - stime) > 0.5);


////////////////////////////////////////////////////////////////////////////////////////////////
//�ėp�֐�

//W�t���X�N���[�����W��0�`1�ɐ��K��
float2 ScreenPosNormalize(float4 ScreenPos){
    return float2((ScreenPos.xy / ScreenPos.w + 1) * 0.5);
}


//���_���W�o�b�t�@�擾
float4 getVertexPosBuf(int index)
{
    float4 Color;
    float2 tpos = 0;
    tpos.x = modf((float)index / VPBUF_WIDTH, tpos.y);
    tpos.y /= VPBUF_HEIGHT;
    tpos += VPBufOffset;
    
    Color = tex2Dlod(VertexPosBuf2, float4(tpos,0,0));
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // UV
    float3 WorldPos   : TEXCOORD1;   // ���[���h���W
    float4 CurrentPos : TEXCOORD2;   // ���݂̍��W
    float4 LastPos    : TEXCOORD3;   // �O��̍��W
    
};

VS_OUTPUT Velocity_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0 , uniform bool useToon , int index: _INDEX)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    if(useToon){
        Out.LastPos = getVertexPosBuf(index);
    }
    
    Out.CurrentPos = Pos;
    
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    //���[���h���W
    Out.WorldPos = mul( Pos, WorldMatrix );
    
    #if TRANS_TEXTURE!=0
        Out.Tex = Tex; //�e�N�X�`��UV
    #endif
    
    return Out;
}


float4 Velocity_PS( VS_OUTPUT IN , uniform bool useToon) : COLOR0
{
    float4 lastPos, ViewPos;
    
    if(useToon){
        lastPos = mul( IN.LastPos, lastMatrix );
        ViewPos = mul( IN.CurrentPos, WorldViewProjMatrix );
    }else{
        lastPos = mul( IN.CurrentPos, lastMatrix );
        ViewPos = mul( IN.CurrentPos, WorldViewProjMatrix );
    }
    
    float alpha = MaterialDiffuse.a;
    
    //�[�x
    float mb_depth = ViewPos.z / ViewPos.w;
    float dof_depth = length(CameraPosition - IN.WorldPos);
    
    dof_depth = min(dof_depth, DepthLimit);
    
    //���ŋ����Ő��K��
    dof_depth /= (FocusLength * SCALE_VALUE);
    
    #if TRANS_TEXTURE!=0
        if(use_texture) alpha *= tex2D(ObjTexSampler,IN.Tex).a;
    #endif
    
    mb_depth += 0.001;
    mb_depth *= (alpha >= TransparentThreshold);
    
    
    //���x�Z�o
    float2 Velocity = ScreenPosNormalize(ViewPos) - ScreenPosNormalize(lastPos);
    Velocity.x *= ViewportAspect;
    
    if(Appear) Velocity = 0; //�o�����A���x�L�����Z��
    
    //���x��F�Ƃ��ďo��
    Velocity = Velocity * 0.5 + 0.5;
    float4 Color = float4(Velocity, dof_depth, mb_depth);
    
    return Color;
    
}


/////////////////////////////////////////////////////////////////////////////////////
//���o�b�t�@�̍쐬

struct VS_OUTPUT2 {
    float4 Pos: POSITION;
    float2 texCoord: TEXCOORD0;
};


VS_OUTPUT2 DrawMatrixBuf_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
    VS_OUTPUT2 Out;
    
    Out.Pos = Pos;
    Out.texCoord = Tex + InfoBufOffset;
    return Out;
}

float4 DrawMatrixBuf_PS(float2 texCoord: TEXCOORD0) : COLOR {
    int dindex = (int)(texCoord * INFOBUFSIZE); //�e�N�Z���ԍ�
    float4 Color;
    
    if(dindex < 4){
        Color = WorldViewProjMatrix[dindex]; //�s����L�^
    }else{
        Color = float4(stime, ftime, 0, 1);
    }
    
    return Color;
}


/////////////////////////////////////////////////////////////////////////////////////
//���_���W�o�b�t�@�̍쐬

struct VS_OUTPUT3 {
    float4 Pos: POSITION;
    float4 BasePos: COLOR0;
};

VS_OUTPUT3 DrawVertexBuf_VS(float4 Pos : POSITION, int index: _INDEX)
{
    VS_OUTPUT3 Out;
    
    float2 tpos = 0;
    tpos.x = modf((float)index / VPBUF_WIDTH, tpos.y);
    tpos.y /= VPBUF_HEIGHT;
    
    //�o�b�t�@�o��
    Out.Pos.xy = (tpos * 2 - 1) * float2(1,-1); //�e�N�X�`�����W�����_���W�ϊ�
    Out.Pos.zw = 1;
    
    //���W��F�Ƃ��ďo��
    Out.BasePos = Pos;
    
    return Out;
}

float4 DrawVertexBuf_PS( VS_OUTPUT3 IN ) : COLOR0
{
    return IN.BasePos;
}

/////////////////////////////////////////////////////////////////////////////////////
//���_���W�o�b�t�@�̃R�s�[

VS_OUTPUT2 CopyVertexBuf_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT2 Out;
  
   Out.Pos = Pos;
   Out.texCoord = Tex + VPBufOffset;
   return Out;
}

float4 CopyVertexBuf_PS(float2 texCoord: TEXCOORD0) : COLOR {
   return tex2Dlod(VertexPosBuf, float4(texCoord, 0, 0));
}


/////////////////////////////////////////////////////////////////////////////////////


float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;


// �I�u�W�F�N�g�`��p�e�N�j�b�N

stateblock PMD_State = stateblock_state
{
    
    DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
    AlphaBlendEnable = false;
    AlphaTestEnable = true;
    
    VertexShader = compile vs_3_0 Velocity_VS(true);
    PixelShader  = compile ps_3_0 Velocity_PS(true);
};

stateblock Accessory_State = stateblock_state
{
    
    DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
    AlphaBlendEnable = false;
    AlphaTestEnable = true;
    
    VertexShader = compile vs_3_0 Velocity_VS(false);
    PixelShader  = compile ps_3_0 Velocity_PS(false);
};

stateblock makeMatrixBufState = stateblock_state
{
    AlphaBlendEnable = false;
    AlphaTestEnable = false;
    VertexShader = compile vs_3_0 DrawMatrixBuf_VS();
    PixelShader  = compile ps_3_0 DrawMatrixBuf_PS();
};


stateblock makeVertexBufState = stateblock_state
{
    DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
    FillMode = POINT;
    CullMode = NONE;
    ZEnable = false;
    ZWriteEnable = false;
    AlphaBlendEnable = false;
    AlphaTestEnable = false;
    
    VertexShader = compile vs_3_0 DrawVertexBuf_VS();
    PixelShader  = compile ps_3_0 DrawVertexBuf_PS();
};

stateblock copyVertexBufState = stateblock_state
{
    AlphaBlendEnable = false;
    AlphaTestEnable = false;
    VertexShader = compile vs_3_0 CopyVertexBuf_VS();
    PixelShader  = compile ps_3_0 CopyVertexBuf_PS();
};

////////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec0_0 < 
    string MMDPass = "object"; 
    bool UseToon = true;
    string Subset = "0"; 
    string Script =
        
        "RenderColorTarget=VertexPosBufTex2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=CopyVertexBuf;"
        
        "RenderColorTarget=MatrixBufTex;"
        "RenderDepthStencilTarget=DepthBufferMB;"
        "Pass=DrawMatrixBuf;"
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        
        "RenderColorTarget=VertexPosBufTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=DrawVertexBuf;"
        
    ;
> {
    pass DrawMatrixBuf < string Script = "Draw=Buffer;";>   { StateBlock = (makeMatrixBufState); }
    pass DrawObject    < string Script = "Draw=Geometry;";> { StateBlock = (PMD_State);  }
    pass DrawVertexBuf < string Script = "Draw=Geometry;";> { StateBlock = (makeVertexBufState); }
    pass CopyVertexBuf < string Script = "Draw=Buffer;";>   { StateBlock = (copyVertexBufState); }
    
}


technique MainTec0_1 < 
    string MMDPass = "object"; 
    bool UseToon = true;
    string Script =
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        
        "RenderColorTarget=VertexPosBufTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=DrawVertexBuf;"
        
    ;
> {
    pass DrawObject    < string Script = "Draw=Geometry;";> { StateBlock = (PMD_State);  }
    pass DrawVertexBuf < string Script = "Draw=Geometry;";> { StateBlock = (makeVertexBufState); }
    
}

technique MainTec1 < 
    string MMDPass = "object"; 
    bool UseToon = false;
    string Script =
        
        "RenderColorTarget=MatrixBufTex;"
        "RenderDepthStencilTarget=DepthBufferMB;"
        "Pass=DrawMatrixBuf;"
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        
    ;
> {
    pass DrawObject    < string Script = "Draw=Geometry;";> { StateBlock = (Accessory_State);  }
    pass DrawMatrixBuf < string Script = "Draw=Buffer;";>   { StateBlock = (makeMatrixBufState); }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec0_0SS < 
    string MMDPass = "object_ss"; 
    bool UseToon = true;
    string Subset = "0"; 
    string Script =
        
        "RenderColorTarget=VertexPosBufTex2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=CopyVertexBuf;"
        
        "RenderColorTarget=MatrixBufTex;"
        "RenderDepthStencilTarget=DepthBufferMB;"
        "Pass=DrawMatrixBuf;"
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        
        "RenderColorTarget=VertexPosBufTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=DrawVertexBuf;"
        
    ;
> {
    pass DrawMatrixBuf < string Script = "Draw=Buffer;";>   { StateBlock = (makeMatrixBufState); }
    pass DrawObject    < string Script = "Draw=Geometry;";> { StateBlock = (PMD_State);  }
    pass DrawVertexBuf < string Script = "Draw=Geometry;";> { StateBlock = (makeVertexBufState); }
    pass CopyVertexBuf < string Script = "Draw=Buffer;";>   { StateBlock = (copyVertexBufState); }
    
}


technique MainTec0_1SS < 
    string MMDPass = "object_ss"; 
    bool UseToon = true;
    string Script =
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        
        "RenderColorTarget=VertexPosBufTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=DrawVertexBuf;"
        
    ;
> {
    pass DrawObject    < string Script = "Draw=Geometry;";> { StateBlock = (PMD_State);  }
    pass DrawVertexBuf < string Script = "Draw=Geometry;";> { StateBlock = (makeVertexBufState); }
    
}

technique MainTec1SS < 
    string MMDPass = "object_ss"; 
    bool UseToon = false;
    string Script =
        
        "RenderColorTarget=MatrixBufTex;"
        "RenderDepthStencilTarget=DepthBufferMB;"
        "Pass=DrawMatrixBuf;"
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        
    ;
> {
    pass DrawObject    < string Script = "Draw=Geometry;";> { StateBlock = (Accessory_State);  }
    pass DrawMatrixBuf < string Script = "Draw=Buffer;";>   { StateBlock = (makeMatrixBufState); }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawObject < string Script = "Draw=Geometry;";> { StateBlock = (PMD_State);  }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// �e�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////

