# FuelControl — SwiftUI, iOS 17+

Aplicación local con SwiftUI, Charts y Observation. No usa red, backend, autenticación real ni dependencias externas. El estado se conserva durante la ejecución de la app y se reinicia al volver a lanzarla.

## Abrir y compilar

Abre `FuelControl.xcodeproj` en Xcode 15 o posterior, selecciona el esquema FuelControl y un simulador iPhone con iOS 17 o posterior. Para un dispositivo físico, configura tu equipo de firma.

Desde macOS:

```sh
cd FuelControlApp
xcodebuild -project FuelControl.xcodeproj -scheme FuelControl -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
swift test
```

`Package.swift` permite probar los mismos modelos y ViewModels con XCTest en macOS 14+. No agrega dependencias al target iOS.

Esta modificación se realizó en Windows, sin Swift, Xcode ni simulador. Se ejecutó la comprobación estática con `node FuelControlApp/validate-project.mjs`; la compilación iOS, los XCTest y la revisión visual quedan pendientes de ejecutarse en macOS.

## Arquitectura

- `App/RootView.swift` conserva SessionViewModel y GeneralViewModel durante toda la ejecución.
- `ViewModels/SessionViewModel.swift`: rol, sucursal activa y acciones de ingreso/salida visual.
- `ViewModels/GeneralViewModel.swift`: sucursales, gerentes, vínculos, posiciones de mapa y consolidación nacional. Incluye los ViewModels de Resumen, Franquicias, Comparar, Administración y detalle de sucursal.
- `ViewModels/SucursalViewModel.swift`: tanques, historial de cortes por día, validación, registros y cierre. CortesViewModel y CorteDetailViewModel exponen los intents de cada pantalla.
- `ViewModels/ScreenViewModels.swift`: Inicio, Ventas, Tanques y Alertas.
- `Models/CorteModels.swift`: Manager, Corte, CorteTurno, MovementCategory, PumpEntry y los tres niveles de tanque.
- Las vistas no consultan MockData. GeneralViewModel utiliza los mocks únicamente para inicializar el estado local.

## Reglas implementadas

- Dos cortes por fecha local y sucursal: Matutino y Vespertino / Nocturno. Se crean de forma idempotente; la app actualiza la fecha al volver al primer plano y periódicamente mientras está abierta. Los anteriores se conservan en memoria.
- Cada corte contiene seis bombas numeradas del 1 al 6. Cada bomba registra combustible, ventas, compras/recepción, pérdidas/daños y motivo de pérdida.
- Los tres campos de galones son obligatorios: cero significa ausencia de movimiento; vacío no equivale a cero. Se aceptan punto o coma decimal y cantidades finitas de 0 a 1,000,000.
- Cambiar cualquier campo invalida la confirmación individual de esa bomba. El ViewModel solo permite cerrar cuando las seis están registradas y válidas.
- El cierre guarda la fecha y bloquea toda modificación también en el ViewModel. El resumen muestra totales por combustible y total general de cada categoría, sin mezclar ventas con entradas de inventario.
- Las ventas de cortes abiertos no se incluyen en los dashboards. Las cerradas se suman una sola vez a los datos iniciales de su sucursal; ingresos calculados con precios locales de ejemplo: Regular $3.75, Súper $4.25 y Diésel $3.50 por galón.
- Los datos iniciales de ventas se desglosan localmente por combustible conservando exactamente los totales del arreglo de sucursales. Son datos de demostración, no mediciones históricas reales.
- Registrar una estación crea tres tanques de 10,000 galones al 60%, dos cortes y métricas de ventas en cero. Aparece inmediatamente en lista, mapa, filtro nacional y opciones del comparador.
- Alta de gerente con nombre, correo único y rol Gerente de sucursal. El vínculo asocia el ID de una sucursal al ID del gerente; guardar otro vínculo reemplaza al gerente anterior de esa sucursal.
- Tanques: Crítico ≤20%, Medio >20% y ≤50%, Óptimo >50%. Los tanques representan lecturas locales; registrar un corte no reemplaza una lectura física.
- Sin gestión de personal ni horarios. Perfil y notificaciones mantienen acciones decorativas.

## Verificación manual en simulador

1. Entrar como Gerente General y registrar una estación. Buscarla en la lista y mapa, seleccionarla en Resumen y Comparar; verificar cero ventas y ausencia de divisiones por cero.
2. Crear un gerente y vincularlo. Abrir la nueva estación y verificar nombre, zona y gerente correctos.
3. Abrir Cortes: verificar exactamente dos. Intentar cerrar sin registros, con cinco bombas o con un dato inválido; el cierre debe permanecer bloqueado.
4. Completar y registrar seis bombas, incluyendo ceros y decimales. Modificar una registrada: debe requerir registrarla de nuevo.
5. Cerrar el corte, volver a abrirlo y verificar solo lectura, seis bombas y totales por combustible/categoría.
6. Volver al resumen nacional y a la sucursal; verificar que incorporan las ventas cerradas una sola vez.
7. Cambiar de rol mediante cerrar sesión y volver a entrar; los datos deben mantenerse hasta finalizar la app.
8. Probar los tres niveles de tanques y navegación desde ambos roles.

Los XCTest cubren cambio de día, dos cortes únicos, seis registros obligatorios, invalidación, inmutabilidad del cierre, valores inválidos, altas y vínculos, propagación al comparador/mapa, consolidación y umbrales de tanque.
