//
//  DataViewController.swift
//  UPC
//
//  Created by Никита Римский on 03.03.17.
//  Copyright © 2017 Никита Римский. All rights reserved.
//

import UIKit
import UICircularProgressRing

class DataViewController: UIViewController, UICircularProgressRingDelegate, UIGestureRecognizerDelegate {
    
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
    
    var conditions = [Double]()
    var taps = [UITapGestureRecognizer]()
    var rings: [UICircularProgressRingView?] { return [tempRing, humRing, noiseRing, lightRing] }
    var font = "SFUIDisplay-Light"
    var currCond = [Int]()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taps = [UITapGestureRecognizer(target: self, action: #selector(showInfo)), UITapGestureRecognizer(target: self, action: #selector(showInfo)), UITapGestureRecognizer(target: self, action: #selector(showInfo)),UITapGestureRecognizer(target: self, action: #selector(showInfo))]
        
        for tap in taps {
            tap.delegate = self
            tap.isEnabled = false
        }
        
        for i in 0...3 {
            rings[i]?.delegate = self
            rings[i]?.addGestureRecognizer(taps[i])
        }
        
        scheduledTimerWithTimeInterval()
    }
    
    func showInfo(sender: UITapGestureRecognizer?) {
        performSegue(withIdentifier: "showInfo", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var tag = 0
        if let send = sender as? UITapGestureRecognizer {
            tag = (send.view?.tag)!
        }
        if let destinationVC = segue.destination as? SeparateInfoViewController {
            switch tag {
            case 12:
                destinationVC.ringType = "temp"
                destinationVC.startValue = conditions[0]
                destinationVC.nums = [9, 25, 41]
                destinationVC.name = "Temperature"
            case 13:
                destinationVC.ringType = "hum"
                destinationVC.startValue = conditions[1]
                destinationVC.nums = [18, 50, 82]
                destinationVC.name = "Humidity"
            case 14:
                destinationVC.ringType = "noise"
                destinationVC.startValue = conditions[2]
                destinationVC.nums = [11, 32, 53]
                destinationVC.name = "Noise"
            case 15:
                destinationVC.ringType = "light"
                destinationVC.startValue = conditions[3]
                destinationVC.nums = [3, 8, 13]
                destinationVC.name = "Light"
            default:
                break
            }
        }
    }

    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.getData), userInfo: nil, repeats: true)
    }
    
    func getData() {
        InternetManager.sharedInstance.getTemper(completionHandler: {success, error in
            if let light = success?["light"],
                let temp = success?["temperature"],
                let hum = success?["humidity"],
                let noise = success?["noise"] {
                
                for tap in self.taps {
                    tap.isEnabled = true
                }
                
                if let response1 = temp as? String,
                    let response2 = hum as? String,
                    let response3 = noise as? String,
                    let response4 = light as? String
                {
                        self.updateData(response1: Double(response1)!, response2: Double(response2)!, response3: Double(response3)!, response4: Double(response4)!)
                    self.giveData(temp: Double(response1)!, hum: Double(response2)!, noise: Double(response3)!, light: Double(response4)!)
                } else if let response1 = temp as? Double,
                    let response2 = hum as? Double,
                    let response3 = noise as? Double,
                    let response4 = light as? Double
                    {
                        self.updateData(response1: response1, response2: response2, response3: response3, response4: response4)
                        self.giveData(temp: response1, hum: response2, noise: response3, light: response4)
                }
            } else {
                self.presentAlert()
                self.timer.invalidate()
            }
        })
    }
    
    func giveData(temp: Double, hum: Double, noise: Double, light: Double) {
        conditions = [temp, hum, noise, light]
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

    func updateData(response1: Double, response2: Double, response3: Double, response4: Double) {
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
                self.valueChanged(ring: rings[i]!, value: Double(values[i]), label: labels[i]!)
            }, completion: nil)
            rings[i]?.setProgress(value: CGFloat(values[i]), animationDuration: 1, completion: nil)
        }
        
        UIView.animate(withDuration: 1, animations: {
            let color: UIColor = self.checker(value: value4, minValue: 0, maxValue: 5)
            self.lightRing.outerRingColor = color
            self.lightRing.innerRingColor = color
            self.lightCondLabel.textColor = color
            self.lightRing.maxValue = 15
            self.lightCondLabel.text = self.nameLabel(color: color)
        })
        
        lightRing.setProgress(value: CGFloat(value4), animationDuration: 1, completion: nil)
    }
    
    func valueChanged(ring: UICircularProgressRingView, value: Double, label: UILabel) {
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
        color = checker(value: value, minValue: Double(minValue), maxValue: Double(maxValue))
        
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
    
    func checker(value: Double, minValue: Double, maxValue: Double) -> UIColor {
        var color: UIColor = .gray
        if value >= minValue && value <= maxValue {
            color = Colours.green
            currCond.append(1)
        } else if value < minValue - 5 || value > maxValue + 5 {
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

