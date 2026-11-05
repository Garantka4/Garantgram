// MARK: Swiftgram
import SGLogging
import SGSimpleSettings
import SGStrings
import SGAPIToken

import SGItemListUI
import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import MtProtoKit
import MessageUI
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import OverlayStatusController
import AccountContext
import AppBundle
import WebKit
import PeerNameColorScreen
import UndoUI


private enum SGControllerSection: Int32, SGItemListSection {
    case ghostMode
    case photo
    case videoNotes
}

private enum SGBoolSetting: String {
    case ghostModeOnline
    case ghostModeTyping
    case ghostModeReadReceipts
    case ghostModeStories
    case hidePhoneInSettings
    case showTabNames
    case showContactsTab
    case showCallsTab
    case wideTabBar
    case foldersAtBottom
    case startTelescopeWithRearCam
    case hideStories
    case uploadSpeedBoost
    case showProfileId
    case warnOnStoriesOpen
    case sendWithReturnKey
    case rememberLastFolder
    case sendLargePhotos
    case storyStealthMode
    case disableSwipeToRecordStory
    case disableDeleteChatSwipeOption
    case quickTranslateButton
    case hideReactions
    case showRepostToStory
    case contextShowSelectFromUser
    case contextShowSaveToCloud
    case contextShowHideForwardName
    case contextShowRestrict
    case contextShowReport
    case contextShowReply
    case contextShowPin
    case contextShowSaveMedia
    case contextShowMessageReplies
    case contextShowJson
    case disableScrollToNextChannel
    case disableScrollToNextTopic
    case disableChatSwipeOptions
    case disableGalleryCamera
    case disableGalleryCameraPreview
    case disableSendAsButton
    case disableSnapDeletionEffect
    case stickerTimestamp
    case hideRecordingButton
    case hideTabBar
    case showDC
    case showCreationDate
    case showRegDate
    case compactChatList
    case compactMessagePreview
    case compactFolderNames
    case allChatsHidden
    case defaultEmojisFirst
    case messageDoubleTapActionOutgoingEdit
    case wideChannelPosts
    case forceEmojiTab
    case forceBuiltInMic
    case secondsInMessages
    case hideChannelBottomButton
    case confirmCalls
    case swipeForVideoPIP
    case enableVoipTcp
    case nyStyleSnow
    case nyStyleLightning
    case tabBarSearchEnabled
    case videoControlsInFooter
    case hideAccountInNotifications
}

private enum SGOneFromManySetting: String {
    case nyStyle
    case bottomTabStyle
    case downloadSpeedBoost
    case allChatsTitleLengthOverride
//    case allChatsFolderPositionOverride
    case translationBackend
    case transcriptionBackend
}

private enum SGSliderSetting: String {
    case accountColorsSaturation
    case outgoingPhotoQuality
    case stickerSize
}

private enum SGDisclosureLink: String {
    case contentSettings
    case languageSettings
}

private struct PeerNameColorScreenState: Equatable {
    var updatedNameColor: PeerNameColor?
    var updatedBackgroundEmojiId: Int64?
}

private struct SGSettingsControllerState: Equatable {
    var searchQuery: String?
}

private typealias SGControllerEntry = SGItemListUIEntry<SGControllerSection, SGBoolSetting, SGSliderSetting, SGOneFromManySetting, SGDisclosureLink, AnyHashable>

