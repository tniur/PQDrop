//
//  String+Extensions.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 09.03.2026.
//

extension String {
    func chunked(into size: Int) -> [FingerprintBlock] {
        guard size > 0, !isEmpty else { return [] }
        
        return stride(from: 0, to: count, by: size).enumerated().map { index, offset in
            let start = self.index(self.startIndex, offsetBy: offset)
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = String(self[start..<end])
            return FingerprintBlock(id: index, text: chunk)
        }
    }
}
