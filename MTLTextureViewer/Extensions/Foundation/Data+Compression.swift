import Foundation
import Compression

extension Data {

    enum Error: Swift.Error {
        case compressionError
    }

    func compressed() -> Data {
        guard !isEmpty else { return self }
        var targetBufferSize = Swift.max(count / 8, 10)
        while true {
            var result = Data(count: targetBufferSize)
            let resultCount = self.compress(into: &result)
            if resultCount == 0 {
                targetBufferSize *= 2
                continue
            }
            return result.prefix(resultCount)
        }
    }

    private func compress(into dest: inout Data) -> Int {
        let destSize = dest.count
        let srcSize = count

        return self.withUnsafeBytes { source in
            return dest.withUnsafeMutableBytes { dest in
                return compression_encode_buffer(
                    dest.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    destSize,
                    source.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    srcSize,
                    nil,
                    COMPRESSION_LZFSE
                )
            }
        }
    }

    func decompressed() throws -> Data {
        guard !isEmpty else { return self }
        var targetBufferSize = count * 8
        while true {
            var result = Data(count: targetBufferSize)
            let resultCount = self.decompress(into: &result)
            if resultCount == 0 { throw Error.compressionError }
            if resultCount == targetBufferSize {
                targetBufferSize *= 2
                continue
            }
            return result.prefix(resultCount)
        }
    }

    private func decompress(into dest: inout Data) -> Int {
        let destSize = dest.count
        let srcSize = count

        return self.withUnsafeBytes { source in
            return dest.withUnsafeMutableBytes { dest in
                return compression_decode_buffer(
                    dest.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    destSize,
                    source.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    srcSize,
                    nil,
                    COMPRESSION_LZFSE
                )
            }
        }
    }
}
