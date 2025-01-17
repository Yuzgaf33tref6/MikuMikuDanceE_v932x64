xof 0302txt 0064
template Header {
 <3D82AB43-62DA-11cf-AB39-0020AF71E433>
 WORD major;
 WORD minor;
 DWORD flags;
}

template Vector {
 <3D82AB5E-62DA-11cf-AB39-0020AF71E433>
 FLOAT x;
 FLOAT y;
 FLOAT z;
}

template Coords2d {
 <F6F23F44-7686-11cf-8F52-0040333594A3>
 FLOAT u;
 FLOAT v;
}

template Matrix4x4 {
 <F6F23F45-7686-11cf-8F52-0040333594A3>
 array FLOAT matrix[16];
}

template ColorRGBA {
 <35FF44E0-6C7C-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
 FLOAT alpha;
}

template ColorRGB {
 <D3E16E81-7835-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
}

template IndexedColor {
 <1630B820-7842-11cf-8F52-0040333594A3>
 DWORD index;
 ColorRGBA indexColor;
}

template Boolean {
 <4885AE61-78E8-11cf-8F52-0040333594A3>
 WORD truefalse;
}

template Boolean2d {
 <4885AE63-78E8-11cf-8F52-0040333594A3>
 Boolean u;
 Boolean v;
}

template MaterialWrap {
 <4885AE60-78E8-11cf-8F52-0040333594A3>
 Boolean u;
 Boolean v;
}

template TextureFilename {
 <A42790E1-7810-11cf-8F52-0040333594A3>
 STRING filename;
}

template Material {
 <3D82AB4D-62DA-11cf-AB39-0020AF71E433>
 ColorRGBA faceColor;
 FLOAT power;
 ColorRGB specularColor;
 ColorRGB emissiveColor;
 [...]
}

template MeshFace {
 <3D82AB5F-62DA-11cf-AB39-0020AF71E433>
 DWORD nFaceVertexIndices;
 array DWORD faceVertexIndices[nFaceVertexIndices];
}

template MeshFaceWraps {
 <4885AE62-78E8-11cf-8F52-0040333594A3>
 DWORD nFaceWrapValues;
 Boolean2d faceWrapValues;
}

template MeshTextureCoords {
 <F6F23F40-7686-11cf-8F52-0040333594A3>
 DWORD nTextureCoords;
 array Coords2d textureCoords[nTextureCoords];
}

template MeshMaterialList {
 <F6F23F42-7686-11cf-8F52-0040333594A3>
 DWORD nMaterials;
 DWORD nFaceIndexes;
 array DWORD faceIndexes[nFaceIndexes];
 [Material]
}

template MeshNormals {
 <F6F23F43-7686-11cf-8F52-0040333594A3>
 DWORD nNormals;
 array Vector normals[nNormals];
 DWORD nFaceNormals;
 array MeshFace faceNormals[nFaceNormals];
}

template MeshVertexColors {
 <1630B821-7842-11cf-8F52-0040333594A3>
 DWORD nVertexColors;
 array IndexedColor vertexColors[nVertexColors];
}

template Mesh {
 <3D82AB44-62DA-11cf-AB39-0020AF71E433>
 DWORD nVertices;
 array Vector vertices[nVertices];
 DWORD nFaces;
 array MeshFace faces[nFaces];
 [...]
}

Header{
1;
0;
1;
}

