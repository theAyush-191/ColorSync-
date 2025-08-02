import UIKit

class ColorCardCell: UICollectionViewCell {
    
    @IBOutlet weak var hexLabel: UILabel!
    
    @IBOutlet weak var syncStatus: UIImageView!
    
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = 10
        colorView.clipsToBounds = true
    }
}
