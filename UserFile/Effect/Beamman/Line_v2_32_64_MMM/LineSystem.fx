//--------------------------------------------------------------//
// lineSystem
// �������ЂƁF���x���A
// �x�[�X�ɂ����V�F�[�_�\�FFireParticleSystemEx
// ���������F2010/10/7
// ���������ꂫ
// 10/10/7:������
// 10/10/7:WORLD_ROTATE�������Ǝ����E�e�N�X�`��4�Ƃ��Ԃ����Ⴏ���肦�Ȃ��c
// 10/10/9:���Ɂ@�˂񂪂�́@�r���{�[�h���@��������������
//--------------------------------------------------------------//

//���C���̒����i0�`100�͈̔͂Ŏw��j
#define LINE_LENGTH 50

//�r���{�[�h�t���O�i���[���h��]�ǐ��Ƃ̕��p�s�B�r���{�[�h���D�悳���j
#define BILLBORAD true
//���[���h��]�ǐ��t���O�i�ǐ�����I�u�W�F�̉�]�ɍ��킹��B�T�C�Y���傫���A�I�u�W�F�̉�]�p�x���}���Ɣ��ɂ悭�Ȃ������ɂȂ�)
#define WORLD_ROTATE true
//�p�x�i0�`360�����j
#define ROTATE 0

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
   string ResourceName = "Line.png";
>;
//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
float lineSize
<
   string UIName = "lineSize";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 1.0 );
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

//���C���̃X�s�[�h
float LineSpd
<
   string UIName = "LineSpd";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = -100.0;
   int UIMax = 100.0;
> = float(10);

//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//

float time_0_X : Time;
// X�t�@�C���ƘA�����Ă���̂ŁA�ύX�s��
#define PARTICLE_COUNT  100
// �ʒu�L�^�p�e�N�X�`���̃T�C�Y  (TEX_WIDTH*TEX_HEIGHT==PARTICLE_COUNT)
#define TEX_WIDTH  10
#define TEX_HEIGHT  10
//�΂̒l
#define PI 3.1415
//�p�x�����W�A���l�ɕϊ�
#define RAD ((ROTATE * PI) / 180.0)

float4x4 world_matrix : World;
float4x4 view_proj_matrix : ViewProjection;
float4x4 view_trans_matrix : ViewTranspose;
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
    string Format = "D24S8";
