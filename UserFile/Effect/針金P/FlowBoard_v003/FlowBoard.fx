////////////////////////////////////////////////////////////////////////////////////////////////
//
//  FlowBoard.fx ver0.0.3 �Ȑ���Ƀ{�[�h��z�u���ĂȂ߂炩�ɗ����܂�
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �K���ݒ�
#define TexFile  "sample.png"   // �{�[�h�ɓ\��t����e�N�X�`���t�@�C����
int TexCount = 13;              // �e�N�X�`����ސ�
int EmpCount = 2;               // �{�[�h�z�񖖔��̋󔒐�

// �K�v�ɉ����Đݒ�
float ObjSize = 1.0;            // �{�[�h�̊�T�C�Y
float IntervalMaxRate = 10.0;   // �{�[�h�z��Ԋu�̍ő�{��
float3 ColorKey = {0.0, 0.0, 0.0}; // �J���[�L�[�̐F(RGB�w��)
float Threshold = 0.0;          // �J���[�L�[��臒l


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define PAI 3.14159265f   // ��

float3 BoneSP1 : CONTROLOBJECT < string name = "(self)"; string item = "��_1"; >;
float3 BoneSP2 : CONTROLOBJECT < string name = "(self)"; string item = "��_2"; >;
float3 BoneSP3 : CONTROLOBJECT < string name = "(self)"; string item = "��_3"; >;
float3 BoneSP4 : CONTROLOBJECT < string name = "(self)"; string item = "��_4"; >;
float3 BoneSP5 : CONTROLOBJECT < string name = "(self)"; string item = "��_5"; >;
float3 BoneSP6 : CONTROLOBJECT < string name = "(self)"; string item = "��_6"; >;
float3 BoneSize1 : CONTROLOBJECT < string name = "(self)"; string item = "�T�C�Y1"; >;
float3 BoneSize2 : CONTROLOBJECT < string name = "(self)"; string item = "�T�C�Y2"; >;
float3 BoneSize3 : CONTROLOBJECT < string name = "(self)"; string item = "�T�C�Y3"; >;
float3 BoneSize4 : CONTROLOBJECT < string name = "(self)"; string item = "�T�C�Y4"; >;
float3 BoneSize5 : CONTROLOBJECT < string name = "(self)"; string item = "�T�C�Y5"; >;
float3 BoneSize6 : CONTROLOBJECT < string name = "(self)"; string item = "�T�C�Y6"; >;
float MorphON : CONTROLOBJECT < string name = "(self)"; string item = "�i�sON"; >;
float MorphStop : CONTROLOBJECT < string name = "(self)"; string item = "��~"; >;
float MorphInit : CONTROLOBJECT < string name = "(self)"; string item = "�����ʒu"; >;
float MorphIntvlB : CONTROLOBJECT < string name = "(self)"; string item = "�Ԋu�g"; >;
float MorphIntvlS : CONTROLOBJECT < string name = "(self)"; string item = "�Ԋu��"; >;
float MorphVel : CONTROLOBJECT < string name = "(self)"; string item = "���x"; >;
float MorphAlpha : CONTROLOBJECT < string name = "(self)"; string item = "�S�̓���"; >;
float MorphRot : CONTROLOBJECT < string name = "(self)"; string item = "��]�p"; >;
float MorphVelRot : CONTROLOBJECT < string name = "(self)"; string item = "�ړ���]"; >;
float MorphAlphaS : CONTROLOBJECT < string name = "(self)"; string item = "�J�n����"; >;
float MorphAlphaE : CONTROLOBJECT < string name = "(self)"; string item = "�I������"; >;

static int TCount = 256 - 256%(TexCount+EmpCount);
static float SpSize1 = length( BoneSP1 - BoneSize1 )*0.2f;
static float SpSize2 = length( BoneSP2 - BoneSize2 )*0.2f;
static float SpSize3 = length( BoneSP3 - BoneSize3 )*0.2f;
static float SpSize4 = length( BoneSP4 - BoneSize4 )*0.2f;
static float SpSize5 = length( BoneSP5 - BoneSize5 )*0.2f;
static float SpSize6 = length( BoneSP6 - BoneSize6 )*0.2f;
static float ObjInterval = 3.0f*(1.0f - MorphIntvlS + IntervalMaxRate * MorphIntvlB);
static float ObjRot = 2.0f * PAI * MorphRot;

