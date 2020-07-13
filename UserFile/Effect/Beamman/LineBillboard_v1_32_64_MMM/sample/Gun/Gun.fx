//--------------------------------------------------------------//
// LineBillboard
// �������ЂƁF���x���A
// �x�[�X�ɂ����V�F�[�_�\�FFireParticleSystemEx
// ���������F2010/10/8
// ���������ꂫ
// 10/10/8:������
//--------------------------------------------------------------//

//�������@�̐ݒ�
//
//�����������F
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST INVSRCALPHA
//
//���Z�����F
//
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST ONE

#define BLENDMODE_SRC SRCALPHA
#define BLENDMODE_DEST ONE

//�e�N�X�`����
texture Line_Tex
<
   string ResourceName = "Gun.png";
>;
//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
float lineSize
<
   string UIName = "lineSize";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 0.5 );
//���C���̒���
float lineLength
<
   string UIName = "lineLength";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 20 );
//UV�X�N���[�����x
float UScroll
<
   string UIName = "UScroll";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.00;
> = float(5);
float VScroll
<
   string UIName = "VScroll";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.00;
> = float(0);

//UV�J��Ԃ���
float UWrapNum
<
   string UIName = "UWrapNum";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0.0;
   int UIMax = 100.0;
> = float(3);
float VWrapNum
<
   string UIName = "VWrapNum";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0.0;
   int UIMax = 100.0;
> = float(1);
//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//

float time_0_X : Time;
//�΂̒l
#define PI 3.1415
//�p�x�����W�A���l�ɕϊ�
#define RAD ((ROTATE * PI) / 180.0)

float4x4 world_matrix : World;
float4x4 view_proj_matrix : ViewProjection;
float4x4 view_trans_matrix : ViewTranspose;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   //���[�J�����W��0�_�ɏ�����
   Out.Pos = float4(0,0,0,1);
   
   //���[���h���W
   float3 world_pos = world_matrix[3].xyz;

   //���[���h�̐i�s�x�N�g��
   float3 vec = normalize(world_matrix[2].xyz);
   
   //�J�����̈ʒu
   float3 eyepos = view_trans_matrix[3].xyz;
   
   //�J��������̃x�N�g��
   float3 eyevec = view_trans_matrix[2].xyz;//normalize(world_pos - eyepos);
   
   //�i�s�x�N�g���ƃJ�����x�N�g���̊O�ςŉ������𓾂�
   float3 side = normalize(cross(vec,eyevec));
   
   //�����ɍ��킹�Ċg��
   side *= lineSize/2/2;
   
   //���[���h�g�嗦�ɍ��킹�Ċg��i������
   side *= length(world_matrix[0]);
   
   //���͍��W��X�l�Ń��[�J���ȍ��E����
   if(Pos.x > 0)
   {
   		//����
   		Out.texCoord.y = 0;
   		Out.Pos += float4(side,0);
   }else{
   		//�E��
   		Out.texCoord.y = 1 * VWrapNum; 
   		Out.Pos -= float4(side,0);
   }
   
   //�����ɍ��킹�Đi�s�x�N�g����L�΂�
   vec *= -lineLength * 5.0 * DiffuseColor.a;
   
   //���[�J����Z�l���{�̏ꍇ�A�i�s�x�N�g����������
   if(Pos.z > 0)
   {
   		Out.texCoord.x = 0; 
   		Out.Pos += float4(vec,0);
   }else{
   		Out.texCoord.x = 1.0 * UWrapNum;
   }
   Out.Pos += float4(world_pos,0);
   
   Out.texCoord += float2(UScroll,VScroll) * time_0_X;
   
   //���[���h�g�嗦�ɍ��킹�Ċg��
   
   
   Out.Pos = mul(Out.Pos, view_proj_matrix);
   Out.color = 1;

   return Out;
}

//�e�N�X�`���̐ݒ�
sampler LineTexSampler = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Line_Tex);
   //�e�N�X�`���͈�0.0�`1.0���I�[�o�[�����ۂ̏���
   //WRAP:���[�v
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   //�e�N�X�`���t�B���^�[
   //LINEAR:���`�t�B���^
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};

//�s�N�Z���V�F�[�_
float4 lineSystem_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   //���͂��ꂽ�e�N�X�`�����W�ɏ]���ĐF��I������
   return float4(tex2D(LineTexSampler,texCoord));
}

//�e�N�j�b�N�̒�`
technique lineSystem <
    string Script = 
		//�`��Ώۂ����C����ʂ�
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    //�p�X�̑I��
	    "Pass=lineSystem;"
    ;
> {
   //���C���p�X
   pass lineSystem
   {
      //Z�l�̍l���F����
      ZENABLE = TRUE;
      //Z�l�̕`��F���Ȃ�
      ZWRITEENABLE = FALSE;
      //�J�����O�I�t�i���ʕ`��
      CULLMODE = NONE;
      //���u�����h���g�p����
      ALPHABLENDENABLE = TRUE;
      //���u�����h�̐ݒ�i�ڂ����͍ŏ��̒萔���Q�Ɓj
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      //�g�p����V�F�[�_��ݒ�
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main();
   }
}

