////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Line.fx ��Ԙc�݃G�t�F�N�g(���C���G�t�F�N�g,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���C���ߓ_���ݒ�
#define UNIT_COUNT   2   // �����̐��~1024 ����x�ɕ`��o���郉�C���ߓ_�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

// ���C���ߓ_�p�����[�^�ݒ�
float LineThick <
   string UIName = "������";
   string UIHelp = "���C���̑���";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );

float LineThick0 <
   string UIName = "����������";
   string UIHelp = "���C���̏�������";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 0.5 );

float LineScaleUp <
   string UIName = "�����ω�";
   string UIHelp = "���C��������̊g��x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 0.3 );

float LineLife <
   string UIName = "������";
   string UIHelp = "���C���ߓ_�̎���(�b)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 30.0;
> = float( 4.0 );

float LineDecrement <
   string UIName = "��������";
   string UIHelp = "���C���ߓ_���������J�n���鎞��(0.0�`1.0:�������Ƃ̔�)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.2 );

float DistRandomRate <
   string UIName = "�h�炬�x";
   string UIHelp = "���C���ׂ̍����h�炬�x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 1.0 );

float DistRandomFreqU <
   string UIName = "U�h���g��";
   string UIHelp = "���C���i�s�����ׂ̍����h�炬���g��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 4.0 );

float DistRandomFreqV <
   string UIName = "V�h���g��";
   string UIHelp = "���C�����p�����ׂ̍����h�炬���g��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );


// �I�v�V�����̃R���g���[���t�@�C����
#define BackgroundCtrlFileName  "BackgroundControl.x" // �w�i���W�R���g���[���t�@�C����
#define TimrCtrlFileName        "TimeControl.x"       // ���Ԑ���R���g���[���t�@�C����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define RandomFileName "Random.bmp" // �z�u��������t�@�C����
#define TEX_WIDTH_A  4            // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH    UNIT_COUNT   // �e�N�X�`���s�N�Z����
#define TEX_HEIGHT   1024         // �e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

// �I�v�V�����̃R���g���[���p�����[�^
bool IsBack : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;
float4x4 BackMat : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;

float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// ���W�ϊ��s��
float4x4 WorldMatrix : WORLD;
float4x4 ViewMatrix  : VIEW;
float4x4 ProjMatrix  : PROJECTION;

// �m�[�}���}�b�v�e�N�X�`��
texture2D NormalMapTex <
    string ResourceName = "NormalMapSample.png";
    int MipLevels = 0;
>;
sampler NormalMapSamp = sampler_state {
    texture = <NormalMapTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

// ���C�����W�L�^�p
texture CoordTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmp : register(s3) = sampler_state
{
   Texture = <CoordTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture CoordDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;

// 1�t���[���O�̍��W�L�^�p
texture CoordTexOld : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmpOld = sampler_state
{
   Texture = <CoordTexOld>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ԊԊu�ݒ�

// ���Ԑ���R���g���[���p�����[�^
bool IsTimeCtrl : CONTROLOBJECT < string name = TimrCtrlFileName; >;
float TimeSi : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Si"; >;
float TimeTr : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Tr"; >;
static bool TimeSync = IsTimeCtrl ? ((TimeSi>0.001f) ? true : false) : true;
static float TimeRate = IsTimeCtrl ? TimeTr : 1.0f;

float time1 : Time;
float time2 : Time < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;

#ifndef MIKUMIKUMOVING

float elapsed_time : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = (TimeSync ? clamp(elapsed_time, 0.001f, 0.1f) : clamp(elapsed_time2, 0.0f, 0.1f)) * TimeRate;

#else

// �X�V�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_R32F" ;
>;
sampler TimeTexSmp : register(s1) = sampler_state
{
   Texture = <TimeTex>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture TimeDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_D24S8";
>;
static float Dt = clamp(time - tex2D(TimeTexSmp, float2(0.5f, 0.5f)).r, 0.0f, 0.1f) * TimeRate;

float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   return float4(time, 0, 0, 1);
}

#endif


////////////////////////////////////////////////////////////////////////////////////////////////

// �w�i�A�N�Z��̃��[���h���W��MMD���[���h���W
float3 InvBackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        pos = mul( float4(pos, 1), float4x4( BackMat[0]*scaling,
                                             BackMat[1]*scaling,
                                             BackMat[2]*scaling,
                                             BackMat[3] )      ).xyz;
    }
    return pos;
}

// MMD���[���h���W���w�i�A�N�Z��̃��[���h���W
float3 BackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        float3x3 mat3x3_inv = transpose((float3x3)BackMat) * scaling;
        pos = mul( float4(pos, 1), float4x4( mat3x3_inv[0], 0, 
                                             mat3x3_inv[1], 0, 
                                             mat3x3_inv[2], 0, 
                                            -mul(BackMat._41_42_43,mat3x3_inv), 1 ) ).xyz;
    }
    return pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
   float4 Pos : POSITION;
   float2 Tex : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////