private func SGControllerEntries(presentationData: PresentationData, callListSettings: CallListSettings, experimentalUISettings: ExperimentalUISettings, appConfiguration: AppConfiguration, nameColors: PeerNameColors, state: SGSettingsControllerState) -> [SGControllerEntry] {
    let lang = presentationData.strings.baseLanguageCode
    let strings = presentationData.strings
    var entries: [SGControllerEntry] = []
    let id = SGItemListCounter()

    // 1. РЕЖИМ ПРИЗРАКА (GHOST MODE)
    entries.append(.header(id: id.count, section: .ghostMode, text: "РЕЖИМ ПРИЗРАКА (GHOST MODE)", badge: nil))
    entries.append(.toggle(id: id.count, section: .ghostMode, settingName: .ghostModeOnline, value: SGSimpleSettings.shared.ghostModeOnline, text: "Не быть в сети (Offline)", enabled: true))
    entries.append(.notice(id: id.count, section: .ghostMode, text: "При нахождении в приложении ваш статус «В сети» скрыт от всех."))
    entries.append(.toggle(id: id.count, section: .ghostMode, settingName: .ghostModeTyping, value: SGSimpleSettings.shared.ghostModeTyping, text: "Скрыть статус «Печатает...»", enabled: true))
    entries.append(.notice(id: id.count, section: .ghostMode, text: "Собеседники не видят, когда вы набираете сообщение или записываете голосовое."))
    entries.append(.toggle(id: id.count, section: .ghostMode, settingName: .ghostModeReadReceipts, value: SGSimpleSettings.shared.ghostModeReadReceipts, text: "Не отмечать прочитанным (Нечиталка)", enabled: true))
    entries.append(.notice(id: id.count, section: .ghostMode, text: "Входящие сообщения остаются непрочитанными для собеседника (одна галочка)."))
    entries.append(.toggle(id: id.count, section: .ghostMode, settingName: .ghostModeStories, value: SGSimpleSettings.shared.ghostModeStories, text: "Скрытный просмотр историй (Stories)", enabled: true))
    entries.append(.notice(id: id.count, section: .ghostMode, text: "Просмотр историй анонимно без фиксации вашего профиля в списке зрителей."))

    // 2. ФОТО (PHOTOS)
    entries.append(.header(id: id.count, section: .photo, text: strings.PhotoEditor_QualityTool.uppercased(), badge: nil))
    entries.append(.percentageSlider(id: id.count, section: .photo, settingName: .outgoingPhotoQuality, value: SGSimpleSettings.shared.outgoingPhotoQuality))
    entries.append(.notice(id: id.count, section: .photo, text: i18n("Settings.Photo.Quality.Notice", lang)))
    entries.append(.toggle(id: id.count, section: .photo, settingName: .sendLargePhotos, value: SGSimpleSettings.shared.sendLargePhotos, text: i18n("Settings.Photo.SendLarge", lang), enabled: true))
    entries.append(.notice(id: id.count, section: .photo, text: i18n("Settings.Photo.SendLarge.Notice", lang)))

    // 3. ВИДЕОСООБЩЕНИЯ (ROUND VIDEOS)
    entries.append(.header(id: id.count, section: .videoNotes, text: i18n("Settings.VideoNotes.Header", lang), badge: nil))
    entries.append(.toggle(id: id.count, section: .videoNotes, settingName: .startTelescopeWithRearCam, value: SGSimpleSettings.shared.startTelescopeWithRearCam, text: i18n("Settings.VideoNotes.StartWithRearCam", lang), enabled: true))

    return entries
}

