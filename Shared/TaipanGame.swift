//
//  TaipanGame.swift
//  Taipan
//
//  Created by sh95014 on 3/27/22.
//

//  Game formulas largely based on Jay Link's port at https://github.com/cymonsgames/CymonsGames/tree/master/taipan

import Foundation
#if os(iOS)
import AudioToolbox
import UIKit
#endif

extension Int {
    static func random(_ numerator: Int, in denominator: Int, comment: String? = nil) -> Bool {
        // random(in: 0..<denominator) < numerator
        let r = random(in: 0..<denominator)
        print("[\(comment ?? "")] random(\(numerator) in: \(denominator)) -> \(r)")
        return r < numerator
    }
    
    static func randomLog(in range: Range<Int>, comment: String? = nil) -> Int {
        let r = random(in: range)
        print("[\(comment ?? "")] random(in: \(range)) -> \(r)")
        return r
    }
    
    static func randomLog(in range: ClosedRange<Int>, comment: String? = nil) -> Int {
        let r = random(in: range)
        print("[\(comment ?? "")] random(in: \(range)) -> \(r)")
        return r
    }
    
    func fancyFormatted() -> String {
        if Bundle.main.preferredLocalizations[0].hasPrefix("zh") {
            if self >= 1_000_000_000_000 {
                let s = self.formatted(.number.scale(0.000000000001).precision(.fractionLength(1)))
                return "\(s)兆"
            }
            else if self >= 100_000_000 {
                let s = self.formatted(.number.scale(0.00000001).precision(.fractionLength(1)))
                return "\(s)億"
            }
            else if self >= 10_000 {
                let s = self.formatted(.number.scale(0.0001).precision(.fractionLength(1)))
                return "\(s)萬"
            }
        }
        else {
            if self >= 1_000_000_000_000 {
                let s = self.formatted(.number.scale(0.000000000001).precision(.fractionLength(1)))
                let format = String(localized: "%@ Trillion")
                return String.localizedStringWithFormat(format, s)
            }
            else if self >= 1_000_000_000 {
                let s = self.formatted(.number.scale(0.000000001).precision(.fractionLength(1)))
                let format = String(localized: "%@ Billion")
                return String.localizedStringWithFormat(format, s)
            }
            else if self >= 1_000_000 {
                let s = self.formatted(.number.scale(0.000001).precision(.fractionLength(1)))
                let format = String(localized: "%@ Million")
                return String.localizedStringWithFormat(format, s)
            }
        }
        return "\(self.formatted())"
    }
}

extension Double {
    static func randomLog(in range: Range<Double>, comment: String? = nil) -> Double {
        let r = random(in: range)
        print("[\(comment ?? "")] random(in: \(range)) -> \(r)")
        return r
    }
        
    static func randomLog(in range: ClosedRange<Double>, comment: String? = nil) -> Double {
        let r = random(in: range)
        print("[\(comment ?? "")] random(in: \(range)) -> \(r)")
        return r
    }
}

class Game: ObservableObject {
    var firmName: String?
    @Published var cash: Int?
    var netWorth: Int { cash! + bank - debt }
    var score: Int { netWorth / 100 / (months != 0 ? months : 1) }
    
    // used to override the random events
    var dbgLiYuenDemand: Int? = nil
    var dbgBailoutOffer = false
    var dbgCutthroats = false
    var dbgMakeShipOffer = false
    var dbgMakeGunOffer = false
    var dbgOpiumSeized = false
    var dbgWarehouseTheft = false
    var dbgLiYuenMessage = false
    var dbgPriceDrop = false
    var dbgPriceJump = false
    var dbgRobbery = false
    var dbgHostileShips = false
    var dbgHostilesCount: Int?
    var dbgRanAway = false
    var dbgHitGun = false
    var dbgEscapedSome = false
    var dbgliYuenDroveThemOff = false
    var dbgLiYuenAttack = false
    var dbgStorm = false
    var dbgGoingDown = false
    var dbgBlownOffCourse = false
    
    init() {
        initializeGame()
        transitionTo(.splash)
    }
    
    func initializeGame() {
        firmName = nil
        cash = 0
        bank = 0
        debt = 0
        warehouse = [:]
        shipHold = [:]
        shipCapacity = 60
        shipGuns = 0
        shipDamage = 0
        year = startYear
        month = .january
        currentCity = .hongkong
    }
    
    // MARK: - State Machine
    
    enum State: String {
        case splash
        case name
        case debtOrGuns
        case arriving
        case liYuenExtortion
        case notEnoughCash
        case borrowForLiYuen
        case borrowedForLiYuen
        case elderBrotherWuPirateWarning
        case mcHenryOffer
        case elderBrotherWuWarning1
        case elderBrotherWuWarning2
        case elderBrotherWuWarning3
        case elderBrotherWuBusiness
        case elderBrotherWuBailout
        case bailoutReaction
        case bankruptcy
        case cutthroats
        case newShipOffer
        case newGunOffer
        case opiumSeized
        case warehouseTheft
        case liYuenMessage
        case goodPrices
        case priceDrop
        case priceJump
        case robbery
        case trading
        case hostilesApproaching
        case seaBattle
        case battleSummary
        case liYuenDroveThemOff
        case liYuenApproaching
        case liYuenLetUsBe
        case liYuenAttacking
        case liYuenBattle
        case liYuenBattleSummary
        case storm
        case storm2
        case stormGoingDown
        case stormMadeIt
        case stormBlownOffCourse
        case retirement
        case finalStats
    }
    
    enum Event: String {
        case done
        case debt
        case guns
        case tap
        case timer
        case yes
        case no
        case repaired
        case battleEnded
        case liYuen
    }
    
    @Published var state: State = .splash
    private var timer: Timer?
    
