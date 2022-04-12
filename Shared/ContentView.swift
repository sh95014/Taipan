//
//  ContentView.swift
//  Shared
//
//  Created by sh95014 on 3/27/22.
//

import SwiftUI

struct TradingView: View {
    @EnvironmentObject private var game: Game
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.sizeCategory) var sizeCategory
    @Binding var isShowingBuyModal: Bool
    @Binding var isShowingSellModal: Bool
    @Binding var isShowingDestinationModal: Bool
    @Binding var isShowingBorrowModal: Bool
    @Binding var isShowingRepayModal: Bool
    @Binding var isShowingBankModal: Bool
    @Binding var isShowingTransferModal: Bool
    @Binding var isShowingRepairModal: Bool

    private let bottomRowMinHeight: CGFloat = 45
    private let bottomRowMinWidth: CGFloat = 45
    
    var locationDebtStatus: some View {
        Group {
            VStack {
                Text("Location")
                    .font(.captionFont)
                Text(game.currentCity?.rawValue ?? "At sea")
            }
            Spacer()
            VStack {
                Text("Debt")
                    .font(.captionFont)
                Text(game.debt.fancyFormatted())
            }
            Spacer()
            VStack {
                Text("Ship Status")
                    .font(.captionFont)
                Text(game.fancyShipStatus(.colon))
                    .foregroundColor(game.shipInDanger ? .warningColor : .taipanColor(colorScheme))
            }
        }
    }
    
    var actions: some View {
        Group {
            RoundRectButton {
                isShowingBuyModal = true
            } content: {
                Text("Buy")
                    .frame(minWidth: bottomRowMinWidth,
                           maxWidth: sizeCategory > .large ? .infinity : nil,
                           minHeight: bottomRowMinHeight)
            }
            .withDisabledStyle(!game.canAffordAny())
            Spacer()
            RoundRectButton {
                isShowingSellModal = true
            } content: {
                Text("Sell")
                    .frame(minWidth: bottomRowMinWidth,
                           maxWidth: sizeCategory > .large ? .infinity : nil,
                           minHeight: bottomRowMinHeight)
            }
            .withDisabledStyle(!game.shipHasCargo())
            Spacer()
            RoundRectButton {
                isShowingBankModal = true
            } content: {
                Text(sizeCategory > .large ? "Visit Bank" : "Visit\nBank")
                    .frame(minWidth: bottomRowMinWidth,
                           maxWidth: sizeCategory > .large ? .infinity : nil,
                           minHeight: bottomRowMinHeight)
            }
            .withDisabledStyle(game.currentCity != .hongkong || (game.cash <= 0 && game.bank <= 0))
            Spacer()
            RoundRectButton {
                isShowingTransferModal = true
            } content: {
                Text(sizeCategory > .large ? "Transfer Cargo" : "Transfer\nCargo")
                    .frame(minWidth: bottomRowMinWidth,
                           maxWidth: sizeCategory > .large ? .infinity : nil,
                           minHeight: bottomRowMinHeight)
            }
            .withDisabledStyle(game.currentCity != .hongkong || (!game.shipHasCargo() && game.warehouseUsedCapacity == 0))
            Spacer()
            RoundRectButton {
                isShowingDestinationModal = true
            } content: {
                Text(sizeCategory > .large ? "Quit Trading" : "Quit\nTrading")
                    .frame(minWidth: bottomRowMinWidth,
                           maxWidth: sizeCategory > .large ? .infinity : nil,
                           minHeight: bottomRowMinHeight)
            }
            .withDisabledStyle(game.shipFreeCapacity < 0)
        }
    }
    
    var body: some View {
        VStack {
            Group {
                Text("Noble House, Hong Kong")
                    .font(.titleFont)
                Text(verbatim: "15 \(game.month.rawValue) \(game.year)")
                    .padding(.bottom, 5)
            }
            
            if sizeCategory > .large {
                VStack { locationDebtStatus }
            }
            else {
                HStack { locationDebtStatus }
            }

            RoundRectVStack(.taipanColor(colorScheme)) {
                Text("Hong Kong Warehouse")
                    .padding(.horizontal, 8)
                    .padding(.bottom, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                            Text(item.shortValue)
                        }
                    }
                    VStack(alignment: .trailing) {
                        ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                            Text("\(game.warehouse[item] ?? 0)")
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("In Use:")
                            .font(.captionFont)
                        Text("\(game.warehouseUsedCapacity)")
                        Text("Vacant")
                            .font(.captionFont)
                        Text("\(game.warehouseFreeCapacity)")
                    }
                }
                .padding(.horizontal, merchandisePadding())
            }
            
            RoundRectVStack(game.shipFreeCapacity >= 0 ? .taipanColor(colorScheme) : .warningColor) {
                HStack {
                    if game.shipFreeCapacity >= 0 {
                        Text("Hold \(game.shipFreeCapacity)")
                    }
                    else {
                        Text("Overload")
                            .foregroundColor(.warningColor)
                    }
                    Spacer()
                    Text("Guns \(game.shipGuns)")
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 2)
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                            Text(item.shortValue)
                        }
                    }
                    VStack(alignment: .trailing) {
                        ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                            Text("\(game.shipHold[item] ?? 0)")
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, merchandisePadding())
            }
            
            HStack {
                Text("Cash: \(game.cash.fancyFormatted())")
                Spacer()
                Text("Bank: \(game.bank.fancyFormatted())")
            }
            
            Divider()
                .background(Color.taipanColor(colorScheme))
            
            switch game.state {
            case .trading:
                Group {
                    Text("Comprador‘s Report")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                    
                    Spacer()
                    
                    Text("Taipan, present prices per unit here are")
                        .withMessageStyle()
                    
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(Game.Merchandise.opium.shortValue):")
                            Text("\(Game.Merchandise.arms.shortValue):")
                        }
                        VStack(alignment: .trailing) {
                            Text("\(game.price[.opium] ?? 0)")
                            Text("\(game.price[.arms] ?? 0)")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(Game.Merchandise.silk.shortValue):")
                            Text("\(Game.Merchandise.general.shortValue):")
                        }
                        VStack(alignment: .trailing) {
                            Text("\(game.price[.silk] ?? 0)")
                            Text("\(game.price[.general] ?? 0)")
                        }
                        Spacer()
                    }
                    .padding(.vertical, 3)
                    
                    Spacer()
                    
                    Text("Shall I")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if sizeCategory > .large {
                        VStack { actions }
                    }
                    else {
                        HStack { actions }
                    }
                    
                    FullWidthButton {
                        
                    } content: {
                        Text("Retire")
                    }
                    .withDisabledStyle(game.currentCity != .hongkong || game.cash + game.bank < 1000000)
                }
            case .arriving:
                CaptainsReport("Arriving at \(game.destinationCity!.rawValue)...")
            case .liYuenExtortion:
                CompradorsReportYesNo("Li Yuen asks \(game.liYuenDemand!.formatted()) in donation to the temple of Tin Hau, the Sea Goddess. Will you pay?")
            case .notEnoughCash:
                CompradorsReport("Taipan, you do not have enough cash!!")
            case .borrowForLiYuen:
                CompradorsReport("Do you want Elder Brother Wu to make up the difference for you?")
            case .borrowedForLiYuen:
                CompradorsReport("Elder Brother has given Li Yuen the difference between what he wanted and your cash on hand and added the same amount to your debt.")
            case .elderBrotherWuPirateWarning:
                CompradorsReport("Very well. Elder Brother Wu will not pay Li Yuen the difference.  I would be very wary of pirates if I were you, Taipan.")
            case .mcHenryOffer:
                McHenryOfferView(isShowingRepairModal: $isShowingRepairModal)
            case .elderBrotherWuWarning1:
                CompradorsReport("Elder Brother Wu has sent \(game.elderBrotherWuBraves) braves to escort you to the Wu mansion, Taipan.")
            case .elderBrotherWuWarning2:
                CompradorsReport("Elder Brother Wu reminds you of the Confucian ideal of personal worthiness, and how this applies to paying one‘s debts.")
            case .elderBrotherWuWarning3:
                CompradorsReport("He is reminded of a fabled barbarian who came to a bad end, after not caring for his obligations.\n\nHe hopes no such fate awaits you, his friend, Taipan.")
            case .elderBrotherWuBusiness:
                ElderBrotherWuBusinessView(isShowingBorrowModal: $isShowingBorrowModal,
                                           isShowingRepayModal: $isShowingRepayModal)
            case .elderBrotherWuBailout:
                CompradorsReportYesNo("Elder Brother is aware of your plight, Taipan.  He is willing to loan you an additional \(game.bailoutOffer!.formatted()) if you will pay back \(game.bailoutRepay!.formatted()). Are you willing, Taipan?")
            case .bailoutReaction:
                CompradorsReport("Very well, Taipan.  Good joss!!")
            case .bankruptcy:
                CompradorsReport("Very well, Taipan, the game is over!")
            case .cutthroats:
                CompradorsReportBadJoss("The local authorities have seized your Opium cargo and have also fined you \(game.opiumFine!.fancyFormatted()), Taipan!")
            case .newShipOffer:
                NewShipOfferView()
            case .newGunOffer:
                CompradorsReportYesNo("Do you wish to buy a ship‘s gun for \(game.offerAmount!.formatted()), Taipan?")
            case .opiumSeized:
                CompradorsReportBadJoss("The local authorities have seized your Opium cargo and have also fined you \(game.opiumFine!.fancyFormatted()), Taipan!")
            case .warehouseTheft:
                CompradorsReport("Messenger reports large theft from warehouse, Taipan.")
            case .liYuenMessage:
                CompradorsReport("Li Yuen has sent a Lieutenant, Taipan.  He says his admiral wishes to see you in Hong Kong, posthaste!")
            case .priceDrop:
                CompradorsReport("Taipan!! The price of \(game.goodPriceMerchandise!.rawValue) has dropped to \(game.price[game.goodPriceMerchandise!]!)!!")
            case .priceJump:
                CompradorsReport("Taipan!! The price of \(game.goodPriceMerchandise!.rawValue) has risen to \(game.price[game.goodPriceMerchandise!]!)!!")
            case .robbery:
                CompradorsReportBadJoss("You‘ve been beaten up and robbed of \(game.robberyLoss!.fancyFormatted()) in cash, Taipan!!")
            case .hostilesApproaching:
                CaptainsReport("\(game.hostilesCount!.formatted()) hostile ships approaching, Taipan!")
            case .battleSummary:
                BattleSummaryView()
            default:
                Text("unhandled state \(game.state.rawValue)")
            }
        }
        .padding(.horizontal, 8)
    }
    
    func merchandisePadding() -> CGFloat {
        switch sizeCategory {
        case .extraSmall: fallthrough
        case .small: fallthrough
        case .medium: fallthrough
        case .large: return 50
        case .extraLarge: return 40
        case .extraExtraLarge: return 30
        case .extraExtraExtraLarge: return 20
        case .accessibilityMedium: fallthrough
        case .accessibilityLarge: fallthrough
        case .accessibilityExtraLarge: fallthrough
        case .accessibilityExtraExtraLarge: fallthrough
        case .accessibilityExtraExtraExtraLarge: fallthrough
        @unknown default: return 10
        }
    }
    
    struct CaptainsReport: View {
        @EnvironmentObject private var game: Game
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var body: some View {
            VStack {
                Text("Captain‘s Report")
                    .withReportStyle()
                Text(message)
                    .withMessageStyle()
                Spacer()
            }
            .withTappableStyle(game)
        }
    }
    
    struct CompradorsReport: View {
        @EnvironmentObject private var game: Game
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                Text(message)
                    .withMessageStyle()
                Spacer()
            }
            .withTappableStyle(game)
        }
    }
    
    struct CompradorsReportYesNo: View {
        @EnvironmentObject private var game: Game
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                Text(message)
                    .withMessageStyle()
                Spacer()
                HStack {
                    RoundRectButton {
                        game.sendEvent(.no)
                    } content: {
                        Text("No")
                            .frame(minWidth:100, minHeight:30)
                    }
                    RoundRectButton {
                        game.sendEvent(.yes)
                    } content: {
                        Text("Yes")
                            .frame(minWidth:100, minHeight:30)
                    }
                }
            }
        }
    }
    
    struct CompradorsReportBadJoss: View {
        @EnvironmentObject private var game: Game
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                Text("Bad Joss!!")
                    .withMessageStyle()
                Text(message)
                    .withMessageStyle()
                Spacer()
            }
            .withTappableStyle(game)
        }
    }
    
    struct McHenryOfferView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingRepairModal: Bool
        
        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                Text("Taipan, Mc Henry from the Hong Kong Shipyards has arrived!!  He says, \"I see ye've a wee bit of damage to yer ship. Will ye be wanting repairs?\"")
                    .withMessageStyle()
                Spacer()
                HStack {
                    RoundRectButton {
                        game.sendEvent(.no)
                    } content: {
                        Text("No")
                            .frame(minWidth:100, minHeight:30)
                    }
                    RoundRectButton {
                        isShowingRepairModal = true
                    } content: {
                        Text("Repair")
                            .frame(minWidth:100, minHeight:30)
                    }
                }
            }
        }
    }
    
    struct ElderBrotherWuBusinessView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingBorrowModal: Bool
        @Binding var isShowingRepayModal: Bool
        
        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                Text("Do you have business with Elder Brother Wu, the moneylender?")
                    .withMessageStyle()
                Spacer()
                HStack {
                    RoundRectButton {
                        game.sendEvent(.no)
                    } content: {
                        Text("No")
                            .frame(minWidth:100, minHeight:30)
                    }
                    RoundRectButton {
                        isShowingBorrowModal = true
                    } content: {
                        Text("Borrow")
                            .frame(minWidth:100, minHeight:30)
                    }
                    .withDisabledStyle(game.cash <= 0)
                    RoundRectButton {
                        isShowingRepayModal = true
                    } content: {
                        Text("Repay")
                            .frame(minWidth:100, minHeight:30)
                    }
                    .withDisabledStyle(game.debt <= 0)
                }
            }
        }
    }
    
    struct NewShipOfferView: View {
        @EnvironmentObject private var game: Game
        
        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                if game.shipDamage > 0 {
                    (Text("Do you wish to trade in your ")
                    + Text("damaged").underline()
                    + Text(" ship for one with 50 more capacity by paying an additional \(game.offerAmount!.formatted()), Taipan?"))
                        .withMessageStyle()
                }
                else {
                    Text("Do you wish to trade in your fine ship for one with 50 more capacity by paying an additional \(game.offerAmount!.formatted()), Taipan?")
                        .withMessageStyle()
                }
                Spacer()
                HStack {
                    RoundRectButton {
                        game.sendEvent(.no)
                    } content: {
                        Text("No")
                            .frame(minWidth:100, minHeight:30)
                    }
                    RoundRectButton {
                        game.sendEvent(.yes)
                    } content: {
                        Text("Yes")
                            .frame(minWidth:100, minHeight:30)
                    }
                }
            }
        }
    }
    
    struct BattleSummaryView: View {
        @EnvironmentObject private var game: Game
        
        var body: some View {
            VStack {
                Text("Captain‘s Report")
                    .withReportStyle()
                if let booty = game.booty {
                    Text("We captured some booty.")
                        .withMessageStyle()
                    Text("It‘s worth \(booty.fancyFormatted()).")
                        .withMessageStyle()
                }
                else if game.shipStatus <= 0 {
                    Text("The buggers got us, Taipan!!!")
                        .withMessageStyle()
                    Text("It‘s all over, now!!!")
                        .withMessageStyle()
                }
                else {
                    Text("We made it!")
                        .withMessageStyle()
                }
                Spacer()
            }
            .withTappableStyle(game)
        }
    }
}

