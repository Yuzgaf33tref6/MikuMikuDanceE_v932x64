////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float4 Color_White = {1,1,1,1};
float4 Color_Black = {0,0,0,1};

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = MaterialDiffuse.a;
//�X�P�[��
float4x4 WorldMatrix : WORLD;
static float scaling = length(WorldMatrix._11_12_13) * 0.1;

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT VS_Black(float4 Pos : POSITION)
{
    VS_OUTPUT Out;
    
    Out.Pos = Pos;
    Out.Pos.zw = 1;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Black() : COLOR0
{
	float4 color = Color_Black;
	color.a = saturate(alpha1 + (1 - scaling));
    return color;
}


technique SLMC {
    
    pass Single_Pass {
    	ZENABLE = false;
    	VertexShader = compile vs_2_0 VS_Black();
        PixelShader  = compile ps_2_0 PS_Black();
    }    
}

technique SLMC_SS < string MMDPass = "object_ss"; > {
    
    pass Single_Pass {
    	ZENABLE = false;
    	VertexShader = compile vs_2_0 VS_Black();
        PixelShader  = compile ps_2_0 PS_Black();
    }
}

