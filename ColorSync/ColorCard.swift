//
//  ColorCard.swift
//  ColorSync
//
//  Created by Ayush Singh on 30/07/25.
//

import UIKit
import RealmSwift

class ColorCard:Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var hex:String
    @Persisted var date:Date
    @Persisted var isSynced:Bool=false
    @Persisted var ownerId:String
    
    
    convenience init(hex: String,date:Date,ownerId:String) {
           self.init()
           self.hex = hex
        self.date=date
        self.ownerId = ownerId
       }
    
    // Static function to generate random hex color
    static func generateRandomHexColor() -> String {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    static func hexToUIColor(_ hex: String) -> UIColor {
            var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if cString.hasPrefix("#") {
                cString.remove(at: cString.startIndex)
            }

            guard cString.count == 6 else { return .gray }

            var rgbValue: UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
    
}
