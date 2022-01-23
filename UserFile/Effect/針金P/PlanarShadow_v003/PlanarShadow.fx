////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PlanarShadow.fx ver0.0.3 MMD�̒n�ʉe��C�ӂ̕��ʂɓ��e�ł���悤�ɂ��܂�
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

float3 PlanarPos = float3(0.0, 10.0, 0.0);    // ���e���镽�ʏ�̔C�ӂ̍��W
float3 PlanarNormal = float3(0.0, 1.0, 0.0);  // ���e���镽�ʂ̖@���x�N�g��


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 ViewProjMatrix  : VIEWPROJECTION;
float3   LightDirection  : DIRECTION < string Object = "Light"; >;

//  �n�ʉe�F
float4 GroundShadowColor : GROUNDSHADOWCOLOR;


///////////////////////////////////////////////////////////////////////////////////////////////
// �C�ӕ��ʂ̉e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
    // �����̉��ʒu(���s�����Ȃ̂�)
    float3 LightPos = Pos.xyz + LightDirection;

    // �C�ӕ��ʂɓ��e
    float a = dot(PlanarNormal, PlanarPos - LightPos);
    float b = dot(PlanarNormal, Pos.xyz - PlanarPos);
    float c = dot(PlanarNormal, Pos.xyz - LightPos);
    Pos = float4(Pos.xyz * a + LightPos * b, c);

    // �r���[�ˉe�ϊ�
    return mul( Pos, ViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
    // �n�ʉe�F�œh��Ԃ�
    return GroundShadowColor;
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
    pass DrawShadow {
        VertexShader = compile vs_2_0 Shadow_VS();
        PixelShader  = compile ps_2_0 Shadow_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
