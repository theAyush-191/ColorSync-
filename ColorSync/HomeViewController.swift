//
//  HomeViewController.swift
//  ColorSync
//
//  Created by Ayush Singh on 30/07/25.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var cards: Results<ColorCard>!
    let realm=try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate=self
        collectionView.dataSource=self
        cards=realm.objects(ColorCard.self)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.itemSize = CGSize(width: 150, height: 100)
                    layout.minimumLineSpacing = 16
                    layout.minimumInteritemSpacing = 16
                }
        
    }
    
    @IBAction func addButton(_ sender: Any) {
        let hex = ColorCard.generateRandomHexColor()
                let newCard = ColorCard(hex: hex)
//                cards.append(newCard)
        DispatchQueue.global(qos: .background).async {
            let bgRealm=try! Realm()
            try! bgRealm.write{
                bgRealm.add(newCard)
            }
        }
       
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
                
    }
    
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
                return cell
    }
    
}



