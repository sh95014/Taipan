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
                    Text(game.fancyShipStatus)
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
                    Text("Comprador's Report")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)

                    Spacer()

                    Text("Taipan, present prices per unit here are")
                        .withQuestionStyle()

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
                        Spacer()
                        RoundRectButton {
                            isShowingSellModal = true
                        } content: {
                            Text("Sell")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(!game.canSell())
                        Spacer()
                        RoundRectButton {
                            isShowingBankModal = true
                        } content: {
                            Text("Visit\nBank")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(game.currentCity != .hongkong)
                        Spacer()
                        RoundRectButton {
                            if let silk = game.warehouse[Game.Merchandise.silk] {
                                game.warehouse[Game.Merchandise.silk] = silk + 20
                            }
                            else {
                                game.warehouse[Game.Merchandise.silk] = 20
                            }
                        } content: {
                            Text("Transfer\nCargo")
                                .frame(minWidth: bottomRowMinWidth, minHeight: bottomRowMinHeight)
                        }
                        .withDisabledStyle(game.currentCity != .hongkong)
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
                    .withDisabledStyle(game.cash + game.bank < 1000000)
                }
            case .arriving:
                VStack {
                    Text("Captain's Report")
                        .withReportStyle()
                    Text("Arriving at \(game.destinationCity!.rawValue)...")
                    Spacer()
                }
                .withTappableStyle(game)
            case .elderBrotherWu:
                VStack {
                    Text("Comprador's Report")
                        .withReportStyle()
                    Text("Do you have business with Elder Brother Wu, the moneylender?")
                        .withQuestionStyle()
                    Spacer()
                    HStack {
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
                        RoundRectButton {
                            game.sendEvent(.no)
                        } content: {
                            Text("No")
                                .frame(minWidth:100, minHeight:30)
                        }
                    }
                }
            case .newShipOffer:
                VStack {
                    Text("Comprador's Report")
                        .withReportStyle()
                    Text("Do you wish to trade in your \(game.shipDamage > 0 ? "damaged" : "fine") ship for one with 50 more capacity by paying an additional \(game.offerAmount.formatted()), Taipan?")
                        .withQuestionStyle()
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
            case .newGunOffer:
                VStack {
                    Text("Comprador's Report")
                        .withReportStyle()
                    Text("Do you wish to buy a ship's gun for \(game.offerAmount.formatted()), Taipan?")
                        .withQuestionStyle()
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
            default:
                Text("unhandled state \(game.state.rawValue)")
            }
        }
        .padding(.horizontal, 8)
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

struct ContentView: View {
    private let bodyFont = Font.custom("MorrisRoman-Black", size: 22)

    @EnvironmentObject private var game: Game
    @State private var isShowingBuyModal = false
    @State private var isShowingSellModal = false
    @State private var isShowingDestinationModal = false
    @State private var isShowingBorrowModal = false
    @State private var isShowingRepayModal = false
    @State private var isShowingBankModal = false

    var body: some View {
        ZStack {
            TradingView(isShowingBuyModal: $isShowingBuyModal,
                        isShowingSellModal: $isShowingSellModal,
                        isShowingDestinationModal: $isShowingDestinationModal,
                        isShowingBorrowModal: $isShowingBorrowModal,
                        isShowingRepayModal: $isShowingRepayModal,
                        isShowingBankModal: $isShowingBankModal)
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
        }
        .foregroundColor(.defaultColor)
        .background(Color.backgroundColor)
        .font(bodyFont)
    }

    var isShowingModal: Bool {
        isShowingBuyModal || isShowingSellModal || isShowingDestinationModal ||
        isShowingBorrowModal
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

// MARK: - Extensions

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
    
    func withQuestionStyle() -> some View {
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

// MARK: - Styling

extension Font {
    static let titleFont = Font.custom("MorrisRoman-Black", size: 30)
    static let bodyFont = Font.custom("MorrisRoman-Black", size: 22)
    static let captionFont = Font.custom("MorrisRoman-Black", size: 16)
}

extension Color {
    static let defaultColor = Color.orange
    static let warningColor = Color.red
    static let sheetColor = Color.init(white: 0.15)
    static let backgroundColor = Color.black
}
