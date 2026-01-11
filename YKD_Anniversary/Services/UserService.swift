//
//  UserService.swift
//  YKD_Anniversary
//
//  Created by 鍵本大地 on 2026/01/05.
//

import Foundation

/// User をローカル（UserDefaults）に保存・読み込みするサービス
/// ・背景画像URL（backgroundImageUrl）も含めて丸ごと保存対象
/// ・現段階ではローカル専用（論理削除・同期考慮なし）
final class UserService {

    /// UserDefaults 用キー
    private let key = "local_user"

    // MARK: - 読み込み
    /// 保存済みユーザーを読み込む
    /// 未保存の場合は初期ユーザーを返す
    func load() -> User {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let user = try? JSONDecoder().decode(User.self, from: data)
        else {
            // 初回起動 or 保存なしの場合
            return User(
                displayName: "",
                statusMessage: "出会ってから"
            )
        }
        return user
    }

    // MARK: - 保存
    /// User を丸ごと保存する
    /// backgroundImageUrl もここで確実に保持される
    func save(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else {
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - 全削除（デバッグ・リセット用）
    /// 保存済み User を完全に削除する
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
