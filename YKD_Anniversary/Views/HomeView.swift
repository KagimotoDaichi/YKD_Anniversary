//
//  HomeView.swift
//  YKD_Anniversary
//
//  ホーム画面
//  ・ステータスメッセージ表示
//  ・経過時間リアルタイム表示
//  ・記念日 / イベント一覧
//  ・イベント追加 / 編集 / 削除の起点
//

import SwiftUI
import PhotosUI

struct HomeView: View {

    // MARK: - 入力（MainView から渡される）
    let user: User

    // MARK: - 相手ユーザー関連
    @State private var partnerUser: User?
    @State private var tempPartnerImage: UIImage?
    @State private var showPartnerImagePicker = false

    // MARK: - セグメント
    @State private var selectedFilter: AnniversaryFilter = .all

    // MARK: - イベント管理
    @State private var events: [Event] = []
    private let eventService = EventService()

    // MARK: - 現在時刻
    @State private var now: Date = Date()

    // MARK: - 画面制御
    @State private var showAddEvent = false
    @State private var selectedEvent: Event?
    @State private var showEditEvent = false
    @State private var showDeleteAlert = false

    // MARK: - 相手アバター表示
    private var displayPartnerImage: UIImage? {
        if let partnerUser {
            return partnerUser.iconImage
        }
        if let saved = user.partnerIconImage {
            return saved
        }
        return tempPartnerImage
    }

    // MARK: - セグメントEnum
    enum AnniversaryFilter: String, CaseIterable, Identifiable {
        case all = "全て"
        case anniversary = "記念日"
        case event = "イベント"
        var id: Self { self }
    }

    // MARK: - フィルタ済みイベント
    private var filteredEvents: [Event] {
        let alive = events.filter { !$0.isDeleted }

        switch selectedFilter {
        case .all:
            return alive
        case .anniversary:
            return alive.filter { $0.type == .anniversary }
        case .event:
            return alive.filter { $0.type == .event }
        }
    }

    // MARK: - View
    var body: some View {
        VStack {

            header

            Spacer().frame(height: 24)

            Text("2人が" + (user.statusMessage ?? "出会ってから"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 46)

            avatarArea

            Text(
                ElapsedTimeFormatter.format(
                    from: user.startDate,
                    to: now
                )
            )
            .font(.title)
            .fontWeight(.semibold)
            .monospacedDigit()
            .padding(.top, 4)

            Spacer().frame(height: 32)

            Picker("AnniversaryEvent", selection: $selectedFilter) {
                ForEach(AnniversaryFilter.allCases) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            List {
                ForEach(filteredEvents) { event in
                    EventRowView(
                        event: event,
                        now: now,
                        onEdit: {
                            selectedEvent = event
                            showEditEvent = true
                        },
                        onDelete: {
                            selectedEvent = event
                            showDeleteAlert = true
                        },
                        onTap: {}
                    )
                }
            }
            .listStyle(.plain)
            .onAppear {
                events = eventService.load()
            }

            Spacer()
        }

        // MARK: - 時刻更新
        .onReceive(
            Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        ) { _ in
            now = Date()
        }

        // MARK: - 相手画像選択
        .photosPicker(
            isPresented: $showPartnerImagePicker,
            selection: Binding(
                get: { nil },
                set: { item in
                    guard let item else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            tempPartnerImage = image
                        }
                    }
                }
            ),
            matching: .images
        )

        // MARK: - 追加
        .sheet(isPresented: $showAddEvent) {
            NavigationStack {
                AddEventView(
                    event: nil,
                    onSave: { event in
                        eventService.add(event)
                        events = eventService.load()
                        showAddEvent = false
                    },
                    onCancel: {
                        showAddEvent = false
                    }
                )
            }
        }

        // MARK: - 編集
        .sheet(isPresented: $showEditEvent) {
            if let selectedEvent {
                NavigationStack {
                    AddEventView(
                        event: selectedEvent,
                        onSave: { edited in
                            eventService.update(edited)
                            events = eventService.load()
                            showEditEvent = false
                            self.selectedEvent = nil
                        },
                        onCancel: {
                            showEditEvent = false
                            self.selectedEvent = nil
                        }
                    )
                }
            }
        }

        // MARK: - 削除確認
        .alert("イベントを削除しますか？", isPresented: $showDeleteAlert) {
            Button("削除", role: .destructive) {
                if let selectedEvent {
                    eventService.delete(selectedEvent)
                    events = eventService.load()
                    self.selectedEvent = nil
                }
            }
            Button("キャンセル", role: .cancel) {
                selectedEvent = nil
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            QuarterCircleButton(
                position: .rightBottom,
                size: 70,
                backgroundColor: .blue,
                iconName: "photo.fill",
                iconColor: .white,
                iconSizeRatio: 0.4,
                iconOffsetRatio: -1
            ) {}
                .ignoresSafeArea()
                .opacity(0.5)

            Spacer()

            QuarterCircleButton(
                position: .leftBottom,
                size: 70,
                backgroundColor: .pink,
                iconName: "plus",
                iconColor: .white,
                iconSizeRatio: 0.45,
                iconOffsetRatio: -1
            ) {
                showAddEvent = true
            }
                .ignoresSafeArea()
                .opacity(0.5)
        }
    }

    // MARK: - Avatar
    private var avatarArea: some View {
        HStack(spacing: 24) {
            Spacer()

            AvatarView(
                image: user.iconImage,
                size: 100,
                isEditable: false,
                onTap: nil
            )

            Text("♡").font(.title)

            AvatarView(
                image: displayPartnerImage,
                size: 100,
                isEditable: partnerUser == nil && user.partnerIconImage == nil,
                onTap: {
                    guard partnerUser == nil,
                          user.partnerIconImage == nil else { return }
                    showPartnerImagePicker = true
                }
            )

            Spacer()
        }
        .padding(.leading, 16)
    }
}

#Preview {
    MainView()
}
