//
//  Renderer.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 21.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Alloy
import MetalKit

class Renderer {

    // MARK: - Properties

    private let renderPipelineState: MTLRenderPipelineState

    // MARK: - Init

    public init(context: MTLContext) throws {
        guard let library = context.shaderLibrary(for: Self.self)
        else { throw MetalError.MTLDeviceError.libraryCreationFailed }

        let renderStateDescriptor = MTLRenderPipelineDescriptor()
        renderStateDescriptor.vertexFunction = library.makeFunction(name: Self.vertexFuntionName)
        renderStateDescriptor.fragmentFunction = library.makeFunction(name: Self.fragmentFuntionName)
        renderStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderStateDescriptor.colorAttachments[0].isBlendingEnabled = false
        self.renderPipelineState = try context.device
                                              .makeRenderPipelineState(descriptor: renderStateDescriptor)
    }

    // MARK: - Draw

    func draw(texture: MTLTexture,
              on mtkView: MTKView,
              in commandBuffer: MTLCommandBuffer) {
        guard let drawable = mtkView.currentDrawable,
              let renderPassDescriptor = mtkView.currentRenderPassDescriptor
        else { return }

        commandBuffer.render(descriptor: renderPassDescriptor) { encoder in
            encoder.setRenderPipelineState(self.renderPipelineState)
            encoder.set(fragmentTextures: [texture])

            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.minFilter = .linear
            samplerDescriptor.magFilter = .linear

            let sampler = self.renderPipelineState
                              .device
                              .makeSamplerState(descriptor: samplerDescriptor)
            encoder.setFragmentSamplerState(sampler,
                                            index: 0)

            encoder.drawPrimitives(type: .triangleStrip,
                                   vertexStart: 0,
                                   vertexCount: 4)
        }
        commandBuffer.present(drawable)
    }

    private static let vertexFuntionName = "vertexFunction"
    private static let fragmentFuntionName = "fragmentFunction"

    public static func configure(_ mtkView: MTKView,
                                 with device: MTLDevice) {
        mtkView.device = device
        mtkView.autoResizeDrawable = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        mtkView.clearColor = MTLClearColor(red: 0, green: 0,
                                         blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
    }
}
