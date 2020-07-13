
//������
int CloneNum = 10;

//���C���̑����iMMD��Őݒ肵�������~�����Őݒ肵���������\������鑾���j
float lineSize = float( 10 );

//�ˏo�x�������_����(0:�x������ 1�ȉ������j
float ShotDelay = 0.1;

//�e���L��
float UpSize = 17.0;

//�Ȑ��̏_�炩��
float CurvePow = 10.0;

//�^�[�Q�b�g�̖��O
float3 TgtPos : CONTROLOBJECT < string name = "reflect_tgt.x"; >;


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


//�p�x�i0�`360�����j
#define ROTATE 0

//�e�N�X�`����
texture Line_Tex
<
   string ResourceName = "Line.png";
>;


//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//

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

float4x4 world_matrix : World;
float4x4 view_proj_matrix : ViewProjection;
float4x4 view_trans_matrix : ViewTranspose;

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;
   
   //�����_���l�擾
   float4 rnddata = tex2Dlod(rnd,float4(cos(index),0,0,1))*2*3.1415;
   
   
   int idx = round(Pos.z*LINE_LENGTH);
   //ID���K��̒�����蒷��������ő�l�ɌŒ�
   if(idx >= LINE_LENGTH)
   {
		idx = LINE_LENGTH-1;
   }
   
   
   
   //������ID
   float fid = 1.0 - (float) idx / (float)LINE_LENGTH;
   //����ID
   float fnextid = 1.0 - (float) (idx+1) / (float)LINE_LENGTH;

	//���[���h�̃x�N�g��
	float3 wvec = normalize(world_matrix[2].xyz);

	//���[���h��]�s����쐬�@���[���h�}�g���b�N�X���R�s�[����
	float4x4 world_rotate = world_matrix;
	//�ړ�������������
	world_rotate[3] = 0;

   //0�_�̍��W
   float3 wpos = world_matrix[3].xyz;

    //���݂̈ړ����W
    float3 nowpos = lerp(wpos,TgtPos,fid);
    
    //�����W
    float3 nextpos = lerp(wpos,TgtPos,fnextid);
    
    //�ڕW�_�ւ̃x�N�g��
    float3 TgtVec = normalize(wpos - TgtPos);
    
    //��x�N�g��
    float3 UpVec = normalize(cos(rnddata.rgb));
    
    //���x�N�g��
    float3 SideVec = normalize(cross(TgtVec,UpVec));
    
    //��x�N�g���Čv�Z
    UpVec = normalize(cross(TgtVec,SideVec));

   float3 pos = Pos;
   pos.z = 0;
   pos *= lineSize;
   pos += (1-pow(1-fid,CurvePow))*UpVec*UpSize;      

   pos += nowpos;
   
   
   Out.Pos = mul(float4(pos, 1), view_proj_matrix);
   
   //���_UV�l�̌v�Z
   Out.texCoord.x = Pos.z;
   Out.texCoord.y = ((Pos.x + Pos.y) + 0.5);
   //UV�X�N���[��
   float fcnum = CloneNum;
   float findex = index;
   
   Out.texCoord.x -= (MaterialDiffuse.a*3-2)+(findex/fcnum)*(ShotDelay);
   Out.color = 1-fid;

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
float4 lineSystem_Pixel_Shader_main(float2 texCoord: TEXCOORD0,float alpha: TEXCOORD1) : COLOR {
	
	float4 Color = float4(tex2D(LineTexSampler,texCoord));
	Color.a = alpha;
	return Color;
}

technique lineSystem <
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

