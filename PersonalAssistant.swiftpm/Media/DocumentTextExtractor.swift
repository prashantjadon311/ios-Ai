// Media/DocumentTextExtractor.swift
// COND: PDFKit document text extraction capped at 50 pages.
// Per V3 §Media/DocumentTextExtractor.swift blueprint.

import Foundation
#if canImport(PDFKit)
import PDFKit
#endif

struct DocumentTextExtractor: Sendable {
    static let maxPages = 50

    static func extractText(from pdfData: Data) -> String {
        #if canImport(PDFKit)
        guard let doc = PDFDocument(data: pdfData) else { return "" }
        var result = ""
        let pageCount = min(doc.pageCount, maxPages)
        for i in 0..<pageCount {
            if let page = doc.page(at: i), let text = page.string {
                result += text + "\n"
            }
        }
        return result
        #else
        return ""
        #endif
    }
}
