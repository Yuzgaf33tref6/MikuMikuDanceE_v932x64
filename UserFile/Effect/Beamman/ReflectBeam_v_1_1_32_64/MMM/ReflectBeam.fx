

#define CONTROLLER "hoge"

//������
#define CLONE_NUM 100

//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
float lineSize = float( 10 );

//�ˏo�x�������_����(0:�x������ 1�ȉ������j
float ShotDelay = 0;

//�e���L��
float UpSize = 1;

//�����ʒu�̃����_����(0:�݂�ȓ��������j
float ShotRand = 1;

//��]���x
float RotationSpd = 5;

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


//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//

float fcnum = CLONE_NUM*2;
int CloneNum = CLONE_NUM*2;

//���݂̕`��ԍ�
int index;

texture2D rndtex <
    string ResourceName = "random1024.bmp";
>;
sampler rnd = sampler_state {
    texture = <rndtex>;
};


//���C���̒����F�ύX�s��
#define LINE_LENGTH 100

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);

float time_0_X : TIME <bool SyncInEditMode=false;>;

//�΂̒l
#define PI 3.1415
//�p�x�����W�A���l�ɕϊ�
#define RAD ((ROTATE * PI) / 180.0)

float4x4 CenterWorld : CONTROLOBJECT < string name = CONTROLLER; string item = "�Z���^�["; >;
float4x4 world_view_proj_matrix : WorldViewProjection;
float4x4 view_trans_matrix : ViewTranspose;

//float morph_num : CONTROLOBJECT < string name = CONTROLLER; string item = "������"; >;

float morph_num <
   string UIName = "morph_num";
   string UIWidget = "Slider";
> = 1;
float morph_t <
   string UIName = "morph_t";
   string UIWidget = "Slider";
> = 0;
float morph_gsi <
   string UIName = "morph_gsi";
   string UIWidget = "Slider";
> = 0;
float morph_len <
   string UIName = "morph_len";
   string UIWidget = "Slider";
> = 1;
float morph_si <
   string UIName = "morph_si";
   string UIWidget = "Slider";
> = 0.5;
float morph_de <
   string UIName = "morph_de";
   string UIWidget = "Slider";
> = 0.5;
float morph_len_rnd <
   string UIName = "morph_len_rnd";
   string UIWidget = "Slider";
> = 0;
float morph_width <
   string UIName = "morph_width";
   string UIWidget = "Slider";
> = 0.5;
float morph_width_pow <
   string UIName = "morph_width_pow";
   string UIWidget = "Slider";
> = 1;
float morph_r_rot <
   string UIName = "morph_r_rot";
   string UIWidget = "Slider";
> = 0;
float morph_l_rot <
   string UIName = "morph_l_rot";
   string UIWidget = "Slider";
> = 0;
float param_h <
   string UIName = "param_h";
   string UIWidget = "Slider";
> = 0;
float param_s <
   string UIName = "param_s";
   string UIWidget = "Slider";
> = 0;
float param_b <
   string UIName = "param_b";
   string UIWidget = "Slider";
> = 0;
float param_alpha <
   string UIName = "param_alpha";
   string UIWidget = "Slider";
> = 0;

//HSB�ϊ��p�F�e�N�X�`��
texture2D ColorPallet <
    string ResourceName = "ColorPallet.png";