public func sgSettingsController(context: AccountContext/*, focusOnItemTag: Int? = nil*/) -> ViewController {
    var presentControllerImpl: ((ViewController, ViewControllerPresentationArguments?) -> Void)?
    var pushControllerImpl: ((ViewController) -> Void)?
//    var getRootControllerImpl: (() -> UIViewController?)?
//    var getNavigationControllerImpl: (() -> NavigationController?)?
    var askForRestart: (() -> Void)?
    
    let initialState = SGSettingsControllerState()
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let stateValue = Atomic(value: initialState)
    let updateState: ((SGSettingsControllerState) -> SGSettingsControllerState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
//    let sliderPromise = ValuePromise(SGSimpleSettings.shared.accountColorsSaturation, ignoreRepeated: true)
//    let sliderStateValue = Atomic(value: SGSimpleSettings.shared.accountColorsSaturation)
//    let _: ((Int32) -> Int32) -> Void = { f in
//        sliderPromise.set(sliderStateValue.modify( {f($0)}))
//    }
    
    let simplePromise = ValuePromise(true, ignoreRepeated: false)
    
    let arguments = SGItemListArguments<SGBoolSetting, SGSliderSetting, SGOneFromManySetting, SGDisclosureLink, AnyHashable>(
        context: context,
        /*updatePeerColor: { color in
          updateState { state in
              var updatedState = state
              updatedState.updatedNameColor = color
              return updatedState
          }
        },*/ setBoolValue: { setting, value in
        switch setting {
        case .ghostModeOnline:
            SGSimpleSettings.shared.ghostModeOnline = value
            if value {
                SGSimpleSettings.shared.ghostModeLastSeenTimestamp = Int32(Date().timeIntervalSince1970)
            } else {
                SGSimpleSettings.shared.ghostModeLastSeenTimestamp = 0
            }
        case .ghostModeTyping:
            SGSimpleSettings.shared.ghostModeTyping = value
        case .ghostModeReadReceipts:
            SGSimpleSettings.shared.ghostModeReadReceipts = value
        case .ghostModeStories:
            SGSimpleSettings.shared.ghostModeStories = value
        case .hidePhoneInSettings:
            SGSimpleSettings.shared.hidePhoneInSettings = value
            askForRestart?()
        case .showTabNames:
            SGSimpleSettings.shared.showTabNames = value
            askForRestart?()
        case .showContactsTab:
            let _ = (
                updateCallListSettingsInteractively(
                    accountManager: context.sharedContext.accountManager, { $0.withUpdatedShowContactsTab(value) }
                )
            ).start()
        case .showCallsTab:
            let _ = (
                updateCallListSettingsInteractively(
                    accountManager: context.sharedContext.accountManager, { $0.withUpdatedShowTab(value) }
                )
            ).start()
        case .tabBarSearchEnabled:
            SGSimpleSettings.shared.tabBarSearchEnabled = value
        case .wideTabBar:
            SGSimpleSettings.shared.wideTabBar = value
            askForRestart?()
        case .foldersAtBottom:
            let _ = (
                updateExperimentalUISettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
                        var settings = settings
                        settings.foldersTabAtBottom = value
                        return settings
                    }
                )
            ).start()
        case .startTelescopeWithRearCam:
            SGSimpleSettings.shared.startTelescopeWithRearCam = value
        case .hideStories:
            SGSimpleSettings.shared.hideStories = value
        case .showProfileId:
            SGSimpleSettings.shared.showProfileId = value
        case .warnOnStoriesOpen:
            SGSimpleSettings.shared.warnOnStoriesOpen = value
        case .sendWithReturnKey:
            SGSimpleSettings.shared.sendWithReturnKey = value
        case .rememberLastFolder:
            SGSimpleSettings.shared.rememberLastFolder = value
        case .sendLargePhotos:
            SGSimpleSettings.shared.sendLargePhotos = value
        case .storyStealthMode:
            SGSimpleSettings.shared.storyStealthMode = value
        case .disableSwipeToRecordStory:
            SGSimpleSettings.shared.disableSwipeToRecordStory = value
        case .quickTranslateButton:
            SGSimpleSettings.shared.quickTranslateButton = value
        case .uploadSpeedBoost:
            SGSimpleSettings.shared.uploadSpeedBoost = value
        case .hideReactions:
            SGSimpleSettings.shared.hideReactions = value
        case .showRepostToStory:
            SGSimpleSettings.shared.showRepostToStoryV2 = value
        case .contextShowSelectFromUser:
            SGSimpleSettings.shared.contextShowSelectFromUser = value
        case .contextShowSaveToCloud:
            SGSimpleSettings.shared.contextShowSaveToCloud = value
        case .contextShowRestrict:
            SGSimpleSettings.shared.contextShowRestrict = value
        case .contextShowHideForwardName:
            SGSimpleSettings.shared.contextShowHideForwardName = value
        case .disableScrollToNextChannel:
            SGSimpleSettings.shared.disableScrollToNextChannel = !value
        case .disableScrollToNextTopic:
            SGSimpleSettings.shared.disableScrollToNextTopic = !value
        case .disableChatSwipeOptions:
            SGSimpleSettings.shared.disableChatSwipeOptions = !value
            simplePromise.set(true) // Trigger update for 'enabled' field of other toggles
            askForRestart?()
        case .disableDeleteChatSwipeOption:
            SGSimpleSettings.shared.disableDeleteChatSwipeOption = !value
            askForRestart?()
        case .disableGalleryCamera:
            SGSimpleSettings.shared.disableGalleryCamera = !value
            simplePromise.set(true)
        case .disableGalleryCameraPreview:
            SGSimpleSettings.shared.disableGalleryCameraPreview = !value
        case .disableSendAsButton:
            SGSimpleSettings.shared.disableSendAsButton = !value
        case .disableSnapDeletionEffect:
            SGSimpleSettings.shared.disableSnapDeletionEffect = !value
        case .contextShowReport:
            SGSimpleSettings.shared.contextShowReport = value
        case .contextShowReply:
            SGSimpleSettings.shared.contextShowReply = value
        case .contextShowPin:
            SGSimpleSettings.shared.contextShowPin = value
        case .contextShowSaveMedia:
            SGSimpleSettings.shared.contextShowSaveMedia = value
        case .contextShowMessageReplies:
            SGSimpleSettings.shared.contextShowMessageReplies = value
        case .stickerTimestamp:
            SGSimpleSettings.shared.stickerTimestamp = value
        case .contextShowJson:
            SGSimpleSettings.shared.contextShowJson = value
        case .hideRecordingButton:
            SGSimpleSettings.shared.hideRecordingButton = !value
        case .hideTabBar:
            SGSimpleSettings.shared.hideTabBar = value
            simplePromise.set(true) // Trigger update for 'enabled' field of other toggles
            askForRestart?()
        case .showDC:
            SGSimpleSettings.shared.showDC = value
        case .showCreationDate:
            SGSimpleSettings.shared.showCreationDate = value
        case .showRegDate:
            SGSimpleSettings.shared.showRegDate = value
        case .compactChatList:
            SGSimpleSettings.shared.compactChatList = value
            askForRestart?()
        case .compactMessagePreview:
            SGSimpleSettings.shared.chatListLines = value ? SGSimpleSettings.ChatListLines.one.rawValue : SGSimpleSettings.ChatListLines.three.rawValue
            askForRestart?()
        case .compactFolderNames:
            SGSimpleSettings.shared.compactFolderNames = value
            askForRestart?()
        case .allChatsHidden:
            SGSimpleSettings.shared.allChatsHidden = value
            askForRestart?()
        case .defaultEmojisFirst:
            SGSimpleSettings.shared.defaultEmojisFirst = value
        case .messageDoubleTapActionOutgoingEdit:
            SGSimpleSettings.shared.messageDoubleTapActionOutgoing = value ? SGSimpleSettings.MessageDoubleTapAction.edit.rawValue : SGSimpleSettings.MessageDoubleTapAction.default.rawValue
        case .wideChannelPosts:
            SGSimpleSettings.shared.wideChannelPosts = value
        case .forceEmojiTab:
            SGSimpleSettings.shared.forceEmojiTab = value
        case .forceBuiltInMic:
            SGSimpleSettings.shared.forceBuiltInMic = value
        case .hideChannelBottomButton:
            SGSimpleSettings.shared.hideChannelBottomButton = !value
        case .secondsInMessages:
            SGSimpleSettings.shared.secondsInMessages = value
        case .confirmCalls:
            SGSimpleSettings.shared.confirmCalls = value
        case .swipeForVideoPIP:
            SGSimpleSettings.shared.videoPIPSwipeDirection = value ? SGSimpleSettings.VideoPIPSwipeDirection.up.rawValue : SGSimpleSettings.VideoPIPSwipeDirection.none.rawValue
        case .enableVoipTcp:
            let _ = (
                updateExperimentalUISettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
                        var settings = settings
                        settings.enableVoipTcp = value
                        return settings
                    }
                )
            ).start()
        case .nyStyleSnow:
            SGSimpleSettings.shared.nyStyle = value ? SGSimpleSettings.NYStyle.snow.rawValue : SGSimpleSettings.NYStyle.default.rawValue
            simplePromise.set(true) // Trigger update for 'enabled' field of other toggles
        case .nyStyleLightning:
            SGSimpleSettings.shared.nyStyle = value ? SGSimpleSettings.NYStyle.lightning.rawValue : SGSimpleSettings.NYStyle.default.rawValue
            simplePromise.set(true) // Trigger update for 'enabled' field of other toggles
        case .videoControlsInFooter:
            SGSimpleSettings.shared.videoControlsInFooter = value
        case .hideAccountInNotifications:
            SGSimpleSettings.shared.hideAccountInNotifications = value
            SGSimpleSettings.shared.synchronizeShared()
        }
    }, updateSliderValue: { setting, value in
        switch (setting) {
            case .accountColorsSaturation:
                if SGSimpleSettings.shared.accountColorsSaturation != value {
                    SGSimpleSettings.shared.accountColorsSaturation = value
                    simplePromise.set(true)
                }
            case .outgoingPhotoQuality:
                if SGSimpleSettings.shared.outgoingPhotoQuality != value {
                    SGSimpleSettings.shared.outgoingPhotoQuality = value
                    simplePromise.set(true)
                }
            case .stickerSize:
                if SGSimpleSettings.shared.stickerSize != value {
                    SGSimpleSettings.shared.stickerSize = value
                    simplePromise.set(true)
                }
        }

    }, setOneFromManyValue: { setting in
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let actionSheet = ActionSheetController(presentationData: presentationData)
        var items: [ActionSheetItem] = []
        
        switch (setting) {
            case .downloadSpeedBoost:
                let setAction: (String) -> Void = { value in
                    SGSimpleSettings.shared.downloadSpeedBoost = value
                    
                    let enableDownloadX: Bool
                    switch (value) {
                        case SGSimpleSettings.DownloadSpeedBoostValues.none.rawValue:
                            enableDownloadX = false
                        default:
                            enableDownloadX = true
                    }
                    
                    // Updating controller
                    simplePromise.set(true)

                    let _ = updateNetworkSettingsInteractively(postbox: context.account.postbox, network: context.account.network, { settings in
                        var settings = settings
                        settings.useExperimentalDownload = enableDownloadX
                        return settings
                    }).start(completed: {
                        Queue.mainQueue().async {
                            askForRestart?()
                        }
                    })
                }

                for value in SGSimpleSettings.DownloadSpeedBoostValues.allCases {
                    items.append(ActionSheetButtonItem(title: i18n("Settings.DownloadsBoost.\(value.rawValue)", presentationData.strings.baseLanguageCode), color: .accent, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        setAction(value.rawValue)
                    }))
                }
            case .bottomTabStyle:
                let setAction: (String) -> Void = { value in
                    SGSimpleSettings.shared.bottomTabStyle = value
                    simplePromise.set(true)
                }

                for value in SGSimpleSettings.BottomTabStyleValues.allCases {
                    items.append(ActionSheetButtonItem(title: i18n("Settings.Folders.BottomTabStyle.\(value.rawValue)", presentationData.strings.baseLanguageCode), color: .accent, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        setAction(value.rawValue)
                    }))
                }
            case .allChatsTitleLengthOverride:
                let setAction: (String) -> Void = { value in
                    SGSimpleSettings.shared.allChatsTitleLengthOverride = value
                    simplePromise.set(true)
                }

                for value in SGSimpleSettings.AllChatsTitleLengthOverride.allCases {
                    let title: String
                    switch (value) {
                        case SGSimpleSettings.AllChatsTitleLengthOverride.short:
                            title = "\"\(presentationData.strings.ChatList_Tabs_All)\""
                        case SGSimpleSettings.AllChatsTitleLengthOverride.long:
                            title = "\"\(presentationData.strings.ChatList_Tabs_AllChats)\""
                        default:
                            title = i18n("Settings.Folders.AllChatsTitle.none", presentationData.strings.baseLanguageCode)
                    }
                    items.append(ActionSheetButtonItem(title: title, color: .accent, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        setAction(value.rawValue)
                    }))
                }
