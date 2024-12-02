import Foundation

actor BankAccount {
    let name: String
    var balance: Decimal
    
    init(name: String, balance: Decimal) {
        self.name = name
        self.balance = balance
    }
    
    func deposit(amount: Decimal) {
        balance += amount
    }
    
    nonisolated func getName() -> String {
        name
    }
    
    func transfer(amount: Decimal, to account: BankAccount) async {
        guard balance > amount else { return }
        balance -= amount
        await account.deposit(amount: amount)
    }
}

let cuentaPaca = BankAccount(name: "Paca Antonia Furnieles", balance: 35000)
let cuentaAntonio = BankAccount(name: "Antonio Segismundo Beniatrez", balance: 45000)

cuentaPaca.name
cuentaPaca.getName()

DispatchQueue.global().async {
    for _ in 1...1000 {
        Task {
            await cuentaPaca.transfer(amount: 10, to: cuentaAntonio)
        }
    }
}

DispatchQueue.global().async {
    for _ in 1...1000 {
        Task {
            await cuentaAntonio.transfer(amount: 10, to: cuentaPaca)
        }
    }
}

sleep(10)

Task {
    await cuentaPaca.balance
    await cuentaAntonio.balance
}
