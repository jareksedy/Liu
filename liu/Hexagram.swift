//
//  Hexagram.swift
//  liu
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

    var searchQuery: String {
        "I Ching hexagram \(id) \(name)"
    }

    var searchURL: URL? {
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: searchQuery)]
        return components?.url
    }
}

// All 64 hexagrams keyed by their 6-bit binary pattern (bottom to top).
// Each Bool: true = yang (solid), false = yin (broken).
enum HexagramLibrary {
    // Lines are stored bottom-to-top: [line1, line2, line3, line4, line5, line6]
    private static let all: [Hexagram] = [
        Hexagram(id: 1, pinyin: "Qián", name: "The Creative", chinese: "乾", lines: [true, true, true, true, true, true]),
        Hexagram(id: 2, pinyin: "Kūn", name: "The Receptive", chinese: "坤", lines: [false, false, false, false, false, false]),
        Hexagram(id: 3, pinyin: "Zhūn", name: "Difficulty at the Beginning", chinese: "屯", lines: [true, false, false, false, true, false]),
        Hexagram(id: 4, pinyin: "Méng", name: "Youthful Folly", chinese: "蒙", lines: [false, true, false, false, false, true]),
        Hexagram(id: 5, pinyin: "Xū", name: "Waiting", chinese: "需", lines: [true, true, true, false, true, false]),
        Hexagram(id: 6, pinyin: "Sòng", name: "Conflict", chinese: "讼", lines: [false, true, false, true, true, true]),
        Hexagram(id: 7, pinyin: "Shī", name: "The Army", chinese: "师", lines: [false, true, false, false, false, false]),
        Hexagram(id: 8, pinyin: "Bǐ", name: "Holding Together", chinese: "比", lines: [false, false, false, false, true, false]),
        Hexagram(id: 9, pinyin: "Xiǎo Chù", name: "Small Taming", chinese: "小畜", lines: [true, true, false, true, true, true]),
        Hexagram(id: 10, pinyin: "Lǚ", name: "Treading", chinese: "履", lines: [true, true, true, false, true, true]),
        Hexagram(id: 11, pinyin: "Tài", name: "Peace", chinese: "泰", lines: [true, true, true, false, false, false]),
        Hexagram(id: 12, pinyin: "Pǐ", name: "Standstill", chinese: "否", lines: [false, false, false, true, true, true]),
        Hexagram(id: 13, pinyin: "Tóng Rén", name: "Fellowship", chinese: "同人", lines: [true, false, true, true, true, true]),
        Hexagram(id: 14, pinyin: "Dà Yǒu", name: "Great Possession", chinese: "大有", lines: [true, true, true, true, false, true]),
        Hexagram(id: 15, pinyin: "Qiān", name: "Modesty", chinese: "谦", lines: [false, false, true, false, false, false]),
        Hexagram(id: 16, pinyin: "Yù", name: "Enthusiasm", chinese: "豫", lines: [false, false, false, true, false, false]),
        Hexagram(id: 17, pinyin: "Suí", name: "Following", chinese: "随", lines: [true, false, false, true, true, false]),
        Hexagram(id: 18, pinyin: "Gǔ", name: "Work on the Decayed", chinese: "蛊", lines: [false, true, true, false, false, true]),
        Hexagram(id: 19, pinyin: "Lín", name: "Approach", chinese: "临", lines: [true, true, false, false, false, false]),
        Hexagram(id: 20, pinyin: "Guān", name: "Contemplation", chinese: "观", lines: [false, false, false, false, true, true]),
        Hexagram(id: 21, pinyin: "Shì Kè", name: "Biting Through", chinese: "噬嗑", lines: [true, false, false, true, false, true]),
        Hexagram(id: 22, pinyin: "Bì", name: "Grace", chinese: "贲", lines: [true, false, true, false, false, true]),
        Hexagram(id: 23, pinyin: "Bō", name: "Splitting Apart", chinese: "剥", lines: [false, false, false, false, false, true]),
        Hexagram(id: 24, pinyin: "Fù", name: "Return", chinese: "复", lines: [true, false, false, false, false, false]),
        Hexagram(id: 25, pinyin: "Wú Wàng", name: "Innocence", chinese: "无妄", lines: [true, false, false, true, true, true]),
        Hexagram(id: 26, pinyin: "Dà Chù", name: "Great Taming", chinese: "大畜", lines: [true, true, true, false, false, true]),
        Hexagram(id: 27, pinyin: "Yí", name: "Nourishment", chinese: "颐", lines: [true, false, false, false, false, true]),
        Hexagram(id: 28, pinyin: "Dà Guò", name: "Great Excess", chinese: "大过", lines: [false, true, true, true, true, false]),
        Hexagram(id: 29, pinyin: "Kǎn", name: "The Abysmal Water", chinese: "坎", lines: [false, true, false, false, true, false]),
        Hexagram(id: 30, pinyin: "Lí", name: "The Clinging Fire", chinese: "离", lines: [true, false, true, true, false, true]),
        Hexagram(id: 31, pinyin: "Xián", name: "Influence", chinese: "咸", lines: [false, false, true, true, true, false]),
        Hexagram(id: 32, pinyin: "Héng", name: "Duration", chinese: "恒", lines: [false, true, true, true, false, false]),
        Hexagram(id: 33, pinyin: "Dùn", name: "Retreat", chinese: "遁", lines: [false, false, true, true, true, true]),
        Hexagram(id: 34, pinyin: "Dà Zhuàng", name: "Great Power", chinese: "大壮", lines: [true, true, true, true, false, false]),
        Hexagram(id: 35, pinyin: "Jìn", name: "Progress", chinese: "晋", lines: [false, false, false, true, false, true]),
        Hexagram(id: 36, pinyin: "Míng Yí", name: "Darkening of Light", chinese: "明夷", lines: [true, false, true, false, false, false]),
        Hexagram(id: 37, pinyin: "Jiā Rén", name: "The Family", chinese: "家人", lines: [true, false, true, false, true, true]),
        Hexagram(id: 38, pinyin: "Kuí", name: "Opposition", chinese: "睽", lines: [true, true, false, true, false, true]),
        Hexagram(id: 39, pinyin: "Jiǎn", name: "Obstruction", chinese: "蹇", lines: [false, false, true, false, true, false]),
        Hexagram(id: 40, pinyin: "Xiè", name: "Deliverance", chinese: "解", lines: [false, true, false, true, false, false]),
        Hexagram(id: 41, pinyin: "Sǔn", name: "Decrease", chinese: "损", lines: [true, true, false, false, false, true]),
        Hexagram(id: 42, pinyin: "Yì", name: "Increase", chinese: "益", lines: [true, false, false, false, true, true]),
        Hexagram(id: 43, pinyin: "Guài", name: "Breakthrough", chinese: "夬", lines: [true, true, true, true, true, false]),
        Hexagram(id: 44, pinyin: "Gòu", name: "Coming to Meet", chinese: "姤", lines: [false, true, true, true, true, true]),
        Hexagram(id: 45, pinyin: "Cuì", name: "Gathering Together", chinese: "萃", lines: [false, false, false, true, true, false]),
        Hexagram(id: 46, pinyin: "Shēng", name: "Pushing Upward", chinese: "升", lines: [false, true, true, false, false, false]),
        Hexagram(id: 47, pinyin: "Kùn", name: "Oppression", chinese: "困", lines: [false, true, false, true, true, false]),
        Hexagram(id: 48, pinyin: "Jǐng", name: "The Well", chinese: "井", lines: [false, true, true, false, true, false]),
        Hexagram(id: 49, pinyin: "Gé", name: "Revolution", chinese: "革", lines: [true, false, true, true, true, false]),
        Hexagram(id: 50, pinyin: "Dǐng", name: "The Cauldron", chinese: "鼎", lines: [false, true, true, true, false, true]),
        Hexagram(id: 51, pinyin: "Zhèn", name: "The Arousing Thunder", chinese: "震", lines: [true, false, false, true, false, false]),
        Hexagram(id: 52, pinyin: "Gèn", name: "Keeping Still Mountain", chinese: "艮", lines: [false, false, true, false, false, true]),
        Hexagram(id: 53, pinyin: "Jiàn", name: "Development", chinese: "渐", lines: [false, false, true, false, true, true]),
        Hexagram(id: 54, pinyin: "Guī Mèi", name: "The Marrying Maiden", chinese: "归妹", lines: [true, true, false, true, false, false]),
        Hexagram(id: 55, pinyin: "Fēng", name: "Abundance", chinese: "丰", lines: [true, false, true, true, false, false]),
        Hexagram(id: 56, pinyin: "Lǚ", name: "The Wanderer", chinese: "旅", lines: [false, false, true, true, false, true]),
        Hexagram(id: 57, pinyin: "Xùn", name: "The Gentle Wind", chinese: "巽", lines: [false, true, true, false, true, true]),
        Hexagram(id: 58, pinyin: "Duì", name: "The Joyous Lake", chinese: "兑", lines: [true, true, false, true, true, false]),
        Hexagram(id: 59, pinyin: "Huàn", name: "Dispersion", chinese: "涣", lines: [false, true, false, false, true, true]),
        Hexagram(id: 60, pinyin: "Jié", name: "Limitation", chinese: "节", lines: [false, true, false, false, true, false]),
        Hexagram(id: 61, pinyin: "Zhōng Fú", name: "Inner Truth", chinese: "中孚", lines: [true, true, false, false, true, true]),
        Hexagram(id: 62, pinyin: "Xiǎo Guò", name: "Small Excess", chinese: "小过", lines: [false, false, true, true, false, false]),
        Hexagram(id: 63, pinyin: "Jì Jì", name: "After Completion", chinese: "既济", lines: [true, false, true, false, true, false]),
        Hexagram(id: 64, pinyin: "Wèi Jì", name: "Before Completion", chinese: "未济", lines: [false, true, false, true, false, true]),
    ]

    /// Look up the hexagram that matches the given 6 lines (bottom to top).
    static func find(lines: [Bool]) -> Hexagram? {
        guard lines.count == 6 else { return nil }
        return all.first { $0.lines == lines }
    }
}
