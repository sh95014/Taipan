//
//  ContentView.swift
//  Shared
//
//  Created by sh95014 on 3/27/22.
//

import SwiftUI

struct NameView: View {
    @EnvironmentObject private var game: Game
    @FocusState private var focused: Bool
    @State private var firmName: String = ""
    @Binding var splashAnimation: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Text("T   A   I   P   A   N   !")
                    .font(.custom("Georgia", size: 30))
                    .padding(.top, 10)
                Divider()
                    .background(Color.taipanColor)
                if splashAnimation {
                    Text("A game based on the China\ntrade of the 1800's")
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 1).delay(1)), removal: .opacity))
                    Text("Created by: Art Canfil")
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 1).delay(1.5)), removal: .opacity))
                }
                Spacer()
            }
            VStack {
                if splashAnimation {
                    Image("lorcha")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.taipanColor.opacity(0.2))
                        .padding(.horizontal, 80)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 1)), removal: .opacity))
                    Spacer()
                    RoundRectVStack(.taipanColor) {
                        HStack {
                            Text("Taipan,")
                                .padding(.leading, 40)
                            Spacer()
                        }
                        HStack {
                            Text("What will you name your")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 30)
                            Spacer()
                        }
                        HStack {
                            Text("Firm:")
                            TextField(
                                "",
                                text: $firmName,
                                onCommit: {
                                    if firmName.count > 0 {
                                        game.firmName = firmName
                                        game.sendEvent(.done)
                                    }
                                    else {
                                        focused = true
                                    }
                                })
                                .padding(5)
                                .foregroundColor(Color.taipanColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(Color.taipanColor.opacity(0.5))
                                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(Color.taipanColor.opacity(0.1))
                                        )
                                )
                                .padding(3)
                                .focused($focused)
                        }
                        .padding(.horizontal, 20)
                        .onAppear {
                            // HACK: doesn't work if setting focused = true without the delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                focused = true
                            }
                        }
                    } // RoundRectVStack
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.5).delay(2)), removal: .opacity))
                    Spacer()
                }
            } // VStack
        } // ZStack
        .onTapGesture {
            focused = true
        }
        .onAppear {
            withAnimation {
                splashAnimation = true
            }
        }
    } // body
}

struct DebtOrGunsView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        Spacer()
        HStack {
            Text("Do you want to start . . .")
            Spacer()
        }
        FullWidthButton {
            game.sendEvent(.debt)
        } content: {
            Text("1) With cash (and a debt)")
        }
        .padding(.vertical, 10)
        Text("» or «")
        FullWidthButton {
            game.sendEvent(.guns)
        } content: {
            VStack {
                Text("2) With five guns and no cash")
                Text("(But no debt!)")
                    .font(.captionFont)
            }
        }
        .padding(.vertical, 10)
        Text("?")
        Spacer()
    }
}

