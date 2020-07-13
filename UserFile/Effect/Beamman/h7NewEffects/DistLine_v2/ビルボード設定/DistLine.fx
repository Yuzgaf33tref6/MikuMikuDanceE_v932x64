//--------------------------------------------------------------//
// DistLine
// ������l�F�r�[���}��P
//--------------------------------------------------------------//

//�O�Ղ̒��F
float4 LineColor = float4(0.1,0.5,0.1,1);
//�c�ݗ�
float DistPow = 0.25;
//�Œᑬ�x�i0�ŏ�ɂł��ςȂ��j
float CutSpeed = 0;

//���C���̒����i�`100�j
#define LINE_LENGTH 50

//�r���{�[�h�t���O
#define BILLBORAD true


//UV�X�N���[�����x
float UScroll = 0;
float VScroll = 0;

//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
float lineSize = 0.1;

//���C���̃X�s�[�h(�ˏo���x�j
float LineSpd = 0;




//���[�J���x�N�g���̎g�p�I��(�R�����g�A�E�g // ������@����Ǝg�p�I�t�j
//#define USE_LOCAL_VEC
//���[���h�x�N�g���̎g�p�I��(�R�����g�A�E�g // ������@����Ǝg�p�I�t�j
#define USE_WORLD_VEC
//���[�J���x�N�g���i�p�x�Ɋ֌W�Ȃ����̕����ɉ��Z�����BLineSpd��0�Ȃ���ʂȂ��j
float3 LocalVec = float3(0,1,0);

//�}�X�N�e�N�X�`���̗L���x
float MaskParam = 1.0;


//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//

#if(LINE_LENGTH > 98)
	#define LINE_LENGTH 98
#elif(LINE_LENGTH < 2)
	#define LINE_LENGTH 2
#endif

//UV�J��Ԃ���
float UWrapNum = 1;
float VWrapNum = 1;

texture DistortionRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for DistortionField.fx";
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
    	"LineSystem.x = hide;"
        "self = hide;";
>;

sampler DistortionView = sampler_state {
    texture = <DistortionRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

//�e�N�X�`����
texture Line_Tex
<
   string ResourceName = "Line.png";
>;

sampler LineTexSampler = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Line_Tex);
   //�e�N�X�`���͈�0.0�`1.0���I�[�o�[�����ۂ̏���

   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   //�e�N�X�`���t�B���^�[
   //LINEAR:���`�t�B���^
   FILTER = LINEAR;
};
texture Mask_Tex
<
   string ResourceName = "MaskTex.png";
>;

