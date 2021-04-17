
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    let categoryLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createCell()
        self.setupContents(textName: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCell() {
        categoryLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
//        layer.borderColor = UIColor.darkGray.cgColor
//        layer.borderWidth = 3.0

        contentView.addSubview(categoryLabel)
    }

    func setupContents(textName: String) {
        categoryLabel.text = textName
    }

}
