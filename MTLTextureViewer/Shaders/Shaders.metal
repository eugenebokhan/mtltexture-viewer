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

vertex VertexOut vertexFunction(uint vertexID [[ vertex_id ]],
                                constant float4x4& transform [[ buffer(0) ]]) {
    float2 uv = vertices[vertexID];
    uv.y *= -1.0f;

    VertexOut out = {
        transform * float4(vertices[vertexID], 0.0f, 1.0f),
        fma(uv, 0.5f, 0.5f)
    };
    return out;
}

fragment half4 fragmentFunction(VertexOut in [[ stage_in ]],
                                texture2d<half, access::sample> sourceTexture [[ texture(0) ]],
                                sampler s [[ sampler(0) ]]) {
    const auto targetPosition = float3(in.uv, 1.0f).xy;
    return sourceTexture.sample(s, targetPosition);
}
