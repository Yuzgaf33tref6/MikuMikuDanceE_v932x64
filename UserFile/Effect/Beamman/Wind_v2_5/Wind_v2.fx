//���G�t�F�N�g �R���g���[���Ή���
//�������ЂƁF���x���A�i�r�[���}��P�j

//�R���g���[������`
#define CONTORLLER_NAME "WindController_0.pmx"

//�p�����[�^�擾
float3 b_AnmSpd : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�Đ����x"; >;
float3 b_TexNum : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�J��Ԃ���"; >;
float3 b_LHeight : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�ʍ���"; >;
float3 b_LRot : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�p�x��"; >;
float3 b_ObjNum : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b������"; >;
float3 b_WHeight : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�S�̍���"; >;
float3 b_Scale : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�L���苭��"; >;
float3 b_ScaleRnd : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�L���蕝"; >;
float3 b_WRot : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b��]���x"; >;
float3 b_PosRnd : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�ʒu����"; >;
float3 b_h : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�F��"; >;
float3 b_s : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�ʓx"; >;
float3 b_b : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b���x"; >;
float3 b_a : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�����x"; >;
float3 b_d : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�c�ݗ�"; >;
float3 b_bri : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�P�x"; >;
float3 b_Size : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "b�ŏ����a"; >;


float m_AnmSpd : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�Đ����x"; >;
float m_TexNum : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�J��Ԃ���"; >;
float m_LHeight : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�ʍ���"; >;
float m_LRot : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�p�x��"; >;
float m_ObjNum : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "������"; >;
float m_WHeight : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�S�̍���"; >;
float m_Scale : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�L���苭��"; >;
float m_ScaleRnd : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�L���蕝"; >;
float m_WRot : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "��]���x"; >;
float m_PosRnd : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�ʒu����"; >;
float m_h : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�F��"; >;
float m_s : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�ʓx"; >;
float m_b : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "���x"; >;
float m_a : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�����x"; >;
float m_d : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�c�ݗ�"; >;
float m_bri : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�P�x"; >;
float m_Size : CONTROLOBJECT < string name = CONTORLLER_NAME; string item = "�ŏ����a"; >;





//�����̖{��
int CloneNum = 128;

//�e�N�X�`����
texture Aura_Tex1
<
   string ResourceName = "Wind_Tex.png";
>;

//�S�̂̍Đ����x
float AnmSpd = 2;

//�S�̂̍���
float Height = 30;

//�z�u���̒�������̂���̗�����
float SetPosRand = 32;

//���ЂƂЂƂ̍����ő�l
float LocalHeight = 2;

//���̍L���苭��
float WindSizeSpd = 5;

//�L����̗�����
float WindSizeRnd = 0;

//�e�N�X�`���J��Ԃ���
float ScrollNum = 1;

//�F�ݒ�
float3 Color = float3( 1, 1, 1 );

//���邳
float Brightness = 10;

//�c�ݗ�
float DistPow = 10;

//�S�̂̉�]���x
float RotateSpd = 0.5;

//�ʉ�]�W���i�X���̂΂���j
float RotateRatio = 0.25;

//�ŏ����a
float MinSize = 5;

//���ˎ��ԃI�t�Z�b�g�i�����_���l�j
float ShotRandOffset = 0;

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


//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//

float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

//HSB�ϊ��p�F�e�N�X�`��
texture2D ColorPallet <
    string ResourceName = "ColorPallet.png";
>;
sampler PalletSamp = sampler_state {
    texture = <ColorPallet>;
    AddressU  = WRAP;
    AddressV = CLAMP;
};


//�v�Z�p�e�N�X�`���T�C�Y
#define TEX_SIZE 1024

#define TEX_WIDTH TEX_SIZE
#define TEX_HEIGHT TEX_SIZE

texture DistortionRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for DistortionField.fx";
    int Width = TEX_SIZE;
    int Height = TEX_SIZE;
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;";
>;

sampler DistortionView = sampler_state {
    texture = <DistortionRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};



texture2D rndtex <
    string ResourceName = "random1024.bmp";
>;
sampler rnd = sampler_state {
    texture = <rndtex>;
};


float time_0_X : Time;
//�΂̒l
#define PI 3.1415
//�p�x�����W�A���l�ɕϊ�
#define RAD(x) ((x * PI) / 180.0)

