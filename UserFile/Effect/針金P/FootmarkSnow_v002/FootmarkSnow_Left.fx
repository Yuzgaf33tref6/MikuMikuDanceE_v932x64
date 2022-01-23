////////////////////////////////////////////////////////////////////////////////////////////////
//
//  FootmarkSnow.fx ver0.0.2 ���f���̓����ɍ��킹�Đϐ�̏�ɑ��Ղ����܂�
//  (FootmarkSnow.x�𑫎�{�[���ɕt���Ďg�p���܂�)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
float FootSize = 1.0;                 // ���Ղ̃T�C�Y
float3 FootOffset = {0.0, 0.0, 0.0};  // ���Ոʒu�̍��W�����l
float FootStartDecrement = 300.0;     // ���Տ������J�n���鎞��(�b)
float FootEndDecrement = 360.0;       // ���Տ������������鎞��(�b)

//�����̒������d�v!!
float FootHeight = 1.85;    // ���Ռ��o���荂(����{�[����Y���W������ȉ��̎��Ɍ��o,����ď������������l��ݒ�)
float FootDistance = 0.3;   // ���Ռ��o���苗��(��O�̑��ՂƂ̋���������ȏ�Ȃ�V�K�ǉ�)
float FootRotation = 20.0;  // ���Ռ��o�����]�p(��O�̑��ՂƂ̉�]�p������ȏ�Ȃ�V�K�ǉ�,deg)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
#define TEX_WIDTH    1   // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT 521   // ���W���e�N�X�`���s�N�Z������

float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

// ������̈ʒu�ƌ���
bool flagFloorCtrl : CONTROLOBJECT < string name = "FloorControl.x"; >;
float4x4 FloorCtrlWldMat : CONTROLOBJECT < string name = "FloorControl.x"; >;
static float3 FloorPos = flagFloorCtrl ? FloorCtrlWldMat._41_42_43  : float3(0, 0, 0);
static float3 FloorNormal = flagFloorCtrl ? normalize(FloorCtrlWldMat._21_22_23) : float3(0, 1, 0);

// �X�P�[�����O�Ȃ��̏����[���h�ϊ��s��
static float4x4 FloorWldMat = flagFloorCtrl ? float4x4( normalize(FloorCtrlWldMat._11_12_13), 0,
                                                        normalize(FloorCtrlWldMat._21_22_23), 0,
                                                        normalize(FloorCtrlWldMat._31_32_33), 0,
                                                        FloorCtrlWldMat[3] )
                                            : float4x4( 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 );

// ���[���h�ϊ��s��ŁA�X�P�[�����O�Ȃ��̋t�s����v�Z����B
float4x4 InverseWorldMatrix(float4x4 mat) {
    float3x3 mat3x3_inv = transpose((float3x3)mat);
    float3x3 mat3x3_inv2 = float3x3( normalize(mat3x3_inv[0]),
                                     normalize(mat3x3_inv[1]),
                                     normalize(mat3x3_inv[2]) );
    return float4x4( mat3x3_inv2[0], 0, 
                     mat3x3_inv2[1], 0, 
                     mat3x3_inv2[2], 0, 
                     -mul(mat._41_42_43, mat3x3_inv2), 1 );
}
// �X�P�[�����O�Ȃ��̏����[���h�t�ϊ��s��
static float4x4 InvFloorWldMat = flagFloorCtrl ? InverseWorldMatrix( FloorCtrlWldMat )
                                               : float4x4( 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 );

int Count = TEX_HEIGHT;
int Index;

// ���W�ϊ��s��
float4x4 WorldMatrix     : WORLD;
float4x4 ViewMatrix      : VIEW;
float4x4 ProjMatrix      : PROJECTION;
float4x4 ViewProjMatrix  : VIEWPROJECTION;

float3 LightDirection    : DIRECTION < string Object = "Light"; >;
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float  SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;

