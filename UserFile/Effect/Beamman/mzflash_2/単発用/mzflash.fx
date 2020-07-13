//===============================================//
//�}�Y���t���b�V���G�t�F�N�g
//������l�F�r�[���}��P�i���x���A�j


//--�}�Y���t���b�V���A�j���[�V�������x--//
float FlashSpd = 5.0;

//--�_�ŊԊu--//
int FlashRld = 16;




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

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION,uniform int type){
   VS_OUTPUT Out;
   float time_0_X = 1-MaterialDiffuse.a;
   if(type == 2)
   {
		Out.texCoord = Pos.xz*0.5+0.5;
		//���[���h�g�嗦�ɍ��킹�Ċg��
		float w = cos(time_0_X * 1);
		if(w > 0)
		{
		    w = pow(w,32);
		}else{
		    w = 0;
		}
		Pos.xz *= w*0.5;
		Out.Pos = mul(Pos.xzyw, WorldViewProjMatrix);
		Out.color = 1;
		return Out;
   }else{
		//���[�J�����W��0�_�ɏ�����
		Out.Pos = float4(0,0,0,1);

		//�i�s�x�N�g���ƃJ�����x�N�g���̊O�ςŉ������𓾂�
		float3 side = 0;
		if(type == 0)
		{
			side = float3(1,0,0);
		}
		if(type == 1)
		{
			side = float3(0,1,0);
		}

		float w = cos(time_0_X * 1);
		if(w > 0)
		{
		    w = pow(w,32);
		}else{
		    w = 0;
		}
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
		float3 vec = float3(0,0,1);
		vec *= -lineLength * 5.0 * DiffuseColor.a * (1-w);

		//���[�J����Z�l���{�̏ꍇ�A�i�s�x�N�g����������
		if(Pos.z > 0)
		{
		    Out.texCoord.x = 0; 
		    Out.Pos += float4(vec,0);
		}else{
		    Out.texCoord.x = 1.0 * UWrapNum;
		}

		Out.texCoord += float2(UScroll,VScroll) * time_0_X;

		//���[���h�g�嗦�ɍ��킹�Ċg��

		Out.Pos.xyz *= 0.2;
		Out.Pos = mul(Out.Pos, WorldViewProjMatrix);
		Out.color = 1;
		return Out;
	}
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

texture Center_Tex
<
   string ResourceName = "mzflash_center.png";
>;
sampler CenterSampler = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Center_Tex);
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
float4 lineSystem_Pixel_Shader_main(float2 texCoord: TEXCOORD0,uniform int type) : COLOR {
	//���͂��ꂽ�e�N�X�`�����W�ɏ]���ĐF��I������
	float Color = MaterialDiffuse.a;
	if(type == 0)
	{
		return Color*float4(tex2D(LineTexSampler,texCoord));
	}else{
		return Color*float4(tex2D(CenterSampler,texCoord));
	}
}

//�e�N�j�b�N�̒�`
technique lineSystem <
    string Script = 
		//�`��Ώۂ����C����ʂ�
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    //�p�X�̑I��
	    "Pass=lineSystem_w;"
	    "Pass=lineSystem_h;"
	    "Pass=lineSystem_c;"
    ;
> {
   //���C���p�X
   pass lineSystem_w
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main(0);
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main(0);
   }
   pass lineSystem_h
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main(1);
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main(0);
   }
   pass lineSystem_c
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main(2);
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main(1);
   }
}