struct KeypadView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var amount: Int
    var limitHint: String?
    
    var body: some View {
        VStack {
            HStack {
                Text("\(amount)")
                    .withTextFieldStyle(width: 100, color: .taipanColor(colorScheme))
                if let limitHint = limitHint {
                    Text(limitHint)
                        .padding(.leading, 20)
                        .multilineTextAlignment(.center)
                        .font(.captionFont)
                        .opacity(0.7)
                }
            }
            Spacer()
                .frame(height: 20)
            ForEach(0...2, id: \.self) { row in
                HStack {
                    ForEach(0...2, id: \.self) { column in
                        let digit = row * 3 + column + 1
                        KeypadButton {
                            amount = amount * 10 + digit
                        } content: {
                            Text("\(digit)")
                        }
                        .padding(2)
                    }
                }
            }
            HStack {
                KeypadButton {
                    amount = amount * 10
                } content: {
                    Text("0")
                }
                .padding(2)
                KeypadButton {
                    amount = amount / 10
                } content: {
                    Image(systemName: "delete.backward")
                }
                .padding(2)
            }
            .padding(.bottom, 20)
        }
    }
}

struct BattleView: View {
    private let bottomRowMinHeight: CGFloat = 45

    @EnvironmentObject private var game: Game
    @Environment(\.colorScheme) var colorScheme
    @State private var hostileYOffset: CGFloat = 0
    @State private var firedOnShipForeground = Color.clear
    @State private var firedOnShipBackground = Color.clear
    @State private var shipOffset: CGSize = CGSize.zero
    @Binding var battleBackgroundColor: Color
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if game.hostilesCount! == 1 {
                        Text("1 ship attacking, Taipan!")
                            .withMessageStyle()
                    }
                    else {
                        Text("\(game.hostilesCount!.formatted()) ships attacking, Taipan!")
                            .withMessageStyle()
                    }
                    Text("Your orders are to: \(game.battleOrder?.rawValue ?? "")")
                        .withMessageStyle()
                }
                Spacer()
                Text("We have\n\(game.shipGuns.formatted()) guns")
                    .multilineTextAlignment(.trailing)
                    .padding(5)
                    .border(Color.taipanColor(colorScheme))
            }
            Text(game.battleMessage ?? " ")
            
            Spacer()
            
            GeometryReader { proxy in
                LazyVGrid(columns: [
                    GridItem(),
                    GridItem(),
                    GridItem(),
                ], spacing: 10) {
                    ForEach(0..<game.maxHostilesOnScreen, id: \.self) { ship in
                        Image("lorcha")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ship != game.targetedShip ? .taipanColor(colorScheme) : firedOnShipForeground)
                            .background(ship != game.targetedShip ? battleBackgroundColor : firedOnShipBackground)
                            .onChange(of: game.targetedShip) { newValue in
                                if newValue == ship {
                                    // flash twice
                                    reverseHostileShip()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        normalHostileShip()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            reverseHostileShip()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                normalHostileShip()
                                                game.gunDidFire()
                                            }
                                        }
                                    }
                                }
                            }
                            .offset(y: ship == game.targetedShip ? hostileYOffset : 0)
                            .clipped()
                            .onChange(of: game.targetedShipSinking) { newValue in
                                if ship == game.targetedShip && (newValue ?? false) {
                                    let sinkDuration = Double.random(in: 0.3...2.0)
                                    withAnimation(.easeIn(duration: sinkDuration)) {
                                        hostileYOffset = proxy.size.height / Double(game.maxHostilesOnScreen / 3)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + sinkDuration) {
                                        game.targetedShipSunk()
                                        hostileYOffset = 0
                                    }
                                }
                            }
                            .opacity(game.shipVisible(ship) ? 1.0 : 0.0)
                    }
                }
                .padding(.horizontal, 8)
            }
            Image(systemName: "plus")
                .padding(.top, 5)
                .opacity(game.hostilesCount! > game.countOfHostilesOnScreen ? 1.0 : 0.0)
            
            Spacer()
            
            Text("Current seaworthiness: ") +
            Text("\(game.fancyShipStatus(.parenthesis))").foregroundColor(game.shipInDanger ? .warningColor : .taipanColor(colorScheme))
            HStack {
                RoundRectButton {
                    game.orderFight()
                } content: {
                    Text("Fight")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                .withDisabledStyle(game.shipGuns == 0 || game.hostilesCount! == 0)
                Spacer()
                RoundRectButton {
                    game.sendEvent(.battleEnded)
                } content: {
                    Text("Run")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                Spacer()
                RoundRectButton {
                } content: {
                    Text("Throw\nCargo")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                .withDisabledStyle(!game.shipHasCargo())
            }
        }
        .withTappableStyle(game)
        .offset(shipOffset)
        .onChange(of: game.shipBeingHit) { newValue in
            if newValue ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                    shipTakingFire()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                        shipTakingFire()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                            shipTakingFire()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                                shipTakingFire()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                                    shipTakingFire()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                                        shipTakingFire()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                                            game.shipDidGetHit()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                shipOffset = CGSize.zero
                battleBackgroundColor = .taipanBackgroundColor(colorScheme)
            }
        }
        .onAppear {
            normalHostileShip()
        }
    }
    
    private func normalHostileShip() {
        firedOnShipForeground = .taipanColor(colorScheme)
        firedOnShipBackground = .taipanBackgroundColor(colorScheme)
    }
    
    private func reverseHostileShip() {
        firedOnShipForeground = .taipanBackgroundColor(colorScheme)
        firedOnShipBackground = .taipanColor(colorScheme)
    }
    
    private func shipTakingFire() {
        shipOffset.width = Double.random(in: -30.0...30.0)
        shipOffset.height = Double.random(in: -30.0...30.0)
        battleBackgroundColor = Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

struct ContentView: View {
    private let bodyFont = Font.custom("MorrisRoman-Black", size: 22)
    
    @EnvironmentObject private var game: Game
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingBuyModal = false
    @State private var isShowingSellModal = false
    @State private var isShowingDestinationModal = false
    @State private var isShowingBorrowModal = false
    @State private var isShowingRepayModal = false
    @State private var isShowingBankModal = false
    @State private var isShowingTransferModal = false
    @State private var isShowingRepairModal = false
    @State private var battleBackgroundColor = Color.clear
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                battleBackgroundColor
                ScrollView {
                    if !game.isUnderAttack() {
                        ZStack {
                            TradingView(isShowingBuyModal: $isShowingBuyModal,
                                        isShowingSellModal: $isShowingSellModal,
                                        isShowingDestinationModal: $isShowingDestinationModal,
                                        isShowingBorrowModal: $isShowingBorrowModal,
                                        isShowingRepayModal: $isShowingRepayModal,
                                        isShowingBankModal: $isShowingBankModal,
                                        isShowingTransferModal: $isShowingTransferModal,
                                        isShowingRepairModal: $isShowingRepairModal)
                                .blur(radius: isShowingModal ? 3 : 0)
                                .disabled(isShowingModal)
                            
                            if isShowingBuyModal {
                                BuyModalView(isShowingBuyModal: $isShowingBuyModal)
                            }
                            else if isShowingSellModal {
                                SellModalView(isShowingSellModal: $isShowingSellModal)
                            }
                            else if isShowingDestinationModal {
                                DestinationModalView(isShowingDestinationModal: $isShowingDestinationModal)
                            }
                            else if isShowingBorrowModal {
                                BorrowModalView(isShowingBorrowModal: $isShowingBorrowModal)
                            }
                            else if isShowingRepayModal {
                                RepayModalView(isShowingRepayModal: $isShowingRepayModal)
                            }
                            else if isShowingBankModal {
                                BankModalView(isShowingBankModal: $isShowingBankModal)
                            }
                            else if isShowingTransferModal {
                                TransferModalView(isShowingTransferModal: $isShowingTransferModal)
                            }
                            else if isShowingRepairModal {
                                RepairModalView(isShowingRepairModal: $isShowingRepairModal)
                            }
                        }
                        .background(Color.taipanBackgroundColor(colorScheme))
                        .frame(minHeight: proxy.size.height)
                    }
                    else {
                        BattleView(battleBackgroundColor: $battleBackgroundColor)
                            .background(battleBackgroundColor)
                            .frame(minHeight: proxy.size.height)
                    }
                }
            }
            .foregroundColor(.taipanColor(colorScheme))
            .font(bodyFont)
            .statusBar(hidden: true)
            .onAppear {
                configureByColorScheme(colorScheme)
            }
            .onChange(of: colorScheme) { newValue in
                configureByColorScheme(newValue)
            }
        }
    }
    
    func configureByColorScheme(_ colorScheme: ColorScheme) {
        battleBackgroundColor = .taipanBackgroundColor(colorScheme)
    }
    
    var isShowingModal: Bool {
        isShowingBuyModal || isShowingSellModal || isShowingDestinationModal ||
        isShowingBorrowModal || isShowingRepairModal
    }
    
    struct BuyModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingBuyModal: Bool
        @State private var selectedMerchandise: Game.Merchandise?
        @State private var amount = 0
        
        var body: some View {
            VStack {
                if let selectedMerchandise = selectedMerchandise {
                    Text("How much \(selectedMerchandise.rawValue) shall I buy, Taipan:")
                    KeypadView(
                        amount: $amount,
                        limitHint: "You can\nafford \(game.canAfford(selectedMerchandise).formatted())"
                    )
                    HStack {
                        RoundRectButton {
                            isShowingBuyModal = false
                            self.selectedMerchandise = nil
                        } content: {
                            Text("Cancel")
                                .frame(minWidth: 80)
                        }
                        .withCancelStyle()
                        RoundRectButton {
                            game.buy(selectedMerchandise, amount)
                            isShowingBuyModal = false
                        } content: {
                            Text("Buy")
                                .frame(minWidth: 80)
                        }
                        .withDisabledStyle(amount == 0 || amount > game.canAfford(selectedMerchandise))
                    }
                }
                else {
                    Text("What do you wish me to buy, Taipan?")
                    ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                        FullWidthButton {
                            selectedMerchandise = item
                        } content: {
                            VStack {
                                Text(item.rawValue)
                                    .frame(maxWidth: .infinity)
                                Text("You can afford \(game.canAfford(item))")
                                    .font(.captionFont)
                            }
                        }
                        .withDisabledStyle(game.canAfford(item) == 0)
                    }
                    FullWidthButton {
                        isShowingBuyModal = false
                        self.selectedMerchandise = nil
                    } content: {
                        Text("Cancel")
                    }
                    .withCancelStyle()
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
    
    struct SellModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingSellModal: Bool
        @State private var selectedMerchandise: Game.Merchandise?
        @State private var amount = 0
        
        var body: some View {
            VStack {
                if let selectedMerchandise = selectedMerchandise,
                   let amountOnShip = game.shipHold[selectedMerchandise] {
                    Text("How much \(selectedMerchandise.rawValue) shall I sell, Taipan:")
                    KeypadView(
                        amount: $amount,
                        limitHint: "You have\n\(amountOnShip.formatted())"
                    )
                    HStack {
                        RoundRectButton {
                            isShowingSellModal = false
                            self.selectedMerchandise = nil
                        } content: {
                            Text("Cancel")
                                .frame(minWidth: 80)
                        }
                        .withCancelStyle()
                        RoundRectButton {
                            game.sell(selectedMerchandise, amount)
                            isShowingSellModal = false
                        } content: {
                            Text("Sell")
                                .frame(minWidth: 80)
                        }
                        .withDisabledStyle(amount == 0 || amount > amountOnShip)
                    }
                }
                else {
                    Text("What do you wish me to sell, Taipan?")
                    ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                        FullWidthButton {
                            selectedMerchandise = item
                        } content: {
                            VStack {
                                Text(item.rawValue)
                                    .frame(maxWidth: .infinity)
                                Text("You have \(game.shipHold[item] ?? 0)")
                                    .font(.captionFont)
                            }
                        }
                        .withDisabledStyle(game.shipHold[item] == nil || game.shipHold[item]! == 0)
                    }
                    FullWidthButton {
                        isShowingSellModal = false
                        self.selectedMerchandise = nil
                    } content: {
                        Text("Cancel")
                    }
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
    
    struct DestinationModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingDestinationModal: Bool
        
        var body: some View {
            VStack {
                Text("Taipan, do you wish me to go to:")
                ForEach(Game.City.allCases, id: \.rawValue) { city in
                    if city != game.currentCity {
                        FullWidthButton {
                            game.departFor(city)
                            isShowingDestinationModal = false
                        } content: {
                            Text(city.rawValue)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                FullWidthButton {
                    isShowingDestinationModal = false
                } content: {
                    Text("Cancel")
                }
                .withCancelStyle()
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
    
    struct BorrowModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingBorrowModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                Text("How much do you wish to borrow?")
                KeypadView(
                    amount: $amount,
                    limitHint: "He will loan up to\n\(game.maximumLoan.formatted())"
                )
                HStack {
                    RoundRectButton {
                        isShowingBorrowModal = false
                    } content: {
                        Text("Cancel")
                            .frame(minWidth: 80)
                    }
                    .withCancelStyle()
                    RoundRectButton {
                        isShowingBorrowModal = false
                        game.borrow(amount)
                    } content: {
                        Text("Borrow")
                            .frame(minWidth: 80)
                    }
                    .withDisabledStyle(amount == 0 || amount > game.maximumLoan)
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
    
    struct RepayModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingRepayModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                Text("How much do you wish to repay him?")
                KeypadView(
                    amount: $amount,
                    limitHint: "You have\n\(game.cash.formatted())"
                )
                HStack {
                    RoundRectButton {
                        isShowingRepayModal = false
                    } content: {
                        Text("Cancel")
                            .frame(minWidth: 80)
                    }
                    .withCancelStyle()
                    RoundRectButton {
                        isShowingRepayModal = false
                        game.repay(amount)
                    } content: {
                        Text("Repay")
                            .frame(minWidth: 80)
                    }
                    .withDisabledStyle(amount == 0 || amount > game.cash)
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
    
    struct BankModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingBankModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                KeypadView(amount: $amount)
                HStack(alignment: .bottom) {
                    RoundRectButton {
                        isShowingBankModal = false
                    } content: {
                        Text("Cancel")
                            .frame(minWidth: 80)
                    }
                    .withCancelStyle()
                    VStack {
                        Text("You have\n\(game.cash.formatted())\nin cash")
                            .font(.captionFont)
                            .multilineTextAlignment(.center)
                        RoundRectButton {
                            game.deposit(amount)
                            isShowingBankModal = false
                        } content: {
                            Text("Deposit")
                                .frame(minWidth: 80)
                        }
                        .withDisabledStyle(amount == 0 || amount > game.cash)
                    }
                    VStack {
                        Text("You have\n\(game.bank.formatted())\nin the bank")
                            .font(.captionFont)
                            .multilineTextAlignment(.center)
                        RoundRectButton {
                            game.withdraw(amount)
                            isShowingBankModal = false
                        } content: {
                            Text("Withdraw")
                                .frame(minWidth: 80)
                        }
                        .withDisabledStyle(amount == 0 || amount > game.bank)
                    }
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
    
    struct TransferModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingTransferModal: Bool
        @State private var selectedMerchandise: Game.Merchandise?
        @State private var toWarehouse: Bool?
        @State private var amount = 0
        
        var body: some View {
            VStack {
                if let selectedMerchandise = selectedMerchandise,
                   let toWarehouse = toWarehouse {
                    if toWarehouse {
                        Text("How much \(selectedMerchandise.rawValue) shall I move to the warehouse, Taipan?")
                    }
                    else {
                        Text("How much \(selectedMerchandise.rawValue) shall I move aboard ship, Taipan?")
                    }
                    
                    let transferLimit = toWarehouse ? game.shipHold[selectedMerchandise]! : game.warehouse[selectedMerchandise]!
                    KeypadView(
                        amount: $amount,
                        limitHint: "You have \(transferLimit.formatted())"
                    )
                    HStack {
                        RoundRectButton {
                            isShowingTransferModal = false
                            self.selectedMerchandise = nil
                        } content: {
                            Text("Cancel")
                                .frame(minWidth: 80)
                        }
                        .withCancelStyle()
                        RoundRectButton {
                            if toWarehouse {
                                game.transferToWarehouse(selectedMerchandise, amount)
                            }
                            else {
                                game.transferToShip(selectedMerchandise, amount)
                            }
                            isShowingTransferModal = false
                        } content: {
                            Text("Transfer")
                                .frame(minWidth: 80)
                        }
                        .withDisabledStyle(amount == 0 || amount > transferLimit)
                    }
                }
                else {
                    Text("What shall I transfer, Taipan?")
                        .padding(.bottom, 20)

                    HStack {
                        VStack {
                            Text("Ship")
                            ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                                FullWidthButton {
                                    selectedMerchandise = item
                                    toWarehouse = true
                                } content: {
                                    VStack {
                                        Label(item.rawValue, systemImage: "chevron.compact.right")
                                            .frame(maxWidth: .infinity)
                                            .labelStyle(TrailingLabelStyle())
                                        Text("You have \(game.shipHold[item] ?? 0)")
                                            .font(.captionFont)
                                    }
                                }
                                .withDisabledStyle(game.shipHold[item] == nil || game.shipHold[item]! == 0)
                            }
                        }
                        VStack {
                            Text("Warehouse")
                            ForEach(Game.Merchandise.allCases, id: \.rawValue) { item in
                                FullWidthButton {
                                    selectedMerchandise = item
                                    toWarehouse = false
                                } content: {
                                    VStack {
                                        Label(item.rawValue, systemImage: "chevron.compact.left")
                                            .frame(maxWidth: .infinity)
                                            .labelStyle(LeadingLabelStyle())
                                        Text("You have \(game.warehouse[item] ?? 0)")
                                            .font(.captionFont)
                                    }
                                }
                                .withDisabledStyle(game.warehouse[item] == nil || game.warehouse[item]! == 0)
                            }
                        }
                    }
                    
                    FullWidthButton {
                        isShowingTransferModal = false
                        self.selectedMerchandise = nil
                    } content: {
                        Text("Cancel")
                    }
                    .withCancelStyle()
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }

    struct RepairModalView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.colorScheme) var colorScheme
        @Binding var isShowingRepairModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                let shipDamagePercent = 100 - game.shipStatus
                Text("Och, 'tis a pity to be \(shipDamagePercent.formatted(.percent)) damaged.\nWe can fix yer whole ship for \(game.mcHenryOffer!.formatted()), or make partial repairs if you wish.\nHow much will ye spend?")
                KeypadView(
                    amount: $amount,
                    limitHint: "You have\n\(game.cash.formatted())"
                )
                HStack {
                    RoundRectButton {
                        game.sendEvent(.no)
                        isShowingRepairModal = false
                    } content: {
                        Text("Cancel")
                            .frame(minWidth: 80)
                    }
                    .withCancelStyle()
                    RoundRectButton {
                        game.repair(amount)
                        isShowingRepairModal = false
                    } content: {
                        Text("Repair")
                            .frame(minWidth: 80)
                    }
                    .withDisabledStyle(amount == 0 || amount > min(game.cash, game.mcHenryOffer!))
                }
            }
            .withModalStyle(.taipanSheetColor(colorScheme))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let game = Game()
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(game)
        }
    }
}

// MARK: - Custom Views

struct FullWidthButton<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void
    let content: () -> Content
    
    init(_ action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            content()
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .foregroundColor(.taipanBackgroundColor(colorScheme))
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.taipanColor(colorScheme), .taipanColor(colorScheme).opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            )
        )
    }
}

struct KeypadButton<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void
    let content: () -> Content
    let size: CGFloat = 40.0
    
    init(_ action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            content()
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
        .foregroundColor(.taipanBackgroundColor(colorScheme))
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.taipanColor(colorScheme), .taipanColor(colorScheme).opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            )
        )
    }
}

struct RoundRectButton<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void
    let content: () -> Content
    
    init(_ action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            content()
        }
        .padding(5)
        .foregroundColor(.taipanBackgroundColor(colorScheme))
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.taipanColor(colorScheme), .taipanColor(colorScheme).opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            )
        )
    }
}

