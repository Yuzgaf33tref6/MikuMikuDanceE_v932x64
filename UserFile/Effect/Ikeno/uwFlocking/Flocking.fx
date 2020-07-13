////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Flocking.fx ver0.0.8  �t���b�L���O�A���S���Y�����g�����Q��s������
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

int ObjCount = 200;  // ���f��������(�ő�1024, Flocking_Obj.fx�������l��ݒ肷��K�v����)

float WideViewRadius = 15.0;     // ���F�G���A���a(�傫������Ƒ��̃��j�b�g��������₷���Ȃ�)
float WideViewAngle = 60.0;      // ���F�G���A�p�x(0�`180)(�傫������Ƒ��̃��j�b�g��������₷���Ȃ�)
float CohesionFactor = 5.0;      // �����x(�傫������Ƌߗ׃��j�b�g�ǂ�������ɂ܂Ƃ܂�₷���Ȃ�)
float AlignmentFactor = 20.0;    // ����x(�傫������Ƌߗ׃��j�b�g�ǂ��������������������₷���Ȃ�)
float SeparationFactor = 100.0;  // �����x(�傫������Ɨאڃ��j�b�g�Ƃ̏Փˉ��x���傫���Ȃ�)
float SeparationLength = 10.0;   // �������苗��(�傫������Ɨאڃ��j�b�g�Ƃ̏Փˉ���s�����Ƃ�₷���Ȃ�)
float DrivingForceFactor = 50.0; // ���i��(�傫������ƈړ��X�s�[�h�������Ȃ�)
float ResistanceFactor = 2.0;    // ��R��(�傫������ƈړ��X�s�[�h���������₷���Ȃ�)
float VerticalAngleLimit = 30.0; // �����ړ������p(0�`90)(�傫������Ə㉺�����̈ړ��������ɂȂ�)
float PotentialOutside = 60.0;   // �ړ������O������(�傫������ƈړ��͈͂��L���Ȃ�)
float PotentialFloor = 10.0;     // �ړ��������ʍ���(�傫������Ə��ɋ߂Â������ɍ����ʒu�ŉ���s�����Ƃ�)
float PotentialCiel = 60.0;      // �ړ������V�䍂��(�傫������Ƃ�荂���ʒu�܂ňړ�����悤�ɂȂ�)

#define ArrangeFileName "ArrangeData.png" // �����z�u���摜�t�@�C����(TexTableEdit���8pixel*1024pixel�̉摜�Ƃ��č쐬)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////

float3 AcsPos : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
float AcsTr   : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi   : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static bool InitFlag = AcsTr > 0.0f ? true : false;
static float OutsideLength = PotentialOutside * AcsSi * 0.1f;
static float PotentialBottom = PotentialFloor + AcsPos.y;
static float PotentialTop = PotentialBottom + (PotentialCiel - PotentialFloor) * AcsSi * 0.1f;

static float WideViewCosA = cos( radians(WideViewAngle) );
static float VAngLimit = radians(VerticalAngleLimit);

#define ARRANGE_TEX_WIDTH  8       // �z�u�e�N�X�`���s�N�Z����
#define ARRANGE_TEX_HEIGHT 1024    // �����z�u���摜�t�@�C���̃s�N�Z������
#define TEX_WIDTH_W   4            // ���j�b�g�z�u�ϊ��s��e�N�X�`���s�N�Z����
#define TEX_WIDTH     1            // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z����
#define TEX_HEIGHT 1024            // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z������

// �z�u���e�N�X�`��
texture2D ArrangeTex <
    string ResourceName = ArrangeFileName;
>;
sampler ArrangeSmp = sampler_state{
    texture = <ArrangeTex>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
};

