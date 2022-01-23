////////////////////////////////////////////////////////////////////////////////////////////////
//
//  NumbersPmd_Float2.fx ver0.0.4 ���l�f�[�^�̕\��(float2�^)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
float3 CameraPos : POSITION  < string Object = "Camera"; >;

// �����ɕ\�������鐔�l��܂��͕ϐ�,������(���m�ɓǂ߂�̂͑S7�����x)
static float2 Value = CameraPos.xy;

int FractCount = 3;  // �����ȉ�����

//#define PLUS  // �{�\�L����ꍇ�̓R�����g�A�E�g���O��


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

int Count = 2;
int ObjIndex;  // �������f���J�E���^

float PmdSi : CONTROLOBJECT < string name = "(self)"; string item = "�X�P�[��"; >;
float PmdTr : CONTROLOBJECT < string name = "(self)"; string item = "����"; >;
float3 PmdPos : CONTROLOBJECT < string name = "(self)"; string item = "�Z���^�["; >;

static int iValue = round(Value[ObjIndex] * pow(10.0f, FractCount));

int TexCount = 15;  // �e�N�X�`��������ސ�

// ��ʃT�C�Y
float2 ScreenSize : VIEWPORTPIXELSIZE;

// �����e�N�X�`��
texture2D NumberTex <
    string ResourceName = "numbers.png";
>;
sampler NumberSamp = sampler_state {
    texture = <NumberTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


////////////////////////////////////////////////////////////////////////////////////////////////
// �������Z
int div(int a, int b) {
    return floor((a+0.1f)/b);
}

// ������]�Z
int mod(int a, int b) {
    return (a - div(a,b)*b);
};

///////////////////////////////////////////////////////////////////////////////////////
// �����e�N�X�`���̑I��

int PickupNumber(int index)
{
   int texIndex = 14;
   int absVal = abs(iValue);

   if(index == FractCount) return 10;
   if(index > FractCount) index--;

   bool endFlag = false;
   for(int i=0; i<=index; i++){
      if(absVal>0){
         texIndex = mod(absVal, 10);
         absVal =   div(absVal, 10);
      }else{
         if(endFlag){
            if(index > FractCount+1) texIndex = 14;
         }else{
            if(index > FractCount){
               #ifdef PLUS
               if(iValue > 0) texIndex = 11;
               #else
               if(iValue > 0) texIndex = 14;
               #endif
               else if(iValue < 0) texIndex = 12;
               else texIndex = 14;
               endFlag = true;
            }else{
               texIndex = 0;
            }
         }
      }
   }

   return texIndex;
}


///////////////////////////////////////////////////////////////////////////////////////
// �����`��

struct VS_OUTPUT
{
    float4 Pos : POSITION;    // �ˉe�ϊ����W
    float2 Tex : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT Obj_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, int index: _INDEX)
{
    VS_OUTPUT Out;

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
    Index = index / 4;

    // �{�[�h�z�u
    Pos.x *= 0.5f;
    Pos.x -= float(Index);
    Pos.y -= ObjIndex * 2.0f - 1.0f;

    // ���[���h���W�ϊ�
    Pos.xy *= (1.0f - PmdSi)*0.07f;
    Pos.x *= ScreenSize.y/ScreenSize.x;
    Pos.xy += PmdPos.xy * 0.1f;
    Pos.zw = float2(0.0f, 1.0f);
    Out.Pos = Pos;

    // �e�N�X�`�����W
    int texIndex = PickupNumber(Index);
    Tex.x = (Tex.x + (float)texIndex ) / (float)TexCount;
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Obj_PS( VS_OUTPUT IN ) : COLOR0
{
   // �e�N�X�`���̐F
   float4 Color = tex2D( NumberSamp, IN.Tex );
   Color.a *= (1.0f - PmdTr);
   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec0 < string MMDPass = "object";
    string Script = "LoopByCount=Count;"
                       "LoopGetIndex=ObjIndex;"
                       "Pass=DrawObject;"
                    "LoopEnd=;"; >
{
   pass DrawObject {
       ZENABLE = false;
       VertexShader = compile vs_3_0 Obj_VS();
       PixelShader  = compile ps_3_0 Obj_PS();
   }
}

technique MainTec1 < string MMDPass = "object_ss";
    string Script = "LoopByCount=Count;"
                       "LoopGetIndex=ObjIndex;"
                       "Pass=DrawObject;"
                    "LoopEnd=;"; >
{
   pass DrawObject {
       ZENABLE = false;
       VertexShader = compile vs_3_0 Obj_VS();
       PixelShader  = compile ps_3_0 Obj_PS();
   }
}

// �G�b�W,�n�ʉe�͔�\��
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

