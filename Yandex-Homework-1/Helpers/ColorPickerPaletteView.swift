import UIKit


class ColorPickerPaletteView : UIView {

    var onColorDidChange: ((_ color: UIColor) -> ())?

    var palette = CGRect.zero
    var elementSize: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureView() {
        self.clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.colorTouched(gestureRecognizer:)))
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        palette = CGRect(x: 0,
                         y: -250,
                         width: rect.width,
                         height: rect.height + 500)
        
        for y in stride(from: CGFloat(0), to: palette.height, by: elementSize) {
            for x in stride(from: (0 as CGFloat), to: palette.width, by: elementSize) {
                let hue = x / palette.width
                let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y: y + palette.origin.y,
                                     width: elementSize, height: elementSize))
            }
        }
    }
    
    func getColorAtPoint(point: CGPoint) -> UIColor
    {
        let roundedPoint = CGPoint(x:
                                    elementSize * CGFloat(Int(point.x / elementSize)),
                                   y:elementSize * CGFloat(Int(point.y / elementSize)))
        
        let hue = roundedPoint.x / self.bounds.width
        
        if palette.contains(point)
        {
            var color =  UIColor(hue: hue,
                                 saturation: 1.0,
                                 brightness: 1.0, alpha: 1.0)
            return color
        } else {
            return .black
        }
    }

    @objc func colorTouched(gestureRecognizer: UILongPressGestureRecognizer){
        let point = gestureRecognizer.location(in: self)
        let color = getColorAtPoint(point: point)
        self.onColorDidChange?(color)
    }
}
