//
//  ContentView.swift
//  Shared
//
//  Created by sh95014 on 3/27/22.
//

import SwiftUI

struct TradingView: View {
    @EnvironmentObject private var game: Game
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
    
    var body: some View {
        VStack {
            Group {
                Text("Noble House, Hong Kong")
                    .font(.titleFont)
                Text(verbatim: "15 \(game.month.rawValue) \(game.year)")
                    .padding(.bottom, 5)
            }
            
            HStack {
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
                        .foregroundColor(game.shipInDanger ? .warningColor : .defaultColor)
                }
            }
            
            RoundRectVStack(.defaultColor) {
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
                .padding(.horizontal, 50)
            }
            
            RoundRectVStack(game.shipFreeCapacity >= 0 ? .defaultColor : .warningColor) {
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
                .padding(.horizontal, 50)
            }
            
            HStack {
                Text("Cash: \(game.cash.fancyFormatted())")
                Spacer()
                Text("Bank: \(game.bank.fancyFormatted())")
            }
            
            Divider()
                .background(Color.defaultColor)
            
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
                    
                    HStack {
                        RoundRectButton {
                            isShowingBuyModal = true
                        } content: {
                            Text("Buy")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(!game.canAffordAny())
                        Spacer()
                        RoundRectButton {
                            isShowingSellModal = true
                        } content: {
                            Text("Sell")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(!game.shipHasCargo())
                        Spacer()
                        RoundRectButton {
                            isShowingBankModal = true
                        } content: {
                            Text("Visit\nBank")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(game.currentCity != .hongkong || (game.cash <= 0 && game.bank <= 0))
                        Spacer()
                        RoundRectButton {
                            isShowingTransferModal = true
                        } content: {
                            Text("Transfer\nCargo")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(game.currentCity != .hongkong || (!game.shipHasCargo() && game.warehouseUsedCapacity == 0))
                        Spacer()
                        RoundRectButton {
                            isShowingDestinationModal = true
                        } content: {
                            Text("Quit\nTrading")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(game.shipFreeCapacity < 0)
                    }
                    
                    FullWidthButton {
                        
                    } content: {
                        Text("Retire")
                    }
                    .withDisabledStyle(game.currentCity != .hongkong || game.cash + game.bank < 1000000)
                }
            case .arriving:
                VStack {
                    Text("Captain‘s Report")
                        .withReportStyle()
                    Text("Arriving at \(game.destinationCity!.rawValue)...")
                    Spacer()
                }
                .withTappableStyle(game)
            case .liYuenExtortion:
                LiYuenExtortionView()
            case .notEnoughCash:
                NotEnoughCashView()
            case .borrowForLiYuen:
                BorrowForLiYuenView()
            case .borrowedForLiYuen:
                BorrowedForLiYuenView()
            case .elderBrotherWuPirateWarning:
                ElderBrotherWuPirateWarningView()
            case .mcHenryOffer:
                McHenryOfferView(isShowingRepairModal: $isShowingRepairModal)
            case .elderBrotherWuWarning1:
                ElderBrotherWuWarningView(page: 1)
            case .elderBrotherWuWarning2:
                ElderBrotherWuWarningView(page: 2)
            case .elderBrotherWuWarning3:
                ElderBrotherWuWarningView(page: 3)
            case .elderBrotherWuBusiness:
                ElderBrotherWuBusinessView(isShowingBorrowModal: $isShowingBorrowModal,
                                           isShowingRepayModal: $isShowingRepayModal)
            case .elderBrotherWuBailout:
                ElderBrotherWuBailoutView()
            case .bailoutReaction:
                BailoutReactionView()
            case .bankruptcy:
                BankruptcyView()
            case .cutthroats:
                CutthroatsView()
            case .newShipOffer:
                NewShipOfferView()
            case .newGunOffer:
                NewGunOfferView()
            case .opiumSeized:
                OpiumSeizedView()
            case .warehouseTheft:
                WarehouseTheftView()
            case .liYuenMessage:
                LiYuenMessageView()
            case .priceDrop:
                PriceDropView()
            case .priceJump:
                PriceJumpView()
            case .robbery:
                RobberyView()
            case .hostilesApproaching:
                HostilesApproachingView()
            default:
                Text("unhandled state \(game.state.rawValue)")
            }
        }
        .padding(.horizontal, 8)
    }
}

struct LiYuenExtortionView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Li Yuen asks \(game.liYuenDemand!.formatted()) in donation to the temple of Tin Hau, the Sea Goddess. Will you pay?")
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

struct NotEnoughCashView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Taipan, you do not have enough cash!!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct BorrowForLiYuenView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Do you want Elder Brother Wu to make up the difference for you?")
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

struct BorrowedForLiYuenView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Elder Brother has given Li Yuen the difference between what he wanted and your cash on hand and added the same amount to your debt.")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct ElderBrotherWuPirateWarningView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Very well. Elder Brother Wu will not pay Li Yuen the difference.  I would be very wary of pirates if I were you, Taipan.")
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

struct ElderBrotherWuWarningView: View {
    @EnvironmentObject private var game: Game
    var page: Int
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            switch page {
            case 1:
                Text("Elder Brother Wu has sent \(game.elderBrotherWuBraves) braves to escort you to the Wu mansion, Taipan.")
                    .withMessageStyle()
            case 2:
                Text("Elder Brother Wu reminds you of the Confucian ideal of personal worthiness, and how this applies to paying one‘s debts.")
                    .withMessageStyle()
            default:
                Text("He is reminded of a fabled barbarian who came to a bad end, after not caring for his obligations.\n\nHe hopes no such fate awaits you, his friend, Taipan.")
                    .withMessageStyle()
            }
            Spacer()
        }
        .withTappableStyle(game)
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

struct ElderBrotherWuBailoutView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Elder Brother is aware of your plight, Taipan.  He is willing to loan you an additional \(game.bailoutOffer!.formatted()) if you will pay back \(game.bailoutRepay!.formatted()). Are you willing, Taipan?")
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

struct BailoutReactionView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Very well, Taipan.  Good joss!!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct BankruptcyView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Very well, Taipan, the game is over!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct CutthroatsView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Bad joss!!")
                .withMessageStyle()
            Text("\(game.bodyguardsLost!.formatted()) of your bodyguards have been killed by cutthroats and you have been robbed of all of your cash, Taipan!!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
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

struct NewGunOfferView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Do you wish to buy a ship‘s gun for \(game.offerAmount!.formatted()), Taipan?")
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

struct OpiumSeizedView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Bad Joss!!")
                .withMessageStyle()
            Text("The local authorities have seized your Opium cargo and have also fined you \(game.opiumFine!.fancyFormatted()), Taipan!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct WarehouseTheftView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Messenger reports large theft from warehouse, Taipan.")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct LiYuenMessageView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Li Yuen has sent a Lieutenant, Taipan.  He says his admiral wishes to see you in Hong Kong, posthaste!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct PriceDropView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Taipan!! The price of \(game.goodPriceMerchandise!.rawValue) has dropped to \(game.price[game.goodPriceMerchandise!]!)!!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct PriceJumpView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Taipan!! The price of \(game.goodPriceMerchandise!.rawValue) has risen to \(game.price[game.goodPriceMerchandise!]!)!!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct RobberyView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Comprador‘s Report")
                .withReportStyle()
            Text("Bad Joss!!")
                .withMessageStyle()
            Text("You‘ve been beaten up and robbed of \(game.robberyLoss!.fancyFormatted()) in cash, Taipan!!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
}

struct HostilesApproachingView: View {
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            Text("Captain‘s Report")
                .withReportStyle()
            Text("\(game.hostileShipsCount!.formatted()) hostile ships approaching, Taipan!")
                .withMessageStyle()
            Spacer()
        }
        .withTappableStyle(game)
    }
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
        .withModalStyle(.sheetColor)
    }
}