float time : TIME;

// ���W�ϊ��s��
float4x4 WorldMatrix        : WORLD;
float4x4 ViewMatrix         : VIEW;
float4x4 ProjMatrix         : PROJECTION;
float4x4 ViewProjMatrix     : VIEWPROJECTION;
float4x4 ViewMatrixInverse  : VIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// �{�[�h�ɓ\��e�N�X�`��
texture2D ParticleTex <
    string ResourceName = TexFile;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �o�ߎ��ԋL�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_A32B32G32R32F" ;
>;
sampler TimeSmp = sampler_state
{
   Texture = <TimeTex>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture TimeTexDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
   string Format = "D24S8";
>;
float4 TimeTexArray[1] : TEXTUREVALUE <
   string TextureName = "TimeTex";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// B-�X�v���C���Ȑ��̌v�Z

// B-�X�v���C����{��
float Spline1(float x0, float x1, float x2, float x3, float u)
{
   float u2 = u*u;
   float u3 = u2*u;
   float s = u3*x3 + (-3.0f*u3+3.0f*u2+3.0f*u+1.0f)*x2
           + (3.0f*u3-6.0f*u2+4.0f)*x1 + (1.0f-u)*(1.0f-u)*(1.0f-u)*x0;
   return (s/6.0f);
}

// �O������B-�X�v���C���Ȑ�
float3 Spline3(float3 p0, float3 p1, float3 p2, float3 p3, float u)
{
   float3 pos;
   pos.x = Spline1(p0.x, p1.x, p2.x, p3.x, u);
   pos.y = Spline1(p0.y, p1.y, p2.y, p3.y, u);
   pos.z = Spline1(p0.z, p1.z, p2.z, p3.z, u);
   return pos;
}

// B-�X�v���C����{��(��K����)
float DiffSpline1(float x0, float x1, float x2, float x3, float u)
{
   float u2 = u*u;
   float s = u2*x3 + (-3.0f*u2+2.0f*u+1.0f)*x2
           + (3.0f*u2-4.0f*u)*x1 - (1.0f-u)*(1.0f-u)*x0;
   return (s*0.5f);
}

// �O������B-�X�v���C���Ȑ�(��K����)
float3 DiffSpline3(float3 p0, float3 p1, float3 p2, float3 p3, float u)
{
   float3 pos;
   pos.x = DiffSpline1(p0.x, p1.x, p2.x, p3.x, u);
   pos.y = DiffSpline1(p0.y, p1.y, p2.y, p3.y, u);
   pos.z = DiffSpline1(p0.z, p1.z, p2.z, p3.z, u);
   return pos;
}

int DivCount = 20; // �Ȑ������v�Z�̂��߂̕�����

// ��ԋȐ������̌v�Z
float CalcSplineLength(float3 p0, float3 p1, float3 p2, float3 p3)
{
   float du = 1.0f / (float)DivCount;
   float3 pp0 = Spline3(p0, p1, p2, p3, 0.0f);
   float len = 0.0f;
   for(int i=1; i<=DivCount; i++){
      float u = du * (float)i;
      float3 pp1 = Spline3(p0, p1, p2, p3, u);
      len += length(pp1 - pp0);
      pp0 = pp1;
   }
   return len;
}

// ���[�̕�Ԓl
static float3 BoneSP0 = BoneSP1 * 2.0f - BoneSP2;
static float3 BoneSP7 = BoneSP6 * 2.0f - BoneSP5;
static float SpSize0 = SpSize1 * 2.0f - SpSize2;
static float SpSize7 = SpSize6 * 2.0f - SpSize5;

// �e��Ԃ̋Ȑ�����
static float spLen2 = CalcSplineLength(BoneSP0, BoneSP1, BoneSP2, BoneSP3);
static float spLen3 = CalcSplineLength(BoneSP1, BoneSP2, BoneSP3, BoneSP4) + spLen2;
static float spLen4 = CalcSplineLength(BoneSP2, BoneSP3, BoneSP4, BoneSP5) + spLen3;
static float spLen5 = CalcSplineLength(BoneSP3, BoneSP4, BoneSP5, BoneSP6) + spLen4;
static float spLen6 = CalcSplineLength(BoneSP4, BoneSP5, BoneSP6, BoneSP7) + spLen5;

// �e��Ԃ̋Ȑ������ɑ΂�����W�ʒu
float4 Spline3L(float3 p0, float3 p1, float3 p2, float3 p3, float L)
{
   float du = 1.0f / (float)DivCount;
   float u = 0.0f;
   float len;
   float3 pp0 = Spline3(p0, p1, p2, p3, 0.0f);

   while(0 < L){
      u += du;
      float3 pp1 = Spline3(p0, p1, p2, p3, u);
      len = length(pp1 - pp0);
      L -= len;
      pp0 = pp1;
   }

   u += du * L / len;
   pp0 = Spline3(p0, p1, p2, p3, u);

   return float4(pp0, u);
}

struct SPDAT {
   float3 Pos0;  // ���W�ʒu
   float3 Pos1;  // �i�s�����̍��W
   float Size;   // �T�C�Y
};

// �Ȑ������ɑ΂�����W�ʒu,�i�s����,�T�C�Y
SPDAT Spline(float L)
{
   SPDAT Out;
   Out.Pos0 = float3( 0.0f, 0.0f, 0.0f );
   Out.Pos1 = float3( 1.0f, 0.0f, 0.0f );
   Out.Size = 1.0;

   float3 b0,b1,b2,b3;
   float s0,s1,s2,s3;
   float dL;

   if( L < 0.0f){
      return Out;
   }else if( L < spLen2 ){
      b0 = BoneSP0; b1 = BoneSP1; b2 = BoneSP2; b3 = BoneSP3;
      s0 = SpSize0; s1 = SpSize1; s2 = SpSize2; s3 = SpSize3;
      dL = L;
   }else if( L < spLen3 ){
      b0 = BoneSP1; b1 = BoneSP2; b2 = BoneSP3; b3 = BoneSP4;
      s0 = SpSize1; s1 = SpSize2; s2 = SpSize3; s3 = SpSize4;
      dL = L - spLen2;
   }else if( L < spLen4 ){
      b0 = BoneSP2; b1 = BoneSP3; b2 = BoneSP4; b3 = BoneSP5;
      s0 = SpSize2; s1 = SpSize3; s2 = SpSize4; s3 = SpSize5;
      dL = L-spLen3;
   }else if( L < spLen5 ){
      b0 = BoneSP3; b1 = BoneSP4; b2 = BoneSP5; b3 = BoneSP6;
      s0 = SpSize3; s1 = SpSize4; s2 = SpSize5; s3 = SpSize6;
      dL = L - spLen4;
   }else if( L <= spLen6+ObjInterval ){
      b0 = BoneSP4; b1 = BoneSP5; b2 = BoneSP6; b3 = BoneSP7;
      s0 = SpSize4; s1 = SpSize5; s2 = SpSize6; s3 = SpSize7;
      dL = L - spLen5;
   }else{
      return Out;
   }

   float4 pos = Spline3L(b0, b1, b2,b3, dL);
   Out.Pos0 = pos.xyz;
   Out.Pos1 = pos.xyz + DiffSpline3(b0, b1, b2,b3, pos.w);
   Out.Size = Spline1(s0, s1, s2, s3, pos.w);

   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �o�ߎ��ԋL�^

float4 Time_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 Time_PS() : COLOR
{
   float4 val = tex2D(TimeSmp, float2(0.5f, 0.5f));
   float t = val.r;
   float dt = (time - val.g) * step(MorphStop, 0.5f);

   if(time < 0.01f || MorphON < 0.5f){
      t = 0.0f;
   }else{
      t += dt;
   }
   val.r = t;

   return float4(t, time, 0, 1);
}

///////////////////////////////////////////////////////////////////////////////////////
// �{�[�h�z��`��
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 Color      : COLOR0;      // �{�[�h�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Obj_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, int index: _INDEX)
{
   VS_OUTPUT2 Out;

   // �C���f�b�N�X���{�[�h�̃��[�J�����W����(pmd�f�[�^�z��ɗR��)
   int Index = index % 4;
   if(Index == 0){
      Pos = float4(1.0f, 1.0f, 0.0f, 1.0f);
   }else if(Index == 1){
      Pos = float4(1.0f, -1.0f, 0.0f, 1.0f);
   }else if(Index == 2){
      Pos = float4(-1.0f, -1.0f, 0.0f, 1.0f);
   }else{
      Pos = float4(-1.0f, 1.0f, 0.0f, 1.0f);
   }

   // �{�[�h�̃C���f�b�N�X
   Index = index / 4;
   int texIndex = round( fmod((float)Index, float(TexCount + EmpCount)) );  // Index%(TexCount+EmpCount)�ł͉��̂�����

   // �{�[�h�̋Ȑ�����
   float L = 0.0;
   if(Index < TCount){
      float t = TimeTexArray[0].r; // �o�ߎ���
      L = spLen6*(1.0f-MorphInit) - 0.1f - ObjInterval*Index + MorphVel*50.0f*t;
      L %= ObjInterval * TCount;
   }

   // �X�v���C���Ȑ���̃{�[�h�̈ʒu,�i�s����,�T�C�Y
   SPDAT SpDat = Spline( L );

   // �ړ������̉�]�p
   float vRot = 0.0f;
   if(MorphVelRot > 0.5f){
      float4 PrjPos0 = mul( float4(SpDat.Pos0, 1.0f), ViewProjMatrix );
      float4 PrjPos1 = mul( float4(SpDat.Pos1, 1.0f), ViewProjMatrix );
      vRot = atan2(PrjPos1.y/PrjPos1.w-PrjPos0.y/PrjPos0.w, PrjPos1.x/PrjPos1.w-PrjPos0.x/PrjPos0.w);
   }

   // �{�[�h�̑傫��
   Pos.xyz *= ObjSize * SpDat.Size;

   // �{�[�h�̉�]
   Pos.xy = Rotation2D(Pos.xy, ObjRot+vRot);

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // �{�[�h�̃��[���h���W�ϊ�
   Pos.xyz += SpDat.Pos0;

#ifndef MIKUMIKUMOVING
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );
#else
    // ���_���W
    if (MMM_IsDinamicProjection)
    {
        float4x4 vpmat = mul( ViewMatrix, MMM_DynamicFov(ProjMatrix, length( CameraPosition - Pos.xyz )) );
        Out.Pos = mul( Pos, vpmat );
    }
    else
    {
        Out.Pos = mul( Pos, ViewProjMatrix );
    }
#endif

   // �\���ʒu�ɑ΂���{�[�h���ߓx
   float alpha = (1.0f-MorphAlpha) * smoothstep(0.0f, spLen6*MorphAlphaS, L)
                       * smoothstep(-spLen6, -spLen6*(1.0f-MorphAlphaE), -L);
   alpha *= step( texIndex, TexCount );

   // �{�[�h�̐F
   Out.Color = float4( 1.0f, 1.0f, 1.0f, alpha );

   // �e�N�X�`�����W
   Tex.x = (Tex.x + (float)texIndex ) / (float)TexCount;
   Out.Tex = Tex;

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Obj_PS( VS_OUTPUT2 IN ) : COLOR0
{
   // �e�N�X�`���̐F
   float4 Color = tex2D( ParticleSamp, IN.Tex );
   Color.a *= IN.Color.a;

   // �J���[�L�[����
   float len = length(Color.rgb - ColorKey) + 0.0001f;
   if(len < Threshold) Color.a = 0.0f;

   clip(Color.a - 0.003);

   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object";
   string Script = 
       "RenderColorTarget0=TimeTex;"
	    "RenderDepthStencilTarget=TimeTexDepthBuffer;"
	    "Pass=UpdateTime;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "Pass=DrawObject;";
>{
   pass UpdateTime < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Time_VS();
       PixelShader  = compile ps_3_0 Time_PS();
   }
   pass DrawObject {
       VertexShader = compile vs_3_0 Obj_VS();
       PixelShader  = compile ps_3_0 Obj_PS();
   }
}

technique MainTec2 < string MMDPass = "object_ss"; >{ }

// �G�b�W,�n�ʉe�͔�\���ɂ���
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

