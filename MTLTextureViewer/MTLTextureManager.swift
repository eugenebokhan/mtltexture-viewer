import MetalTools

class MTLTextureManager {
    
    enum ColorSpace: String {
        case srgb
        case rgb
    }

    // MARK: - Type Definitions

    enum ExportType: String, CaseIterable {
        case texture
        case compressedTexture
        case png, PNG
    }

    enum ImportType: String, CaseIterable {
        case texture
        case compressedTexture
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
    let colorSpace: ColorSpace
    var texture: MTLTexture?

    init(context: MTLContext, colorSpace: ColorSpace) {
        self.context = context
        self.colorSpace = colorSpace
    }

    // MARK: - Read / Write

    func read(from url: URL) throws {
        guard let type = url.importType
        else { throw Error.brokenURL }

        switch type {
        case .texture, .compressedTexture:
            var textureData = try Data(contentsOf: url)
            if type == .compressedTexture { textureData = try textureData.decompressed() }
            self.texture = try self.jsonDecoder
                                   .decode(MTLTextureCodableContainer.self,
                                           from: textureData)
                                   .texture(device: self.context.device)
        case .jpg, .JPG, .png, .PNG, .heic, .HEIC:
            guard let cgImage = NSImage(contentsOf: url)?.cgImage
            else { throw Error.cgImageCreationFailed }
            self.texture = try self.context.texture(from: cgImage, srgb: self.colorSpace == .srgb)
        }
    }

    func write(to url: URL) throws {
        guard let type = url.exportType
        else { throw Error.brokenURL }
        guard let texture = self.texture
        else { throw Error.textureDataIsMissing }

        switch type {
        case .texture, .compressedTexture:
            var textureData = try self.jsonEncoder.encode(texture.codable())
            if type == .compressedTexture { textureData = textureData.compressed() }
            try textureData.write(to: url)
        case .png, .PNG:
            guard let cgImage = try? texture.cgImage(),
                  let pngData = NSImage(cgImage: cgImage).pngData
            else { throw Error.cgImageCreationFailed }
            try pngData.write(to: url)
        }
    }

}
