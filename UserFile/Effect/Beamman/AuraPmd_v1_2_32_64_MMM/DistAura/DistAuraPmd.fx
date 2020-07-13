//MME_AuraPMD ver1.0
//�������ЂƁF���x���A�i�r�[���}��P�j

float4x4 World : CONTROLOBJECT < string name = "(self)";string item = "�Z���^�[";>;

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
#define BLENDMODE_DEST INVSRCALPHA

//�e�N�X�`����
texture Aura_Tex1
<
   string ResourceName = "MME_Aura_tex1.png";
>;
texture Aura_Tex2
<
   string ResourceName = "MME_Aura_tex2.png";
>;

//�O���T�C�Y�iSi�O�����[�t*���̃T�C�Y�j
float OutSize = float( 10 );
//�����T�C�Y�iSi�������[�t*���̃T�C�Y�j
float InSize = float( 10 );
//����(Si�������[�t*���̃T�C�Y)
float Height = float( 10 );
//�S�̂̊g��i�k���j�ő�l
float MaxSize = float(25);

//�����p�x�i360�őS���́j
float SpritRot = float( 360 );

//�e�N�X�`���X�N���[���������x
float ScrollSpd = float( 0 );

//�e�N�X�`���J��Ԃ��ő吔
float ScrollNum = float( 10 );

//�F�ݒ�
float4 Color = float4( 1, 1, 1, 1 );

//���邳�ő�l
float Brightness = float( 10 );

//���������x
float DefAlpha = float( 1 );

float param_outsize : CONTROLOBJECT < string name = "(self)"; string item = "Si�O��"; >;
float param_insize : CONTROLOBJECT < string name = "(self)"; string item = "Si����"; >;
float param_height : CONTROLOBJECT < string name = "(self)"; string item = "Si����"; >;
float param_local_p : CONTROLOBJECT < string name = "(self)"; string item = "Si�S��+"; >;
float param_local_m : CONTROLOBJECT < string name = "(self)"; string item = "Si�S��-"; >;
float param_h : CONTROLOBJECT < string name = "(self)"; string item = "�F��"; >;
float param_s : CONTROLOBJECT < string name = "(self)"; string item = "�ʓx"; >;
float param_b : CONTROLOBJECT < string name = "(self)"; string item = "���x"; >;
float param_split : CONTROLOBJECT < string name = "(self)"; string item = "�����p�x"; >;
float param_scroll_p : CONTROLOBJECT < string name = "(self)"; string item = "���x+"; >;
float param_scroll_m : CONTROLOBJECT < string name = "(self)"; string item = "���x-"; >;
float param_scroll_num : CONTROLOBJECT < string name = "(self)"; string item = "�J��Ԃ�"; >;
float param_endanm1 : CONTROLOBJECT < string name = "(self)"; string item = "���A�j��1"; >;
float param_endanm2 : CONTROLOBJECT < string name = "(self)"; string item = "���A�j��2"; >;
float param_alpha : CONTROLOBJECT < string name = "(self)"; string item = "�����x"; >;
float param_dist : CONTROLOBJECT < string name = "(self)"; string item = "�c��"; >;




//--�悭�킩��Ȃ��l�͂������牺�͂�������Ⴞ��--//
//HSB�ϊ��p�F�e�N�X�`��
texture2D ColorPallet <
    string ResourceName = "ColorPallet.png";
>;
sampler PalletSamp = sampler_state {
    texture = <ColorPallet>;
};
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

float time_0_X : Time;
//�΂̒l
#define PI 3.1415
//�p�x�����W�A���l�ɕϊ�
#define RAD(x) ((x * PI) / 180.0)

