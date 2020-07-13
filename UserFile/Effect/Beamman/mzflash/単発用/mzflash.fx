//===============================================//
//�}�Y���t���b�V���G�t�F�N�g
//������l�F�r�[���}��P�i���x���A�j

//�t�@�C������ς����ꍇ�������ύX
float TrNum : CONTROLOBJECT < string name = "mzflash.x";  string item = "Tr";>;


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
   string ResourceName = "mzflash_0.png";
   //string ResourceName = "mzflash_1.png";
   //string ResourceName = "mzflash_2.png";
>;
//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
float lineSize
<
   string UIName = "lineSize";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 2 );
//���C���̒���
float lineLength
<
   string UIName = "lineLength";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 3 );
//UV�X�N���[�����x
float UScroll
<
   string UIName = "UScroll";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.00;
> = float(0);
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
> = float(1);
float VWrapNum
<
   string UIName = "VWrapNum";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0.0;
   int UIMax = 100.0;
> = float(1);
//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//


//�΂̒l
#define PI 3.1415
//�p�x�����W�A���l�ɕϊ�
#define RAD ((ROTATE * PI) / 180.0)

float4x4 world_matrix : World;
float4x4 view_proj_matrix : ViewProjection;
float4x4 view_trans_matrix : ViewTranspose;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

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
   
   float w = TrNum;
   w = pow(w,16);
   
   //�����ɍ��킹�Ċg��
   side *= lineSize/2/2;
   
   //���[���h�g�嗦�ɍ��킹�Ċg��i������
   side *= length(world_matrix[0]) * w;
   
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
   vec *= -lineLength * 5.0 * (1-w);
   
   //���[�J����Z�l���{�̏ꍇ�A�i�s�x�N�g����������
   if(Pos.z > 0)
   {
   		Out.texCoord.x = 0; 
   		Out.Pos += float4(vec,0);
   }else{
   		Out.texCoord.x = 1.0 * UWrapNum;
   }
   Out.Pos += float4(world_pos,0);
   
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
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
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