// �����W�l��1�t���[���O�̍��W�ɃR�s�[

float4 CopyPos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   float4 Pos = tex2D(CoordSmp, Tex);
   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////
// ���C���ߓ_�̒ǉ��E���W�X�V�v�Z(xyz:���W,w:�o�ߎ���+1sec,w�͍X�V����1�ɏ���������邽��+1s����X�^�[�g)

float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���C���ߓ_�̍��W
   float4 Pos;

   // ���݂̃I�u�W�F�N�g���W
   float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

   // 1�t���[���O�̃I�u�W�F�N�g���W
   float3 WPos0 = tex2D(CoordSmpOld, float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT)).xyz;

   // ���C���ߓ_�C���f�b�N�X
   int i = floor( Tex.x*TEX_WIDTH );
   int j = floor( Tex.y*TEX_HEIGHT );
   int index = i*TEX_HEIGHT + j;

   if( distance(WPos1, WPos0) > 0.001f ){
      if(index == 0){
         Pos = float4( WPos1, 1.0011f );  // Pos.w>1.001�Ń��C���ߓ_�ǉ�
      }else{
         j--;
         if(j<0){
            i--;
            j = TEX_HEIGHT - 1;
         }
         Pos = tex2D(CoordSmpOld, float2((0.5f+i)/TEX_WIDTH, (0.5f+j)/TEX_HEIGHT));
         if(Pos.w > 1.001f){
            // ���łɒǉ����Ă��郉�C���ߓ_�͌o�ߎ��Ԃ�i�߂�
            Pos.w += Dt;
            Pos.w *= step(Pos.w-1.0f, LineLife); // �w�莞�Ԃ𒴂����0(���C���ߓ_����)
         }
      }
   }else{
      Pos = tex2D(CoordSmp, Tex);
      if(Pos.w > 1.001f){
         // ���łɒǉ����Ă��郉�C���ߓ_�͌o�ߎ��Ԃ�i�߂�
         Pos.w += Dt;
         Pos.w *= step(Pos.w-1.0f, LineLife); // �w�莞�Ԃ𒴂����0(���C���ߓ_����)
      }
   }

   // 0�t���[���Đ��Ń��C���ߓ_������
   if(time < 0.001f) Pos = float4(WorldMatrix._41_42_43, 0.0f);

   return Pos;
}


///////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�
#ifndef MIKUMIKUMOVING
    #define GET_PMAT(p) (ProjMatrix)
#else
    #define GET_PMAT(p) (MMM_IsDinamicProjection ? MMM_DynamicFov(ProjMatrix, length(p.xyz)) : ProjMatrix)
#endif


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
    float2 Tex       : TEXCOORD0;   // �e�N�X�`��
    float2 Dir       : TEXCOORD1;   // �i�s����
    float4 VPos      : TEXCOORD2;   // �r���[���W
    float4 Color     : COLOR0;      // ���C���ߓ_�̐F
};