float4x4 ViewProjMatrix : VIEWPROJECTION;

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
   float4 LastPos: TEXCOORD2;
   float2 Vec: TEXCOORD3;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION,float2 Tex:TEXCOORD0){
   VS_OUTPUT Out;
   
   //�p�����[�^�K�p
   OutSize = OutSize * param_outsize;
   InSize = InSize * param_insize;
   Height = Height * param_height;
   SpritRot = SpritRot*(1-param_split);
   ScrollSpd += (param_scroll_p - param_scroll_m);
   
   Out.texCoord.x = Tex.y*(1+(ScrollNum*param_scroll_num));
   Out.texCoord.y = Tex.x;
   
   //Z�l�i0�`�P�j����p�x���v�Z���A���W�A���l�ɕϊ�����
   float rad = RAD(Tex.y * SpritRot);

   //--xz���W��ɔz�u����
   //�e�N�X�`�����W��0.5�ȉ�
   if(Tex.x < 0.5)
   {
   		Out.Pos.x = cos(rad) * OutSize;	
   		Out.Pos.z = sin(rad) * OutSize;
   		//y�l�͍����p�����[�^���̂܂�
   		//WAVE�̏ꍇ��TR�l�ɂ���č����ω�
   		float w = Height;
	    w = lerp(0,Height,(1-param_endanm1));
   		Out.Pos.y = w;
   }else{
	   //����
	   //DISC�̏ꍇ��TR�l�ɂ���ē����ω�
	    float w = InSize;
	    w = lerp(OutSize,InSize,(1-param_endanm2));
   		Out.Pos.x = cos(rad) * w;		   
   		Out.Pos.z = sin(rad) * w;
   		Out.Pos.y = 0;
   } 
   Out.Pos *= (param_local_p - param_local_m)*MaxSize + 2.0;
   Out.Pos.w = 1;
   Out.Pos = mul(Out.Pos, World);
   Out.Pos = mul(Out.Pos, ViewProjMatrix);
   Out.LastPos = Out.Pos;
   Out.color = (time_0_X * ScrollSpd) % 1.0;

	float2 NowScPos;
	float2 TgtScPos;
	float4 Now = mul(float4(0,0,0,1),ViewProjMatrix);
	float4 Prev = mul(float4(World[1].xyz,1),ViewProjMatrix);


	NowScPos.x = (Now.x / Now.w)*0.5+0.5;
	NowScPos.y = (-Now.y / Now.w)*0.5+0.5;

	TgtScPos.x = (Prev.x / Prev.w)*0.5+0.5;
	TgtScPos.y = (-Prev.y / Prev.w)*0.5+0.5;

	Out.Vec = normalize(NowScPos - TgtScPos);
	
   return Out;
}

//�e�N�X�`���̐ݒ�
sampler AuraTex1Sampler = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Aura_Tex1);
   //�e�N�X�`���͈�0.0�`1.0���I�[�o�[�����ۂ̏���
   //WRAP:���[�v
   ADDRESSU = WRAP;
   ADDRESSV = CLAMP;
   //�e�N�X�`���t�B���^�[
   //LINEAR:���`�t�B���^
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
//�e�N�X�`���̐ݒ�
sampler AuraTex2Sampler = sampler_state
{
   //�g�p����e�N�X�`��
   Texture = (Aura_Tex2);
   //�e�N�X�`���͈�0.0�`1.0���I�[�o�[�����ۂ̏���
   //WRAP:���[�v
   ADDRESSU = WRAP;
   ADDRESSV = CLAMP;
   //�e�N�X�`���t�B���^�[
   //LINEAR:���`�t�B���^
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
//�s�N�Z���V�F�[�_

//�ʓx�v�Z�p
const float4 calcY = float4( 0.2989f, 0.5866f, 0.1145f, 0.00f );

float4 lineSystem_Pixel_Shader_main(VS_OUTPUT IN) : COLOR {
	//���͂��ꂽ�e�N�X�`�����W�ɏ]���ĐF��I������

	float2 add = float2(IN.color,0);
	float4 col = float4(tex2D(AuraTex1Sampler,IN.texCoord + add));
	add.x += 0.1;
	float4 col2 = float4(tex2D(AuraTex2Sampler,IN.texCoord - add));
	
	float distcut = (1-col.b * col2.b) * (1-param_endanm1) * (1-param_endanm2);
	float4 c = normalize(col - col2);
	
	//�X�N���[�����W���v�Z
	float2 UVPos;
	UVPos.x = (IN.LastPos.x / IN.LastPos.w)*0.5+0.5;
	UVPos.y = (-IN.LastPos.y / IN.LastPos.w)*0.5+0.5;
	float4 Dist = tex2D(DistortionView,UVPos+float2(c.r,c.g)*0.1*distcut*param_dist);
	
	float4 pallet = tex2D(PalletSamp,float2(param_h,param_s))*param_b;
	Dist.rgb += pallet*distcut*param_dist;
	Dist.a = (1-param_alpha);
	return Dist;
}

//�e�N�j�b�N�̒�`
technique lineSystem  < string MMDPass = "object_ss"; > {
   //���C���p�X
   pass lineSystem
   {
      //Z�l�̍l���F����
      ZENABLE = TRUE;
      //Z�l�̕`��F���Ȃ�
      ZWRITEENABLE = TRUE;
      //�J�����O�I�t�i���ʕ`��
      CULLMODE = NONE;
      //���u�����h���g�p����
      ALPHABLENDENABLE = TRUE;
      //���u�����h�̐ݒ�i�ڂ����͍ŏ��̒萔���Q�Ɓj
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      //�g�p����V�F�[�_��ݒ�
      VertexShader = compile vs_2_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_2_0 lineSystem_Pixel_Shader_main();
   }
}
technique lineSystem  < string MMDPass = "object"; > {
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
      VertexShader = compile vs_2_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_2_0 lineSystem_Pixel_Shader_main();
   }
}
technique EdgeTec < string MMDPass = "edge"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}