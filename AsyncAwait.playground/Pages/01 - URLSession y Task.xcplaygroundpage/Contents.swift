import UIKit

//: ### URLSession y el Mundo Web
//: `URLSession` es una clase muy poderosa que nos proporciona Apple para hacer peticiones a servidores web, ya sea para recuperar datos, enviarlos, o incluso subir archivos. En este ejemplo estamos configurando una `URLSession` para realizar una petición HTTP. Vamos a ver paso a paso cómo lo hacemos y qué conceptos web debemos entender primero.

//: #### HTTP: GET, POST, DELETE, PUT
//: En el mundo de la web, los **métodos HTTP** son las operaciones que puedes realizar sobre los recursos del servidor. Los principales métodos HTTP son:
//:
//: - **GET**: Se utiliza para **obtener información** de un servidor. Imagina que vas a un sitio web a leer un artículo; el navegador hace una petición GET para obtener ese artículo.
//: - **POST**: Se utiliza para **enviar información** al servidor. Por ejemplo, al hacer login, se suele usar una petición POST para enviar el usuario y contraseña.
//: - **PUT**: Se utiliza para **actualizar un recurso existente** en el servidor. Podrías usar PUT para actualizar la información de perfil en una app.
//: - **DELETE**: Se utiliza para **eliminar un recurso** en el servidor. Por ejemplo, cuando borras una cuenta, envías una petición DELETE para eliminar la información en el servidor.
//:
//: Estos métodos nos permiten interactuar con el servidor para crear, leer, actualizar o eliminar información.

//: #### Estados HTTP
//: Cada vez que se realiza una solicitud HTTP, el servidor devuelve un **estado HTTP** para informar si la operación fue exitosa o no. Los estados HTTP se dividen en grupos:
//:
//: - **1xx (Informativos)**: El servidor ha recibido la solicitud y continúa procesándola. Estos estados suelen ser invisibles para el usuario.
//: - **2xx (Éxito)**: La solicitud se realizó correctamente.
//:   - **200 OK**: Todo está bien y se obtuvo el resultado esperado.
//:   - **201 Created**: El recurso se creó correctamente.
//: - **3xx (Redirección)**: Se requiere una acción adicional para completar la solicitud, por ejemplo, redirigir a otra URL.
//:   - **301 Moved Permanently**: El recurso ha sido movido a una nueva URL de manera permanente.
//: - **4xx (Errores del Cliente)**: Algo estuvo mal en la solicitud del cliente.
//:   - **404 Not Found**: El recurso solicitado no se pudo encontrar.
//:   - **401 Unauthorized**: La solicitud no tiene autorización suficiente.
//: - **5xx (Errores del Servidor)**: Hay un problema en el lado del servidor.
//:   - **500 Internal Server Error**: Algo falló en el servidor durante la solicitud.

//: Creamos una URL a partir de una cadena que nos lleva a una imagen en internet.
let url = URL(string: "https://pbs.twimg.com/profile_images/1017076264644022272/tetffw3o_400x400.jpg")!

//: ### Configurando URLSession
//: Creamos una configuración para nuestra `URLSession`. La configuración nos permite ajustar el comportamiento de la sesión, como los tiempos de espera.
var configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 10 // Tiempo de espera de 10 segundos

//: Creamos la `URLSession` con la configuración ajustada.
let session = URLSession(configuration: configuration)

//: ### URLRequest: Configurando la Petición
//: `URLRequest` nos permite configurar cómo vamos a hacer la solicitud, en este caso, un POST.
var request = URLRequest(url: url)
request.httpMethod = "POST" // Método POST para enviar datos al servidor

//: Añadimos un **header** a la solicitud. En este caso, usamos un **token Bearer** que sirve para autenticar la petición y garantizar que el servidor la acepte.
request.setValue("Bearer ljasldjhalksjhdalksjhdaksjhd", forHTTPHeaderField: "Authorization")

//: ### Task y Concurrencia con async/await
//: Ahora creamos una **tarea asíncrona** para hacer la solicitud y obtener la respuesta. Usamos `Task` que es una estructura introducida para trabajar con concurrencia en Swift.
//:
//: #### ¿Qué es `Task`?
//: - Un **Task** es una operación concurrente que podemos ejecutar en el contexto de Swift. En este caso, estamos creando un `Task` que es **asincrónico**, lo cual significa que puede ejecutarse en segundo plano mientras nuestra app sigue funcionando.
//: - Un `Task` también puede considerarse como un "futuro" que tiene un **valor pendiente**. Esto quiere decir que es como una "promesa" de que en algún momento obtendremos el valor. Hasta que se complete, el resultado aún no está disponible.
//:
//: En este código, la tarea está diseñada para devolver un valor de tipo `Data?`, que representará los datos de la imagen si la descarga es exitosa o `nil` si ocurre algún error.
let task = Task { () -> Data? in
    do {
        //: Intentamos descargar los datos usando `await` que esperará de manera asíncrona hasta que se complete la operación.
        let (data, _) = try await session.data(for: request)
        return data
    } catch {
        //: Si ocurre un error, retornamos `nil`.
        return nil
    }
}
