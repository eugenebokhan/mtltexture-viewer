//
//  MTLTextureManager.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 24.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Alloy

class MTLTextureManager {

    // MARK: - Type Definitions

    enum ExportType: String, CaseIterable {
        case texture
        case png, PNG
    }

    enum ImportType: String, CaseIterable {
        case texture
        case png, PNG, jpg, JPG, heic, HEIC
    }

    enum Error: Swift.Error {
        case textureDataIsMissing
        case cgImageCreationFailed
        case brokenURL
    }

    // MARK: - Properties

    let context: MTLContext
    let jsonDecoder = JSONDecoder()
    let jsonEncoder = JSONEncoder()
    var texture: MTLTexture?

    init(context: MTLContext) {
        self.context = context
    }

    // MARK: - Read / Write

    func read(from url: URL) throws {
        guard let type = url.importType
        else { throw Error.brokenURL }

        switch type {
        case .texture:
            self.texture = try self.jsonDecoder.decode(MTLTextureCodableBox.self,
                                                       from: Data(contentsOf: url))
                                               .texture(device: context.device)
        case .jpg, .JPG, .png, .PNG, .heic, .HEIC:
            guard let cgImage = NSImage(contentsOf: url)?.cgImage
            else { throw Error.cgImageCreationFailed }
            self.texture = try self.context.texture(from: cgImage)
        }
    }

    func write(to url: URL) throws {
        guard let type = url.exportType
        else { throw Error.brokenURL }
        guard let texture = self.texture
        else { throw Error.textureDataIsMissing }

        switch type {
        case .texture:
            try self.jsonEncoder.encode(texture.codable())
                                .write(to: url)
        case .png, .PNG:
            guard let cgImage = texture.cgImage,
                  let pngData = NSImage(cgImage: cgImage).pngData
            else { throw Error.cgImageCreationFailed }
            try pngData.write(to: url)
        }
    }

}

extension URL {

    var importType: MTLTextureManager.ImportType? {
        return MTLTextureManager.ImportType(rawValue: self.pathExtension)
    }

    var exportType: MTLTextureManager.ExportType? {
        return MTLTextureManager.ExportType(rawValue: self.pathExtension)
    }

}
