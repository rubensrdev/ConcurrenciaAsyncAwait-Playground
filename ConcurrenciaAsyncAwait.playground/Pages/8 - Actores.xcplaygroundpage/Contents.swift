import Foundation

actor BankAccount {
    let name: String
    var balance: Double
    
    init(name: String, balance: Double) {
        self.name = name
        self.balance = balance
    }
    
    func deposit(amount: Double) {
        balance += amount
    }
    
    nonisolated func getName() -> String { // porque es let, ya está aislado no necesita Task ni Await
        name
    }
    
    func transfer(amount: Double, to account: BankAccount) async {
        guard balance >= amount else { return }
        balance -= amount
        await account.deposit(amount: amount)
    }
}

let cuentaPaca = BankAccount(name: "Paca Antonia Furnieles", balance: 35000)
let cuentaAntonio = BankAccount(name: "Antonio Segismundo Beniatrez", balance: 45000)

Task {
    await cuentaPaca.balance // como es var si necesita protección ante DATA RACE
}

cuentaPaca.name // es let y no necesita protección

DispatchQueue.global().async {
    for _ in 1...5000 {
        Task {
            await cuentaPaca.transfer(amount: 10, to: cuentaAntonio)
        }
    }
}

DispatchQueue.global().async {
    for _ in 1...5000 {
        Task {
            await cuentaAntonio.transfer(amount: 10, to: cuentaPaca)
        }
    }
}

sleep(12)

Task {
    await cuentaPaca.balance
    await cuentaAntonio.balance
}
