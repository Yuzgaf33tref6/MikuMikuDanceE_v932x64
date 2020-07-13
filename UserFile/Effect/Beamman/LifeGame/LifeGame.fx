//�v�Z����
int CalcSpd = 2;

//�F�ݒ�i0�`1)
float4 DotColor[]=
{
{0,0,0,0},	//�����l0(�w�i)
{0,0,2,1},	//�����l1
{0,1,3,1},	//�����l2
{0,2,4,1},	//�����l3
};

//�e�N�X�`���T�C�Y
#define TEX_SIZE 64

//��ʒ[�J��Ԃ��ݒ�
//#define AddresMode WRAP
#define AddresMode Border

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse        : WORLDVIEWINVERSE;

//���C�t�Q�[���p�v�Z�e�N�X�`��
texture LifeTex : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
>;
sampler LifeTex_Samp = sampler_state
{
	// ���p����e�N�X�`��
	Texture = <LifeTex>;
    Filter = NONE;
    AddressU = AddresMode;		// �J��Ԃ�
    AddressV = AddresMode;		// �J��Ԃ�
};
//���C�t�Q�[���p�e�N�X�`���ۑ��p
texture LifeTex_Buf : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
>;
sampler LifeTex_Buf_Samp = sampler_state
{
	// ���p����e�N�X�`��
	Texture = <LifeTex_Buf>;
    Filter = NONE;
    AddressU = AddresMode;		// �J��Ԃ�
    AddressV = AddresMode;		// �J��Ԃ�
};
//���C�t�Q�[�������l�e�N�X�`��
texture Life_Zero
<
   string ResourceName = "life.png";
>;
sampler Life_Zero_Samp = sampler_state
{
	// ���p����e�N�X�`��
	Texture = <Life_Zero>;
    Filter = NONE;
    AddressU = AddresMode;		// �J��Ԃ�
    AddressV = AddresMode;		// �J��Ԃ�
};
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
    string Format = "D24S8";
>;

float time : Time;
static float2 SampStep = (float2(1,1)/TEX_SIZE);

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
};

//���C�t�Q�[���v�Z�p
VS_OUTPUT Cpu_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5/TEX_SIZE, 0.5/TEX_SIZE);
   return Out;
}
static float2 test[8] = 
		{
			{0,1},{0,-1},
			{1,0},{1,1},{1,-1},
			{-1,0},{-1,1},{-1,-1},
		};

float4 Calc_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
	float4 col = 0;
	
	int nTime = time*30;
	
	//0F�ڂ͏����l������
	if(time == 0)
	{
		col = tex2D( Life_Zero_Samp, Tex);
	}else if(nTime%CalcSpd == 0){
		//���C���v�Z
		float4 Now = tex2D(LifeTex_Buf_Samp,Tex);
		
		int LiveCnt = 0;
		for(int i=0;i<8;i++)
		{
			float4 Tgt = tex2D(LifeTex_Buf_Samp,Tex+test[i]*SampStep);
			LiveCnt += (Tgt.r != 0);
		}
		//����
		if(Now.r != 0 && (LiveCnt == 2 || LiveCnt == 3))
		{
			if(LiveCnt == 3)
				col.rgb = float3(1,0.5,0);
			else
				col.rgb = float3(1,0.75,0);
		}else
		//�a��
		if(LiveCnt == 3)
		{
			col.rgb = float3(0.5,1,0);
		}else		
		//����
		if(LiveCnt <= 1 || LiveCnt >= 4)
		{
			col.rgb = 0;
		}
	}else{
		col = tex2D(LifeTex_Buf_Samp,Tex);
	}
	col.a = 1;
	//return tex2D(Life_Zero_Samp,Tex);

    return col;
}
float4 Cpy_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
	float4 col;
	col = tex2D( LifeTex_Samp, Tex );
    return col;
}

// ���_�V�F�[�_
VS_OUTPUT Mask_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}
// �s�N�Z���V�F�[�_
float4 Mask_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
	float4 col = tex2D( LifeTex_Buf_Samp, Tex );
	if(col.g < 0.5-0.1)
	{
		col = DotColor[0];
	}else if(col.g < 0.75-0.1){
		col = DotColor[1];
	}else if(col.g <  1-0.1){
		col = DotColor[2];
	}else{
		col = DotColor[3];
	}
    return col;
}

float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

technique MainTec < 
	string MMDPass = "object";
	string Script = 
		"ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
    	
    	//�e�N�X�`���v�Z
	    "RenderDepthStencilTarget=DepthBuffer;"
        "RenderColorTarget0=LifeTex;"
	    "Pass=CalcLife;"
        
        //�e�N�X�`���R�s�[
        "RenderColorTarget0=LifeTex_Buf;"
	    "Pass=CopyLife;"

		//���C���`��
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=MainPath;"
    ;
 > {
    pass CalcLife < string Script = "Draw=Buffer;";> {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Cpu_VS();
        PixelShader  = compile ps_3_0 Calc_PS();
    }
    pass CopyLife < string Script = "Draw=Buffer;";> {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Cpu_VS();
        PixelShader  = compile ps_3_0 Cpy_PS();
    }
    pass MainPath {
    	CULLMODE = NONE;
        VertexShader = compile vs_3_0 Mask_VS();
        PixelShader  = compile ps_3_0 Mask_PS();
    }
}

