//
//  SettingView.swift
//  YKD_Anniversary
//
//  Created by 鍵本大地 on 2026/01/03.
//

import SwiftUI
import PhotosUI

struct SettingView: View {

    // MARK: - 外部入力
    let saveRequest: Bool
    private let originalUser: User
    let onSave: (User) -> Void
    let onDirtyChange: (Bool) -> Void
    let onOpenPairing: () -> Void

    // MARK: - 編集用 State
    @State private var displayName: String
    @State private var statusMessage: String
    @State private var emotionTags: Set<EmotionTag>
    @State private var startDate: Date

    // 画像
    @State private var selectedMyImage: UIImage?
    @State private var selectedPartnerImage: UIImage?
    @State private var myPhotoItem: PhotosPickerItem?
    @State private var partnerPhotoItem: PhotosPickerItem?

    // MARK: - Init
    init(
        user: User,
        saveRequest: Bool,
        onSave: @escaping (User) -> Void,
        onDirtyChange: @escaping (Bool) -> Void,
        onOpenPairing: @escaping () -> Void
    ) {
        self.originalUser = user
        self.saveRequest = saveRequest
        self.onSave = onSave
        self.onDirtyChange = onDirtyChange
        self.onOpenPairing = onOpenPairing

        _displayName = State(initialValue: user.displayName)
        _statusMessage = State(initialValue: user.statusMessage ?? "")
        _emotionTags = State(initialValue: user.emotionTags)
        _startDate = State(initialValue: user.startDate)
    }

    // MARK: - 差分判定
    private var hasChanges: Bool {
        displayName != originalUser.displayName ||
        statusMessage != (originalUser.statusMessage ?? "") ||
        emotionTags != originalUser.emotionTags ||
        startDate != originalUser.startDate ||
        selectedMyImage != nil ||
        selectedPartnerImage != nil
    }

    // MARK: - 表示用画像
    private var myImage: UIImage? {
        selectedMyImage ?? originalUser.iconImage
    }

    private var partnerImage: UIImage? {
        selectedPartnerImage ?? originalUser.partnerIconImage
    }

    // MARK: - View
    var body: some View {
        Form {

            // =====================
            // ユーザー情報
            // =====================
            Section(header: Text("ユーザー情報")) {

                HStack(spacing: 24) {
                    ProfileAvatar(image: myImage, title: "自分")

                    if originalUser.coupleId == nil {
                        ProfileAvatar(image: partnerImage, title: "相手")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)

                PhotosPicker(selection: $myPhotoItem, matching: .images) {
                    Text("自分のプロフィール画像を変更")
                }

                if originalUser.coupleId == nil {
                    PhotosPicker(selection: $partnerPhotoItem, matching: .images) {
                        Text("相手のプロフィール画像を変更")
                    }
                }

                TextField("表示名", text: $displayName)
                    .onChange(of: displayName) {
                        onDirtyChange(hasChanges)
                    }

                TextField("出会ってから", text: $statusMessage)
                    .onChange(of: statusMessage) {
                        onDirtyChange(hasChanges)
                    }
            }

            // =====================
            // 交際開始日
            // =====================
            Section(header: Text("交際開始日")) {
                DatePicker(
                    "開始日",
                    selection: $startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .onChange(of: startDate) {
                    onDirtyChange(hasChanges)
                }
            }

            // =====================
            // 感情タグ
            // =====================
            Section(header: Text("気分（複数選択可）")) {
                ForEach(EmotionTag.allCases, id: \.self) { tag in

                    let isOnBinding = Binding<Bool>(
                        get: { emotionTags.contains(tag) },
                        set: { newValue in
                            if newValue {
                                emotionTags.insert(tag)
                            } else {
                                emotionTags.remove(tag)
                            }
                            onDirtyChange(hasChanges)
                        }
                    )

                    Toggle(tag.rawValue, isOn: isOnBinding)
                }
            }

            // =====================
            // カップル共有
            // =====================
            Section(header: Text("カップル共有")) {
                if let coupleId = originalUser.coupleId {
                    Text("カップルID：\(coupleId)")
                        .font(.footnote)
                } else {
                    Text("未連携")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(action: onOpenPairing) {
                    Label("共有・連携画面を開く", systemImage: "person.2.fill")
                }
            }
        }
        .navigationTitle("設定")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存", action: save)
                    .disabled(!hasChanges)
            }
        }

        .onChange(of: saveRequest) { _, newValue in
            if newValue {
                save()
            }
        }

        .onChange(of: myPhotoItem) { _, newItem in
            loadImage(from: newItem) {
                selectedMyImage = $0
                onDirtyChange(hasChanges)
            }
        }

        .onChange(of: partnerPhotoItem) { _, newItem in
            loadImage(from: newItem) {
                selectedPartnerImage = $0
                onDirtyChange(hasChanges)
            }
        }
    }

    // MARK: - 保存
    private func save() {
        guard hasChanges else { return }

        let latestUser = UserService().load()

        let updatedUser = User(
            id: latestUser.id,
            coupleId: latestUser.coupleId,
            displayName: displayName,
            iconUrl: selectedMyImage.map { ImageService.save(image: $0) }
                ?? latestUser.iconUrl,
            partnerIconUrl: selectedPartnerImage.map { ImageService.save(image: $0) }
                ?? latestUser.partnerIconUrl,
            backgroundImageUrl: latestUser.backgroundImageUrl, //背景を保持
            startDate: startDate,
            statusMessage: statusMessage.isEmpty ? nil : statusMessage,
            emotionTags: emotionTags,
            updatedAt: Date()
        )

        onSave(updatedUser)
        onDirtyChange(false)
    }


    private func loadImage(
        from item: PhotosPickerItem?,
        completion: @escaping (UIImage) -> Void
    ) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
}

// =====================
// 表示専用アバター
// =====================
struct ProfileAvatar: View {

    let image: UIImage?
    let title: String

    var body: some View {
        VStack {
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, height: 120)
            .background(Color.gray.opacity(0.2))
            .clipShape(Circle())

            Text(title)
                .font(.caption)
        }
    }
}
