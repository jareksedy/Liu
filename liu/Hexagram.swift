//
//  Hexagram.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import Foundation

struct Hexagram: Identifiable {
    let id: Int
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
        Hexagram(id: 1,  name: "Qián (The Creative)",        chinese: "乾", lines: [true,  true,  true,  true,  true,  true]),
        Hexagram(id: 2,  name: "Kūn (The Receptive)",        chinese: "坤", lines: [false, false, false, false, false, false]),
        Hexagram(id: 3,  name: "Zhūn (Difficulty at the Beginning)", chinese: "屯", lines: [true,  false, false, false, true,  false]),
        Hexagram(id: 4,  name: "Méng (Youthful Folly)",      chinese: "蒙", lines: [false, true,  false, false, false, true]),
        Hexagram(id: 5,  name: "Xū (Waiting)",               chinese: "需", lines: [true,  true,  true,  false, true,  false]),
        Hexagram(id: 6,  name: "Sòng (Conflict)",            chinese: "讼", lines: [false, true,  false, true,  true,  true]),
        Hexagram(id: 7,  name: "Shī (The Army)",             chinese: "师", lines: [false, true,  false, false, false, false]),
        Hexagram(id: 8,  name: "Bǐ (Holding Together)",      chinese: "比", lines: [false, false, false, false, true,  false]),
        Hexagram(id: 9,  name: "Xiǎo Chù (Small Taming)",   chinese: "小畜", lines: [true,  true,  false, true,  true,  true]),
        Hexagram(id: 10, name: "Lǚ (Treading)",              chinese: "履", lines: [true,  true,  true,  false, true,  true]),
        Hexagram(id: 11, name: "Tài (Peace)",                 chinese: "泰", lines: [true,  true,  true,  false, false, false]),
        Hexagram(id: 12, name: "Pǐ (Standstill)",            chinese: "否", lines: [false, false, false, true,  true,  true]),
        Hexagram(id: 13, name: "Tóng Rén (Fellowship)",      chinese: "同人", lines: [true,  false, true,  true,  true,  true]),
        Hexagram(id: 14, name: "Dà Yǒu (Great Possession)", chinese: "大有", lines: [true,  true,  true,  true,  false, true]),
        Hexagram(id: 15, name: "Qiān (Modesty)",             chinese: "谦", lines: [false, false, true,  false, false, false]),
        Hexagram(id: 16, name: "Yù (Enthusiasm)",            chinese: "豫", lines: [false, false, false, true,  false, false]),
        Hexagram(id: 17, name: "Suí (Following)",             chinese: "随", lines: [true,  false, false, true,  true,  false]),
        Hexagram(id: 18, name: "Gǔ (Work on the Decayed)",   chinese: "蛊", lines: [false, true,  true,  false, false, true]),
        Hexagram(id: 19, name: "Lín (Approach)",              chinese: "临", lines: [true,  true,  false, false, false, false]),
        Hexagram(id: 20, name: "Guān (Contemplation)",        chinese: "观", lines: [false, false, false, false, true,  true]),
        Hexagram(id: 21, name: "Shì Kè (Biting Through)",    chinese: "噬嗑", lines: [true,  false, false, true,  false, true]),
        Hexagram(id: 22, name: "Bì (Grace)",                  chinese: "贲", lines: [true,  false, true,  false, false, true]),
        Hexagram(id: 23, name: "Bō (Splitting Apart)",        chinese: "剥", lines: [false, false, false, false, false, true]),
        Hexagram(id: 24, name: "Fù (Return)",                 chinese: "复", lines: [true,  false, false, false, false, false]),
        Hexagram(id: 25, name: "Wú Wàng (Innocence)",        chinese: "无妄", lines: [true,  false, false, true,  true,  true]),
        Hexagram(id: 26, name: "Dà Chù (Great Taming)",      chinese: "大畜", lines: [true,  true,  true,  false, false, true]),
        Hexagram(id: 27, name: "Yí (Nourishment)",            chinese: "颐", lines: [true,  false, false, false, false, true]),
        Hexagram(id: 28, name: "Dà Guò (Great Excess)",      chinese: "大过", lines: [false, true,  true,  true,  true,  false]),
        Hexagram(id: 29, name: "Kǎn (The Abysmal Water)",    chinese: "坎", lines: [false, true,  false, false, true,  false]),
        Hexagram(id: 30, name: "Lí (The Clinging Fire)",      chinese: "离", lines: [true,  false, true,  true,  false, true]),
        Hexagram(id: 31, name: "Xián (Influence)",            chinese: "咸", lines: [false, false, true,  true,  true,  false]),
        Hexagram(id: 32, name: "Héng (Duration)",             chinese: "恒", lines: [false, true,  true,  true,  false, false]),
        Hexagram(id: 33, name: "Dùn (Retreat)",               chinese: "遁", lines: [false, false, true,  true,  true,  true]),
        Hexagram(id: 34, name: "Dà Zhuàng (Great Power)",    chinese: "大壮", lines: [true,  true,  true,  true,  false, false]),
        Hexagram(id: 35, name: "Jìn (Progress)",              chinese: "晋", lines: [false, false, false, true,  false, true]),
        Hexagram(id: 36, name: "Míng Yí (Darkening of Light)", chinese: "明夷", lines: [true,  false, true,  false, false, false]),
        Hexagram(id: 37, name: "Jiā Rén (The Family)",        chinese: "家人", lines: [true,  false, true,  false, true,  true]),
        Hexagram(id: 38, name: "Kuí (Opposition)",            chinese: "睽", lines: [true,  true,  false, true,  false, true]),
        Hexagram(id: 39, name: "Jiǎn (Obstruction)",          chinese: "蹇", lines: [false, false, true,  false, true,  false]),
        Hexagram(id: 40, name: "Xiè (Deliverance)",           chinese: "解", lines: [false, true,  false, true,  false, false]),
        Hexagram(id: 41, name: "Sǔn (Decrease)",              chinese: "损", lines: [true,  true,  false, false, false, true]),
        Hexagram(id: 42, name: "Yì (Increase)",               chinese: "益", lines: [true,  false, false, false, true,  true]),
        Hexagram(id: 43, name: "Guài (Breakthrough)",         chinese: "夬", lines: [true,  true,  true,  true,  true,  false]),
        Hexagram(id: 44, name: "Gòu (Coming to Meet)",       chinese: "姤", lines: [false, true,  true,  true,  true,  true]),
        Hexagram(id: 45, name: "Cuì (Gathering Together)",    chinese: "萃", lines: [false, false, false, true,  true,  false]),
        Hexagram(id: 46, name: "Shēng (Pushing Upward)",     chinese: "升", lines: [false, true,  true,  false, false, false]),
        Hexagram(id: 47, name: "Kùn (Oppression)",            chinese: "困", lines: [false, true,  false, true,  true,  false]),
        Hexagram(id: 48, name: "Jǐng (The Well)",             chinese: "井", lines: [false, true,  true,  false, true,  false]),
        Hexagram(id: 49, name: "Gé (Revolution)",             chinese: "革", lines: [true,  false, true,  true,  true,  false]),
        Hexagram(id: 50, name: "Dǐng (The Cauldron)",        chinese: "鼎", lines: [false, true,  true,  true,  false, true]),
        Hexagram(id: 51, name: "Zhèn (The Arousing Thunder)", chinese: "震", lines: [true,  false, false, true,  false, false]),
        Hexagram(id: 52, name: "Gèn (Keeping Still Mountain)", chinese: "艮", lines: [false, false, true,  false, false, true]),
        Hexagram(id: 53, name: "Jiàn (Development)",          chinese: "渐", lines: [false, false, true,  false, true,  true]),
        Hexagram(id: 54, name: "Guī Mèi (The Marrying Maiden)", chinese: "归妹", lines: [true,  true,  false, true,  false, false]),
        Hexagram(id: 55, name: "Fēng (Abundance)",            chinese: "丰", lines: [true,  false, true,  true,  false, false]),
        Hexagram(id: 56, name: "Lǚ (The Wanderer)",           chinese: "旅", lines: [false, false, true,  true,  false, true]),
        Hexagram(id: 57, name: "Xùn (The Gentle Wind)",       chinese: "巽", lines: [false, true,  true,  false, true,  true]),
        Hexagram(id: 58, name: "Duì (The Joyous Lake)",       chinese: "兑", lines: [true,  true,  false, true,  true,  false]),
        Hexagram(id: 59, name: "Huàn (Dispersion)",           chinese: "涣", lines: [false, true,  false, false, true,  true]),
        Hexagram(id: 60, name: "Jié (Limitation)",             chinese: "节", lines: [false, true,  false, false, true,  false]),
        Hexagram(id: 61, name: "Zhōng Fú (Inner Truth)",      chinese: "中孚", lines: [true,  true,  false, false, true,  true]),
        Hexagram(id: 62, name: "Xiǎo Guò (Small Excess)",    chinese: "小过", lines: [false, false, true,  true,  false, false]),
        Hexagram(id: 63, name: "Jì Jì (After Completion)",    chinese: "既济", lines: [true,  false, true,  false, true,  false]),
        Hexagram(id: 64, name: "Wèi Jì (Before Completion)",  chinese: "未济", lines: [false, true,  false, true,  false, true]),
    ]

    /// Look up the hexagram that matches the given 6 lines (bottom to top).
    static func find(lines: [Bool]) -> Hexagram? {
        guard lines.count == 6 else { return nil }
        return all.first { $0.lines == lines }
    }
}
