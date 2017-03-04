//
//  DataViewController.swift
//  UPC
//
//  Created by Никита Римский on 03.03.17.
//  Copyright © 2017 Никита Римский. All rights reserved.
//

import UIKit
import UICircularProgressRing

class DataViewController: UIViewController, UICircularProgressRingDelegate {
    
    public func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {}

    @IBOutlet weak var tempRing: UICircularProgressRingView!
    @IBOutlet weak var humRing: UICircularProgressRingView!
    @IBOutlet weak var noiseRing: UICircularProgressRingView!
    @IBOutlet weak var lightRing: UICircularProgressRingView!
    
    @IBOutlet weak var currCondLabel: UILabel!
    @IBOutlet weak var tempCondLabel: UILabel!
    @IBOutlet weak var humidityCondLabel: UILabel!
    @IBOutlet weak var noiseCondLabel: UILabel!
    @IBOutlet weak var lightCondLabel: UILabel!
    
    var rings: [UICircularProgressRingView?] { return [tempRing, humRing, noiseRing, lightRing] }
    var font = "SFUIDisplay-Light"
    var currCond = [Int]()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for ring in rings {
            ring?.delegate = self
            ring?.fontSize = 60
//            ring?.customFontWithName = font
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.getData), userInfo: nil, repeats: true)
    }
    
    func getData() {
        InternetManager.sharedInstance.getTemper(completionHandler: {success, error in
            if let light = success?["light"], let temp = success?["temperatue"], let hum = success?["humidity"], let noise = success?["noise"] {
                self.updateData(response1: temp as! CGFloat, response2: hum as! CGFloat, response3: noise as! CGFloat, response4: light as! CGFloat)
            } else {
                self.presentAlert()
                self.timer.invalidate()
            }
        })
    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "Ooops", message:
            "You have problems with connection", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {
            UIAlertAction in
            self.scheduledTimerWithTimeInterval()
        }
        alertController.addAction(tryAgainAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func updateData(response1: CGFloat, response2: CGFloat, response3: CGFloat, response4: CGFloat) {
        let value = response1 < 50 ? response1 : 50
        let value2 =  response2 < 100 ? response2 : 100
        let value3 = response3 < 65 ? response3 : 65
        let value4 = response4 < 15 ? response4 : 15
        
        let rings = [tempRing, humRing, noiseRing]
        let labels = [tempCondLabel, humidityCondLabel, noiseCondLabel]
        let values = [value, value2, value3]
        currCond = []
        
        for i in 0...2 {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .transitionCrossDissolve, animations: {
                self.valueChanged(ring: rings[i]!, value: values[i], label: labels[i]!)
            }, completion: nil)
            rings[i]?.setProgress(value: values[i], animationDuration: 1, completion: nil)
        }
        
        UIView.animate(withDuration: 1, animations: {
            let color: UIColor = self.checker(value: value4, minValue: 0, maxValue: 5)
            self.lightRing.outerRingColor = color
            self.lightRing.innerRingColor = color
            self.lightCondLabel.textColor = color
            self.lightCondLabel.text = self.nameLabel(color: color)
        })
        
        lightRing.setProgress(value: value4, animationDuration: 1, completion: {
            self.lightRing.maxValue = 15
        })
    }
    
    func valueChanged(ring: UICircularProgressRingView, value: CGFloat, label: UILabel) {
        var minValue: CGFloat = 0
        var maxValue: CGFloat = 0
        var color: UIColor = .gray
        
        switch ring {
        case tempRing:
            minValue = 24
            maxValue = 26
        case humRing:
            minValue = 45
            maxValue = 55
        case noiseRing:
            minValue = 30
            maxValue = 35
        default:
            break
        }
        
        ring.maxValue = maxValue + minValue
        color = checker(value: value, minValue: minValue, maxValue: maxValue)
        
        ring.innerRingColor = color
        ring.outerRingColor = color
        label.textColor = color
        label.text = nameLabel(color: color)
        
        if currCond.contains(3){
            currCondLabel.text = "Terrible"
            currCondLabel.textColor = Colours.red
        } else if !currCond.contains(3) && currCond.contains(2) {
            currCondLabel.text = "Satisfactory"
            currCondLabel.textColor = Colours.yellow
        } else  if !currCond.contains(3) && !currCond.contains(2) && currCond.contains(1) {
            currCondLabel.text = "Excellent"
            currCondLabel.textColor = Colours.green
        }
    }
    
    func checker(value: CGFloat, minValue: CGFloat, maxValue: CGFloat) -> UIColor {
        var color: UIColor = .gray
        if value >= minValue && value <= maxValue {
            color = Colours.green
            currCond.append(1)
        } else if value <= minValue - 5 || value >= maxValue + 5 {
            color = Colours.red
            currCond.append(3)
        } else {
            color = Colours.yellow
            currCond.append(2)
        }
        return color
    }
    
    func nameLabel(color: UIColor) -> String {
        var name = ""
        switch color {
        case Colours.green:
            name = "Excellent"
        case Colours.red:
            name = "Terrible"
        case Colours.yellow:
            name = "Satisfactory"
        default:
            name = ""
        }
        return name
    }
}