sampler MaskSamp = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Mask_Tex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   FILTER = LINEAR;
};
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
   float2 texCoordDef: TEXCOORD1;
   float4 LastPos: TEXCOORD2;
   float2 Vec: TEXCOORD3;
   float Len: TEXCOORD4;
};
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   int idx = round(Pos.z*PARTICLE_COUNT);

   //���݂̍��W���擾
   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/TEX_HEIGHT + 0.05);
   float4x4 base_mat = float4x4(tex2Dlod(WorldBase1, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase2, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase3, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase4, float4(base_tex_coord,0,1)));
   
   base_mat._14 = 0;
   base_mat._24 = 0;
   base_mat._34 = 0;
   base_mat._44 = 1;
   float3 pos = Pos;
   pos.z = 0;      

   float4 rspos = 0;
   float3 vec = 0;
   float3 tgt_pos;
   for(int i = 1;i<LINE_LENGTH;i++)
   {
	   //�x�N�g���v�Z�p�ڕW�h�c
	   int tgt = idx+i;
	   //���h�c�̃}�g���N�X���擾
	   float2 tgt_tex_coord = float2( float(tgt%TEX_WIDTH)/TEX_WIDTH + 0.05, float(tgt/TEX_WIDTH)/TEX_HEIGHT + 0.05);
	   float4x4 tgt_mat = float4x4(tex2Dlod(WorldBase1, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase2, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase3, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase4, float4(tgt_tex_coord,0,1)));
	   
	   //tgt�̍��W��ۑ�
	   tgt_pos = tgt_mat._41_42_43;
	   
	   //tgt�ւ̃x�N�g�����v�Z
	   vec = normalize(base_mat._41_42_43 - tgt_pos);
	   
	   //�덷�ɂ�蓯����W���擾�A�x�N�g�����O�̏ꍇ
	   if((vec.x + vec.y + vec.z) != 0)
	   {
	      //�擾�������[�v�𔲂���
	      break;
	   }
    }	 
   if(BILLBORAD)
   {
	   //���C���̃r���{�[�h��
  

		//�J��������̃x�N�g��
		float3 eyevec = normalize(view_trans_matrix[2].xyz);

		//�i�s�x�N�g���ƃJ�����x�N�g���̊O�ςŉ������𓾂�
		float3 side = normalize(cross(vec,eyevec));

		//�����ɍ��킹�Ċg��
		side *= lineSize/5;

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
	   //-���[���h�}�g���b�N�X�ɍ��킹�ĉ�]�A�g�k����
	   //���[���h�}�g���b�N�X����ړ������폜
	   float4x4 matRotScale = base_mat;
	   //�}�g���b�N�X�v�Z
	   rspos = mul(rspos,matRotScale);
   	   //rspos = mul(rspos,length(world_matrix[0]));
   }
   pos.xyz = rspos.xyz;
   
   pos += base_mat._41_42_43;
   //pos += world_matrix[2]*Pos.z;
   
   Out.Pos = mul(float4(pos, 1), view_proj_matrix);
   Out.LastPos = Out.Pos;
   
   //���_UV�l�̌v�Z
   Out.texCoord.x = (Pos.z * ((float)PARTICLE_COUNT/(float)LINE_LENGTH));
   Out.texCoord.y = 1-(((Pos.x + Pos.y) + 0.5));

	//�����e�N�X�`���l��ۑ�
   Out.texCoordDef = Out.texCoord;
   
   Out.texCoord *= float2(UWrapNum,VWrapNum);
   
   //UV�X�N���[��
   Out.texCoord += float2(UScroll,VScroll) * time_0_X;
   
	float2 NowScPos;
	float2 TgtScPos;
	float4 Now = mul(float4(base_mat._41_42_43,1),view_proj_matrix);
	float4 Prev = mul(float4(tgt_pos,1),view_proj_matrix);
	
	
	NowScPos.x = (Now.x / Now.w)*0.5+0.5;
	NowScPos.y = (-Now.y / Now.w)*0.5+0.5;
   
	TgtScPos.x = (Prev.x / Prev.w)*0.5+0.5;
	TgtScPos.y = (-Prev.y / Prev.w)*0.5+0.5;
   
   Out.Vec = normalize(NowScPos - TgtScPos);

   Out.Len = length(base_mat._41_42_43 - tgt_pos);

   //ID���K��̒�����蒷�����������
   if(idx >= LINE_LENGTH-1)
   {
   		Out.Pos.z = -2;
   }

   return Out;
}

float4 lineSystem_Pixel_Shader_main_dist(VS_OUTPUT IN) : COLOR {

	float4 col = tex2D(LineTexSampler,IN.texCoord);
	col.a *= MaterialDiffuse.a;

	//�X�N���[�����W���v�Z
	float2 UVPos;
	UVPos.x = (IN.LastPos.x / IN.LastPos.w)*0.5+0.5;
	UVPos.y = (-IN.LastPos.y / IN.LastPos.w)*0.5+0.5;
	col.r *= lerp(1,tex2D(MaskSamp,IN.texCoordDef).r,MaskParam);
	//return float4(IN.texCoordDef,0,1);
	
	float4 Dist = tex2D(DistortionView,UVPos + IN.Vec * col.r * DistPow);
	
	col.rgb = lerp(Dist.rgb,Dist.rgb+LineColor.rgb*LineColor.a,col.r);
	col.a *= saturate((IN.Len > CutSpeed));
	return col;
	
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
   		return float4(world_matrix._11_12_13,1);
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
   		return float4(world_matrix._21_22_23,1);
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
   		return float4(world_matrix._31_32_33,1);
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
   		return float4(world_matrix._41_42_43,1);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase4, base_tex_coord);
       
       float3 Vec = 0;

       #ifdef USE_WORLD_VEC
       		Vec = normalize(tex2D(WorldBase3,base_tex_coord));
       #endif
       #ifdef USE_LOCAL_VEC
       		Vec = normalize(Vec+normalize(LocalVec));
       #endif
       
       prev.xyz += Vec * -LineSpd;
   	   return prev;
   }
}

technique lineSystem <
    string Script = 
	    "RenderDepthStencilTarget=DepthBuffer;"
        "RenderColorTarget0=WorldTex1;"
	    "Pass=WorldBase1;"
	    "RenderColorTarget0=WorldTex2;"
	    "Pass=WorldBase2;"
	    "RenderColorTarget0=WorldTex3;"
	    "Pass=WorldBase3;"
	    "RenderColorTarget0=WorldTex4;"
	    "Pass=WorldBase4;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=lineSystem_dist;"
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
   pass lineSystem_dist
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=SRCALPHA;
      DESTBLEND=INVSRCALPHA;
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main_dist();
   }
}

