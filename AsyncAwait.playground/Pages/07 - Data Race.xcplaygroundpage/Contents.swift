import Foundation

class BankAccount {
    let name: String
    var balance: Decimal
    
    init(name: String, balance: Decimal) {
        self.name = name
        self.balance = balance
    }
    
    func deposit(amount: Decimal) {
        balance += amount
    }
    
    func transfer(amount: Decimal, to account: BankAccount) {
        guard balance > amount else { return }
        balance -= amount
        account.deposit(amount: amount)
    }
}

// nonisolated(unsafe) let cuentaPaca = BankAccount(name: "Paca Antonia Furnieles", balance: 35000)
// nonisolated(unsafe) let cuentaAntonio = BankAccount(name: "Antonio Segismundo Beniatrez", balance: 45000)


let cuentaPaca = BankAccount(name: "Paca Antonia Furnieles", balance: 35000)
let cuentaAntonio = BankAccount(name: "Antonio Segismundo Beniatrez", balance: 45000)

cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)

cuentaPaca.balance
cuentaAntonio.balance

DispatchQueue.global().async {
    for _ in 1...1000 {
        Task { @MainActor in
            cuentaPaca.transfer(amount: 10, to: cuentaAntonio)
        }
    }
}

DispatchQueue.global().async {
    for _ in 1...1000 {
        Task { @MainActor in
            cuentaAntonio.transfer(amount: 10, to: cuentaPaca)
        }
    }
}

sleep(10)

cuentaPaca.balance
cuentaAntonio.balance
