//
//  HomeViewController.swift
//  ColorSync
//
//  Created by Ayush Singh on 30/07/25.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseFirestore
import Network

class HomeViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var networkStatus: UIBarButtonItem!
    
    var cards: Results<ColorCard>!
    let realm=try! Realm()
    
    let uid=Auth.auth().currentUser?.uid ?? ""
    
    let monitor = NWPathMonitor()
    let monitorQueue = DispatchQueue.global(qos: .background)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate=self
        collectionView.dataSource=self
        
        loadCardsFromRealm()
        
        networkMonitor()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            layout.itemSize = CGSize(width: 150, height: 100)
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 16
            
        }
        
        if monitor.currentPath.status == .satisfied{
            fetchDataFromFirestore()
        }
        
    }
    
    
    
    @IBAction func addButton(_ sender: Any) {
        
        var hex:String
        
        repeat{
            hex=ColorCard.generateRandomHexColor()
        }while realm.objects(ColorCard.self).filter("ownerId == %@ AND hex == %@", uid, hex).count > 0
                
                let newCard = ColorCard(hex: hex,date:Date(),ownerId:uid)
                
                try! realm.write{
            realm.add(newCard)
                    
        }
        
        if monitor.currentPath.status == .satisfied {
            loadCardsToFirestore(newCard)
            syncUnsyncedCards()
        }
        
        self.loadCardsFromRealm()
        
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
        
    }
    
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        let storyboard=UIStoryboard(name: "Main", bundle: nil)
        let loginVC=storyboard.instantiateViewController(identifier: "LoginViewController")
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    
    //MARK: - Load Data
    func loadCardsFromRealm(){
        
        cards=realm.objects(ColorCard.self).filter("ownerId == %@", uid).sorted(byKeyPath: "date", ascending: true)
        collectionView.reloadData()
        
    }
    
    
}

//MARK: - Collection View Delegate Methods
extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCardCell", for: indexPath) as? ColorCardCell else {
            return UICollectionViewCell()
        }
        
        let card = cards[indexPath.row]
        cell.hexLabel.text = card.hex
        cell.colorView.backgroundColor = ColorCard.hexToUIColor(card.hex)
        cell.colorView.layer.cornerRadius = 10
        
        if card.isSynced {
            cell.syncStatus.image = UIImage(systemName: "cloud")
            cell.syncStatus.tintColor = .systemBlue
        } else {
            cell.syncStatus.image = UIImage(systemName: "cloud.slash")
            cell.syncStatus.tintColor = .systemRed
        }
        return cell
    }
    
}



//FireStore Methods
extension HomeViewController{
    
    //MARK: - Load cards to Firestore
    func loadCardsToFirestore( _ card : ColorCard){
        
        guard let uid=Auth.auth().currentUser?.uid else{
            return
        }
        
        let db=Firestore.firestore()
        let hex=card.hex
        let date = card.date
        let ownerId=uid
        
        db.collection("Users").document(uid).collection("colorCards").document(card.id).setData([
            "id": card.id,
            "hex": hex,
            "date": Timestamp(date: date)
        ]) { error in
            if let error = error{
                print("Upload Failed:\(error.localizedDescription)")
                return
            }
            print("Upload Successful for \(uid)")
            
            DispatchQueue.main.async {
                
                if let cardToUpdate = self.realm.objects(ColorCard.self)
                    .filter("hex == %@ AND date == %@ AND ownerId == %@", hex, date, ownerId)
                    .first {
                    try! self.realm.write {
                        cardToUpdate.isSynced = true
                    }
                }
                self.loadCardsFromRealm()
            }
        }
        //        print("Saving to Firestore path: Users/\(uid)/colorCards/\(cardId)")
        //        print("Hex: \(hex)")
        //        print("Date: \(date)")
        
    }
    
    func syncUnsyncedCards(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let unsyncedCards=realm.objects(ColorCard.self).filter("ownerId == %@ AND isSynced == false", uid)
        
        for card in unsyncedCards{
            loadCardsToFirestore(card)
        }
        
    }
    
    //MARK: - Network Monitor Method
    func networkMonitor(){
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied{
                    
                    print("Connected to internet")
                    self.networkStatus.image=UIImage(systemName: "wifi")
                    self.networkStatus.tintColor = .systemGreen
                    
                    self.syncUnsyncedCards()
                    self.fetchDataFromFirestore()
                }
                
                
                else{
                    self.networkStatus.image=UIImage(systemName: "wifi.slash")
                    self.networkStatus.tintColor = .systemRed
                    print("Not connected to internet")
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    
    
    //MARK: - Fetch data from Firestore
    func fetchDataFromFirestore(){
        guard let uid=Auth.auth().currentUser?.uid else{
            return
        }
        
        let db=Firestore.firestore()
        
        db.collection("Users").document(uid)
            .collection("colorCards").order(by: "date", descending: false).getDocuments { snapshot, error in
                if let error = error{
                    print("Error fetching from Firestore: \(error.localizedDescription)")
                    return
                }
                
                guard let documents=snapshot?.documents else{
                    print("No documents found for user \(uid)")
                    return
                }
                
                try! self.realm.write{
                    for doc in documents{
                        let data=doc.data()
                        guard let id = data["id"] as? String else { continue }
                        let hex = data["hex"] as? String ?? "#FFFFFF"
                        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                        
                        let exists = self.realm.object(ofType: ColorCard.self, forPrimaryKey: id) != nil
                        
                        if !exists {
                            let card = ColorCard(hex: hex, date: date, ownerId: uid)
                            card.id = id
                            card.isSynced = true
                            self.realm.add(card)
                        }
                    }
                }
                
                print("Fetched \(documents.count) cards from Firestore")
                self.loadCardsFromRealm()
            }
        
        
    }
    
}



