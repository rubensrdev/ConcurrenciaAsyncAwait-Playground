import Foundation
import Synchronization

/*:
# Bloqueo de Datos en Concurrencia Estricta
Swift 6 introdujo el concepto de **concurrencia estricta**. Este modelo de concurrencia busca garantizar que los accesos a datos compartidos en contextos concurrentes estén adecuadamente sincronizados para evitar errores como el **data race** (cuando varios hilos intentan acceder o modificar un recurso al mismo tiempo sin sincronización adecuada).

La concurrencia estricta asegura que cada acceso a un dato compartido esté asociado a un contexto (hilo o actor) específico. Si no se asegura esta serialización, los errores de concurrencia pueden volverse extremadamente difíciles de detectar y depurar.

A continuación, veremos tres técnicas para bloquear datos de manera segura en un entorno de concurrencia en Swift.
*/

//: ## ClaseSegura con NSLock y `@unchecked Sendable`
//: ### Explicación
//: En el primer ejemplo utilizamos `NSLock`, una de las clases más tradicionales para la sincronización de hilos en Swift y Cocoa.
//:
//: Al usar `NSLock`, necesitamos decirle al compilador que garantizaremos la seguridad del acceso, ya que el compilador no puede garantizar la seguridad de esta concurrencia de forma estática. Para ello usamos `@unchecked Sendable`.

final class ClaseSegura: @unchecked Sendable {
    //: `NSLock` es una clase que proporciona un mecanismo de bloqueo para evitar el acceso concurrente a recursos compartidos.
    let lock = NSLock()
    private var _value: String
    
    init(value: String) {
        self._value = value
    }
    
    var value: String {
        get {
            //: Al leer el valor, bloqueamos el acceso al recurso.
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            //: Al escribir un nuevo valor, también bloqueamos para evitar el acceso simultáneo.
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
}

/*:
### `@unchecked Sendable`
El `@unchecked Sendable` nos permite decirle al compilador que esta clase es segura para el uso concurrente. Sin embargo, **debemos usarlo con cuidado**, ya que estamos tomando la responsabilidad de garantizar la seguridad de los datos. Es útil en casos donde utilizamos mecanismos externos, como `NSLock`, que el compilador no puede analizar para asegurar el acceso seguro.

Cuando se usa `@unchecked Sendable`, **el desarrollador asume toda la responsabilidad** de asegurar que no habrá **data races**. Es decir, debemos asegurarnos de que cada acceso al recurso esté correctamente protegido, como se hace aquí con `NSLock`.
*/

//: ## ClaseSegura2 con `Mutex`
//: ### Explicación
//: En este segundo ejemplo utilizamos un `Mutex` (proporcionado por `Synchronization`), un mecanismo de sincronización más moderno y más seguro que `NSLock`.

final class ClaseSegura2: Sendable {
    //: Utilizamos un `Mutex` que encapsula la lógica del bloqueo, haciéndolo más seguro.
    private let _value: Mutex<String>
    
    init(value: String) {
        //: Inicializamos el `Mutex` con un valor inicial.
        self._value = .init(value)
    }
    
    var value: String {
        get {
            //: `withLock` garantiza que accedemos al valor de manera segura.
            _value.withLock {
                $0
            }
        }
        set {
            //: `withLock` también se usa para modificar el valor de forma segura.
            _value.withLock {
                $0 = newValue
            }
        }
    }
}

/*:
### `Mutex` en Synchronization
El uso de `Mutex` es más seguro que `NSLock` porque encapsula internamente toda la lógica del bloqueo. Con `Mutex`, no tenemos que preocuparnos de bloquear y desbloquear manualmente, lo que minimiza los errores humanos. Además, ayuda a hacer el código más limpio y fácil de entender, ya que se reduce la cantidad de código de sincronización que tenemos que escribir.
*/

//: ## ClaseSegura3 con Actor Privado
//: ### Explicación
//: En el tercer ejemplo usamos un **actor**. Un actor es un tipo seguro para la concurrencia que garantiza automáticamente el acceso seguro a sus propiedades. Este actor se encapsula dentro de una clase para asegurarse de que el acceso esté siempre bien sincronizado.

final class ClaseSegura3: Sendable {
    //: `Value` es un actor privado que protege el acceso a la propiedad `value`.
    private let _value: Value
    
    init(value: String) {
        self._value = Value(value: value)
    }
    
    //: ### Definición del actor privado
    private actor Value {
        var value: String
        
        init(value: String) {
            self.value = value
        }
        
        //: Método para actualizar el valor dentro del actor.
        func setValue(value: String) {
            self.value = value
        }
    }
    
    //: ### Acceso asíncrono al valor
    var value: String {
        get async {
            //: Accedemos al valor usando `await` para asegurarnos de que la lectura sea segura.
            await _value.value
        }
    }
    
    //: ### Modificación asíncrona del valor
    func setValue(value: String) async {
        //: Actualizamos el valor usando un método del actor.
        await _value.setValue(value: value)
    }
}

//: ### Uso de `ClaseSegura3` con `Task` y `await`
//: La siguiente tarea nos permite interactuar con `ClaseSegura3` usando concurrencia.
Task {
    let segura3 = ClaseSegura3(value: "OLA K ASE")
    await segura3.value
    await segura3.setValue(value: "HOLI")
}

/*:
### Conclusión
Cada una de estas tres técnicas permite proteger el acceso a datos compartidos en un entorno concurrente, pero todas tienen diferencias importantes:

1. **NSLock con `@unchecked Sendable`**:
   - Es una forma manual de proteger recursos. Requiere tener cuidado al bloquear y desbloquear para evitar errores humanos.
   - El uso de `@unchecked Sendable` deja la responsabilidad de la seguridad concurrente al desarrollador.

2. **`Mutex` de `Synchronization`**:
   - `Mutex` simplifica y asegura la lógica del bloqueo, minimizando errores humanos.
   - Es más seguro y moderno que `NSLock`.

3. **Actor Privado**:
   - El actor es una herramienta poderosa que asegura automáticamente el acceso seguro a sus propiedades.
   - Requiere la escritura de código asíncrono y el uso de `await`, lo que puede ser una curva de aprendizaje adicional, pero proporciona la mayor seguridad.

Cada una de estas técnicas tiene sus ventajas y desventajas, y la elección depende del contexto de uso y de los requerimientos específicos del proyecto.
*/ 
