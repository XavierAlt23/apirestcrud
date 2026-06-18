# ☕ Cafetería Universitaria

API REST CRUD con dos entidades relacionadas (Producto y Pedido) consumida desde una aplicación móvil desarrollada en Flutter.

## Tecnologías

| Componente | Tecnología |
|---|---|
| Backend | FastAPI (Python) |
| Base de datos | SQLite + SQLAlchemy |
| Frontend móvil | Flutter |
| State Management | Provider (MVVM) |

## Estructura del Proyecto

```
pry_apicrud/
├── backend/                        # API REST (FastAPI + SQLite)
│   ├── main.py                     # App principal, CORS, seed data
│   ├── database.py                 # Configuración SQLAlchemy
│   ├── models.py                   # Modelos ORM
│   ├── schemas.py                  # Validación Pydantic
│   ├── routers/
│   │   ├── productos.py            # CRUD Productos
│   │   └── pedidos.py              # CRUD Pedidos
│   └── requirements.txt
│
├── lib/                            # App Flutter (MVVM)
│   ├── main.dart                   # Entry point + MultiProvider
│   ├── models/                     # Modelos de datos
│   ├── services/                   # Consumo HTTP
│   ├── viewmodels/                 # Lógica de negocio (Provider)
│   ├── views/                      # Pantallas
│   └── widgets/                    # Componentes reutilizables
│
└── pubspec.yaml
```

## Requisitos Previos

- **Python 3.10+** — Para el backend
- **Flutter SDK 3.12+** — Para la app móvil
- **Emulador Android** o dispositivo físico conectado

## 🚀 Ejecución — Se necesitan 2 terminales

### Terminal 1 — Backend (FastAPI)

**Windows (PowerShell):**
```powershell
# 1. Ir al directorio del backend
cd backend

# 2. Crear entorno virtual
python -m venv venv

# 3. Activar entorno virtual
.\venv\Scripts\Activate.ps1

# 4. Instalar dependencias
pip install -r requirements.txt

# 5. Ejecutar el servidor API
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Linux / macOS:**
```bash
# 1. Ir al directorio del backend
cd backend

# 2. Crear entorno virtual
python3 -m venv venv

# 3. Activar entorno virtual
source venv/bin/activate

# 4. Instalar dependencias
pip install -r requirements.txt

# 5. Ejecutar el servidor API
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> El servidor estará disponible en **http://localhost:8000**
> Documentación Swagger en **http://localhost:8000/docs**

> **Nota:** El backend (Terminal 1) debe estar corriendo antes de lanzar la app Flutter.

> **Windows:** Si PowerShell bloquea la ejecución de scripts, ejecuta primero:
> `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

| Dispositivo | IP en `api_service.dart` |
|---|---|
| Emulador Android | `10.0.2.2` (automático) |
| Web / Desktop | `localhost` (automático) |
| Dispositivo físico | Tu IP local (ej: `192.168.1.x`) |

> Si usas un dispositivo físico, edita `lib/services/api_service.dart` y cambia la IP.

### Terminal 2 — Flutter (App Móvil)

```bash
# 1. Ir al directorio raíz del proyecto (ajusta según tu ruta)
cd apirestcrud

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar la app
flutter run
```



## Endpoints API

### Productos
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/productos/` | Listar todos los productos |
| GET | `/api/productos/{id}` | Buscar producto por ID |
| POST | `/api/productos/` | Crear producto |
| PUT | `/api/productos/{id}` | Actualizar producto |
| DELETE | `/api/productos/{id}` | Eliminar producto |

### Pedidos
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/pedidos/` | Listar todos los pedidos |
| GET | `/api/pedidos/{id}` | Buscar pedido por ID |
| POST | `/api/pedidos/` | Crear pedido |
| PUT | `/api/pedidos/{id}` | Actualizar pedido |
| DELETE | `/api/pedidos/{id}` | Eliminar pedido |

## Reglas de Negocio

1. Un pedido debe tener **al menos un producto**.
2. No se puede pedir una cantidad **mayor al stock** disponible.
3. El **total se calcula automáticamente** según precio × cantidad.
4. Al registrar un pedido, el **stock del producto disminuye**.
5. Al eliminar un pedido pendiente, el **stock se restaura**.

## Pruebas en Postman

Importa el archivo `backend/Cafeteria_Universitaria_API.postman_collection.json` en Postman para probar todos los endpoints.

## Pantallas Flutter

| Pantalla | Descripción |
|---|---|
| Splash Screen | Animación de bienvenida con logo |
| Home | GridView de productos con búsqueda y filtros |
| Detalle Producto | Info completa con agregar al carrito |
| Formulario Producto | Crear y editar productos |
| Carrito / Pedido | Revisar items y confirmar pedido |
| Resumen | Confirmación del pedido realizado |
| Lista Pedidos | Historial de todos los pedidos |