// ���C�g�F
#ifndef MIKUMIKUMOVING
float3 LightDiffuse      : DIFFUSE  < string Object = "Light"; >;
float3 LightAmbient      : AMBIENT  < string Object = "Light"; >;
float3 LightSpecular     : SPECULAR < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;
#else
float3 LightDiffuses[MMM_LightCount]   : LIGHTDIFFUSECOLORS;
float3 LightAmbients[MMM_LightCount]   : LIGHTAMBIENTCOLORS;
float3 LightSpeculars[MMM_LightCount]  : LIGHTSPECULARCOLORS;
static float4 DiffuseColor = MaterialDiffuse * float4(LightDiffuses[0]*1.3, 1.0f);
static float3 AmbientColor = MaterialAmbient * LightAmbients[0] + MaterialEmmisive*1.8f;
static float3 SpecularColor = MaterialSpecular * LightSpeculars[0];
#endif

bool use_texture;   // �e�N�X�`���̗L��

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

// ���Ս��W�L�^�p
texture CoordTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmp : register(s3) = sampler_state
{
   Texture = <CoordTex>;
    AddressU  = WRAP;
    AddressV = WRAP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture CoordDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;

// �I�u�W�F�N�g�̃��[���h���W�L�^�p
texture WorldCoord : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format="A32B32G32R32F";
>;
sampler WorldCoordSmp = sampler_state
{
   Texture = <WorldCoord>;
   AddressU = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture WorldCoordDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
    string Format = "D24S8";
>;

texture WorldCoord2 : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format="A32B32G32R32F";
>;
sampler WorldCoordSmp2 = sampler_state
{
   Texture = <WorldCoord2>;
   AddressU = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ԊԊu�v�Z(MMM�ł� ELAPSEDTIME �̓I�t�X�N���[���̗L���ő傫���ς��̂Ŏg��Ȃ�)

float time : Time;

#ifndef MIKUMIKUMOVING

float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

#else

// �X�V�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_R32F" ;
>;
sampler TimeTexSmp = sampler_state
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
static float Dt = clamp(time - tex2D(TimeTexSmp, float2(0.5f,0.5f)).r, 0.001f, 0.1f);

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
// ���W��2D��]
float3 Rotation2D(float3 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.z * sin(rot);
    float z = pos.x * sin(rot) + pos.z * cos(rot);

    return float3(x, pos.y, z);
}


////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
   float4 Pos : POSITION;
   float2 Tex : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}


// 0�t���[���Đ��ō��W��������
float4 InitPos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   float4 Pos;
   if( time < 0.001f ){
      // 0�t���[���Đ��Ń��Z�b�g
      Pos = mul( WorldMatrix[3], InvFloorWldMat );
      Pos = float4(Pos.x, atan2(WorldMatrix._13, WorldMatrix._33), Pos.z, 0.0f);
   }else{
      Pos = tex2D(CoordSmp, Tex);
   }

   return Pos;
}


// ���Ղ̔����E���W�v�Z(xz:���W,y:��]�p,w:�o�ߎ���+1sec)
float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���Ղ̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   if(Pos.w > 1.001f){
      // ���łɔ������Ă��鑫�Ղ͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, FootEndDecrement); // �w�莞�Ԃ𒴂����0
   }

   // ����{�[���̃��[���h���W
   float3 WPos0 = tex2D(WorldCoordSmp2, float2(0.5f, 0.5f)).xyz;
   float4 WPos1 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
   float3 WPos2 = mul( WorldMatrix[3], InvFloorWldMat ).xyz;

   // ����index
   int index = floor( Tex.y*TEX_HEIGHT );
   // �{�[������������ȉ��ō~�����㏸����ƐV���ɑ��Ղ𔭐�������(�O�Ղƃ_�u��ꍇ�͏��O)
   if(round(WPos1.w) == index){
      if(WPos1.y < FootHeight){
         if((WPos1.y-WPos0.y) < 0.0f && (WPos2.y-WPos1.y) > 0.0f){
            float2 texCoord = float2(0.5f/TEX_WIDTH, (index-0.5f)/TEX_HEIGHT);
            float4 Pos0 = tex2D(CoordSmp, texCoord);
            float len = distance(Pos0.xz, WPos1.xz);
            float rot = atan2(WorldMatrix._13, WorldMatrix._33) - atan2(FloorWldMat._13, FloorWldMat._33);
            if(len > FootDistance || abs(Pos0.y-rot) > radians(FootRotation)){
               Pos.x = WPos1.x;
               Pos.y = rot;
               Pos.z = WPos1.z;
               Pos.w = 1.0011f;  // Pos.w>1.001�ő��Ք���
            }
         }
      }
   }

   return Pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�̃��[���h���W�L�^(xyz:���W,w:����������index)

// ���ʂ̒��_�V�F�[�_
float4 WorldCoord_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

// 0�t���[���Đ��Ń��[���h���W��������
float4 InitWorldCoord_PS() : COLOR
{
   float4 Pos;
   if( time < 0.001f ){
      // 0�t���[���Đ��Ń��Z�b�g
      Pos = mul( WorldMatrix[3], InvFloorWldMat );
      Pos.w = 0.0f;
   }else{
      Pos = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
   }

   return Pos;
}

// ���[���h���W���o�b�N�A�b�v
float4 WorldCoord_PS() : COLOR
{
   // �I�u�W�F�N�g�̃��[���h���W
   float4 Pos = mul( WorldMatrix[3], InvFloorWldMat );
   Pos.w = tex2D(WorldCoordSmp2, float2(0.5f, 0.5f)).w;

   return Pos;
}

// 0�t���[���Đ��Ń��[���h���W��������
float4 InitWorldCoord2_PS() : COLOR
{
   float4 Pos;
   if( time < 0.001f ){
      // 0�t���[���Đ��Ń��Z�b�g
      Pos = mul( WorldMatrix[3], InvFloorWldMat );
      Pos.w = 0.0f;
   }else{
      Pos = tex2D(WorldCoordSmp2, float2(0.5f, 0.5f));
   }

   return Pos;
}

// �o�b�N�A�b�v���[���h���W�̃R�s�[&����index
float4 WorldCoord2_PS() : COLOR
{
   float4 WPos0 = tex2D(WorldCoordSmp2, float2(0.5f, 0.5f));
   float4 WPos1 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
   float3 WPos2 = mul( WorldMatrix[3], InvFloorWldMat ).xyz;

   // ����index
   int index = round( WPos0.w );

   // ���������Ղ�index
   if(WPos1.y < FootHeight){
      if((WPos1.y-WPos0.y) < 0.0f && (WPos2.y-WPos1.y) > 0.0f){
         float2 texCoord = float2(0.5f/TEX_WIDTH, (index-0.5f)/TEX_HEIGHT);
         float4 Pos0 = tex2D(CoordSmp, texCoord);
         float len = distance(Pos0.xz, WPos1.xz);
         float rot = atan2(WorldMatrix._13, WorldMatrix._33) - atan2(FloorWldMat._13, FloorWldMat._33);
         if(len > FootDistance || abs(Pos0.y-rot) > radians(FootRotation)){
            WPos1.w += 1.0f;  // �V�K���Ք����ŃC���N�������g
            WPos1.w *= step(WPos1.w, TEX_HEIGHT-1.0f);
         }
      }
   }

   return WPos1;
}


///////////////////////////////////////////////////////////////////////////////////////
// ���Օ`��

struct VS_OUTPUT2 {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex      : TEXCOORD4;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Foot_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0;

   float2 texCoord = float2(0.5f/TEX_WIDTH, (Index+0.5f)/TEX_HEIGHT);

   // ���Ղ̋N�_���W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 1));

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;
   // ���Ղ̑傫��
   Pos.xyz *= FootSize * AcsSi;

   // ���Ղ̉�]
   Pos.xyz += FootOffset;
   Pos.xyz = Rotation2D(Pos.xyz, Pos0.y);

   // ���Ղ̃��[���h���W
   Pos.x += Pos0.x;
   Pos.y += 0.05f;
   Pos.z += Pos0.z;
   Pos.w = 1.0f;
   Pos = mul( Pos, FloorWldMat);
   Pos.xyz *= step(0.001f, etime);

   // �J�����Ƃ̑��Έʒu
   Out.Eye = CameraPosition - Pos.xyz;

   // ���_�@��
   Out.Normal = normalize( mul( Rotation2D(Normal, Pos0.y), (float3x3)FloorWldMat) );

#ifndef MIKUMIKUMOVING
   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );
#else
   // ���_���W
   if (MMM_IsDinamicProjection)
   {
       float4x4 vpmat = mul( ViewMatrix, MMM_DynamicFov(ProjMatrix, length( Out.Eye )) );
       Out.Pos = mul( Pos, vpmat );
   }
   else
   {
       Out.Pos = mul( Pos, ViewProjMatrix );
   }
#endif

   // �o�ߎ��Ԃɑ΂��鑫�Փ��ߓx
   float alpha = smoothstep(-FootEndDecrement, -FootStartDecrement, -etime);

   // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
   Out.Color.rgb = AmbientColor + max(0, DiffuseColor.rgb * dot( Out.Normal, -LightDirection ));
   Out.Color.a = DiffuseColor.a * alpha * step(0.001f, etime);
   Out.Color = saturate( Out.Color );

   // �e�N�X�`�����W
   Out.Tex = Tex;

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Foot_PS( VS_OUTPUT2 IN ) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;
    if ( use_texture ) {
        // �e�N�X�`���K�p
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }

    // �X�y�L�����K�p
    Color.rgb += Specular;

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object"; string Subset = "0";
   string Script = 
       "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=InitPos;"
       "RenderColorTarget0=WorldCoord;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=InitWorldCoord;"
       "RenderColorTarget0=WorldCoord2;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=InitWorldCoord2;"
       "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdatePos;"
       "RenderColorTarget0=WorldCoord2;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=UpdateWorldCoord2;"
       "RenderColorTarget0=WorldCoord;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=UpdateWorldCoord;"
       #ifdef MIKUMIKUMOVING
       "RenderColorTarget0=TimeTex;"
           "RenderDepthStencilTarget=TimeDepthBuffer;"
           "Pass=UpdateTime;"
       #endif
       "RenderColorTarget0=;"
	   "RenderDepthStencilTarget=;"
           "LoopByCount=Count;"
           "LoopGetIndex=Index;"
               "Pass=DrawObject;"
           "LoopEnd=;";
>{
   pass InitPos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 Common_VS();
       PixelShader  = compile ps_2_0 InitPos_PS();
   }
   pass InitWorldCoord < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 InitWorldCoord_PS();
   }
   pass InitWorldCoord2 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 InitWorldCoord2_PS();
   }
   pass UpdatePos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 Common_VS();
       PixelShader  = compile ps_2_0 UpdatePos_PS();
   }
   pass UpdateWorldCoord2 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord2_PS();
   }
   pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS();
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
       VertexShader = compile vs_3_0 Foot_VS();
       PixelShader  = compile ps_3_0 Foot_PS();
   }
}

technique MainTec2 < string MMDPass = "object"; string Subset = "1-1000";
   string Script = 
           "LoopByCount=Count;"
           "LoopGetIndex=Index;"
               "Pass=DrawObject;"
           "LoopEnd=;";
>{
   pass DrawObject {
       VertexShader = compile vs_3_0 Foot_VS();
       PixelShader  = compile ps_3_0 Foot_PS();
   }
}

