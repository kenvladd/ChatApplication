//
//  ConversationViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/27/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class ConversationViewController: ViewController {
    
    @IBOutlet var myTable: UITableView!
    private let channelCellIdentifier = "channelCell"
    private var currentChannelAlertController: UIAlertController?

    private let database = Firestore.firestore()
    private var channelReference: CollectionReference {
      return database.collection("channels")
    }

    private var channels: [Channel] = []
    private var channelListener: ListenerRegistration?

    private var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTable.delegate = self
        myTable.dataSource = self
        
        currentUser = Auth.auth().currentUser
        
        channelListener = channelReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            self.myTable.reloadData()
        }
    }
    
    private func addChannelToTable(_ channel: Channel) {

            if channels.contains(channel) {
                return

            }
            channels.append(channel)

            channels.sort()

        }
        private func updateChannelInTable(_ channel: Channel) {

            guard let index = channels.firstIndex(of: channel) else {

                return

            }
            channels[index] = channel

        }
        private func removeChannelFromTable(_ channel: Channel) {

            guard let index = channels.firstIndex(of: channel) else {

                return

            }

            

            channels.remove(at: index)

        }
        private func handleDocumentChange(_ change: DocumentChange) {

            guard let channel = Channel(document: change.document) else {

                return

            }
            switch change.type {

            case .added:

                addChannelToTable(channel)

            case .modified:

                updateChannelInTable(channel)

            case .removed:

                removeChannelFromTable(channel)

            }

        }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = channels[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let _currentUser = currentUser {
        let channel = channels[indexPath.row]
        let viewController = ChatViewController(user: _currentUser, channel: channel)
        navigationController?.pushViewController(viewController, animated: true)

                }
    }
}
