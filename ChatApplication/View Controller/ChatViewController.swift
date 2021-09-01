//
//  ChatViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/27/21.
//

//import UIKit
//import MessageKit
//
//struct Sender: SenderType {
//    var senderId: String
//
//    var displayName: String
//}
//
//struct Message: MessageType {
//    var sender: SenderType
//
//    var messageId: String
//
//    var sentDate: Date
//
//    var kind: MessageKind
//
//
//}
//
//class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
//
//    let currentUser = Sender(senderId: "self", displayName: "Me Me")
//    let otherUser = Sender(senderId: "other", displayName: "John Doe")
//    var messages = [MessageType]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400 ), kind: .text("Hello World")))
//        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-76400 ), kind: .text("Howdy")))
//        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-66400 ), kind: .text("Good")))
//        messages.append(Message(sender: otherUser, messageId: "4", sentDate: Date().addingTimeInterval(-46400 ), kind: .text("Noice")))
//
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//    }
//
//    func currentSender() -> SenderType {
//        return currentUser
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages[indexPath.section]
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        messages.count
//    }
//
//}

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

final class ChatViewController: MessagesViewController {
  //3. defining properties. The messages array is the data model, and the messageListener is a listener which handles clean up.
  
  
  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  
  private let user: User
  private let channel: Channel

  private let database = Firestore.firestore()
  private var reference: CollectionReference?
  
  init(user: User, channel: Channel) {
    self.user = user
    self.channel = channel
    super.init(nibName: nil, bundle: nil)

    title = channel.name
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    messageListener?.remove() // clean up listener
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    setUpMessageView()
    removeMessageAvatars()
    listenToMessages()
  }
  
  private func listenToMessages() { //10. for the update of text in sections
    
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      return
    }

    reference = database.collection("channels/\(id)/thread")
    // Real-time update. Firestore calls this snapshot listener whenever there’s a change to the database.
    messageListener = reference?
      .addSnapshotListener { [weak self] querySnapshot, error in
        guard let self = self else { return }
        guard let snapshot = querySnapshot else {
          print("""
            Error listening for channel updates: \
            \(error?.localizedDescription ?? "No error")
            """)
          return
        }

        snapshot.documentChanges.forEach { change in
          self.handleDocumentChange(change)
        }
      }
  }
  
  private func save (_ message: Message) {
    
    reference?.addDocument(data: message.representation) { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("Error sending Messager: \(error.localizedDescription)")
        return
      }
      self.messagesCollectionView.scrollToLastItem()
    }
  }
  
  // MARK: - Helpers
  private func insertNewMessage(_ message: Message) { // 9. adds a new message.
    
    if messages.contains(message) {
      return
    }

    messages.append(message)
    messages.sort()

    let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
    let shouldScrollToBottom =
      messagesCollectionView.isAtBottom && isLatestMessage

    messagesCollectionView.reloadData()

    if shouldScrollToBottom { // it scrolls to reveal the new message
      messagesCollectionView.scrollToLastItem(animated: true)
    }
  }
  
  private func handleDocumentChange(_ change: DocumentChange) { // 12. for the real-time updating of message.
    guard let message = Message(document: change.document) else {
      return
    }

    switch change.type {
    case .added:
      insertNewMessage(message)
    default:
      break
    }
  }
  
  private func setUpMessageView() {
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .green
    messageInputBar.sendButton.setTitleColor(.green, for: .normal)
    // 8. Relevant delegates
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
  }
  
  private func removeMessageAvatars() {  // 7. Removes the blank space left for each hidden avatar and adjusts the inset of the top label above each message.
    
    guard
      let layout = messagesCollectionView.collectionViewLayout
        as? MessagesCollectionViewFlowLayout
    else {
      return
    }
    
    layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
    layout.textMessageSizeCalculator.incomingAvatarSize = .zero
    layout.setMessageIncomingAvatarSize(.zero)
    layout.setMessageOutgoingAvatarSize(.zero)
    
    let incomingLabelAlignment = LabelAlignment(
      textAlignment: .left,
      textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
    layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
    
    let outgoingLabelAlignment = LabelAlignment(
      textAlignment: .right,
      textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
    layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
  }
}

// MARK: - MessagesDisplayDelegate
//6. the collection view are simply images with text overlaid. Outgoing Message on right and incoming Message on the left.
extension ChatViewController: MessagesDisplayDelegate {
  // 1 if it’s from the current sender. If it is, return the app’s primary green color. If not, return a muted gray color. MessageKit uses this color for the background image of the message
  func backgroundColor(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> UIColor {
    return isFromCurrentSender(message: message) ? .green : .gray
  }

  // 2 return false to remove the header from each message. use this to display thread-specific information, such as a timestamp
  func shouldDisplayHeader(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> Bool {
    return false
  }

  // 3 hide the avatar from the view
  func configureAvatarView(
    _ avatarView: AvatarView,
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) {
    avatarView.isHidden = true
  }

  // 4 corner for the tail of the message bubble.
  func messageStyle(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> MessageStyle {
    let corner: MessageStyle.TailCorner =
      isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {//5. Setting up the display n layout delegate
  // 1 Adds a little bit of padding on the bottom of each message to improve the chat’s readability.
  func footerViewSize(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGSize {
    return CGSize(width: 0, height: 8)
  }

  // 2 Sets the height of the top label above each message. This label will hold the sender’s name.
  func messageTopLabelHeight(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGFloat {
    return 20
  }
}
// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource { //4. Setting up the chat interface configuring the data source
  // 1 Each message takes up a section in the collection view.
  func numberOfSections(
    in messagesCollectionView: MessagesCollectionView
  ) -> Int {
    return messages.count
  }

  // 2 MessageKit name, ID for user. conforming to SenderType.
  func currentSender() -> SenderType {
    return Sender(senderId: user.uid, displayName: AppSettings.displayName)
  }

  // 3 Message model object conforms to MessageType, return the message for the given index path.
  func messageForItem(
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> MessageType {
    return messages[indexPath.section]
  }

  // 4 returns the attributed text for the name above each message bubble
  func messageTopLabelAttributedText(
    for message: MessageType,
    at indexPath: IndexPath
  ) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ])
  }
}
// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate { //11.
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    // 1 Create a Message from the contents of the input bar and the current user.
    let message = Message(user: user, content: text)
    // 2 Save the message to the Firestore database.
    save(message)
    // 3 Clear the input bar’s text
    inputBar.inputTextView.text = ""
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {}
