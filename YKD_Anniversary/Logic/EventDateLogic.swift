//
//  EventDateLogic.swift
//  YKD_Anniversary
//
//  日付計算専用ロジック
//

import Foundation

enum EventDateLogic {

    /// 2つの日付の差（日数）
    static func daysBetween(from: Date, to: Date) -> Int {
        Calendar.current
            .dateComponents([.day], from: from, to: to)
            .day ?? 0
    }

    /// 次の記念日の日付を算出
    /// - Parameters:
    ///   - originalDate: 記念日の元日付
    ///   - now: 現在日時
    static func nextAnniversaryDate(
        originalDate: Date,
        now: Date
    ) -> Date {

        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)

        // 月日だけ取り出す
        let md = calendar.dateComponents([.month, .day], from: originalDate)

        // 今年の記念日
        let thisYear = calendar.date(from: DateComponents(
            year: currentYear,
            month: md.month,
            day: md.day
        ))!

        // まだ来ていなければ今年、過ぎていれば来年
        return thisYear >= now
            ? thisYear
            : calendar.date(byAdding: .year, value: 1, to: thisYear)!
    }
}
