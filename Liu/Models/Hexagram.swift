//
//  Hexagram.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import Foundation

struct Hexagram: Identifiable {
    let id: Int
    let pinyin: String
    let name: String
    let chinese: String
    let lines: [Bool] // true = solid (yang ⚊), false = broken (yin ⚋), bottom to top

    var unicodeSymbol: String {
        String(UnicodeScalar(0x4DC0 + id - 1)!)
    }

    var firstTrigramName: String {
        Trigram.find(Array(lines[0..<3]))?.name ?? ""
    }

    var secondTrigramName: String {
        Trigram.find(Array(lines[3..<6]))?.name ?? ""
    }

    var firstTrigramChinese: String {
        Trigram.find(Array(lines[0..<3]))?.chinese ?? ""
    }

    var secondTrigramChinese: String {
        Trigram.find(Array(lines[3..<6]))?.chinese ?? ""
    }

    func getSearchURL(relatingResult: Hexagram?) -> URL? {
        var searchQuery: String

        if let relatingResult {
            searchQuery = "i ching hexagram \(id) changing to \(relatingResult.id) interpretation"
        } else {
            searchQuery = "i ching hexagram \(id) interpretation"
        }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: searchQuery)]
        return components?.url
    }
}