// 1�t���[���O�̍��W�L�^�p
texture CoordTexOld : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler SmpCoordOld = sampler_state
{
   Texture = <CoordTexOld>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���݂̍��W�L�^�p
shared texture Flocking_CoordTex : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler Flocking_SmpCoord = sampler_state
{
   Texture = <Flocking_CoordTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���x�L�^�p
shared texture Flocking_VelocityTex : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler Flocking_SmpVelocity = sampler_state
{
   Texture = <Flocking_VelocityTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// �|�e���V�����L�^�p
shared texture Flocking_PotentialTex : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler Flocking_SmpPotential = sampler_state
{
   Texture = <Flocking_PotentialTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���ʂ̐[�x�X�e���V���o�b�t�@
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
    string Format = "D24S8";
>;

// ���j�b�g�z�u�ϊ��s��L�^�p
shared texture Flocking_TransMatrixTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH_W;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture TransMatrixDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH_W;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ԊԊu�v�Z(MMM�ł� ELAPSEDTIME �̓I�t�X�N���[���̗L���ő傫���ς��̂Ŏg��Ȃ�)

float time : Time;
//float elapsed_time : ELAPSEDTIME;
//static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

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
    string Format = "D24S8";
>;
static float Dt = clamp(time-tex2D(TimeTexSmp, float2(0.5f,0.5f)).r, 0.001f, 0.1f);


////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̉�]�s��
float4x4 RotMatrix(float3 Angle)
{
   float3 AngleY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosy = -AngleY.z;
   float siny = sign(AngleY.x) * sqrt(1.0f - cosy*cosy);
   float3 AngleXY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosx = dot( AngleXY, Angle );
   float sinx = sign(Angle.y) * sqrt(1.0f - cosx*cosx);

   float4x4 rMat = { cosy,       0.0f,  siny,      0.0f,
                    -sinx*siny,  cosx,  sinx*cosy, 0.0f,
                    -cosx*siny, -sinx,  cosx*cosy, 0.0f,
                     0.0f,       0.0f,  0.0f,      1.0f };

   return rMat;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̉�]�t�s��
float4x4 InvRotMatrix(float3 Angle)
{
   float3 AngleY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosy = -Angle.z;
   float siny = sign(Angle.x) * sqrt(1.0f - cosy*cosy);
   float3 AngleXY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosx = dot( Angle, AngleXY );
   float sinx = sign(Angle.y) * sqrt(1.0f - cosx*cosx);

   float4x4 rMat = { cosy, -sinx*siny, -cosx*siny, 0.0f,
                     0.0f,  cosx,      -sinx,      0.0f,
                     siny,  sinx*cosy,  cosx*cosy, 0.0f,
                     0.0f,  0.0f,       0.0f,      1.0f };

   return rMat;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u���e�N�X�`������f�[�^�����o��
float ColorToFloat(int i, int j)
{
    float4 d = tex2D(ArrangeSmp, float2((i+0.5)/ARRANGE_TEX_WIDTH, (j+0.5)/ARRANGE_TEX_HEIGHT));
    float tNum = (65536.0f * d.x + 256.0f * d.y + d.z) * 255.0f;
    int pNum = round(d.w * 255.0f);
    int sgn = 1 - 2 * (pNum % 2);
    float data = tNum * pow(10.0f, pNum/2 - 64) * sgn;
    return data;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT
{
    float4 Pos : POSITION;    // �ˉe�ϊ����W
    float2 Tex : TEXCOORD0;   // �e�N�X�`��
};

VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// 0�t���[���Đ��Ń��j�b�g���W�E���x�E�|�e���V������������
// �����E���x�̌v�Z(xyz:���K�����ꂽ�����x�N�g���Cw:����)

struct PS_OUTPUT {
   float4 Pos : COLOR0;
   float4 Vel : COLOR1;
   float4 Pot : COLOR2;
};

PS_OUTPUT Init_PS(float2 Tex: TEXCOORD0)
{
   PS_OUTPUT Out;

   if( time < 0.001f && InitFlag ){
      // 0�t���[���Đ��Ń��Z�b�g
      int j = floor( Tex.y*TEX_HEIGHT );
      float3 pos = float3(ColorToFloat(0, j), ColorToFloat(1, j), ColorToFloat(2, j));
      Out.Pos = float4(pos, 1.0f);

      float rx = radians(ColorToFloat(3, j));
      float ry = radians(ColorToFloat(4, j));
      float sinx,cosx,siny,cosy;
      sincos(rx, sinx, cosx);
      sincos(ry, siny, cosy);
      float3x3 rMat = { cosy,       0.0f,  siny,
                       -sinx*siny,  cosx,  sinx*cosy,
                       -cosx*siny, -sinx,  cosx*cosy};
      float3 ang = mul( float3(0.0f, 0.0f, -1.0f), rMat );
      Out.Vel = float4(ang, 0.0f);

      //�|�e���V�����ɂ�鑀�Ǘ͂�1�t���[���O�̌��ʂ��g���邽��0�t���[���Đ����͏������̕K�v�L��
      Out.Pot = float4(0.0f, 0.0f, 0.0f, 0.0f);

   }else{
      Out.Pos = tex2D(Flocking_SmpCoord, Tex);
      // ���x�X�V
      float4 vel0 = tex2D(Flocking_SmpVelocity, Tex);
      float3 Pos1 = (float3)tex2D(SmpCoordOld, Tex);
      float3 Pos2 = (float3)tex2D(Flocking_SmpCoord, Tex);
      float3 v = ( Pos2 - Pos1 )/Dt;
      float len = length( v );
      Out.Vel = (len > 0.0001f) ? float4( normalize(v), len ) : float4( vel0.xyz, len );

      Out.Pot =  tex2D(Flocking_SmpPotential, Tex);
   }

   return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �����j�b�g���W�l��1�t���[���O�̍��W�ɃR�s�[

float4 PosCopy_PS(float2 Tex: TEXCOORD0) : COLOR
{
   float4 Pos = tex2D(Flocking_SmpCoord, Tex);
   return Pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �����j�b�g���W�l���t���b�L���O�A���S���Y���ōX�V�E�|�e���V�����X�V

struct PS_OUTPUT2 {
   float4 Pos : COLOR0;
   float4 Pot : COLOR1;
};

PS_OUTPUT2 Flocking_PS(float2 Tex: TEXCOORD0)
{
   PS_OUTPUT2 Out;

    // 1�t���[���O�̈ʒu
    float3 Pos0 = tex2D(SmpCoordOld, Tex).xyz;

    // �����E���x
    float4 v = tex2D(Flocking_SmpVelocity, Tex);
    float3 Angle = v.xyz;
    float3 Vel = Angle * v.w;

    // ��]�t�s��
    float3x3 invRMat = (float3x3)InvRotMatrix(Angle);

    // ���Ǘ͏�����
    float3 SteerForce = float3(0.0f, 0.0f, 0.0f);
    float3 AvgPos = float3(0.0f, 0.0f, 0.0f);
    float3 AvgAng = float3(0.0f, 0.0f, 0.0f);
    int n = 0;

    // �t���b�L���O�A���S���Y��(�e���j�b�g�̈ʒu�֌W���瑀�Ǘ͂����߂�)
    int j = floor( Tex.y*TEX_HEIGHT );
    for(int i=0; i<ObjCount; i++){
       if( i != j ){
          float y = (float(i) + 0.5f)/TEX_HEIGHT;
          float3 pos_i = tex2D(SmpCoordOld, float2(Tex.x, y)).xyz;
          float3 ang_i = tex2D(Flocking_SmpVelocity, float2(Tex.x, y)).xyz;
          float len = length( pos_i - Pos0 );
          float cosa = dot( normalize(pos_i - Pos0), Angle );
          if(len < WideViewRadius){
             // �����̑��Ǘ�(���j�b�g���m�̏Փˉ��)
             if(len < SeparationLength){
                float3 pos_local = mul( pos_i-Pos0, invRMat );
                SteerForce += normalize( -pos_local ) * SeparationFactor / len * min(1.0f, time/5.0f);
             }
             // ���F���j�b�g���ǂ���
             if(cosa > WideViewCosA){
                AvgPos += pos_i;
                AvgAng += ang_i;
                n++;
             }
          }
       }
    }
    if( n > 0){
       // �����̑��Ǘ�(��ɂ܂Ƃ܂��)
       AvgPos = mul( AvgPos/float(n)-Pos0, invRMat );
       AvgPos.z = 0.0f;
       SteerForce += AvgPos * CohesionFactor;

       // ����̑��Ǘ�(�������������������)
       AvgAng = normalize( mul( AvgAng, invRMat ) );
       float a1 = acos( clamp(dot( AvgAng, float3(0.0f, 0.0f, -1.0f) ), -1.0f, 1.0f) );
       AvgAng = normalize( float3(AvgAng.xy, 0.0f) );
       SteerForce += AvgAng * a1 * AlignmentFactor;
    }

    // �|�e���V�����ɂ�鑀�Ǘ͂�t��
    SteerForce += tex2D(Flocking_SmpPotential, Tex).xyz;

    // ���Ǘ͂̕��������[���h���W�n�ɕϊ�
    SteerForce = mul( SteerForce, (float3x3)RotMatrix(Angle) );

    // �����x�v�Z(���i��+��R��+���Ǘ�)
    float3 Accel = DrivingForceFactor * Angle - ResistanceFactor * Vel + SteerForce;

    // �V�������W�ɍX�V
    float3 Pos = Pos0 + Dt * (Vel + Dt * Accel);

    // ���������p�x�����ɂ��ʒu�␳
    if( (PotentialBottom <= Pos.y && Pos.y <= PotentialTop) ||
        (Pos.y < PotentialBottom && Pos.y < Pos0.y) ||
        (PotentialTop < Pos.y && Pos0.y < Pos.y) ){
       float3 pos2 = Pos - Pos0;
       float3 pos3 = float3(pos2.x, 0.0f, pos2.z );
       float a = acos( min(dot( normalize(pos2), normalize(pos3) ), 1.0f) );
       if(a > VAngLimit){
          pos3.y = sign(pos2.y) * length(pos3) * tan(VAngLimit);
          Pos = Pos0 + pos3;
       }
    }
    Out.Pos = float4( Pos, 1.0f );

    // �ȉ����j�b�g���w��͈͓��ɗ��߂邽�߂̃|�e���V�����ɂ�鑀�Ǘ͂��v�Z
    // ���̏�Q���A�N�Z�̃|�e���V���������Z���Ă��玟�t���[���Ŏg�p����

    // ���Ǘ͏�����
    SteerForce = float3(0.0f, 0.0f, 0.0f);

    // �O���|�e���V����(�����ɍs�������Ȃ��悤��)
    Pos.xz -= AcsPos.xz;
    float lenP0 = length( Pos );
    float limit = (lenP0 < 2.0f*OutsideLength) ? -abs(sin(time)) : -0.9999f;

    float p = clamp(-OutsideLength-Pos.x, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(-1.0f, 0.0f, 0.0f) ) > limit ){
       float3 pa = mul( float3(-Pos.x, 0.0f, -Pos.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }
    p = clamp(Pos.x-OutsideLength, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(1.0f, 0.0f, 0.0f) ) > limit ){
       float3 pa = mul( float3(-Pos.x, 0.0f, -Pos.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }
    p = clamp(-OutsideLength-Pos.z, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(0.0f, 0.0f, -1.0f) ) > limit ){
       float3 pa = mul( float3(-Pos.x, 0.0f, -Pos.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }
    p = clamp(Pos.z-OutsideLength, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(0.0f, 0.0f, 1.0f) ) > limit ){
       float3 pa = mul( float3(-Pos.x, 0.0f, -Pos.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }

    // ���ʃ|�e���V����(�����ɐ���Ȃ��悤��)
    p = max( PotentialBottom - Pos.y, 0.0f);
    SteerForce.y += p*p;

    // �V��|�e���V����(����߂��Ȃ��悤��)
    p = max( Pos.y - PotentialTop, 0.0f);
    SteerForce.y -= p*p;

    Out.Pot = float4(SteerForce, 0.0f);

    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���j�b�g�z�u�ϊ��s��̍쐬

VS_OUTPUT TransMatrix_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out;
    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.5f/TEX_WIDTH_W, 0.5f/TEX_HEIGHT);
    return Out;
}

float4 TransMatrix_PS(float2 Tex: TEXCOORD0) : COLOR
{
    int i0 = floor( Tex.x * TEX_WIDTH_W );
    int i = i0 / 4;
    int j = floor( Tex.y * TEX_HEIGHT );

    // ���f���z�u���W���擾
    float3 Pos = tex2D(Flocking_SmpCoord, float2((0.5f+i)/TEX_WIDTH, Tex.y)).xyz;

    // ���f�������x�N�g�����擾
    float3 Angle = tex2D(Flocking_SmpVelocity, float2((0.5f+i)/TEX_WIDTH, Tex.y)).xyz;

   // ���f���̔z�u�ϊ��s��
   float4x4 TrMat = RotMatrix(Angle);
   float scale = ColorToFloat(i+6, j);

   TrMat._11_12_13 *= scale;
   TrMat._21_22_23 *= scale;
   TrMat._31_32_33 *= scale;
   TrMat._41_42_43 = Pos;

   return TrMat[i0 % 4];
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ԋL�^

float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   return float4(time, 0, 0, 1);
}

/////////////////////////////////////////////////////////////////////////////////
// �t���b�L���O�A���S���Y���v�Z���s���e�N�j�b�N
// �����̌v�Z���ʂ����Flocking_Obj.fx�Ń��j�b�g�̕����E�`����s��

technique MainTec0 < string MMDPass = "object";
    string Script = 
        // 0�t���[���Đ��ŏ������E���x�v�Z
        "RenderColorTarget0=Flocking_CoordTex;"
        "RenderColorTarget1=Flocking_VelocityTex;"
        "RenderColorTarget2=Flocking_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=InitPass;"
        // 1�t���[���O�̍��W�ɃR�s�[
        "RenderColorTarget0=CoordTexOld;"
        "RenderColorTarget1=;"
        "RenderColorTarget2=;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosCopy;"
        // �t���b�L���O�A���S���Y��
        "RenderColorTarget0=Flocking_CoordTex;"
        "RenderColorTarget1=Flocking_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=FlockingPass;"
        // �z�u�ϊ��s��쐬
        "RenderColorTarget0=Flocking_TransMatrixTex;"
        "RenderColorTarget1=;"
	    "RenderDepthStencilTarget=TransMatrixDepthBuffer;"
	    "Pass=SetTransMatrix;"
        // ���ԍX�V
        "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;";
>{
    pass InitPass < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Init_PS();
    }
    pass PosCopy < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosCopy_PS();
    }
    pass FlockingPass < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Flocking_PS();
    }
    pass SetTransMatrix < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 TransMatrix_VS();
        PixelShader  = compile ps_3_0 TransMatrix_PS();
    }
    pass UpdateTime < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_2_0 UpdateTime_VS();
        PixelShader  = compile ps_2_0 UpdateTime_PS();
    }
}


