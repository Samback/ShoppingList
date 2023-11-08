//
//  SwiftUIView.swift
//  
//
//  Created by Max Tymchii on 30.09.2023.
//

import SwiftUI
import Theme
import Models
import Utils

extension NoteModel {

    static var demoNotesList: [NoteModel] {
        return [
            NoteModel(id: UUID(), title: "Milk", isCompleted: true),
            NoteModel(id: UUID(), title: "Bread", isCompleted: true),
            NoteModel(id: UUID(), title: "Water", isCompleted: false),
            NoteModel(id: UUID(), title: "Beer", isCompleted: false)
        ]
    }
}

extension PurchaseModel.Status {
    var emojiOpacity: Double {
        switch self {
        case .done:
            return 1
        case .inProgress:
            return 1
        }
    }

    var titleForeground: Color {
        switch self {
        case .done:
            return ColorTheme.live().secondary
        case .inProgress:
            return ColorTheme.live().primary
        }
    }

    var doneCounterForeground: Color {
        switch self {
        case .done:
            return ColorTheme.live().secondary
        case .inProgress:
            return ColorTheme.live().accent
        }
    }

    var totalCounterForeground: Color {
        switch self {
        case .done:
            return ColorTheme.live().secondary
        case .inProgress:
            return ColorTheme.live().secondary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .done:
            return ColorTheme.live().surface
        case .inProgress:
            return .clear
        }
    }

    var borderColor: Color {
        switch self {
        case .done:
            return .clear
        case .inProgress:
            return ColorTheme.live().secondary
        }
    }

}

struct PurchaseListCell: View {

    let purchaseModel: PurchaseModel

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(purchaseModel.emojiIcon)
                .opacity(purchaseModel.status.emojiOpacity)
                .font(.largeTitle)
                .padding(.leading, 24)

            Text(purchaseModel.title)
                .padding(.leading, 24)
                .multilineTextAlignment(.leading)
                .foregroundStyle(purchaseModel.status.titleForeground)
                .font(.system(size: 22, weight: .medium))

            Spacer()

            HStack(alignment: .center, spacing: 4) {
                Text(purchaseModel.doneNotesCount.description)
                    .foregroundStyle(purchaseModel.status.doneCounterForeground)
                    .font(.system(size: 22, weight: .medium))

                Text("/")
                    .foregroundStyle(purchaseModel.status.totalCounterForeground)
                    .font(.system(size: 14, weight: .regular))

                Text(purchaseModel.totalNotesCount.description)
                    .foregroundStyle(purchaseModel.status.totalCounterForeground)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.trailing, 16)
            }

        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .frame(minHeight: 80)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(purchaseModel.status.borderColor, lineWidth: 1
                    )

                RoundedRectangle(cornerRadius: 12)
                    .fill(purchaseModel.status.backgroundColor)
            }
            .background(.clear)
        }

    }
}

#Preview {
    VStack(alignment: .leading) {
        PurchaseListCell(purchaseModel: PurchaseModel(id: UUID(),
                                                      emojiIcon: EmojisDB.randomEmoji(),
                                                      notes: NoteModel.demoNotesList,
                                                      title: "Lidl"))
    }
    .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    .background(.black)
}
