//
//  AddEventView.swift
//  YKD_Anniversary
//
//  記念日・イベント 追加 / 編集 画面
//

import SwiftUI

struct AddEventView: View {

    @Environment(\.dismiss) private var dismiss

    // 編集時は値あり / 新規は nil
    let event: Event?

    let onSave: (Event) -> Void
    let onCancel: () -> Void

    // ===== 編集用 State =====
    @State private var type: EventType
    @State private var title: String
    @State private var date: Date
    @State private var memo: String

    // ===== 初期化 =====
    init(
        event: Event? = nil,
        onSave: @escaping (Event) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.event = event
        self.onSave = onSave
        self.onCancel = onCancel

        _type  = State(initialValue: event?.type ?? .anniversary)
        _title = State(initialValue: event?.title ?? "")
        _date  = State(initialValue: event?.eventDate ?? Date())
        _memo  = State(initialValue: event?.memo ?? "")
    }

    var body: some View {
        Form {

            // ===== タイトル =====
            Section(header: Text("タイトル")) {
                TextField("例：付き合った日 / デート / 旅行", text: $title)
            }

            // ===== 種別 =====
            Section(header: Text("種類")) {
                Picker("種類", selection: $type) {
                    Text("記念日").tag(EventType.anniversary)
                    Text("イベント").tag(EventType.event)
                }
                .pickerStyle(.segmented)
            }

            // ===== 日付（カレンダー）=====
            Section(header: Text("日付")) {
                DatePicker(
                    "日付を選択",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ja_JP"))
            }

            // ===== メモ =====
            Section(header: Text("メモ")) {
                TextEditor(text: $memo)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2))
                    )
            }
        }
        .navigationTitle(event == nil ? "記念日・イベント追加" : "編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            // ===== キャンセル =====
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") {
                    onCancel()
                    dismiss()
                }
            }

            // ===== 削除（編集時のみ）=====
            if event != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        guard let event else { return }

                        let deletedEvent = Event(
                            id: event.id,
                            coupleId: event.coupleId,
                            type: event.type,
                            title: event.title,
                            eventDate: event.eventDate,
                            memo: event.memo,
                            createdBy: event.createdBy,
                            updatedBy: "me",
                            updatedAt: Date(),
                            isDeleted: true
                        )

                        onSave(deletedEvent)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }

            // ===== 保存 =====
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    let savedEvent = Event(
                        id: event?.id ?? UUID().uuidString,
                        coupleId: event?.coupleId ?? "",
                        type: type,
                        title: title,
                        eventDate: date,
                        memo: memo.isEmpty ? nil : memo,
                        createdBy: event?.createdBy ?? "me",
                        updatedBy: "me",
                        updatedAt: Date(),
                        isDeleted: false
                    )

                    onSave(savedEvent)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
    }
}
