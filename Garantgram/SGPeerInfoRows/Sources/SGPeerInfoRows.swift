import Foundation
import UIKit
import AccountContext
import TelegramPresentationData
import TelegramCore

func sgPeerInfoProfileItems(nearestChatParticipant: (String?, Int32?), data: PeerInfoScreenData, context: AccountContext, presentationData: PresentationData, interaction: PeerInfoInteraction, isMyProfile: Bool) -> [PeerInfoScreenItem] {
    return []
}

func sgPeerInfoSettingsProfileIdItems(data: PeerInfoScreenData, interaction: PeerInfoInteraction) -> [PeerInfoScreenItem] {
    return []
}

func sgPeerInfoSettingsItems(context: AccountContext, paymentsEnabled: Bool, presentationData: PresentationData, interaction: PeerInfoInteraction) -> [PeerInfoScreenItem] {
    var items: [PeerInfoScreenItem] = []
    items.append(PeerInfoScreenDisclosureItem(id: 1, label: .none, text: presentationData.strings.baseLanguageCode == "ru" ? "Режим призрака (Ghost Mode)" : "Ghost Mode (Garantgram)", icon: PresentationResourcesSettings.security, action: {
        interaction.openSettings(.swiftgram)
    }))
    return items
}