float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
   float alpha: TEXCOORD2;
   float4 CenterPos: TEXCOORD3;
   float4 DistPos: TEXCOORD4;
};

//�ۑ��p�ϐ�
int index = 0;
//���ˎ���
float ThunderWaitTime = 60;

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){

	m_ObjNum = saturate(m_ObjNum+(b_ObjNum.x)*0.1);
	m_Size += (b_Size.x)*0.025;
	m_PosRnd += (b_PosRnd.x)*0.005;
	m_LHeight += (b_LHeight.x)*0.1;
	m_LRot += (b_LRot.x)*0.1;
	m_WHeight += (b_WHeight.x)*0.1;
	m_Scale += (b_Scale.x)*0.1;
	m_ScaleRnd += (b_ScaleRnd.x)*0.1;
	m_WRot += (b_WRot.x)*0.1;
	m_TexNum += (b_TexNum.x)*0.1;
	m_AnmSpd += (b_AnmSpd.x)*0.1;



	SetPosRand *= m_PosRnd;
	WindSizeSpd*= m_Scale;
	WindSizeRnd+= m_ScaleRnd*2;
	ScrollNum+=m_TexNum*5;
	RotateRatio *= m_LRot;
	RotateSpd *= m_WRot;
	MinSize *= m_Size;
	
   VS_OUTPUT Out;
    float fCloneNum = CloneNum;
    fCloneNum *= m_ObjNum;
    float findex = index;
	float offset = findex*(ThunderWaitTime / (fCloneNum*ThunderWaitTime)) + sin(findex)*ShotRandOffset;
	float time_buf = time_0_X*AnmSpd*m_AnmSpd + offset;
    float t = time_buf*60;
 
 //�����_���l
  float3 rand = tex2Dlod(rnd, float4(findex/(float)fCloneNum,0,0,1));
   t %= ThunderWaitTime;

 
   Out.texCoord.y = (Pos.x + 1)/2 - 0.001;
   Out.texCoord.x = Pos.z * ScrollNum + rand.x;
   if(t > ThunderWaitTime/2 * (60/ThunderWaitTime))
   {
   		t = 0;
   }
   Out.alpha = t / (ThunderWaitTime/2 * (60/ThunderWaitTime));
   
   MinSize += t*0.05*WindSizeSpd*WindSizeRnd*rand.z;
   float h = saturate(t*0.05)*LocalHeight*m_LHeight;
   //Z�l�i0�`�P�j����p�x���v�Z���A���W�A���l�ɕϊ�����
   float rad = RAD(Pos.z * 360);
   
   
   //--xz���W��ɔz�u����
   
   //x���}�C�i�X=�O��
   if(Pos.x < 0)
   {
   		Out.Pos.x = cos(rad) * MinSize;	
   		Out.Pos.z = sin(rad) * MinSize;
   		//y�l�͍����p�����[�^���̂܂�
   		Out.Pos.y = h/2;
   }else{
	   //����
   		Out.Pos.x = cos(rad) * MinSize;		   
   		Out.Pos.z = sin(rad) * MinSize;
   		Out.Pos.y = -h/2;
   } 
   float4 Center = Out.Pos;
   Center.y = 0;
   Center.w = 1;
   Out.Pos.w = 1;
   
	float radx = (-0.5 + rand.x)*2*2*3.1415;
	float radz = (-0.5 + rand.z)*2*2*3.1415;
	float rady = time_0_X*RotateSpd*10*m_WRot;
	radx *= RotateRatio;
	radz *= RotateRatio;

  float4x4 matRot;
   
   //Y����] 
   matRot[0] = float4(cos(rady),0,-sin(rady),0); 
   matRot[1] = float4(0,1,0,0); 
   matRot[2] = float4(sin(rady),0,cos(rady),0); 
   matRot[3] = float4(0,0,0,1); 
 
   Out.Pos = mul(Out.Pos,matRot);
   Center = mul(Center,matRot);
   
   
   //X����]
   matRot[0] = float4(1,0,0,0); 
   matRot[1] = float4(0,cos(radx),sin(radx),0); 
   matRot[2] = float4(0,-sin(radx),cos(radx),0); 
   matRot[3] = float4(0,0,0,1); 
   
   Out.Pos = mul(Out.Pos,matRot);
   Center = mul(Center,matRot);
 
   //Z����]
   matRot[0] = float4(cos(radz),sin(radz),0,0); 
   matRot[1] = float4(-sin(radz),cos(radz),0,0); 
   matRot[2] = float4(0,0,1,0); 
   matRot[3] = float4(0,0,0,1); 
   
   Out.Pos = mul(Out.Pos,matRot);
   Center = mul(Center,matRot);
   
   Out.Pos.x += rand.x*SetPosRand-SetPosRand/2;
   Out.Pos.z += rand.z*SetPosRand-SetPosRand/2;
   
   Out.Pos.y += rand.y*Height*m_WHeight;
   Center.y  += rand.y*Height*m_WHeight;
   Out.Pos = mul(Out.Pos, WorldViewProjMatrix);
   Center = mul(Center, WorldViewProjMatrix);
   Out.color = t;


	Out.DistPos = Out.Pos;
	Out.CenterPos = Center;
	
	//������`�F�b�N
	if(findex >= fCloneNum)
	{
		Out.Pos.w = -2;
	}
	
   return Out;
}

