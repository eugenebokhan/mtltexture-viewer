//
//  Shaders.metal
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 21.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
    float2 uv;
};

constant float2 vertices[] = {
    float2(-1.0f, 1.0f), float2(-1.0f, -1.0f),
    float2(1.0f, 1.0f), float2(1.0f, -1.0f)
};

vertex VertexOut vertexFunction(uint vertexID [[ vertex_id ]]) {
    float2 uv = vertices[vertexID];
    uv.y = -uv.y;

    VertexOut out {
      .position = float4(vertices[vertexID], 0.0, 1.0),
      .uv = fma(uv, 0.5f, 0.5f)
    };

    return out;
}

fragment half4 fragmentFunction(VertexOut in [[ stage_in ]],
                                texture2d<half, access::sample> sourceTexture [[ texture(0) ]],
                                sampler s [[ sampler(0) ]]) {
    return half4(sourceTexture.sample(s, in.uv));;
}