Mesh {
 51;
 0.06697;1.66159;-0.16168;,
 0.13394;0.00000;-0.32336;,
 0.00000;0.00000;-0.35000;,
 0.00000;1.66159;-0.17500;,
 0.12374;1.66159;-0.12374;,
 0.24749;0.00000;-0.24749;,
 0.16168;1.66159;-0.06697;,
 0.32336;0.00000;-0.13394;,
 0.17500;1.66159;0.00000;,
 0.35000;0.00000;0.00000;,
 0.16168;1.66159;0.06697;,
 0.32336;0.00000;0.13394;,
 0.12374;1.66159;0.12374;,
 0.24749;0.00000;0.24749;,
 0.06697;1.66159;0.16168;,
 0.13394;0.00000;0.32336;,
 0.00000;1.66159;0.17500;,
 0.00000;0.00000;0.35000;,
 -0.06697;1.66159;0.16168;,
 -0.13394;0.00000;0.32336;,
 -0.12374;1.66159;0.12374;,
 -0.24749;0.00000;0.24749;,
 -0.16168;1.66159;0.06697;,
 -0.32336;0.00000;0.13394;,
 -0.17500;1.66159;-0.00000;,
 -0.35000;0.00000;-0.00000;,
 -0.16168;1.66159;-0.06697;,
 -0.32336;0.00000;-0.13394;,
 -0.12374;1.66159;-0.12374;,
 -0.24749;0.00000;-0.24749;,
 -0.06697;1.66159;-0.16168;,
 -0.13394;0.00000;-0.32336;,
 0.00000;1.66159;-0.17500;,
 0.00000;0.00000;-0.35000;,
 0.00000;0.00000;-0.03500;,
 0.01339;0.00000;-0.03234;,
 0.02475;0.00000;-0.02475;,
 0.03234;0.00000;-0.01339;,
 0.03500;0.00000;0.00000;,
 0.03234;0.00000;0.01339;,
 0.02475;0.00000;0.02475;,
 0.01339;0.00000;0.03234;,
 0.00000;0.00000;0.03500;,
 -0.01339;0.00000;0.03234;,
 -0.02475;0.00000;0.02475;,
 -0.03234;0.00000;0.01339;,
 -0.03500;0.00000;-0.00000;,
 -0.03234;0.00000;-0.01339;,
 -0.02475;0.00000;-0.02475;,
 -0.01339;0.00000;-0.03234;,
 0.00000;0.00000;-0.03500;;
 
 64;
 3;0,1,2;,
 3;0,2,3;,
 3;4,5,1;,
 3;4,1,0;,
 3;6,7,5;,
 3;6,5,4;,
 3;8,9,7;,
 3;8,7,6;,
 3;10,11,9;,
 3;10,9,8;,
 3;12,13,11;,
 3;12,11,10;,
 3;14,15,13;,
 3;14,13,12;,
 3;16,17,15;,
 3;16,15,14;,
 3;18,19,17;,
 3;18,17,16;,
 3;20,21,19;,
 3;20,19,18;,
 3;22,23,21;,
 3;22,21,20;,
 3;24,25,23;,
 3;24,23,22;,
 3;26,27,25;,
 3;26,25,24;,
 3;28,29,27;,
 3;28,27,26;,
 3;30,31,29;,
 3;30,29,28;,
 3;32,33,31;,
 3;32,31,30;,
 3;0,34,35;,
 3;0,3,34;,
 3;4,35,36;,
 3;4,0,35;,
 3;6,36,37;,
 3;6,4,36;,
 3;8,37,38;,
 3;8,6,37;,
 3;10,38,39;,
 3;10,8,38;,
 3;12,39,40;,
 3;12,10,39;,
 3;14,40,41;,
 3;14,12,40;,
 3;16,41,42;,
 3;16,14,41;,
 3;18,42,43;,
 3;18,16,42;,
 3;20,43,44;,
 3;20,18,43;,
 3;22,44,45;,
 3;22,20,44;,
 3;24,45,46;,
 3;24,22,45;,
 3;26,46,47;,
 3;26,24,46;,
 3;28,47,48;,
 3;28,26,47;,
 3;30,48,49;,
 3;30,28,48;,
 3;32,49,50;,
 3;32,30,49;;
 
 MeshMaterialList {
  1;
  64;
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0;;
  Material {
   0.800000;0.800000;0.800000;1.000000;;
   5.000000;
   0.000000;0.000000;0.000000;;
   0.000000;0.000000;0.000000;;
  }
 }
 MeshNormals {
  64;
  -0.065796;0.104515;-0.992344;,
  0.318966;0.104515;-0.941986;,
  0.655168;0.104515;-0.748219;,
  0.891627;0.104515;-0.440542;,
  0.992344;0.104515;-0.065796;,
  0.941986;0.104515;0.318966;,
  0.748219;0.104515;0.655168;,
  0.440542;0.104515;0.891627;,
  0.065797;0.104515;0.992344;,
  -0.318966;0.104515;0.941986;,
  -0.655168;0.104515;0.748219;,
  -0.891627;0.104515;0.440542;,
  -0.992344;0.104515;0.065797;,
  -0.941986;0.104515;-0.318966;,
  -0.748218;0.104515;-0.655169;,
  -0.440542;0.104515;-0.891628;,
  0.065797;0.104515;-0.992344;,
  0.440542;0.104515;-0.891627;,
  0.748219;0.104515;-0.655168;,
  0.941986;0.104515;-0.318966;,
  0.992344;0.104515;0.065797;,
  0.891627;0.104515;0.440542;,
  0.655168;0.104515;0.748219;,
  0.318966;0.104515;0.941986;,
  -0.065796;0.104515;0.992344;,
  -0.440542;0.104515;0.891628;,
  -0.748219;0.104515;0.655169;,
  -0.941986;0.104515;0.318966;,
  -0.992344;0.104515;-0.065797;,
  -0.891627;0.104515;-0.440542;,
  -0.655168;0.104515;-0.748219;,
  -0.318965;0.104515;-0.941986;,
  -0.065926;0.083777;0.994301;,
  -0.441411;0.083777;0.893386;,
  -0.749694;0.083777;0.656460;,
  -0.943844;0.083777;0.319595;,
  -0.994301;0.083777;-0.065926;,
  -0.893386;0.083777;-0.441411;,
  -0.656460;0.083777;-0.749694;,
  -0.319595;0.083777;-0.943843;,
  0.065926;0.083777;-0.994301;,
  0.441410;0.083777;-0.893386;,
  0.749694;0.083777;-0.656461;,
  0.943843;0.083777;-0.319595;,
  0.994301;0.083777;0.065926;,
  0.893386;0.083777;0.441411;,
  0.656460;0.083777;0.749694;,
  0.319594;0.083777;0.943844;,
  -0.319595;0.083777;0.943844;,
  0.065926;0.083777;0.994301;,
  -0.656460;0.083777;0.749694;,
  -0.893386;0.083777;0.441411;,
  -0.994301;0.083777;0.065926;,
  -0.943843;0.083777;-0.319595;,
  -0.749694;0.083777;-0.656460;,
  -0.441411;0.083777;-0.893386;,
  -0.065926;0.083777;-0.994301;,
  0.319595;0.083777;-0.943844;,
  0.656460;0.083777;-0.749694;,
  0.893386;0.083777;-0.441411;,
  0.994301;0.083777;-0.065926;,
  0.943843;0.083777;0.319595;,
  0.749694;0.083777;0.656461;,
  0.441410;0.083777;0.893386;;
  64;
  3;1,17,16;,
  3;1,16,0;,
  3;2,18,17;,
  3;2,17,1;,
  3;3,19,18;,
  3;3,18,2;,
  3;4,20,19;,
  3;4,19,3;,
  3;5,21,20;,
  3;5,20,4;,
  3;6,22,21;,
  3;6,21,5;,
  3;7,23,22;,
  3;7,22,6;,
  3;8,24,23;,
  3;8,23,7;,
  3;9,25,24;,
  3;9,24,8;,
  3;10,26,25;,
  3;10,25,9;,
  3;11,27,26;,
  3;11,26,10;,
  3;12,28,27;,
  3;12,27,11;,
  3;13,29,28;,
  3;13,28,12;,
  3;14,30,29;,
  3;14,29,13;,
  3;15,31,30;,
  3;15,30,14;,
  3;0,16,31;,
  3;0,31,15;,
  3;48,32,33;,
  3;48,49,32;,
  3;50,33,34;,
  3;50,48,33;,
  3;51,34,35;,
  3;51,50,34;,
  3;52,35,36;,
  3;52,51,35;,
  3;53,36,37;,
  3;53,52,36;,
  3;54,37,38;,
  3;54,53,37;,
  3;55,38,39;,
  3;55,54,38;,
  3;56,39,40;,
  3;56,55,39;,
  3;57,40,41;,
  3;57,56,40;,
  3;58,41,42;,
  3;58,57,41;,
  3;59,42,43;,
  3;59,58,42;,
  3;60,43,44;,
  3;60,59,43;,
  3;61,44,45;,
  3;61,60,44;,
  3;62,45,46;,
  3;62,61,45;,
  3;63,46,47;,
  3;63,62,46;,
  3;49,47,32;,
  3;49,63,47;;
 }
 MeshTextureCoords {
  51;
  0.062500;0.000000;,
  0.062500;1.000000;,
  0.000000;1.000000;,
  0.000000;0.000000;,
  0.125000;0.000000;,
  0.125000;1.000000;,
  0.187500;0.000000;,
  0.187500;1.000000;,
  0.250000;0.000000;,
  0.250000;1.000000;,
  0.312500;0.000000;,
  0.312500;1.000000;,
  0.375000;0.000000;,
  0.375000;1.000000;,
  0.437500;0.000000;,
  0.437500;1.000000;,
  0.500000;0.000000;,
  0.500000;1.000000;,
  0.562500;0.000000;,
  0.562500;1.000000;,
  0.625000;0.000000;,
  0.625000;1.000000;,
  0.687500;0.000000;,
  0.687500;1.000000;,
  0.750000;0.000000;,
  0.750000;1.000000;,
  0.812500;0.000000;,
  0.812500;1.000000;,
  0.875000;0.000000;,
  0.875000;1.000000;,
  0.937500;0.000000;,
  0.937500;1.000000;,
  1.000000;0.000000;,
  1.000000;1.000000;,
  0.000000;1.000000;,
  0.062500;1.000000;,
  0.125000;1.000000;,
  0.187500;1.000000;,
  0.250000;1.000000;,
  0.312500;1.000000;,
  0.375000;1.000000;,
  0.437500;1.000000;,
  0.500000;1.000000;,
  0.562500;1.000000;,
  0.625000;1.000000;,
  0.687500;1.000000;,
  0.750000;1.000000;,
  0.812500;1.000000;,
  0.875000;1.000000;,
  0.937500;1.000000;,
  1.000000;1.000000;;
 }
}
