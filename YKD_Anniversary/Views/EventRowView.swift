//
//  EventRowView.swift
//  YKD_Anniversary
//
//  イベント1行表示用View
//

import SwiftUI

struct EventRowView: View {

    let event: Event
    let now: Date

    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {

        Button(action: onTap) {
            HStack(alignment: .top) {

                // ===== 左側：タイトル & サブ情報 =====
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)

                    Text(subTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // ===== 右側：3点リーダー（タップ判定拡張済み）=====
                Menu {
                    Button("編集", action: onEdit)
                    Button("削除", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.secondary)
                        .padding(12)                 // タップ判定を広げる
                        .contentShape(Rectangle())   // 透明部分も有効
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain) // 行タップ時の変なハイライト防止
    }

    // MARK: - 表示文言
    private var subTitle: String {
        switch event.type {

        case .event:
            let days = EventDateLogic.daysBetween(
                from: now,
                to: event.eventDate
            )

            if days == 0 {
                return "本日"
            } else if days > 0 {
                return "あと \(days) 日"
            } else {
                return "\(-days) 日前"
            }

        case .anniversary:
            let passed = EventDateLogic.daysBetween(
                from: event.eventDate,
                to: now
            )

            let next = EventDateLogic.daysBetween(
                from: now,
                to: EventDateLogic.nextAnniversaryDate(
                    originalDate: event.eventDate,
                    now: now
                )
            )

            if passed == 0 {
                return "本日"
            } else if passed < 0 {
                return "次は \(next) 日後"
            } else {
                return "\(passed) 日経過 ・ 次は \(next) 日後"
            }
        }
    }
}