>;
//���[���h�s���ۑ�����e�N�X�`���[
texture WorldTex1 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture WorldTex2 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture WorldTex3 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture WorldTex4 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler WorldBase1 = sampler_state
{
   Texture = (WorldTex1);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
sampler WorldBase2 = sampler_state
{
   Texture = (WorldTex2);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
sampler WorldBase3 = sampler_state
{
   Texture = (WorldTex3);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
sampler WorldBase4 = sampler_state
{
   Texture = (WorldTex4);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   int idx = round(Pos.z*PARTICLE_COUNT);
   //ID���K��̒�����蒷��������ő�l�ɌŒ�
   if(idx >= LINE_LENGTH)
   {
		idx = LINE_LENGTH;
   }
   //���݂̍��W���擾
   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/TEX_HEIGHT + 0.05);
   float4x4 base_mat = float4x4(tex2Dlod(WorldBase1, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase2, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase3, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase4, float4(base_tex_coord,0,1)));
   float3 pos = Pos.xyz;
   pos.z = 0;      

   float4 rspos = 0;
   if(BILLBORAD)
   {
	   //���C���̃r���{�[�h��
	   float3 vec = 0;
	   int end = 0;
	   for(int i = 1;i<LINE_LENGTH || !end;i++)
	   {
		   //�x�N�g���v�Z�p�ڕW�h�c
		   int tgt = idx+i;
		   //���h�c�̃}�g���N�X���擾
		   float2 tgt_tex_coord = float2( float(tgt%TEX_WIDTH)/TEX_WIDTH + 0.05, float(tgt/TEX_WIDTH)/TEX_HEIGHT + 0.05);
		   float4x4 tgt_mat = float4x4(tex2Dlod(WorldBase1, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase2, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase3, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase4, float4(tgt_tex_coord,0,1)));
		   
		   //tgt�̍��W��ۑ�
		   float3 tgt_pos = tgt_mat._41_42_43;
		   
		   //tgt�ւ̃x�N�g�����v�Z
		   vec = normalize(base_mat._41_42_43 - tgt_pos);
		   
		   //�덷�ɂ�蓯����W���擾�A�x�N�g�����O�̏ꍇ
		   if((vec.x + vec.y + vec.z) != 0)
		   {
		      //�擾�������[�v�𔲂���
		      end = 1;
		   }
        }	   

		//�J��������̃x�N�g��
		float3 eyevec = normalize(view_trans_matrix[2].xyz);

		//�i�s�x�N�g���ƃJ�����x�N�g���̊O�ςŉ������𓾂�
		float3 side = normalize(cross(vec,eyevec));

		//�����ɍ��킹�Ċg��
		side *= lineSize/16;

		//���[���h�g�嗦�ɍ��킹�Ċg��i������
		side *= length(world_matrix[0]);

		//���͍��W��X�l�Ń��[�J���ȍ��E����
		if(Pos.x > 0)
		{
		    //����
		    rspos += float4(side,0);
		}else{
		    //�E��
		    rspos -= float4(side,0);
		}
	   
	   rspos = mul(rspos,length(world_matrix[0]));
   }else{
	   pos *= lineSize;
       rspos = float4(pos,0);
	   //��r���{�[�h���C������
	   if(WORLD_ROTATE)
	   {
		   //-���[���h�}�g���b�N�X�ɍ��킹�ĉ�]�A�g�k����
		   //���[���h�}�g���b�N�X����ړ������폜
		   float4x4 matRotScale = base_mat;
		   matRotScale[3] = 0;
		   //�}�g���b�N�X�v�Z
		   rspos = mul(rspos,matRotScale);
	   	   rspos = mul(rspos,length(world_matrix[0]));
	   }else{
	   	   rspos = mul(rspos,length(world_matrix[0]));
	   }
	   

	   //���[�J����]����
	   //��]�s��̍쐬
	   float4x4 matRot;
	   matRot[0] = float4(cos(RAD),sin(RAD),0,0); 
	   matRot[1] = float4(-sin(RAD),cos(RAD),0,0); 
	   matRot[2] = float4(0,0,1,0); 
	   matRot[3] = float4(0,0,0,1); 

	   rspos = mul(rspos,matRot);
	   
   }
   pos.x = rspos.x;
   pos.y = rspos.y;
   pos.z = rspos.z;
   

   pos += base_mat._41_42_43;
   
   
   Out.Pos = mul(float4(pos, 1), view_proj_matrix);
   
   //���_UV�l�̌v�Z
   Out.texCoord.x = (Pos.z * ((float)PARTICLE_COUNT/(float)LINE_LENGTH)) * UWrapNum;
   Out.texCoord.y = ((Pos.x + Pos.y) + 0.5) * -VWrapNum;
   //UV�X�N���[��
   Out.texCoord.x += float2(UScroll,VScroll) * time_0_X;
   Out.color = 1;

   return Out;
}
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
float4 lineSystem_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {

   float4 col = tex2D(LineTexSampler,texCoord);
   col.a *= MaterialDiffuse.a;

   return float4(col);
}

struct VS_OUTPUT2 {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
};

VS_OUTPUT2 WorldBase_Vertex_Shader_main(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT2 Out;
  
   Out.Pos = Pos;
   Out.texCoord = Tex ;
   return Out;
}
//���W���e�N�X�`���ɕۑ�
float4 WorldBase1_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   
    int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   
   //ID��LINE_LENGTH(�擪�j�������烏�[���h�ړ��l��ۑ�
   //�܂��A�Đ������0.05�b�Ԃ͏����ʒu�ɍ��킹��
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._11_12_13,0);
   }else{
	   
	   //ID����UV���W���v�Z
	   idx-=1;
	   
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase1, base_tex_coord);
   	   return prev;
   }
}
float4 WorldBase2_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._21_22_23,0);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase2, base_tex_coord);
   	   return prev;
   }
}
float4 WorldBase3_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._31_32_33,0);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase3, base_tex_coord);
   	   return prev;
   }
}
float4 WorldBase4_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._41_42_43,0);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase4, base_tex_coord);
       prev += normalize(tex2D(WorldBase2, base_tex_coord)) * LineSpd;
   	   return prev;
   }
}

technique lineSystem <
    string Script = 
	    "RenderDepthStencilTarget=DepthBuffer;"
        "RenderColorTarget0=WorldTex1;"
	    "Pass=WorldBase1;"
	    "RenderColorTarget0=WorldTex2;"
	    "Pass=WorldBase1;"
	    "RenderColorTarget0=WorldTex3;"
	    "Pass=WorldBase2;"
	    "RenderColorTarget0=WorldTex4;"
	    "Pass=WorldBase4;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=lineSystem;"
    ;
> {
	pass WorldBase1 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase1_Pixel_Shader_main();
	}
	pass WorldBase2 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase2_Pixel_Shader_main();
	}
	pass WorldBase3 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase3_Pixel_Shader_main();
	}
	pass WorldBase4 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase4_Pixel_Shader_main();
	}
   pass lineSystem
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main();
   }
}