>;
sampler PalletSamp = sampler_state {
    texture = <ColorPallet>;
};

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   //�����_���l�擾
   float4 rnddata = tex2Dlod(rnd,float4(cos((index+123)),0,0,1))*2*3.1415;
   
	//���[�t�K�p
	//������
	CloneNum *= (1-morph_num)*100;

	//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
	lineSize *= morph_si*0.5;

	//�ˏo�x�������_����(0:�x������ 1�ȉ������j
	ShotDelay += morph_de*2;

	//�e���L��
	UpSize *= morph_len;

	//�����ʒu�̃����_����(0:�݂�ȓ��������j
	ShotRand *= morph_len_rnd*morph_len;

	//��]���x
	RotationSpd *= morph_r_rot-morph_l_rot;
   
   	UpSize += (rnddata.r%1.0)*ShotRand;
	UpSize *= 10;
    float3 TgtPos = 0;
   
   
   
   
   int idx = round(Pos.z*LINE_LENGTH);
   //ID���K��̒�����蒷��������ő�l�ɌŒ�
   if(idx >= LINE_LENGTH)
   {
		idx = LINE_LENGTH-1;
   }
   
   
   
   //������ID
   float fid = (float) idx / (float)LINE_LENGTH;
   //����ID
   float fnextid = (float) (idx+1) / (float)LINE_LENGTH;

   //0�_�̍��W
   float3 wpos = 0;

   //���݂̈ړ����W
   float3 nowpos = lerp(wpos+float3(0,0,UpSize*10),wpos,fid);
	
   float3 pos = Pos;
   pos.z = 0;
   pos *= lineSize;

   pos += nowpos;
   morph_width *= 50;
   morph_width_pow *= 10;
   pos.y += (1-pow(fid,1+morph_width_pow))*morph_width*(1+(rnddata.g%1.0)*ShotRand);
   
   
   float4x4 matRot;
   rnddata.xyz += RotationSpd*fid;
   //Z����]
   matRot[0] = float4(cos(rnddata.z),sin(rnddata.z),0,0); 
   matRot[1] = float4(-sin(rnddata.z),cos(rnddata.z),0,0); 
   matRot[2] = float4(0,0,1,0); 
   matRot[3] = float4(0,0,0,1); 
   
   pos = mul(pos,matRot);
   
   /*
   float4x4 matRot;
   
   rnddata.xyz += RotationSpd*fid;
   
   //X����]
   matRot[0] = float4(1,0,0,0); 
   matRot[1] = float4(0,cos(rnddata.x),sin(rnddata.x),0); 
   matRot[2] = float4(0,-sin(rnddata.x),cos(rnddata.x),0); 
   matRot[3] = float4(0,0,0,1); 
   
   pos = mul(pos,matRot);
   
   //Y����] 
   matRot[0] = float4(cos(rnddata.y),0,-sin(rnddata.y),0); 
   matRot[1] = float4(0,1,0,0); 
   matRot[2] = float4(sin(rnddata.y),0,cos(rnddata.y),0); 
   matRot[3] = float4(0,0,0,1); 
 
   pos = mul(pos,matRot);
 
   //Z����]
   matRot[0] = float4(cos(rnddata.z),sin(rnddata.z),0,0); 
   matRot[1] = float4(-sin(rnddata.z),cos(rnddata.z),0,0); 
   matRot[2] = float4(0,0,1,0); 
   matRot[3] = float4(0,0,0,1); 
   
   pos = mul(pos,matRot);
   */
   
   pos.xyz *= 1+morph_gsi*10;
   
   Out.Pos = mul(float4(pos, 1),CenterWorld);
   Out.Pos = mul(Out.Pos, world_view_proj_matrix);
   
   //���_UV�l�̌v�Z
   Out.texCoord.x = Pos.z;
   Out.texCoord.y = ((Pos.x + Pos.y) + 0.5);
   //UV�X�N���[��
   float findex = floor(index);
   
   findex *= morph_num;
   fcnum *= morph_num;
   
   Out.texCoord.x -= ((1-morph_t)*3-2)+(findex/fcnum)*ShotDelay;
   Out.color = fid;
   
   if(morph_num <= (findex/fcnum)*2)
   {
   		Out.color = 0;
   }

   return Out;
}
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
   MIPFILTER = NONE;
};
//�ʓx�v�Z�p
const float4 calcY = float4( 0.2989f, 0.5866f, 0.1145f, 0.00f );

float4 lineSystem_Pixel_Shader_main(float2 texCoord: TEXCOORD0,float alpha: TEXCOORD1) : COLOR {
	
	float4 Color = float4(tex2D(LineTexSampler,texCoord));
	Color.a = alpha;
	
	float r = Color.rgb * calcY;
	r *= param_b*10;

	float4 pallet = tex2D(PalletSamp,float2(param_h,param_s));
	Color.rgb *= pallet.rgb;
	Color.rgb += r;
	Color.a *= 1-param_alpha;
	return Color;
}
technique lineSystem <
    string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
		"LoopByCount=CloneNum;"
        "LoopGetIndex=index;"
	    "Pass=lineSystem;"
        "LoopEnd=;"
    ;
> {
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

technique lineSystem_ss <
	string MMDPass = "object_ss";
    string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
		"LoopByCount=CloneNum;"
        "LoopGetIndex=index;"
	    "Pass=lineSystem;"
        "LoopEnd=;"
    ;
> {
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
// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {}
// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {}
// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {}