//�e�N�X�`���̐ݒ�
sampler AuraTex1Sampler = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Aura_Tex1);
   //�e�N�X�`���͈�0.0�`1.0���I�[�o�[�����ۂ̏���
   //WRAP:���[�vCenter
   ADDRESSU = WRAP;
   ADDRESSV = CLAMP;
   //�e�N�X�`���t�B���^�[
   //LINEAR:���`�t�B���^
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};

//�s�N�Z���V�F�[�_

float4 lineSystem_Pixel_Shader_main(VS_OUTPUT IN) : COLOR {
   //���͂��ꂽ�e�N�X�`�����W�ɏ]���ĐF��I������
   	
	m_h += (b_h.x)*0.1;
	m_s += (b_s.x)*0.1;
	m_b += (b_b.x)*0.1;
	m_a = saturate(m_a + (b_a)*0.1);
	m_d += (b_d.x)*0.1;
	m_bri += (b_bri.x)*0.1;	
	
	//�A���t�@�l
	float a = saturate(IN.alpha+m_a);
	
	float4 col;
	//�f�J�[���e�N�X�`���`��ǂݍ���
	float4 decal = float4(tex2D(AuraTex1Sampler,IN.texCoord));   

	//--�c�ݓ���w�i�擾--//
	
	//�X�N���[������W���v�Z
	float3 Center;
	Center = IN.CenterPos.xyz/IN.CenterPos.w;
	Center.y *= -1;
	Center.xy += 1;
	Center.xy *= 0.5;
	float3 DistTgt;
	DistTgt = IN.DistPos.xyz/IN.DistPos.w;
	DistTgt.y *= -1;
	DistTgt.xy += 1;
	DistTgt.xy *= 0.5;
	
	
	
	DistPow = m_d*DistPow*a;
	float dif = decal.r*DistPow;  
	//�e�N�X�`���̃x�N�g��
	float2 tex_vec = normalize(DistTgt.xy - Center.xy);
	col.rgb = tex2D(DistortionView,DistTgt.xy+tex_vec*0.025*dif).rgb;
	col.a = 1;

	//�p���b�g����F�擾
	float4 pallet = tex2D(PalletSamp,float2(m_h,m_s))*(1-m_a);
	pallet.a = 1;
	//�f�J�[���̔������ɏ]���č��
	pallet.rgb *= (pallet.rgb + decal.r) * decal.r * a * 10;
	//�e�F������1�𒴂������͑��F�Ɉ���
	float3 over_col = saturate((pallet.rgb - 0.5)*0.5);
	float over = over_col.r + over_col.g + over_col.b;
	pallet.rgb += over*5*m_bri;
	pallet.rgb *= (1-IN.alpha);
	pallet.rgb *= (1-m_a);
	//�x�[�X�ɉ��Z����
	col += pallet;
	col -= m_b*5*(1-m_a);
	col = saturate(col);
	col.a = decal.r*10;
	col.a *= 1-saturate(IN.alpha);

	return col;
}

//�e�N�j�b�N�̒�`
technique lineSystem <
    string Script = 
		//�`��Ώۂ����C����ʂ�
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    //�p�X�̑I��
		"LoopByCount=CloneNum;"
        "LoopGetIndex=index;"
	    "Pass=lineSystem;"
        "LoopEnd=;"
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

