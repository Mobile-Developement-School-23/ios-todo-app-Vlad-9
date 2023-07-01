import UIKit

class CreateNewTaskTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Новое"
        label.font = .systemFont(ofSize: 17)
        label.textColor = Colors.labelTeritary.value
        //   label.font = .systemFont(ofSize: C, weight: .semibold)
        
        return label
    }()
    var icon = UIImageView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        icon.image = UIImage(named: "addIcon")
        addSubview(titleLabel)
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: self.topAnchor,constant: 16),
            icon.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16),
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor,constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16),
        ])
        self.selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backgroundColor = .red
        
        // Initialization code
    }
}
  
