//
//  TaipanGame.swift
//  Taipan
//
//  Created by sh95014 on 3/27/22.
//

import Foundation

extension Int {
    static func random(_ numerator: Int, in denominator: Int, comment: String? = nil) -> Bool {
        // random(in: 0..<denominator) < numerator
        let r = random(in: 0..<denominator)
        print("\(comment ?? "") random(\(numerator) in: \(denominator)) -> \(r)")
        return r < numerator
    }
    
    func fancyFormatted() -> String {
        if self >= 1000000000000 {
            let s = self.formatted(.number.scale(0.000000000001).precision(.fractionLength(1)))
            return "\(s) Trillion"
        }
        else if self >= 1000000000 {
            let s = self.formatted(.number.scale(0.000000001).precision(.fractionLength(1)))
            return "\(s) Billion"
        }
        else if self >= 1000000 {
            let s = self.formatted(.number.scale(0.000001).precision(.fractionLength(1)))
            return "\(s) Million"
        }
        else {
            return "\(self.formatted())"
        }
    }
}

class Game: ObservableObject {
    @Published var companyName: String?
    @Published var cash: Int = 50000
    
    // used to override the random events
    var dbgMakeShipOffer = false
    var dbgMakeGunOffer = false
    var dbgOpiumSeized = false
    var dbgWarehouseTheft = false
    var dbgPriceDrop = false
    var dbgPriceJump = false
    
    init() {
        currentCity = .hongkong
        setPrices()
        state = .elderBrotherWuBusiness
    }
    
    // MARK: - State Machine
    
    enum State: String {
        case arriving
        case liYuanExtortion
        case mcHenryOffer
        case elderBrotherWuWarning1
        case elderBrotherWuWarning2
        case elderBrotherWuWarning3
        case elderBrotherWuBusiness
        case newShipOffer
        case newGunOffer
        case opiumSeized
        case warehouseTheft
        case liYuanMessage
        case goodPrices
        case priceDrop
        case priceJump
        case robbery
        case trading
    }
    
    enum Event: String {
        case tap
        case timer
        case yes
        case no
        case repaired
    }
    
    @Published var state: State = .trading
    private var timer: Timer?
    