struct RoundRectVStack<Content: View>: View {
    let color: Color
    let content: () -> Content
    
    init(_ color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.color = color
        self.content = content
    }
    
    var body: some View {
        VStack {
            content()
        }
        .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(color.opacity(0.3))
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.1), .clear]), startPoint: .top, endPoint: .bottom)
                    )
                )
            )
    }
}

// MARK: - Styling

extension Color {
    static let darkDefaultColor = Color.orange
    static let darkBackgroundColor = Color.black
    static let darkSheetColor = Color.init(white: 0.15)
    static let warningColor = Color.red

    static let lightDefaultColor = Color.init(red: 0.40, green: 0.26, blue: 0.13)
    static let lightBackgroundColor = Color.white
    static let lightSheetColor = Color.init(white: 0.75)

    static func taipanColor(_ colorScheme: ColorScheme) -> Color {
        (colorScheme == .dark) ? .darkDefaultColor : .lightDefaultColor
    }
    
    static func taipanBackgroundColor(_ colorScheme: ColorScheme) -> Color {
        (colorScheme == .dark) ? .darkBackgroundColor : .lightBackgroundColor
    }
    
    static func taipanSheetColor(_ colorScheme: ColorScheme) -> Color {
        (colorScheme == .dark) ? .darkSheetColor : .lightSheetColor
    }
}

extension Font {
    static let titleFont = Font.custom("MorrisRoman-Black", size: 30)
    static let bodyFont = Font.custom("MorrisRoman-Black", size: 22)
    static let captionFont = Font.custom("MorrisRoman-Black", size: 16)
}

struct LeadingLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
    }
}

struct TrailingLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension Text {
    func withTextFieldStyle(width: CGFloat, color: Color) -> some View {
        self.frame(width: width, alignment: .trailing)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(color.opacity(0.5))
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color.opacity(0.1))
                    )
            )
            .font(.titleFont)
    }
    
    func withReportStyle() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
    }
    
    func withMessageStyle() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func withDisabledStyle(_ disabled: Bool) -> some View {
        self.disabled(disabled)
            .opacity(disabled ? 0.4 : 1)
    }

    func withCancelStyle() -> some View {
        self.saturation(0.5)
    }
}

extension VStack {
    func withModalStyle(_ backgroundColor: Color) -> some View {
        self.padding(15)
            .cornerRadius(5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .shadow(radius: 5)
            .padding(15)
    }
    
    func withTappableStyle(_ game: Game) -> some View {
        self.contentShape(Rectangle())
            .onTapGesture {
                game.sendEvent(.tap)
            }
    }
}