// ���_�V�F�[�_
VS_OUTPUT2 Line_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out = (VS_OUTPUT2)0;

   int i1 = RepertIndex;
   int j1 = round( Pos.x * 100.0f );
   int Index = i1 * TEX_HEIGHT + j1;
   float2 texCoord = float2((i1+0.5f)/TEX_WIDTH, (j1+0.5f)/TEX_HEIGHT);

   int i0 = i1;
   int j0 = j1 - 1;
   if(j0 < 0){ i0--; j0=TEX_HEIGHT-1; }
   float2 texCoordPrev = float2((i0+0.5f)/TEX_WIDTH, (j0+0.5f)/TEX_HEIGHT);

   int i2 = i1;
   int j2 = j1 + 1;
   if(j2 > TEX_HEIGHT-1){ i2++; j2=0; }
   float2 texCoordNext = float2((i2+0.5f)/TEX_WIDTH, (j2+0.5f)/TEX_HEIGHT);

   // ���C���ߓ_�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoordPrev, 0, 0));
   float4 Pos1 = tex2Dlod(CoordSmp, float4(texCoord,     0, 0));
   float4 Pos2 = tex2Dlod(CoordSmp, float4(texCoordNext, 0, 0));

   // �o�ߎ���
   float etime = Pos1.w - 1.0f;
   float etimeNext = Pos2.w;

   // �o�ߎ��Ԃɑ΂��郉�C���ߓ_�g��x
   float scale = lerp(LineThick0*0.5f, LineThick*0.5f + LineScaleUp * sqrt(etime), smoothstep(0.0f, 0.5f, etime));

   // ���C���ߓ_�̃��[���h���W
   Pos0 = float4(InvBackWorldCoord(Pos0.xyz), 1.0f);
   Pos1 = float4(InvBackWorldCoord(Pos1.xyz), 1.0f);
   Pos2 = float4(InvBackWorldCoord(Pos2.xyz), 1.0f);

   // ���C���ߓ_�̃r���[���W
   float4 VPos0 = mul( Pos0, ViewMatrix );
   float4 VPos1 = mul( Pos1, ViewMatrix );
   float4 VPos2 = mul( Pos2, ViewMatrix );

   // ���C���̑O�����
   float2 prevVec = normalize( VPos0.xy - VPos1.xy );
   float2 nextVec = normalize( VPos2.xy - VPos1.xy );
   if(Index == 0) prevVec = -nextVec;
   if(etimeNext <= 1.0f) nextVec = -prevVec;

   // ���_�̃r���[���W
   float2 vec1 = (Pos.y > 0) ? float2(prevVec.y, -prevVec.x) : float2(-prevVec.y, prevVec.x);
   float2 vec2 = (Pos.y > 0) ? float2(-nextVec.y, nextVec.x) : float2(nextVec.y, -nextVec.x);
   float2 vec =  normalize(vec1+vec2) / max( sqrt((dot(vec1,vec2) + 1.0f) * 0.5f), 0.5f );
   Out.VPos.xyz = VPos1.xyz + float3(vec * scale * AcsSi*0.1f, 0.0f);
   Out.VPos.w = 1.0f;

   // �i�s�����x�N�g��
   Out.Dir = normalize( (Pos.y > 0) ? float2(-vec.y, vec.x) : float2(vec.y, -vec.x) );

   // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Out.VPos, GET_PMAT(Out.VPos) );

   // ���C���ߓ_�̏�Z�F
   float alpha = step(0.001f, etime) * smoothstep(-LineLife, -LineLife*LineDecrement, -etime) * AcsTr;
   Out.Color = float4(0, 0, 0, alpha);

   // �e�N�X�`�����W
   Out.Tex = float2(-etime, sign(Pos.y));

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Line_PS( VS_OUTPUT2 IN ) : COLOR0
{
    // �������ʂ͕`�悵�Ȃ�
    clip( IN.Color.a - 0.005f );

    // �@��(0�`1�ɂȂ�悤�␳)
    float s = 1.0f - abs(IN.Tex.y);
    float3 Normal = float3(IN.Dir * sin(0.5f*PAI*s),  -cos(0.5f*PAI*s));
    float3 randNormal = tex2D(NormalMapSamp, float2(IN.Tex.x*DistRandomFreqU, (IN.Tex.y+1.0f)*0.5f*DistRandomFreqV)).rgb - 0.5f;
    Normal += DistRandomRate * randNormal;
    Normal = normalize(Normal);
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, IN.Color.a);

    // �[�x(0�`DEPTH_FAR��0.5�`1.0�ɐ��K��)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=CoordTexOld;"
            "RenderDepthStencilTarget=CoordDepthBuffer;"
            "Pass=CopyPos;"
        "RenderColorTarget0=CoordTex;"
            "RenderDepthStencilTarget=CoordDepthBuffer;"
            "Pass=UpdatePos;"
       #ifdef MIKUMIKUMOVING
       "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
       #endif
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;"
        ;
>{
    pass CopyPos < string Script = "Draw=Buffer;";>{
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 CopyPos_PS();
    }
    pass UpdatePos < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 UpdatePos_PS();
    }
    #ifdef MIKUMIKUMOVING
    pass UpdateTime < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_1_1 UpdateTime_VS();
        PixelShader  = compile ps_2_0 UpdateTime_PS();
    }
    #endif
    pass DrawObject {
        ZENABLE = TRUE;
        ZWRITEENABLE = FALSE;
        ALPHABLENDENABLE = FALSE;
        VertexShader = compile vs_3_0 Line_VS();
        PixelShader  = compile ps_3_0 Line_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////
// �G�b�W�E�n�ʉe�EZPlot�͕\�����Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot";> { }