    private func setTimer(_ interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [self] timer in
            sendEvent(.timer)
        }
    }
    
    func transitionTo(_ newState: State) {
        switch newState {
        case .mcHenryOffer:
            if currentCity == .hongkong && shipDamage > 0 {
                setMcHenryOffer()
                state = newState
            }
            else {
                transitionTo(.elderBrotherWuWarning1)
            }
        case .elderBrotherWuWarning1:
            if debt > 10000 && !elderBrotherWuWarningIssued {
                setTimer(3)
                state = newState
            }
            else {
                transitionTo(.elderBrotherWuBusiness)
            }
        case .elderBrotherWuWarning2:
            setTimer(3)
            state = newState
        case .elderBrotherWuWarning3:
            elderBrotherWuWarningIssued = true
            setTimer(5)
            state = newState
        case .elderBrotherWuBusiness:
            if currentCity == .hongkong {
                state = newState
            }
            else {
                transitionTo(.newShipOffer)
            }
        case .opiumSeized:
            if shipHold[.opium] != nil && currentCity != .hongkong && (Int.random(1, in: 18) || dbgOpiumSeized) {
                seizeOpium()
                state = newState
                setTimer(5)
            }
            else {
                transitionTo(.warehouseTheft)
            }
        case .warehouseTheft:
            if warehouseUsedCapacity > 0 && (Int.random(1, in: 50) || dbgWarehouseTheft) {
                warehouseTheft()
                state = newState
                setTimer(5)
            }
            else {
                transitionTo(.liYuanMessage)
            }
        case .liYuanMessage:
            transitionTo(.goodPrices)
        case .goodPrices:
            if Int.random(1, in: 9) || dbgPriceDrop || dbgPriceJump {
                if Int.random(1, in: 2) || dbgPriceDrop {
                    transitionTo(.priceDrop)
                }
                else {
                    transitionTo(.priceJump)
                }
            }
            else {
                transitionTo(.robbery)
            }
        case .priceDrop:
            priceDrop()
            state = newState
            setTimer(3)
        case .priceJump:
            priceJump()
            state = newState
            setTimer(3)
        case .robbery:
            transitionTo(.trading)
        default:
            state = newState
            break
        }
    }
    
    func sendEvent(_ event: Event) {
        switch (state, event) {
        case (.arriving, .tap): timer?.invalidate(); fallthrough
        case (.arriving, .timer):
            arriveAt(destinationCity!)
            transitionTo(.mcHenryOffer)
        case (.mcHenryOffer, .no),
             (.mcHenryOffer, .repaired):
            transitionTo(.elderBrotherWuWarning1)
        case (.elderBrotherWuWarning1, .tap): timer?.invalidate(); fallthrough
        case (.elderBrotherWuWarning1, .timer):
            transitionTo(.elderBrotherWuWarning2)
        case (.elderBrotherWuWarning2, .tap): timer?.invalidate(); fallthrough
        case (.elderBrotherWuWarning2, .timer):
            transitionTo(.elderBrotherWuWarning3)
        case (.elderBrotherWuWarning3, .tap): timer?.invalidate(); fallthrough
        case (.elderBrotherWuWarning3, .timer):
            transitionTo(.elderBrotherWuBusiness)
        case (.elderBrotherWuBusiness, .no):
            transitionTo(newShipOrGunOffer() ?? .opiumSeized)
        case (.newShipOffer, .yes):
            transitionTo(upgradeShip() ?? .opiumSeized)
        case (.newShipOffer, .no):
            transitionTo(.opiumSeized)
        case (.newGunOffer, .yes):
            buyGun()
            fallthrough
        case (.newGunOffer, .no):
            transitionTo(.opiumSeized)
        case (.opiumSeized, .tap): timer?.invalidate(); fallthrough
        case (.opiumSeized, .timer):
            transitionTo(.warehouseTheft)
        case (.warehouseTheft, .tap): timer?.invalidate(); fallthrough
        case (.warehouseTheft, .timer):
            transitionTo(.liYuanMessage)
        case (.priceDrop, .tap): timer?.invalidate(); fallthrough
        case (.priceDrop, .timer):
            transitionTo(.robbery)
        case (.priceJump, .tap): timer?.invalidate(); fallthrough
        case (.priceJump, .timer):
            transitionTo(.robbery)
        default:
            print("illegal event \(event) in state \(state)")
            break
        }
    }
    
    // MARK: - Ship
    
    @Published var shipDamage: Int = 0
    var shipStatus: Int { 100 - Int((Double(shipDamage) / Double(shipCapacity)) * 100) }
    var fancyShipStatus: String {
        let statusStrings = [ "Critical", "Poor", "Fair", "Good", "Prime", "Perfect" ]
        return "\(statusStrings[shipStatus / 20]): \(shipStatus)"
    }
    var shipInDanger: Bool { shipStatus < 40 }
    
    @Published var shipCapacity: Int = 60
    @Published var shipHold: [Merchandise: Int] = [:]
    @Published var shipGuns: Int = 3
    private let gunWeight = 10
    
    var shipFreeCapacity: Int {
        var freeCapacity = shipCapacity - shipGuns * gunWeight
        for (_, units) in shipHold {
            freeCapacity -= units
        }
        return freeCapacity
    }
    
    func transferToShip(_ merchandise: Merchandise, _ amount: Int) {
        shipHold[merchandise] = (shipHold[merchandise] ?? 0) + amount
        warehouse[merchandise] = warehouse[merchandise]! - amount
    }
    
    // MARK: - Warehouse
    
    @Published var warehouse: [Merchandise: Int] = [:]
    private let warehouseCapacity = 10000
    
    var warehouseUsedCapacity: Int {
        var usedCapacity = 0
        for (_, units) in warehouse {
            usedCapacity += units
        }
        return usedCapacity
    }
    
    var warehouseFreeCapacity: Int { warehouseCapacity - warehouseUsedCapacity }
    
    func transferToWarehouse(_ merchandise: Merchandise, _ amount: Int) {
        warehouse[merchandise] = (warehouse[merchandise] ?? 0) + amount
        shipHold[merchandise] = shipHold[merchandise]! - amount
    }
    
    func warehouseTheft() {
        for (merchandise, units) in warehouse {
            warehouse[merchandise] = Int(Double(units) / 1.8 * Double.random(in: 0.0...1.0))
        }
    }

    // MARK: - Market
    
    enum Merchandise: String, CaseIterable {
        case opium   = "Opium"
        case silk    = "Silk"
        case arms    = "Arms"
        case general = "General Cargo"
        var shortValue: String { self.rawValue.components(separatedBy: " ").first! }
    }
    
    private let priceMultiplier: [City: [Merchandise: Int]] = [
        .hongkong:  [ .opium:   11, .silk:  11, .arms: 12, .general: 10 ],
        .shanghai:  [ .opium:   16, .silk:  14, .arms: 16, .general: 11 ],
        .nagasaki:  [ .opium:   15, .silk:  15, .arms: 10, .general: 12 ],
        .saigon:    [ .opium:   14, .silk:  16, .arms: 11, .general: 13 ],
        .manila:    [ .opium:   12, .silk:  10, .arms: 13, .general: 14 ],
        .singapore: [ .opium:   10, .silk:  13, .arms: 14, .general: 15 ],
        .batavia:   [ .opium:   13, .silk:  12, .arms: 15, .general: 16 ],
    ]
    private let basePrice: [Merchandise: Int] = [ .opium: 1000, .silk: 100, .arms: 10, .general:  1 ]
    @Published var price: [Merchandise: Int] = [:]
    
    private func setPrices() {
        for merchandise in Merchandise.allCases {
            price[merchandise] = priceMultiplier[currentCity!]![merchandise]! / 2 * Int.random(in: 1...3) * basePrice[merchandise]!
        }
    }
    
    @Published var goodPriceMerchandise: Merchandise?
    
    private func priceDrop() {
        goodPriceMerchandise = Merchandise.allCases.randomElement()!
        price[goodPriceMerchandise!]! /= 5
        dbgPriceDrop = false
    }
    
    private func priceJump() {
        goodPriceMerchandise = Merchandise.allCases.randomElement()!
        price[goodPriceMerchandise!]! *= Int.random(in: 5...9)
        dbgPriceJump = false
    }
    
    func canAfford(_ merchandise: Merchandise) -> Int {
        cash / price[merchandise]!
    }
    
    func canAffordAny() -> Bool {
        for (_, price) in self.price {
            if cash >= price {
                return true
            }
        }
        return false
    }
    
    func buy(_ merchandise: Merchandise, _ amount: Int) {
        if cash >= price[merchandise]! * amount {
            cash -= price[merchandise]! * amount
            shipHold[merchandise] = (shipHold[merchandise] ?? 0) + amount
        }
    }
    
    func canSell() -> Bool {
        for (_, units) in shipHold {
            if units > 0 {
                return true
            }
        }
        return false
    }
    
    func sell(_ merchandise: Merchandise, _ amount: Int) {
        if amount <= shipHold[merchandise] ?? 0 {
            cash += price[merchandise]! * amount
            shipHold[merchandise]! -= amount
        }
    }
    
    // MARK: - Travel
    
    enum City: String, CaseIterable {
        case hongkong  = "Hong Kong"
        case shanghai  = "Shanghai"
        case nagasaki  = "Nagasaki"
        case saigon    = "Saigon"
        case manila    = "Manila"
        case singapore = "Singapore"
        case batavia   = "Batavia"
    }

    enum Month: String, CaseIterable {
        case january   = "Jan"
        case february  = "Feb"
        case march     = "Mar"
        case april     = "Apr"
        case may       = "May"
        case june      = "Jun"
        case july      = "Jul"
        case august    = "Aug"
        case september = "Sep"
        case october   = "Oct"
        case november  = "Nov"
        case december  = "Dec"
        func next() -> Self {
            let allCases = Self.allCases
            return allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
        }
        func index() -> Int {
            Self.allCases.firstIndex(of: self)!
        }
    }
    
    @Published var currentCity: City?
    @Published var destinationCity: City?
    @Published var month: Month = .january
    @Published var year: Int = 1860
    private var months: Int { (year - 1860) * 12 + month.index() }
    
    private func aMonthPassed() {
        if month == .december {
            year += 1
        }
        month = month.next()
    }
    
    func departFor(_ city: City) {
        currentCity = nil
        destinationCity = city
        aMonthPassed()
        debt = Int(Double(debt) * 1.1)
        bank = Int(Double(bank) * 1.005)
        state = .arriving
        setTimer(3)
    }
    
    private func arriveAt(_ city: City) {
        currentCity = city
        destinationCity = nil
        setPrices()
    }
    
    // MARK: - Li Yuan
    
    private var liYuanPaidOff = false
    
    // MARK: - Mc Henry
    
    var mcHenryOffer: Int?
    private var mcHenryRate: Int?
    private func setMcHenryOffer() {
        mcHenryRate = Int(Double(60 * (months + 3) / 4) * Double.random(in: 0.0...1.0) + Double(25 * (months + 3) / 4 * shipCapacity / 50))
        mcHenryOffer = mcHenryRate! * shipDamage + 1
    }
    
    func repair(_ amount: Int) {
        shipDamage -= Int(Double(amount / mcHenryRate!) + 0.5)
        shipDamage = max(shipDamage, 0)
        cash -= amount
        sendEvent(.repaired)
    }
    
    // MARK: - Elder Brother Wu
    
    @Published var debt: Int = 0
    private var elderBrotherWuWarningIssued = false
    let elderBrotherWuBraves = Int.random(in: 50...149)
    
    var maximumLoan: Int { cash * 2 }
    
    func borrow(_ amount: Int) {
        debt += amount
        cash += amount
    }
    
    func repay(_ amount: Int) {
        cash -= min(amount, debt)
        debt -= min(amount, debt)
    }
    
    // MARK: - Bank
    @Published var bank: Int = 0
    
    func deposit(_ amount: Int) {
        if amount <= cash {
            bank += amount
            cash -= amount
        }
    }
    
    func withdraw(_ amount: Int) {
        if amount <= bank {
            cash += amount
            bank -= amount
        }
    }
    
    // MARK: - Special Offers
    
    var offerAmount: Int = 0
    
    private func newShipOrGunOffer() -> State? {
        if Int.random(1, in: 4, comment: "make offer?") || dbgMakeShipOffer || dbgMakeGunOffer {
            if Int.random(1, in: 2, comment: "ship?") || dbgMakeShipOffer {
                dbgMakeShipOffer = false
                offerAmount = 1000 + Int.random(in: 0...1000 * (months + 5) / 6) * (shipCapacity / 50)
                if cash >= offerAmount {
                    return .newShipOffer
                }
            }
            else {
                dbgMakeGunOffer = false;
                return newGunOffer()
            }
        }
        return nil
    }
    
    private func newGunOffer() -> State? {
        if shipGuns < 1000 {
            offerAmount = 500 + Int.random(in: 0...1000 * (months + 5) / 6)
            if cash >= offerAmount && shipFreeCapacity > gunWeight {
                return .newGunOffer
            }
        }
        return nil
    }
    
    private func upgradeShip() -> State? {
        cash -= offerAmount
        shipCapacity += 50
        shipDamage = 0
        
        if Int.random(1, in: 2, comment: "gun?") || dbgMakeGunOffer {
            return newGunOffer()
        }
        return nil
    }
    
    private func buyGun() {
        cash -= offerAmount
        shipGuns += 1
    }
    
    // MARK: - Authorities
    
    var fine: Int?
    
    func seizeOpium() {
        fine = Int(Double(cash) / 1.8 * Double.random(in: 0.0...1.0) + 1)
        cash -= fine!
        cash = max(0, cash)
        shipHold[.opium] = nil
    }
}