//        case .allChatsFolderPositionOverride:
//            let setAction: (String) -> Void = { value in
//                SGSimpleSettings.shared.allChatsFolderPositionOverride = value
//                simplePromise.set(true)
//            }
//
//            for value in SGSimpleSettings.AllChatsFolderPositionOverride.allCases {
//                items.append(ActionSheetButtonItem(title: i18n("Settings.Folders.AllChatsTitle.\(value)", presentationData.strings.baseLanguageCode), color: .accent, action: { [weak actionSheet] in
//                    actionSheet?.dismissAnimated()
//                    setAction(value.rawValue)
//                }))
//            }
            case .translationBackend:
                let setAction: (String) -> Void = { value in
                    SGSimpleSettings.shared.translationBackend = value
                    simplePromise.set(true)
                }

                for value in SGSimpleSettings.TranslationBackend.allCases {
                    if value == .system {
                        if #available(iOS 18.0, *) {
                        } else {
                            continue // System translation is not available on iOS 17 and below
                        }
                    }
                    items.append(ActionSheetButtonItem(title: i18n("Settings.Translation.Backend.\(value.rawValue)", presentationData.strings.baseLanguageCode), color: .accent, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        setAction(value.rawValue)
                    }))
                }
            case .transcriptionBackend:
                let setAction: (String) -> Void = { value in
                    SGSimpleSettings.shared.transcriptionBackend = value
                    simplePromise.set(true)
                }

                for value in SGSimpleSettings.TranscriptionBackend.allCases {
                    if #available(iOS 13.0, *) {
                    } else {
                        if value == .apple {
                            continue // Apple recognition is not available on iOS 12
                        }
                    }
                    items.append(ActionSheetButtonItem(title: i18n("Settings.Transcription.Backend.\(value.rawValue)", presentationData.strings.baseLanguageCode), color: .accent, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        setAction(value.rawValue)
                    }))
                }
            case .nyStyle:
                let setAction: (String) -> Void = { value in
                    SGSimpleSettings.shared.nyStyle = value
                    simplePromise.set(true)
                }

                for value in SGSimpleSettings.NYStyle.allCases {
                    items.append(ActionSheetButtonItem(title: i18n("Settings.NY.Style.\(value.rawValue)", presentationData.strings.baseLanguageCode), color: .accent, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        setAction(value.rawValue)
                    }))
                }
        }
        
        actionSheet.setItemGroups([ActionSheetItemGroup(items: items), ActionSheetItemGroup(items: [
            ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, color: .accent, font: .bold, action: { [weak actionSheet] in
                actionSheet?.dismissAnimated()
            })
        ])])
        presentControllerImpl?(actionSheet, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
    }, openDisclosureLink: { [weak context] link in
        guard let context else {
            return
        }
        switch (link) {
            case .languageSettings:
                pushControllerImpl?(context.sharedContext.makeLocalizationListController(context: context))
            case .contentSettings:
                let _ = (getSGSettingsURL(context: context) |> deliverOnMainQueue).start(next: { [weak context] url in
                    guard let strongContext = context else {
                        return
                    }
                    strongContext.sharedContext.applicationBindings.openUrl(url)
                })
        }
    }, searchInput: { searchQuery in
        updateState { state in
            var updatedState = state
            updatedState.searchQuery = searchQuery
            return updatedState
        }
    })
    
    let sharedData = context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.callListSettings, ApplicationSpecificSharedDataKeys.experimentalUISettings])
    let preferences = context.engine.data.subscribe(TelegramEngine.EngineData.Item.Configuration.App())
    let updatedContentSettingsConfiguration = contentSettingsConfiguration(network: context.account.network)
    |> map(Optional.init)
    let contentSettingsConfiguration = Promise<ContentSettingsConfiguration?>()
    contentSettingsConfiguration.set(.single(nil)
    |> then(updatedContentSettingsConfiguration))
    
    let signal = combineLatest(simplePromise.get(), /*sliderPromise.get(),*/ statePromise.get(), context.sharedContext.presentationData, sharedData, preferences, contentSettingsConfiguration.get(),
        context.engine.accountData.observeAvailableColorOptions(scope: .replies),
        context.engine.accountData.observeAvailableColorOptions(scope: .profile)
    )
    |> map { _, /*sliderValue,*/ state, presentationData, sharedData, appConfiguration, contentSettingsConfiguration, availableReplyColors, availableProfileColors ->  (ItemListControllerState, (ItemListNodeState, Any)) in
        
        let callListSettings: CallListSettings = sharedData.entries[ApplicationSpecificSharedDataKeys.callListSettings]?.get(CallListSettings.self) ?? CallListSettings.defaultSettings
        let experimentalUISettings: ExperimentalUISettings = sharedData.entries[ApplicationSpecificSharedDataKeys.experimentalUISettings]?.get(ExperimentalUISettings.self) ?? ExperimentalUISettings.defaultSettings
        
        let entries = SGControllerEntries(presentationData: presentationData, callListSettings: callListSettings, experimentalUISettings: experimentalUISettings, appConfiguration: appConfiguration, nameColors: PeerNameColors.with(availableReplyColors: availableReplyColors, availableProfileColors: availableProfileColors), state: state)
        
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Garantgram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        
        // TODO(swiftgram): focusOnItemTag support
        /* var index = 0
        var scrollToItem: ListViewScrollToItem?
         if let focusOnItemTag = focusOnItemTag {
            for entry in entries {
                if entry.tag?.isEqual(to: focusOnItemTag) ?? false {
                    scrollToItem = ListViewScrollToItem(index: index, position: .top(0.0), animated: false, curve: .Default(duration: 0.0), directionHint: .Up)
                }
                index += 1
            }
        } */
        
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, ensureVisibleItemTag: /*focusOnItemTag*/ nil, initialScrollToItem: nil /* scrollToItem*/ )
        
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] c, a in
        controller?.present(c, in: .window(.root), with: a)
    }
    pushControllerImpl = { [weak controller] c in
        (controller?.navigationController as? NavigationController)?.pushViewController(c)
    }
//    getRootControllerImpl = { [weak controller] in
//        return controller?.view.window?.rootViewController
//    }
//    getNavigationControllerImpl = { [weak controller] in
//        return controller?.navigationController as? NavigationController
//    }
    askForRestart = { [weak context] in
        guard let context = context else {
            return
        }
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        presentControllerImpl?(
            UndoOverlayController(
                presentationData: presentationData, 
                content: .info(title: nil, // i18n("Common.RestartRequired", presentationData.strings.baseLanguageCode),
                    text: i18n("Common.RestartRequired", presentationData.strings.baseLanguageCode),
                    timeout: nil,
                    customUndoText: i18n("Common.RestartNow", presentationData.strings.baseLanguageCode) //presentationData.strings.Common_Yes
                ),
                elevatedLayout: false,
                action: { action in if action == .undo { exit(0) }; return true }
            ),
            nil
        )
    }
    return controller

}