struct TradingView: View {
    @EnvironmentObject private var game: Game
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
                    .opacity(0.8)
                Text(game.currentCity?.rawValue ?? "At sea")
            }
            Spacer()
            VStack {
                Text("Debt")
                    .font(.captionFont)
                    .opacity(0.8)
                Text(game.debt.fancyFormatted())
            }
            Spacer()
            VStack {
                Text("Ship Status")
                    .font(.captionFont)
                    .opacity(0.8)
                Text(game.fancyShipStatus(.colon))
                    .foregroundColor(game.shipInDanger ? .warningColor : .taipanColor)
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
            .withDisabledStyle(game.currentCity != .hongkong || (game.cash! <= 0 && game.bank <= 0))
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
                Text("\(game.firmName!)")
                    .font(.titleFont)
                    .lineLimit(1)
                Text(verbatim: "15 \(game.month.rawValue) \(game.year!)")
                    .padding(.bottom, 5)
            }
            
            if sizeCategory > .large {
                VStack { locationDebtStatus }
            }
            else {
                HStack { locationDebtStatus }
            }
            
            RoundRectVStack(.taipanColor) {
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
                            .opacity(0.8)
                        Text("\(game.warehouseUsedCapacity)")
                        Text("Vacant")
                            .font(.captionFont)
                            .opacity(0.8)
                        Text("\(game.warehouseFreeCapacity)")
                    }
                }
                .padding(.horizontal, merchandisePadding())
            }
            
            RoundRectVStack(game.shipFreeCapacity >= 0 ? .taipanColor : .warningColor) {
                HStack {
                    if game.shipFreeCapacity >= 0 {
                        Text("Hold \(game.shipFreeCapacity)")
                    }
                    else {
                        Text("Overload")
                            .foregroundColor(.warningColor)
                    }
                    Spacer()
                    Text("Guns \(game.shipGuns!.formatted())")
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
                Text("Cash: \(game.cash!.fancyFormatted())")
                Spacer()
                Text("Bank: \(game.bank.fancyFormatted())")
            }
            
            Divider()
                .background(Color.taipanColor)
            
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
                        game.transitionTo(.retirement)
                    } content: {
                        Text("Retire")
                    }
                    .withDisabledStyle(game.currentCity != .hongkong || game.cash! + game.bank < 1000000)
                }
            case .arriving:
                CaptainsReport("Arriving at \(game.destinationCity!.rawValue)...")
            case .liYuenExtortion:
                CompradorsReportYesNo("Li Yuen asks \(game.liYuenDemand!.formatted()) in donation to the temple of Tin Hau, the Sea Goddess. Will you pay?")
            case .notEnoughCash:
                CompradorsReport("Taipan, you do not have enough cash!!")
            case .borrowForLiYuen:
                CompradorsReportYesNo("Do you want Elder Brother Wu to make up the difference for you?")
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
                CompradorsReport("Very well, Taipan. Good joss!!")
            case .bankruptcy:
                CompradorsReport("Very well, Taipan, the game is over!")
            case .cutthroats:
                CompradorsReportBadJoss("\(game.bodyguardsLost!.formatted()) of your bodyguards have been killed by cutthroats and you have been robbed of all of your cash, Taipan!!")
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
                CompradorsReport("Taipan!! The price of \(game.goodPriceMerchandise!.rawValue) has dropped to \(game.price[game.goodPriceMerchandise!]!.formatted())!!")
            case .priceJump:
                CompradorsReport("Taipan!! The price of \(game.goodPriceMerchandise!.rawValue) has risen to \(game.price[game.goodPriceMerchandise!]!.formatted())!!")
            case .robbery:
                CompradorsReportBadJoss("You‘ve been beaten up and robbed of \(game.robberyLoss!.fancyFormatted()) in cash, Taipan!!")
            case .hostilesApproaching:
                CaptainsReport("\(game.hostilesCount!.formatted()) hostile ships approaching, Taipan!")
            case .battleSummary:
                BattleSummaryView()
            case .liYuenDroveThemOff:
                CaptainsReport("Li Yuen‘s fleet drove them off!")
            case .liYuenApproaching:
                CaptainsReportLiYuen(nil)
            case .liYuenLetUsBe:
                CaptainsReportLiYuen("Good joss!! They let us be!!")
            case .liYuenAttacking:
                CaptainsReportLiYuen("\(game.hostilesCount!.formatted()) ships of Li Yuen‘s pirate fleet, Taipan!!")
            case .liYuenBattleSummary:
                BattleSummaryView()
            case .storm:
                CaptainsReportStorm()
            case .storm2:
                CaptainsReportStorm()
            case .stormGoingDown:
                CaptainsReportStorm()
            case .stormMadeIt:
                CaptainsReportStorm()
            case .stormBlownOffCourse:
                CaptainsReport("We've been blown off course to \(game.destinationCity!.rawValue).")
            case .retirement:
                RetirementView()
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
    
    struct CaptainsReportLiYuen: View {
        @EnvironmentObject private var game: Game
        var message: String?
        
        init(_ message: String?) {
            self.message = message
        }
        
        var body: some View {
            VStack {
                Text("Captain‘s Report")
                    .withReportStyle()
                Text("Li Yuen‘s pirates, Taipan!!")
                    .withMessageStyle()
                if let message = message {
                    Text(message)
                        .withMessageStyle()
                        .padding(.top, 10)
                }
                Spacer()
            }
            .withTappableStyle(game)
        }
    }
    
    struct CaptainsReportStorm: View {
        @EnvironmentObject private var game: Game
        
        var body: some View {
            VStack {
                Text("Captain‘s Report")
                    .withReportStyle()
                Text("Storm, Taipan!!")
                    .withMessageStyle()
                if [ .storm2, .stormGoingDown ].contains(game.state) {
                    Text("I think we‘re going down!!")
                        .withMessageStyle()
                        .padding(.leading, 20)
                        .padding(.top, 10)
                }
                else if game.state == .stormMadeIt {
                    Text("We made it!!")
                        .withMessageStyle()
                        .padding(.leading, 20)
                        .padding(.top, 10)
                }
                if game.state == .stormGoingDown {
                    Text("We‘re going down, Taipan!!!!")
                        .withMessageStyle()
                        .padding(.leading, 40)
                        .padding(.top, 10)
                }
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
                    .padding(.top, 10)
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
                    .withDisabledStyle(game.cash! <= 0)
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
                    Text("It‘s worth \(booty.fancyFormatted())!")
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
    
    struct RetirementView: View {
        @EnvironmentObject private var game: Game
        @Environment(\.sizeCategory) var sizeCategory

        var body: some View {
            VStack {
                Text("Comprador‘s Report")
                    .withReportStyle()
                VStack {
                    Text("You‘re a")
                        .kerning(sizeCategory > .extraLarge ? 7 : 10)
                    Text("MILLIONAIRE!")
                        .kerning(sizeCategory > .extraLarge ? 7 : 10)
                        .padding(.top, 5)
                }
                .padding(sizeCategory > .extraLarge ? 10 : 20)
                .foregroundColor(.taipanBackgroundColor)
                .background(Color.taipanColor)
                .padding(sizeCategory > .extraLarge ? 5 : 10)
                Spacer()
            }
            .withTappableStyle(game)
        }
    }
}

struct KeypadView: View {
    @Binding var amount: Int
    var limitHint: String?
    var bigNumbers: Bool?
    
    var body: some View {
        VStack {
            if bigNumbers ?? false {
                Text("\(amount)")
                    .withTextFieldStyle(width: 250, color: .taipanColor)
                if let limitHint = limitHint {
                    Text(limitHint)
                        .padding(.leading, 20)
                        .multilineTextAlignment(.center)
                        .font(.captionFont)
                        .opacity(0.7)
                }
            }
            else {
                HStack {
                    Text("\(amount)")
                        .withTextFieldStyle(width: 100, color: .taipanColor)
                    if let limitHint = limitHint {
                        Text(limitHint)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 20)
                            .multilineTextAlignment(.center)
                            .font(.captionFont)
                            .opacity(0.7)
                    }
                }
            }
            Spacer()
                .frame(height: 20)
            ForEach(0...2, id: \.self) { row in
                HStack {
                    ForEach(0...2, id: \.self) { column in
                        let digit = row * 3 + column + 1
                        KeypadButton {
                            amount = (amount % 1000000000000) * 10 + digit
                        } content: {
                            Text("\(digit)")
                                .font(.keypadDigitFont)
                        }
                        .padding(2)
                    }
                }
            }
            HStack {
                KeypadButton {
                    amount = (amount % 1000000000000) * 10
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
    @State private var hostileYOffset: CGFloat = 0
    @State private var firedOnShipForeground = Color.clear
    @State private var firedOnShipBackground = Color.clear
    @State private var shipOffset: CGSize = CGSize.zero
    @Binding var battleBackgroundColor: Color
    @Binding var isShowingSellModal: Bool
    
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
                Text("We have\n\(game.shipGuns!.formatted()) guns")
                    .multilineTextAlignment(.trailing)
                    .padding(5)
                    .border(Color.taipanColor)
            }
            Text(game.battleMessage ?? " ")
            
            Spacer()
            
            LazyVGrid(columns: [
                GridItem(),
                GridItem(),
                GridItem(),
            ], spacing: 10) {
                ForEach(0..<game.maxHostilesOnScreen, id: \.self) { ship in
                    HostileShipView(ship: ship,
                                    firedOnShipForeground: $firedOnShipForeground,
                                    firedOnShipBackground: $firedOnShipBackground,
                                    battleBackgroundColor: $battleBackgroundColor,
                                    hostileYOffset: $hostileYOffset)
                }
            }
            .padding(.horizontal, 8)
            Image(systemName: "plus")
                .padding(.top, 5)
                .opacity(game.hostilesCount! > game.countOfHostilesOnScreen ? 1.0 : 0.0)
            
            Spacer()
            
            Text("Current seaworthiness: ") +
            Text("\(game.fancyShipStatus(.parenthesis))").foregroundColor(game.shipInDanger ? .warningColor : .taipanColor)
            HStack {
                RoundRectButton {
                    game.orderFight()
                } content: {
                    Text("Fight")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                .withDisabledStyle(game.shipGuns! == 0 || game.hostilesCount! == 0)
                Spacer()
                RoundRectButton {
                    game.orderRun()
                } content: {
                    Text("Run")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                .withDisabledStyle(game.hostilesCount! == 0)
                Spacer()
                RoundRectButton {
                    game.orderThrowCargo()
                    isShowingSellModal = true
                } content: {
                    Text("Throw\nCargo")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                .withDisabledStyle(!game.shipHasCargo() || game.hostilesCount! == 0)
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
                battleBackgroundColor = .taipanBackgroundColor
            }
        }
        .padding(2)
    }
    
    struct HostileShipView: View {
        @EnvironmentObject private var game: Game
        var ship: Int
        @Binding var firedOnShipForeground: Color
        @Binding var firedOnShipBackground: Color
        @Binding var battleBackgroundColor: Color
        @Binding var hostileYOffset: CGFloat
        
        var body: some View {
            Image("lorcha")
                .resizable()
                .scaledToFit()
                .foregroundColor(ship != game.targetedShip ? .taipanColor : firedOnShipForeground)
                .background(ship != game.targetedShip ? battleBackgroundColor : firedOnShipBackground)
                .offset(y: ship == game.targetedShip ? hostileYOffset : 0)
                .clipped()
                .opacity(game.hostileShipVisible(ship) ? 1.0 : 0.0)
                .overlay(
                    ZStack {
                        Image("damage1")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ship != game.targetedShip ? battleBackgroundColor : firedOnShipBackground)
                            .offset(y: ship == game.targetedShip ? hostileYOffset : 0)
                            .opacity(((game.hostileShipDamage(ship) & 0b0001) != 0) ? 1.0 : 0.0)
                        Image("damage2")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ship != game.targetedShip ? battleBackgroundColor : firedOnShipBackground)
                            .offset(y: ship == game.targetedShip ? hostileYOffset : 0)
                            .opacity(((game.hostileShipDamage(ship) & 0b0010) != 0) ? 1.0 : 0.0)
                        Image("damage3")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ship != game.targetedShip ? battleBackgroundColor : firedOnShipBackground)
                            .offset(y: ship == game.targetedShip ? hostileYOffset : 0)
                            .opacity(((game.hostileShipDamage(ship) & 0b0100) != 0) ? 1.0 : 0.0)
                        Image("damage4")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ship != game.targetedShip ? battleBackgroundColor : firedOnShipBackground)
                            .offset(y: ship == game.targetedShip ? hostileYOffset : 0)
                            .opacity(((game.hostileShipDamage(ship) & 0b1000) != 0) ? 1.0 : 0.0)
                    }
                )
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
                .onChange(of: game.targetedShipSinking) { newValue in
                    if ship == game.targetedShip && (newValue ?? false) {
                        let sinkDuration = Double.random(in: 0.3...2.0)
                        withAnimation(.easeIn(duration: sinkDuration)) {
                            // the lorcha is 5.56“ x 4.31“, and the iPhone Pro Max is 428pt wide
                            hostileYOffset = 111
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + sinkDuration) {
                            game.targetedShipSunk()
                            hostileYOffset = 0
                        }
                    }
                }
                .onAppear {
                    normalHostileShip()
                }
        }
        
        private func normalHostileShip() {
            firedOnShipForeground = .taipanColor
            firedOnShipBackground = .taipanBackgroundColor
        }
        
        private func reverseHostileShip() {
            // inverts the foreground and background colors to simulate hitting
            // a hostile ship
            firedOnShipForeground = .taipanBackgroundColor
            firedOnShipBackground = .taipanColor
        }
    }
    
    private func shipTakingFire() {
        // offset the entire view and change the background color randomly to
        // simulate getting hit
        shipOffset.width = Double.random(in: -30.0...30.0)
        shipOffset.height = Double.random(in: -30.0...30.0)
        battleBackgroundColor = Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

struct FinalStatsView: View {
    @EnvironmentObject private var game: Game

    var body: some View {
        let score = game.score
        
        if game.state == .finalStats {
            Group {
                Text("\(game.firmName!)")
                    .font(.titleFont)
                    .lineLimit(1)
                    .padding(.bottom, 10)
                Text("Your final status:")
                    .withReportStyle()
                Text("Net Cash: \(game.netWorth.fancyFormatted())")
                    .withReportStyle()
                Text("Ship Size: \(game.shipCapacity.formatted()) units with \(game.shipGuns!.formatted()) guns")
                    .withReportStyle()

                let years = game.months / 12
                let months = game.months % 12
                Text("You traded for \(years) " +
                     ((years == 1) ? "year" : "years") +
                     " \(months) " +
                     ((months == 1) ? "month" : "months"))
                    .withReportStyle()

                Text("Your score is \(score).")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 3)
                    .foregroundColor(.taipanBackgroundColor)
                    .background(Color.taipanColor)
                
                if score < 0 {
                    Text("The crew has requested that you stay on shore for their safety!!")
                        .withReportStyle()
                        .padding(.top, 10)
                }
                else if score < 100 {
                    Text("Have you considered a land based job?")
                        .withReportStyle()
                        .padding(.top, 10)
                }
            } // Group
            
            Text("Your Rating:")
                .withMessageStyle()
                .padding(.top, 10)
            RoundRectVStack(.taipanColor) {
                HStack {
                    Text("Ma Tsu")
                        .foregroundColor(score >= 50000 ? .taipanBackgroundColor : Color.taipanColor)
                        .background(score >= 50000 ? Color.taipanColor : .taipanBackgroundColor)
                    Spacer()
                    Text("50,000 and over")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                HStack {
                    Text("Master Taipan")
                        .foregroundColor((score >= 8000 && score < 50000) ? .taipanBackgroundColor : Color.taipanColor)
                        .background((score >= 8000 && score < 50000) ? Color.taipanColor : .taipanBackgroundColor)
                    Spacer()
                    Text("8,000 to 49,999")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                HStack {
                    Text("Taipan")
                        .foregroundColor((score >= 1000 && score < 8000) ? .taipanBackgroundColor : Color.taipanColor)
                        .background((score >= 1000 && score < 8000) ? Color.taipanColor : .taipanBackgroundColor)
                    Spacer()
                    Text("1,000 to 7,999")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                HStack {
                    Text("Compradore")
                        .foregroundColor((score >= 500 && score < 1000) ? .taipanBackgroundColor : Color.taipanColor)
                        .background((score >= 500 && score < 1000) ? Color.taipanColor : .taipanBackgroundColor)
                    Spacer()
                    Text("500 to 999")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                HStack {
                    Text("Galleyhand")
                        .foregroundColor(score < 500 ? .taipanBackgroundColor : Color.taipanColor)
                        .background(score < 500 ? Color.taipanColor : .taipanBackgroundColor)
                    Spacer()
                    Text("less than 500")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
            } // RoundRectVStack
            .padding(.horizontal, 2)
            
            Spacer()
            
            Group {
                Text("Play again?")
                    .withMessageStyle()
                
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
                } // HStack
            } // Group
        }
    }
}

struct ContentView: View {
    private let bodyFont = Font.custom("MorrisRoman-Black", size: 22)
    
    @EnvironmentObject private var game: Game
    @State private var isShowingBuyModal = false
    @State private var isShowingSellModal = false
    @State private var isShowingDestinationModal = false
    @State private var isShowingBorrowModal = false
    @State private var isShowingRepayModal = false
    @State private var isShowingBankModal = false
    @State private var isShowingTransferModal = false
    @State private var isShowingRepairModal = false
    @State private var battleBackgroundColor = Color.clear
    @State private var splashAnimation = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                battleBackgroundColor
                    .ignoresSafeArea()
                ScrollView {
                    if game.isUnderAttack() {
                        ZStack {
                            BattleView(battleBackgroundColor: $battleBackgroundColor,
                                       isShowingSellModal: $isShowingSellModal)
                                .blur(radius: isShowingModal ? 3 : 0)
                                .disabled(isShowingModal)
                            
                            if isShowingSellModal {
                                SellModalView(isShowingSellModal: $isShowingSellModal)
                            }
                        }
                        .background(battleBackgroundColor)
                        .frame(minHeight: proxy.size.height)
                    }
                    else if game.state == .name {
                        VStack {
                            NameView(splashAnimation: $splashAnimation)
                        }
                        .padding(2)
                        .frame(minHeight: proxy.size.height)
                    }
                    else if game.state == .debtOrGuns {
                        VStack { DebtOrGunsView() }
                            .padding(2)
                            .frame(minHeight: proxy.size.height)
                    }
                    else if game.state == .finalStats {
                        VStack { FinalStatsView() }
                            .padding(2)
                            .frame(minHeight: proxy.size.height)
                    }
                    else {
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
                                .padding(2)
                            
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
                        .background(Color.taipanBackgroundColor)
                        .frame(minHeight: proxy.size.height)
                    }
                }
            }
            .foregroundColor(.taipanColor)
            .font(bodyFont)
            .statusBar(hidden: true)
            .onAppear {
                battleBackgroundColor = .taipanBackgroundColor
            }
        }
        .statusBar(hidden: true)
    }
    
    var isShowingModal: Bool {
        isShowingBuyModal || isShowingSellModal || isShowingDestinationModal ||
        isShowingBorrowModal || isShowingRepayModal || isShowingBankModal ||
        isShowingTransferModal || isShowingRepairModal
    }
    
    struct BuyModalView: View {
        @EnvironmentObject private var game: Game
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
                    FullWidthButton {
                        amount = game.canAfford(selectedMerchandise)
                    } content: {
                        VStack {
                            Text("All I can afford (\(game.canAfford(selectedMerchandise)))")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    FullWidthButton {
                        amount = game.shipFreeCapacity
                    } content: {
                        VStack {
                            Text("Enough to fill ship (\(game.shipFreeCapacity))")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .withDisabledStyle(game.shipFreeCapacity > game.canAfford(selectedMerchandise))
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
                    .padding(.top, 10)
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
            .withModalStyle(.taipanSheetColor)
        }
    }
    
    struct SellModalView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingSellModal: Bool
        @State private var selectedMerchandise: Game.Merchandise?
        @State private var amount = 0
        
        var body: some View {
            let discard = game.isUnderAttack()
            
            VStack {
                let merchandise = selectedMerchandise ?? game.onlyMerchandiseOnShip()
                if let merchandise = merchandise,
                   let amountOnShip = game.shipHold[merchandise] {
                    if discard {
                        Text("How much, Taipan?")
                    }
                    else {
                        Text("How much \(merchandise.rawValue) shall I sell, Taipan:")
                    }
                    KeypadView(
                        amount: $amount,
                        limitHint: "You have\n\(amountOnShip.formatted())"
                    )
                    FullWidthButton {
                        amount = amountOnShip
                    } content: {
                        VStack {
                            Text("All of it (\(amountOnShip))")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    if game.shipFreeCapacity < 0 {
                        FullWidthButton {
                            amount = -game.shipFreeCapacity
                        } content: {
                            VStack {
                                Text("Overload (\(-game.shipFreeCapacity))")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    HStack {
                        RoundRectButton {
                            isShowingSellModal = false
                            self.selectedMerchandise = nil
                            if discard {
                                game.discardCancelled()
                            }
                        } content: {
                            Text("Cancel")
                                .frame(minWidth: 80)
                        }
                        .withCancelStyle()
                        RoundRectButton {
                            if discard {
                                game.discard(merchandise, amount)
                            }
                            else {
                                game.sell(merchandise, amount)
                            }
                            isShowingSellModal = false
                        } content: {
                            if discard {
                                Text("Throw")
                                    .frame(minWidth: 80)
                            }
                            else {
                                Text("Sell")
                                    .frame(minWidth: 80)
                            }
                        }
                        .withDisabledStyle(amount == 0 || amount > amountOnShip)
                    }
                    .padding(.top, 10)
                }
                else {
                    if discard {
                        Text("What shall I throw overboard, Taipan?")
                    }
                    else {
                        Text("What do you wish me to sell, Taipan?")
                    }
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
                        if discard {
                            game.discardCancelled()
                        }
                    } content: {
                        Text("Cancel")
                    }
                }
            }
            .withModalStyle(.taipanSheetColor)
        }
    }
    
    struct DestinationModalView: View {
        @EnvironmentObject private var game: Game
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
            .withModalStyle(.taipanSheetColor)
        }
    }
    
    struct BorrowModalView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingBorrowModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                Text("How much do you wish to borrow?")
                KeypadView(
                    amount: $amount,
                    limitHint: "He will loan up to \(game.maximumLoan.formatted())",
                    bigNumbers: true
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
            .withModalStyle(.taipanSheetColor)
        }
    }
    
    struct RepayModalView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingRepayModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                Text("How much do you wish to repay him?")
                KeypadView(
                    amount: $amount,
                    limitHint: "You have\n\(game.cash!.formatted())"
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
                    .withDisabledStyle(amount == 0 || amount > game.cash!)
                }
            }
            .withModalStyle(.taipanSheetColor)
        }
    }
    
    struct BankModalView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingBankModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                KeypadView(amount: $amount,
                           bigNumbers: true)
                HStack(alignment: .bottom) {
                    RoundRectButton {
                        isShowingBankModal = false
                    } content: {
                        Text("Cancel")
                            .frame(minWidth: 80)
                    }
                    .withCancelStyle()
                    VStack {
                        Text("You have\n\(game.cash!.formatted())\nin cash")
                            .font(.captionFont)
                            .multilineTextAlignment(.center)
                        RoundRectButton {
                            game.deposit(amount)
                            isShowingBankModal = false
                        } content: {
                            Text("Deposit")
                                .frame(minWidth: 80)
                        }
                        .withDisabledStyle(amount == 0 || amount > game.cash!)
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
            .withModalStyle(.taipanSheetColor)
        }
    }
    
    struct TransferModalView: View {
        @EnvironmentObject private var game: Game
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
            .withModalStyle(.taipanSheetColor)
        }
    }

    struct RepairModalView: View {
        @EnvironmentObject private var game: Game
        @Binding var isShowingRepairModal: Bool
        @State private var amount = 0
        
        var body: some View {
            VStack {
                let shipDamagePercent = 100 - game.shipStatus
                let mcHenryOffer = game.mcHenryOffer!
                Text("Och, 'tis a pity to be \(shipDamagePercent.formatted(.percent)) damaged.\nWe can fix yer whole ship for \(mcHenryOffer.formatted()), or make partial repairs if you wish.\nHow much will ye spend?")
                KeypadView(
                    amount: $amount,
                    limitHint: "You have\n\(game.cash!.formatted())"
                )
                FullWidthButton {
                    amount = mcHenryOffer
                } content: {
                    VStack {
                        Text("Fix the whole ship (\(mcHenryOffer.formatted()))")
                            .frame(maxWidth: .infinity)
                    }
                }
                .withDisabledStyle(game.cash! < mcHenryOffer)
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
                    .withDisabledStyle(amount == 0 || amount > min(game.cash!, game.mcHenryOffer!))
                }
                .padding(.top, 10)
            }
            .withModalStyle(.taipanSheetColor)
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
        .foregroundColor(.taipanBackgroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.taipanColor, .taipanColor.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            )
        )
    }
}

struct KeypadButton<Content: View>: View {
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
        .foregroundColor(.taipanBackgroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.taipanColor, .taipanColor.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            )
        )
    }
}

struct RoundRectButton<Content: View>: View {
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
        .foregroundColor(.taipanBackgroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.taipanColor, .taipanColor.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
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
    static let warningColor = Color.red
    static let taipanColor = Color("ForegroundColor")
    static let taipanBackgroundColor = Color("BackgroundColor")
    static let taipanSheetColor = Color("SheetColor")
}

extension Font {
    static let titleFont = Font.custom("MorrisRoman-Black", size: 30)
    static let keypadDigitFont = Font.custom("MorrisRoman-Black", size: 26)
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