struct SellModalView: View {
    @EnvironmentObject private var game: Game
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
        .withModalStyle(.sheetColor)
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
        .withModalStyle(.sheetColor)
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
        .withModalStyle(.sheetColor)
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
        .withModalStyle(.sheetColor)
    }
}

struct BankModalView: View {
    @EnvironmentObject private var game: Game
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
        .withModalStyle(.sheetColor)
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
        .withModalStyle(.sheetColor)
    }
}

struct RepairModalView: View {
    @EnvironmentObject private var game: Game
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
        .withModalStyle(.sheetColor)
    }
}

struct KeypadView: View {
    @Binding var amount: Int
    var limitHint: String?
    
    var body: some View {
        VStack {
            HStack {
                Text("\(amount)")
                    .withTextFieldStyle(width: 100)
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
    @State private var shipYOffset: CGFloat = 0
    @State private var shipToSink = 2
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("10 ships attacking, Taipan!")
                        .withMessageStyle()
                    Text("Your orders are to: Fight")
                        .withMessageStyle()
                }
                Spacer()
                Text("We have\n\(game.shipGuns.formatted()) guns")
                    .multilineTextAlignment(.trailing)
                    .padding(5)
                    .border(Color.defaultColor)
            }
            Text("Aye, we‘ll fight ‘em, Taipan!")
            
            Spacer()
            
            LazyVGrid(columns: [
                GridItem(),
                GridItem(),
                GridItem(),
            ], spacing: 10) {
                ForEach(1...9, id: \.self) { ship in
                    Image("lorcha")
                        .resizable()
                        .scaledToFit()
//                        .background(ship == 6 ? Color.defaultColor : Color.clear)
//                        .foregroundColor(ship == 6 ? Color.backgroundColor : Color.defaultColor)
                        .animation(.linear(duration: 0.5), value: shipYOffset)
                        .offset(y: ship == shipToSink ? shipYOffset : 0)
                        .clipped()
                }
            }
            .padding(.horizontal, 8)
            Image(systemName: "plus")
                .padding(.top, 5)
            
            Spacer()
            
            Text("Current seaworthiness: \(game.fancyShipStatus(.parenthesis))")
            HStack {
                RoundRectButton {
                    shipYOffset = 100
                } content: {
                    Text("Fight")
                        .frame(maxWidth: .infinity, minHeight: bottomRowMinHeight)
                }
                .withDisabledStyle(game.shipGuns == 0)
                Spacer()
                RoundRectButton {
                    shipYOffset = 0
                    shipToSink = 1 + (shipToSink + 1) % 9
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
    @State private var isUnderAttack = false
    
    var body: some View {
        if !isUnderAttack {
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
            .foregroundColor(.defaultColor)
            .background(Color.backgroundColor)
            .font(bodyFont)
        }
        else {
            ZStack {
                Color.backgroundColor
                BattleView()
            }
            .foregroundColor(.defaultColor)
            .background(Color.backgroundColor)
            .font(bodyFont)
        }
    }
    
    var isShowingModal: Bool {
        isShowingBuyModal || isShowingSellModal || isShowingDestinationModal ||
        isShowingBorrowModal || isShowingRepairModal
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
        .foregroundColor(Color.backgroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.defaultColor, .defaultColor.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
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
        .foregroundColor(Color.backgroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.defaultColor, .defaultColor.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
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
        .foregroundColor(Color.backgroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.defaultColor, .defaultColor.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
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
    static let defaultColor = Color.orange
    static let warningColor = Color.red
    static let sheetColor = Color.init(white: 0.15)
    static let backgroundColor = Color.black
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
    func withTextFieldStyle(width: CGFloat) -> some View {
        self.frame(width: width, alignment: .trailing)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(Color.defaultColor.opacity(0.5))
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.defaultColor.opacity(0.1))
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
        self.padding(20)
            .cornerRadius(5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .shadow(radius: 5)
    }
    
    func withTappableStyle(_ game: Game) -> some View {
        self.contentShape(Rectangle())
            .onTapGesture {
                game.sendEvent(.tap)
            }
    }
}


