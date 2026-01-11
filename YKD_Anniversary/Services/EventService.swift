//
//  EventService.swift
//  YKD_Anniversary
//
//  ローカルイベント永続化サービス
//

import Foundation

final class EventService {

    // UserDefaults保存キー
    private let key = "local_events"

    // MARK: - Load

    /// 保存済みイベントを全件取得
    func load() -> [Event] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let events = try? JSONDecoder().decode([Event].self, from: data)
        else {
            return []
        }
        return events
    }

    // MARK: - Save (全保存)

    /// 配列を丸ごと保存
    func save(_ events: [Event]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - Create

    /// 新規イベント追加
    func add(_ event: Event) {
        var events = load()
        events.append(event)
        save(events)
    }

    // MARK: - Update

    /// 既存イベント更新（id一致で差し替え）
    func update(_ event: Event) {
        var events = load()

        guard let index = events.firstIndex(where: { $0.id == event.id }) else {
            return
        }

        events[index] = event
        save(events)
    }

    // MARK: - Delete（物理削除）

    /// イベントを完全削除
    func delete(_ event: Event) {
        var events = load()
        events.removeAll { $0.id == event.id }
        save(events)
    }
}