    private func setTimer(_ interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [self] timer in
            sendEvent(.timer)
        }
    }
    
    func transitionTo(_ newState: State) {
        print("transitioning to state \(newState)")
        
        switch newState {
        case .splash:
            setTimer(5)
            state = newState
        case .name:
            initializeGame()
            state = newState
        case .arriving:
            setTimer(3)
            state = newState
        case .liYuenExtortion:
            if currentCity == .hongkong && cash! > 0 && liYuenCounter == liYuenCounterWantsMoney {
                liYuenExtortion()
                state = newState
            }
            else {
                transitionTo(.mcHenryOffer)
            }
        case .notEnoughCash:
            if !payLiYuen() {
                setTimer(3)
                state = newState
            }
            else {
                transitionTo(.mcHenryOffer)
            }
        case .borrowedForLiYuen:
            setTimer(5)
            state = newState
        case .elderBrotherWuPirateWarning:
            setTimer(5)
            state = newState
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
                if (cash == 0 && bank == 0 && shipGuns! == 0 &&
                    shipFreeCapacity == shipCapacity &&
                    warehouseUsedCapacity == 0) || dbgBailoutOffer {
                    transitionTo(.elderBrotherWuBailout)
                }
                else {
                    state = newState
                }
            }
            else {
                transitionTo(.cutthroats)
            }
        case .elderBrotherWuBailout:
            elderBrotherWuBailout()
            state = newState
        case .bailoutReaction:
            setTimer(5)
            state = newState
        case .bankruptcy:
            setTimer(5)
            state = newState
        case .cutthroats:
            if debt > 20000 && cash! > 0 && (Int.random(1, in: 5, comment: "cutthroats") || dbgCutthroats) {
                cutthroats()
                setTimer(5)
                state = newState
            }
            else {
                transitionTo(newShipOrGunOffer() ?? .opiumSeized)
            }
        case .opiumSeized:
            if hasOpiumOnShip && currentCity != .hongkong && (Int.random(1, in: 18, comment: "opium seizure") || dbgOpiumSeized) {
                seizeOpium()
                state = newState
                setTimer(5)
            }
            else {
                transitionTo(.warehouseTheft)
            }
        case .warehouseTheft:
            if warehouseUsedCapacity > 0 && (Int.random(1, in: 50, comment: "warehouse theft") || dbgWarehouseTheft) {
                warehouseTheft()
                state = newState
                setTimer(5)
            }
            else {
                transitionTo(.liYuenMessage)
            }
        case .liYuenMessage:
            if Int.random(1, in: 20, comment: "li yuen message") {
                if liYuenCounter >= liYuenCounterJustPaid {
                    liYuenCounter += 1
                }
                if liYuenCounter == 4 {
                    liYuenCounter = liYuenCounterWantsMoney
                }
            }
            if currentCity != .hongkong && liYuenCounter == liYuenCounterWantsMoney && (Int.random(3, in: 4, comment: "li yuen message") || dbgLiYuenMessage) {
                dbgLiYuenMessage = false
                state = newState
                setTimer(3)
            }
            else {
                transitionTo(.goodPrices)
            }
        case .goodPrices:
            if Int.random(1, in: 9, comment: "good prices") || dbgPriceDrop || dbgPriceJump {
                if Int.random(1, in: 2, comment: "jump or drop") || dbgPriceDrop {
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
            if cash! > 25000 && (Int.random(1, in: 20, comment: "robbery") || dbgRobbery) {
                robbery()
                state = newState
                setTimer(5)
            }
            else {
                transitionTo(.trading)
            }
        case .hostilesApproaching:
            if Int.random(1, in: pirateOdds!, comment: "pirates") || dbgHostileShips {
                dbgHostileShips = false
                hostileShips(.generic)
                state = newState
                setTimer(3)
            } else if Int.random(1, in: 4 + 8 * liYuenCounter, comment: "li yuen's pirates") || dbgLiYuenAttack {
                dbgLiYuenAttack = false
                transitionTo(.liYuenApproaching)
            }
            else {
                transitionTo(.storm)
            }
        case .seaBattle:
            seaBattle()
            state = newState
        case .battleSummary:
            battleSummary()
            state = newState
            setTimer(3)
        case .liYuenDroveThemOff:
            state = newState
            setTimer(3)
        case .liYuenApproaching:
            hostileShips(.liYuen)
            state = newState
            setTimer(3)
        case .liYuenLetUsBe:
            if liYuenCounter > 0 {
                state = newState
                setTimer(3)
            }
            else {
                transitionTo(.liYuenAttacking)
            }
        case .liYuenAttacking:
            state = newState
            setTimer(3)
        case .liYuenBattle:
            seaBattle()
            state = newState
        case .liYuenBattleSummary:
            battleSummary()
            state = newState
            setTimer(3)
        case .storm:
            if Int.random(1, in: 10, comment: "storm") || dbgStorm {
                dbgStorm = false
                state = newState
                setTimer(3)
            }
            else {
                transitionTo(.arriving)
            }
        case .storm2:
            if Int.random(1, in: 30, comment: "going down") || dbgGoingDown {
                state = newState
                setTimer(3)
            }
            else {
                transitionTo(.stormMadeIt)
            }
        case .stormGoingDown:
            if Double.randomLog(in: 0...Double(shipDamage / shipCapacity * 3), comment: "going down") > 1 || dbgGoingDown {
                dbgGoingDown = false
                state = newState
                setTimer(3)
            }
            else {
                transitionTo(.stormMadeIt)
            }
        case .stormMadeIt:
            state = newState
            setTimer(3)
        case .stormBlownOffCourse:
            if Int.random(1, in: 3, comment: "blown off course") || dbgBlownOffCourse {
                dbgBlownOffCourse = false
                blownOffCourse()
                state = newState
                setTimer(3)
            }
            else {
                transitionTo(.arriving)
            }
        case .retirement:
            state = newState
            setTimer(5)
        default:
            state = newState
            break
        }
    }
    
    func sendEvent(_ event: Event) {
        print("received event \(event) in state \(state)")
        
        switch (state, event) {
        case (.splash, .tap): timer?.invalidate(); fallthrough
        case (.splash, .timer):
            transitionTo(.name)
            
        case (.name, .done):
            transitionTo(.debtOrGuns)
            
        case (.debtOrGuns, .debt):
            cash = 400
            debt = 5000
            shipGuns = 0
            liYuenCounter = 0
            pirateOdds = 10
            setPrices()
            transitionTo(.liYuenExtortion)
        case (.debtOrGuns, .guns):
            cash = 0
            debt = 0
            shipGuns = 5
            liYuenCounter = 1
            pirateOdds = 7
            setPrices()
            transitionTo(.liYuenExtortion)
            
        case (.arriving, .tap): timer?.invalidate(); fallthrough
        case (.arriving, .timer):
            arriveAt(destinationCity!)
            transitionTo(.liYuenExtortion)
        
        case (.liYuenExtortion, .yes):
            transitionTo(.notEnoughCash)
        case (.liYuenExtortion, .no):
            transitionTo(.mcHenryOffer)
        
        case (.notEnoughCash, .tap): timer?.invalidate(); fallthrough
        case (.notEnoughCash, .timer):
            transitionTo(.borrowForLiYuen)
        
        case (.borrowForLiYuen, .yes):
            borrowForLiYuen()
            transitionTo(.borrowedForLiYuen)
        case (.borrowForLiYuen, .no):
            transitionTo(.elderBrotherWuPirateWarning)
        
        case (.borrowedForLiYuen, .tap): timer?.invalidate(); fallthrough
        case (.borrowedForLiYuen, .timer):
            transitionTo(.mcHenryOffer)
        
        case (.elderBrotherWuPirateWarning, .tap): timer?.invalidate(); fallthrough
        case (.elderBrotherWuPirateWarning, .timer):
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
            transitionTo(.cutthroats)
        
        case (.elderBrotherWuBailout, .yes):
            acceptBailout()
            transitionTo(.bailoutReaction)
        
        case (.elderBrotherWuBailout, .no):
            transitionTo(.bankruptcy)
        
        case (.bankruptcy, .tap): timer?.invalidate(); fallthrough
        case (.bankruptcy, .timer):
            transitionTo(.finalStats)
        
        case (.bailoutReaction, .tap): timer?.invalidate(); fallthrough
        case (.bailoutReaction, .timer):
            transitionTo(.cutthroats)
        
        case (.cutthroats, .tap): timer?.invalidate(); fallthrough
        case (.cutthroats, .timer):
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
            transitionTo(.liYuenMessage)
        
        case (.liYuenMessage, .tap): timer?.invalidate(); fallthrough
        case (.liYuenMessage, .timer):
            transitionTo(.goodPrices)
        
        case (.priceDrop, .tap): timer?.invalidate(); fallthrough
        case (.priceDrop, .timer):
            transitionTo(.robbery)
        
        case (.priceJump, .tap): timer?.invalidate(); fallthrough
        case (.priceJump, .timer):
            transitionTo(.robbery)
        
        case (.robbery, .tap): timer?.invalidate(); fallthrough
        case (.robbery, .timer):
            transitionTo(.trading)
        
        case (.hostilesApproaching, .tap): timer?.invalidate(); fallthrough
        case (.hostilesApproaching, .timer):
            transitionTo(.seaBattle)
        
        case (.seaBattle, .battleEnded):
            transitionTo(.battleSummary)
        case (.seaBattle, .liYuen):
            transitionTo(.liYuenDroveThemOff)
        case (.seaBattle, .tap):
            seaBattleTap()
        
        case (.battleSummary, .tap): timer?.invalidate(); fallthrough
        case (.battleSummary, .timer):
            transitionTo(shipStatus > 0 ? .storm : .finalStats)
        
        case (.liYuenDroveThemOff, .tap): timer?.invalidate(); fallthrough
        case (.liYuenDroveThemOff, .timer):
            transitionTo(.liYuenApproaching)
        
        case (.liYuenApproaching, .tap): timer?.invalidate(); fallthrough
        case (.liYuenApproaching, .timer):
            transitionTo(.liYuenLetUsBe)
        
        case (.liYuenLetUsBe, .tap): timer?.invalidate(); fallthrough
        case (.liYuenLetUsBe, .timer):
            transitionTo(.storm)
        
        case (.liYuenAttacking, .tap): timer?.invalidate(); fallthrough
        case (.liYuenAttacking, .timer):
            transitionTo(.liYuenBattle)
        
        case (.liYuenBattle, .battleEnded):
            transitionTo(.liYuenBattleSummary)
        case (.liYuenBattle, .tap):
            seaBattleTap()
        
        case (.liYuenBattleSummary, .tap): timer?.invalidate(); fallthrough
        case (.liYuenBattleSummary, .timer):
            transitionTo(.storm)
        
        case (.storm, .tap): timer?.invalidate(); fallthrough
        case (.storm, .timer):
            endBattle()
            transitionTo(.storm2)
        
        case (.storm2, .tap): timer?.invalidate(); fallthrough
        case (.storm2, .timer):
            transitionTo(.stormGoingDown)
        
        case (.stormGoingDown, .tap): timer?.invalidate(); fallthrough
        case (.stormGoingDown, .timer):
            transitionTo(.finalStats)
        
        case (.stormMadeIt, .tap): timer?.invalidate(); fallthrough
        case (.stormMadeIt, .timer):
            transitionTo(.stormBlownOffCourse)
        
        case (.stormBlownOffCourse, .tap): timer?.invalidate(); fallthrough
        case (.stormBlownOffCourse, .timer):
            transitionTo(.arriving)
        
        case (.retirement, .tap): timer?.invalidate(); fallthrough
        case (.retirement, .timer):
            transitionTo(.finalStats)
        
        case (.finalStats, .no):
            exit(0)
        case (.finalStats, .yes):
            transitionTo(.name)
            break
        
        default:
            print("illegal event \(event) in state \(state)")
            break
        }
    }
    
    // MARK: - Ship
    
    var shipDamage: Int = 0
    var shipStatus: Int { max(100 - Int((Double(shipDamage) / Double(shipCapacity)) * 100), 0) }
    enum ShipStatusStyle {
        case colon
        case parenthesis
    }
    func fancyShipStatus(_ style: ShipStatusStyle = .colon) -> String {
        let statusStrings = [
            String(localized: "Critical"),
            String(localized: "Poor"),
            String(localized: "Fair"),
            String(localized: "Good"),
            String(localized: "Prime"),
            String(localized: "Perfect")
            ]
        switch style {
        case .colon:
            return "\(statusStrings[shipStatus / 20]): \(shipStatus)"
        case .parenthesis:
            return "\(statusStrings[shipStatus / 20]) (\(shipStatus.formatted(.percent)))"
        }
    }
    var shipInDanger: Bool { shipStatus < 40 }
    
    @Published var shipCapacity: Int = 0
    @Published var shipHold: [Merchandise: Int] = [:]
    @Published var shipGuns: Int?
    private let gunWeight = 10
    
    var shipFreeCapacity: Int {
        return shipCapacity - shipGuns! * gunWeight - shipHold.reduce(into: 0) { $0 += $1.value }
    }
    
    func transferToShip(_ merchandise: Merchandise, _ amount: Int) {
        guard let warehouseMerchandise = warehouse[merchandise],
              warehouseMerchandise >= amount
        else {
            print("insufficient \(merchandise.label) in warehouse to transfer \(amount)")
            return
        }
        
        shipHold[merchandise] = (shipHold[merchandise] ?? 0) + amount
        warehouse[merchandise] = warehouseMerchandise - amount
    }
    
    func shipHasCargo() -> Bool {
        for (_, units) in shipHold {
            if units > 0 {
                return true
            }
        }
        return false
    }
    
    var hasOpiumOnShip: Bool {
        if let opium = shipHold[.opium] {
            return opium > 0
        }
        return false
    }
    
    func onlyMerchandiseOnShip() -> Merchandise? {
        let actualHoldings = shipHold.filter { key, value in
            value > 0
        }
        if actualHoldings.count == 1 {
            return actualHoldings.first!.key
        }
        return nil
    }
    
    // MARK: - Warehouse
    
    @Published var warehouse: [Merchandise: Int] = [:]
    private let warehouseCapacity = 10000
    
    var warehouseUsedCapacity: Int {
        return warehouse.reduce(into: 0) { $0 += $1.value }
    }
    
    var warehouseFreeCapacity: Int { warehouseCapacity - warehouseUsedCapacity }
    
    func transferToWarehouse(_ merchandise: Merchandise, _ amount: Int) {
        guard let shipMerchandise = shipHold[merchandise],
              shipMerchandise >= amount
        else {
            print("insufficient \(merchandise.label) on ship to transfer \(amount)")
            return
        }
        
        warehouse[merchandise] = (warehouse[merchandise] ?? 0) + amount
        shipHold[merchandise] = shipMerchandise - amount
    }
    
    func warehouseTheft() {
        for (merchandise, units) in warehouse {
            warehouse[merchandise] = Int(Double(units) / 1.8 * Double.randomLog(in: 0.0...1.0, comment: "warehouse theft"))
        }
    }

    // MARK: - Market
    
    enum Merchandise: Int, CaseIterable {
        case opium
        case silk
        case arms
        case general
        var shortLabel: String {
            [
                String(localized: "merchandise.opium.short"),
                String(localized: "merchandise.silk.short"),
                String(localized: "merchandise.arms.short"),
                String(localized: "merchandise.general.short"),
            ][self.rawValue]
        }
        var label: String {
            [
                String(localized: "merchandise.opium"),
                String(localized: "merchandise.silk"),
                String(localized: "merchandise.arms"),
                String(localized: "merchandise.general"),
            ][self.rawValue]
        }
        var keyboardShortcut: Character {
            [ "O", "S", "A", "G" ][self.rawValue]
        }
    }
    
    private let priceMultiplier: [City: [Merchandise: Int]] = [
        .hongkong:  [ .opium: 11, .silk: 11, .arms: 12, .general: 10 ],
        .shanghai:  [ .opium: 16, .silk: 14, .arms: 16, .general: 11 ],
        .nagasaki:  [ .opium: 15, .silk: 15, .arms: 10, .general: 12 ],
        .saigon:    [ .opium: 14, .silk: 16, .arms: 11, .general: 13 ],
        .manila:    [ .opium: 12, .silk: 10, .arms: 13, .general: 14 ],
        .singapore: [ .opium: 10, .silk: 13, .arms: 14, .general: 15 ],
        .batavia:   [ .opium: 13, .silk: 12, .arms: 15, .general: 16 ],
    ]
    private let basePrice: [Merchandise: Int] = [ .opium: 1000, .silk: 100, .arms: 10, .general:  1 ]
    @Published var price: [Merchandise: Int] = [:]
    
    private func setPrices() {
        guard let currentCity = currentCity,
              let cityPriceMultiplier = priceMultiplier[currentCity]
        else {
            print("unable to set prices")
            return
        }
        
        for merchandise in Merchandise.allCases {
            if let cityPriceMultiplerForMerchandise = cityPriceMultiplier[merchandise],
               let basePriceForMerchandise = basePrice[merchandise] {
                price[merchandise] = cityPriceMultiplerForMerchandise / 2 * Int.randomLog(in: 1...3, comment: "price of \(merchandise.label)") * basePriceForMerchandise
            }
            else {
                print("unable to set price for \(merchandise)")
            }
        }
    }
    
    var goodPriceMerchandise: Merchandise?
    
    private func priceDrop() {
        if let merchandise = Merchandise.allCases.randomElement(),
           let originalPrice = price[merchandise] {
            goodPriceMerchandise = merchandise
            price[merchandise] = originalPrice / 5
        }
        else {
            print("unable to compute price drop")
        }
        dbgPriceDrop = false
    }
    
    private func priceJump() {
        if let merchandise = Merchandise.allCases.randomElement(),
           let originalPrice = price[merchandise] {
            goodPriceMerchandise = merchandise
            price[merchandise] = originalPrice * Int.randomLog(in: 5...9, comment: "price jump")
        }
        else {
            print("unable to compute price jump")
        }
        dbgPriceJump = false
    }
    
    func canAfford(_ merchandise: Merchandise) -> Int {
        if let unitPrice = price[merchandise] {
            return cash! / unitPrice
        }
        else {
            print("unable to get unit price")
            return 0
        }
    }
    
    func canAffordAny() -> Bool {
        for (_, price) in self.price {
            if cash! >= price {
                return true
            }
        }
        return false
    }
    
    func buy(_ merchandise: Merchandise, _ amount: Int) {
        if let unitPrice = price[merchandise],
           cash! >= unitPrice * amount {
            cash! -= unitPrice * amount
            shipHold[merchandise] = (shipHold[merchandise] ?? 0) + amount
        }
        else {
            print("unable to buy \(amount) of \(merchandise.label)")
        }
    }
    
    func sell(_ merchandise: Merchandise, _ amount: Int) {
        if let unitPrice = price[merchandise],
           let inventory = shipHold[merchandise],
           amount <= inventory {
            cash! += unitPrice * amount
            shipHold[merchandise] = inventory - amount
        }
        else {
            print("unable to sell \(amount) of \(merchandise.label)")
        }
    }
    
    // MARK: - Travel
    
    enum City: Int, CaseIterable {
        case hongkong
        case shanghai
        case nagasaki
        case saigon
        case manila
        case singapore
        case batavia
        var keyboardShortcut: Character { Character("\(self.rawValue + 1)") }
        var label: String {
            [
                String(localized: "Hong Kong"),
                String(localized: "Shanghai"),
                String(localized: "Nagasaki"),
                String(localized: "Saigon"),
                String(localized: "Manila"),
                String(localized: "Singapore"),
                String(localized: "Batavia"),
            ][self.rawValue]
        }
    }

    enum Month: Int, CaseIterable {
        case january = 0
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
        func next() -> Self {
            let allCases = Self.allCases
            return allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
        }
        func index() -> Int {
            Self.allCases.firstIndex(of: self)!
        }
        var label: String {
            [
                String(localized: "Jan", comment: "January"),
                String(localized: "Feb", comment: "February"),
                String(localized: "Mar", comment: "March"),
                String(localized: "Apr", comment: "April"),
                String(localized: "May", comment: "May"),
                String(localized: "Jun", comment: "June"),
                String(localized: "Jul", comment: "July"),
                String(localized: "Aug", comment: "August"),
                String(localized: "Sep", comment: "September"),
                String(localized: "Oct", comment: "October"),
                String(localized: "Nov", comment: "November"),
                String(localized: "Dec", comment: "December"),
            ][self.rawValue]
        }
    }
    
    @Published var currentCity: City?
    var destinationCity: City?
    @Published var month: Month = .january
    private let startYear = 1860
    @Published var year: Int?
    var months: Int { (year! - startYear) * 12 + month.index() }
    
    func departFor(_ city: City) {
        // clean up
        bailoutOffer = nil
        bailoutRepay = nil
        bodyguardsLost = nil
        goodPriceMerchandise = nil
        liYuenDemand = nil
        mcHenryOffer = nil
        mcHenryRate = nil
        offerAmount = nil
        opiumFine = nil
        robberyLoss = nil
        
        currentCity = nil // "at sea"
        destinationCity = city
        
        // a month passed
        if month == .december {
            year! += 1
        }
        month = month.next()
        debt = Int(Double(debt) * 1.1)
        bank = Int(Double(bank) * 1.005)
        
        transitionTo(.hostilesApproaching)
    }
    
    private func arriveAt(_ city: City) {
        currentCity = city
        setPrices()
    }
    
    // MARK: - Li Yuen
    
    private var liYuenCounter: Int = 0
    let liYuenCounterWantsMoney: Int = 0
    let liYuenCounterJustPaid: Int = 1
    var liYuenDemand: Int?
    
    private func liYuenExtortion() {
        if let dbgLiYuenDemand = dbgLiYuenDemand {
            liYuenDemand = dbgLiYuenDemand
            self.dbgLiYuenDemand = nil
        }
        else if months <= 12 {
            // Link's implementation has this as:
            //   float i = 1.8, j = 0,
            //   amount = ((cash / i) * ((float) rand() / RAND_MAX)) + j;
            // which can be zero, so let's enforce a floor
            liYuenDemand = 50 + Int.randomLog(in: 0...Int(Double(cash!) / 1.8), comment: "li yuen demand 1")
        }
        else {
            liYuenDemand = Int.randomLog(in: 1000 * months...2000 * months, comment: "li yuen demand 2-1") +
                           Int.randomLog(in: 0...Int(Double(cash!) / 1.4), comment: "li yuen demand 2-2")
        }
    }
    
    private func payLiYuen() -> Bool {
        if let liYuenDemand = liYuenDemand,
           cash! >= liYuenDemand {
            cash! -= liYuenDemand
            liYuenCounter = liYuenCounterJustPaid
            return true
        }
        else {
            print("unable to pay off Li Yuen")
            return false
        }
    }
    
    // MARK: - Mc Henry
    
    var mcHenryOffer: Int?
    private var mcHenryRate: Int?
    private func setMcHenryOffer() {
        let mcHenryRate = Int(Double(60 * (months + 3) / 4) * Double.randomLog(in: 0.0...1.0, comment: "mchenry rate") + Double(25 * (months + 3) / 4 * shipCapacity / 50))
        mcHenryOffer = mcHenryRate * shipDamage + 1
        self.mcHenryRate = mcHenryRate
    }
    
    func repair(_ amount: Int) {
        if let mcHenryRate = mcHenryRate {
            shipDamage -= Int(Double(amount / mcHenryRate) + 0.5)
            shipDamage = max(shipDamage, 0)
            cash! -= amount
            sendEvent(.repaired)
        }
        else {
            print("unable to repair")
        }
    }
    
    // MARK: - Elder Brother Wu
    
    @Published var debt: Int = 0
    private var elderBrotherWuWarningIssued = false
    let elderBrotherWuBraves = Int.randomLog(in: 50...149, comment: "elder brother wu braves")
    
    var maximumLoan: Int { cash! * 2 }
    
    func borrow(_ amount: Int) {
        debt += amount
        cash! += amount
    }
    
    func borrowForLiYuen() {
        if let liYuenDemand = liYuenDemand {
            debt += liYuenDemand - cash!
            cash! = 0
            liYuenCounter = liYuenCounterJustPaid
        }
        else {
            print("unable to pay off Li Yuen")
        }
    }
    
    func repay(_ amount: Int) {
        cash! -= min(amount, debt)
        debt -= min(amount, debt)
    }
    
    var bailoutOffer: Int?
    var bailoutRepay: Int?
    private var bailoutCounter = 0
    
    func elderBrotherWuBailout() {
        bailoutCounter += 1
        bailoutOffer = Int.randomLog(in: 500...1999, comment: "bailout amount")
        bailoutRepay = 1500 + Int.randomLog(in: 0...2000 * bailoutCounter, comment: "repay amount")
        dbgBailoutOffer = false
    }
    
    func acceptBailout() {
        if let bailoutOffer = bailoutOffer,
           let bailoutRepay = bailoutRepay {
            cash! += bailoutOffer
            debt += bailoutRepay
        }
        else {
            print("unable to bailout")
        }
    }
    
    // MARK: - Bank
    @Published var bank: Int = 0
    
    func deposit(_ amount: Int) {
        if amount <= cash! {
            bank += amount
            cash! -= amount
        }
    }
    
    func withdraw(_ amount: Int) {
        if amount <= bank {
            cash! += amount
            bank -= amount
        }
    }
    
    // MARK: - Special Offers
    
    var offerAmount: Int?
    
    private func newShipOrGunOffer() -> State? {
        if Int.random(1, in: 4, comment: "make offer?") || dbgMakeShipOffer || dbgMakeGunOffer {
            if Int.random(1, in: 2, comment: "ship?") || dbgMakeShipOffer {
                dbgMakeShipOffer = false
                let offerAmount = 1000 + Int.randomLog(in: 0...1000 * (months + 5) / 6, comment: "new ship offer") * (shipCapacity / 50)
                if cash! >= offerAmount {
                    self.offerAmount = offerAmount
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
        if shipGuns! < 1000 {
            let offerAmount = 500 + Int.randomLog(in: 0...1000 * (months + 5) / 6, comment: "new gun offer")
            if cash! >= offerAmount && shipFreeCapacity > gunWeight {
                self.offerAmount = offerAmount
                return .newGunOffer
            }
        }
        return nil
    }
    
    private func upgradeShip() -> State? {
        if let offerAmount = offerAmount {
            cash! -= offerAmount
            shipCapacity += 50
            shipDamage = 0
            
            if Int.random(1, in: 2, comment: "gun?") || dbgMakeGunOffer {
                return newGunOffer()
            }
        }
        else {
            print("unable to upgrade ship")
        }
        return nil
    }
    
    private func buyGun() {
        if let offerAmount = offerAmount {
            cash! -= offerAmount
            shipGuns! += 1
        }
        else {
            print("unable to buy gun")
        }
    }

    // MARK: - Pirates
    
    enum HostileType: Int {
        case generic = 1
        case liYuen = 2
    }
    
    private var pirateOdds: Int?
    private var hostileType: HostileType?
    var hostilesCount: Int?
    var originalHostileShipsCount: Int?
    func isUnderAttack() -> Bool {
        [ .seaBattle, .liYuenBattle ].contains(state)
    }
    
    func hostileShips(_ hostileType: HostileType) {
        // first clean up the previous battle, if any
        endBattle()
        
        self.hostileType = hostileType
        if hostileType == .generic {
            // Link's implementation has this as:
            //   int num_ships = rand()%((capacity / 10) + guns) + 1;
            // but let's enforce a floor of 2 pirate ships
            hostilesCount = dbgHostilesCount ?? min(Int.randomLog(in: 2...shipCapacity / 10 + shipGuns!, comment: "generic count"), 9999)
        }
        else {
            // int num_ships = rand()%((capacity / 5) + guns) + 5;
            hostilesCount = dbgHostilesCount ?? 5 + Int.randomLog(in: 0...shipCapacity / 5 + shipGuns!, comment: "li yuen count")
        }
        originalHostileShipsCount = hostilesCount
        dbgHostilesCount = nil
    }
    
    enum BattleOrder: Int {
        case fight
        case run
        case throwCargo
        var label: String {
            [
                String(localized: "Fight"),
                String(localized: "Run"),
                String(localized: "Throw Cargo"),
            ][self.rawValue]
        }
    }
    
    var maxHostilesOnScreen = 9
    var hostilesOnScreen: [(hitPoints: Int, damage: Int)]?
    var nextDamage: Int = 0
    @Published var battleOrder: BattleOrder?
    @Published var battleMessage: String?
    private var battleTimer: Timer?
    private var shotsLeft: Int?
    @Published var targetedShip: Int?
    @Published var targetedShipSinking: Bool?
    private var sinkCount: Int?
    
    private func setBattleTimer(_ interval: TimeInterval, action: @escaping () -> Void) {
        battleTimer?.invalidate()
        battleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            action()
        }
    }
    
    // start the battle
    private func seaBattle() {
        #if os(iOS)
        maxHostilesOnScreen = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 9
        #else
        maxHostilesOnScreen = 10
        #endif
        hostilesOnScreen = Array(repeating: (0, 0), count: maxHostilesOnScreen)
        nextDamage = Int.randomLog(in: 0...3, comment: "next damage")
        fillScreenWithShips()
        escapeChance = 0
        escapeChanceIncrement = 1
        executeOrder()
    }
    
    // user wants to skip the time delay
    private func seaBattleTap() {
        battleTimer?.fire()
    }
    
    var countOfHostilesOnScreen: Int {
        var count = hostilesOnScreen!.lazy.filter({ $0.hitPoints > 0 }).count
        if targetedShipSinking ?? false {
            // while the ship is sinking, it's already <= 0 in hostilesOnScreen
            // but should still count
            count += 1
        }
        return count
    }
    
    // show as many of the attacking pirate ships as will fit
    private func fillScreenWithShips() {
        var shipsToPlace = hostilesCount! - countOfHostilesOnScreen
        if shipsToPlace > 0 {
            for i in 0..<maxHostilesOnScreen {
                if hostilesOnScreen![i].hitPoints <= 0 {
                    // Link's implementation:
                    // (int)((ec * ((float) rand() / RAND_MAX)) + 20);
                    // 'ec' is a counter that starts at 20 and increments by 10 every year
                    hostilesOnScreen![i].hitPoints = 20 + Int.randomLog(in: 0...(20 + (year! - startYear) * 10), comment: "hit points of ship \(i)")
                    hostilesOnScreen![i].damage = 0
                    shipsToPlace -= 1
                    print("ship[\(i)] = \(hostilesOnScreen![i])")
                }
                if shipsToPlace == 0 {
                    break
                }
            }
        }
    }
    
    // a particular pirate ship is considered visible if it's afloat or in the
    // process of sinking
    func hostileShipVisible(_ ship: Int) -> Bool {
        return hostilesOnScreen![ship].hitPoints > 0 || (ship == targetedShip && (targetedShipSinking ?? false))
    }
    
    func hostileShipDamage(_ ship: Int) -> Int {
        return hostilesOnScreen![ship].damage
    }
    
    // user ordered to fight
    func orderFight() {
        battleOrder = .fight
    }
    
    // user ordered to run
    func orderRun() {
        battleOrder = .run
    }
    
    // user ordered to throw cargo
    func orderThrowCargo() {
        battleOrder = .throwCargo
        
        // stop the clock, give the user time to pick what cargo to throw
        battleTimer?.invalidate()
    }
    
    // execute the user's last order
    private func executeOrder() {
        if shipStatus == 0 {
            sendEvent(.battleEnded)
        }
        else if hostilesCount == 0 {
            battleMessage = String(localized: "We got ‘em all, Taipan!")
            setBattleTimer(3) { [self] in
                sendEvent(.battleEnded)
            }
        }
        else {
            setBattleTimer(3) { [self] in
                switch battleOrder {
                case .fight:
                    if shipGuns! > 0 {
                        fireGuns()
                    }
                    else {
                        battleMessage = String(localized: "We have no guns, Taipan!!")
                        setBattleTimer(3) { [self] in
                            hostileFile()
                        }
                    }
                case .run:
                    battleMessage = String(localized: "Aye, we‘ll run, Taipan.")
                    runAway()
                    break
                case .throwCargo:
                    runAway()
                    break
                default:
                    battleMessage = String(localized: "Taipan, what shall we do??")
                    setBattleTimer(3) { [self] in
                        hostileFile()
                    }
                }
            }
        }
    }
    
    // fire each of our available guns
    private func fireGuns() {
        shotsLeft = shipGuns!
        battleMessage = String(localized: "Aye, we‘ll fight ‘em, Taipan.")
        fillScreenWithShips()
        sinkCount = 0
        escapeChance = 3
        escapeChanceIncrement = 1
        setBattleTimer(3) { [self] in
            fireGun()
        }
    }
    
    // fire one gun
    private func fireGun() {
        self.battleMessage = String(localized: "We‘re firing on ‘em, Taipan!")
        self.setBattleTimer(1) { [self] in
            // randomly pick a target among ships on screen that haven't sunk yet
            repeat {
                let target = Int.randomLog(in: 0..<maxHostilesOnScreen, comment: "target ship")
                if hostilesOnScreen![target].hitPoints > 0 {
                    targetedShip = target
                }
            } while targetedShip == nil
            print("firing on \(targetedShip!)")
        }
    }
    
    // animation for gunfire has completed
    func gunDidFire() {
        if let targetedShip = targetedShip {
            hostilesOnScreen![targetedShip].hitPoints -= Int.randomLog(in: 10...40, comment: "damage to ship \(targetedShip)")
            // show some random visual damage, unrelated to the hit points
            hostilesOnScreen![targetedShip].damage |= 1 << nextDamage
            nextDamage = (nextDamage + Int.randomLog(in: 1...3, comment: "steps to next damage")) % 4
            print("ship[\(targetedShip)] = \(hostilesOnScreen![targetedShip])")
            if hostilesOnScreen![targetedShip].hitPoints <= 0 {
                targetedShipSinking = true
            }
            else {
                self.targetedShip = nil
                fireNextShot()
            }
        }
    }
    
    // animation for ship sinking has completed
    func targetedShipSunk() {
        targetedShip = nil
        targetedShipSinking = nil
        sinkCount! += 1
        hostilesCount! -= 1
        if hostilesCount! > 0 {
            fireNextShot()
        }
        else {
            battleMessage = String(localized: "We got ‘em all, Taipan!")
            setBattleTimer(3) { [self] in
                sendEvent(.battleEnded)
            }
        }
    }
    
    private func fireNextShot() {
        setBattleTimer(0.5) { [self] in
            shotsLeft! -= 1
            if shotsLeft! > 0 && countOfHostilesOnScreen > 0 {
                fireGun()
            }
            else {
                // all guns fired, summarize the round
                if sinkCount! > 0 {
                    battleMessage = String(localized: "Sunk \(sinkCount!.formatted()) of the buggers, Taipan!")
                }
                else {
                    battleMessage = String(localized: "Hit ‘em, but didn‘t sink ‘em, Taipan!")
                }
                
                let numerator = Int(Double(hostilesCount!) * 0.6 / Double(hostileType!.rawValue))
                if Int.random(numerator, in: originalHostileShipsCount!) || dbgRanAway {
                    dbgRanAway = false
                    let cowards = hostilesCount! / 3 / hostileType!.rawValue
                    let ranAway = cowards <= 1 ? 1 : Int.randomLog(in: 1...cowards, comment: "ran away")
                    setBattleTimer(3) { [self] in
                        battleMessage = String(localized: "\(ranAway.formatted()) ran away, Taipan!")
                        hostilesCount! -= ranAway
                        refreshHostilesOnScreen()
                        setBattleTimer(3) { [self] in
                            hostileFile()
                        }
                    }
                }
                else {
                    setBattleTimer(3) { [self] in
                        hostileFile()
                    }
                }
            }
        }
    }
    
    func refreshHostilesOnScreen() {
        if hostilesCount! < maxHostilesOnScreen {
            var count = countOfHostilesOnScreen
            for i in stride(from: maxHostilesOnScreen - 1, through: 0, by: -1)  {
                if count > hostilesCount! && hostilesOnScreen![i].hitPoints > 0 {
                    count -= 1
                    hostilesOnScreen![i].hitPoints = 0
                }
            }
        }
    }
    
    @Published var shipBeingHit: Bool?
    
    // pirates fire at us
    private func hostileFile() {
        battleMessage = String(localized: "They‘re firing on us, Taipan!")
        setBattleTimer(3) { [self] in
            shipBeingHit = true
            #if os(iOS)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            #endif
        }
    }
    
    // animation for ship hit completed
    func shipDidGetHit() {
        battleMessage = String(localized: "We‘ve been hit, Taipan!!")
        shipBeingHit = false
        
        // we don't have an easy way of triggering the pop-up from here,
        // and constantly throwing cargo seems weird, so we clear the
        // order and let the user decide again
        if battleOrder == .throwCargo {
            battleOrder = nil
        }
        
        // Link's implementation:
        // i = (num_ships > 15) ? 15 : num_ships; (unless the buggers hit a gun)
        // damage = damage + ((ed * i * id) * ((float) rand() / RAND_MAX)) + (i / 2);
        // 'ed' is a counter that starts at 0.5 and increases by 0.5 each year
        
        let ed = Double(year! - startYear + 1) * 0.5
        let i = Double(min(hostilesCount!, 15))
        let id = Double(hostileType!.rawValue)
        let damagePercentage = shipDamage * 100 / shipCapacity // 0..100
        if shipGuns! > 0 && (damagePercentage > 80 || Int.random(shipDamage, in: shipCapacity) || dbgHitGun) {
            dbgHitGun = false
            setBattleTimer(3) { [self] in
                battleMessage = String(localized: "The buggers hit a gun, Taipan!!")
                shipGuns! -= 1
                shipDamage += Int(Double.randomLog(in: 0.0...(ed * id), comment: "damage 1") + i / 2)
                setBattleTimer(3) { [self] in
                    executeOrder()
                }
            }
        }
        else {
            shipDamage += Int(Double.randomLog(in: 0.0...(ed * i * id), comment: "damage 2") + i / 2)
            if hostileType == .generic && (Int.random(1, in: 20) || dbgliYuenDroveThemOff) {
                setBattleTimer(3) { [self] in
                    sendEvent(.liYuen)
                }
            }
            else {
                executeOrder()
            }
        }
    }
    
    var escapeChance: Int? // known as 'ok' in Link's code
    var escapeChanceIncrement: Int? // 'ik' in Link's code
    
    private func runAway() {
        // Brave Sir Robin ran away.
        // (”No!“)
        // Bravely ran away away.
        // (”I didn‘t!“)
        // When danger reared it's ugly head,
        // He bravely turned his tail and fled.
        // (”I never!“)
        // Yes, brave Sir Robin turned about
        // And gallantly he chickened out.
        // (”You're lying!“)
        // Swiftly taking to his feet,
        // He beat a very brave retreat.
        // Bravest of the brave, Sir Robin!
        
        setBattleTimer(3) { [self] in
            escapeChance! += escapeChanceIncrement!
            escapeChanceIncrement! += 1
            print("escapeChance = \(escapeChance!)")
            print("escapeChanceIncrement = \(escapeChanceIncrement!)")
            if Int.randomLog(in: 0..<escapeChance!, comment: "escape chance") > Int.randomLog(in: 0..<hostilesCount!, comment: "hostiles count") {
                battleMessage = String(localized: "We got away from ‘em, Taipan!")
                setBattleTimer(3) { [self] in
                    sendEvent(.battleEnded)
                }
            }
            else {
                battleMessage = String(localized: "Couldn‘t lose ‘em.")
                setBattleTimer(3) { [self] in
                    if (hostilesCount! > 2 && Int.random(1, in: 5)) || dbgEscapedSome {
                        dbgEscapedSome = false
                        let lost = hostilesCount! < 4 ? 1 : Int.randomLog(in: 1..<hostilesCount! / 2, comment: "escaped from")
                        hostilesCount! -= lost
                        battleMessage = String(localized: "But we escaped from \(lost.formatted()) of ‘em!")
                        refreshHostilesOnScreen()
                        setBattleTimer(3) { [self] in
                            hostileFile()
                        }
                    }
                    else {
                        hostileFile()
                    }
                }
            }
        }
    }
    
    func discard(_ merchandise: Merchandise, _ amount: Int) {
        if let inventory = shipHold[merchandise],
           amount <= inventory {
            shipHold[merchandise] = inventory - amount
            escapeChance! += amount / 10
            print("escapeChance = \(escapeChance!)")
            battleMessage = String(localized: "Let‘s hope we lose ‘em, Taipan!")
            executeOrder()
        }
        else {
            print("unable to throw away \(amount) of \(merchandise.label)")
        }
    }
    
    // user cancelled "throw cargo" command
    func discardCancelled() {
        battleOrder = nil
        setBattleTimer(3) { [self] in
            executeOrder()
        }
    }
    
    @Published var booty: Int?
    
    private func battleSummary() {
        if hostilesCount == 0 {
            booty = 250 + months * 250 * originalHostileShipsCount! + Int.randomLog(in: 0...1000, comment: "booty")
            cash! += booty!
        }
    }
    
    // clean up the variables used in the battle
    private func endBattle() {
        hostileType = nil
        hostilesCount = nil
        originalHostileShipsCount = nil
        hostilesOnScreen = nil
        battleOrder = nil
        battleMessage = nil
        battleTimer?.invalidate()
        battleTimer = nil
        shotsLeft = nil
        targetedShip = nil
        targetedShipSinking = nil
        sinkCount = nil
        shipBeingHit = nil
        booty = nil
        escapeChance = nil
        escapeChanceIncrement = nil
    }
    
    // MARK: - Other Encounters
    
    var opiumFine: Int?
    
    func seizeOpium() {
        let fine = Int(Double(cash!) / 1.8 * Double.randomLog(in: 0.0...1.0, comment: "opium fine") + 1)
        cash! = max(cash! - fine, 0)
        shipHold[.opium] = nil
        self.opiumFine = fine
        dbgOpiumSeized = false
    }
    
    var robberyLoss: Int?
    
    func robbery() {
        // Link's implementation has this as:
        //   float robbed = ((cash / 1.4) * ((float) rand() / RAND_MAX));
        // but that could yield 0 if rand() is 0.
        let robberyLoss = Int(Double(cash!) / 1.4 * Double.randomLog(in: 0.1...1.0, comment: "robbery loss"))
        cash! = max(cash! - robberyLoss, 0)
        self.robberyLoss = robberyLoss
        dbgRobbery = false
    }
    
    var bodyguardsLost: Int?
    
    func cutthroats() {
        cash = 0
        bodyguardsLost = Int.randomLog(in: 1...3, comment: "bodyguards lost")
    }
    
    func blownOffCourse() {
        var newDestination: City
        repeat {
            newDestination = City.allCases.randomElement()!
        } while newDestination == destinationCity
        destinationCity = newDestination
    }
}
