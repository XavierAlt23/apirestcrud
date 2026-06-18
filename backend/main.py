"""
Cafetería Universitaria — API REST CRUD
FastAPI application with CORS, automatic table creation, and seed data.
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from database import engine, SessionLocal, Base
from models import Producto, Pedido, DetallePedido
from routers import productos, pedidos


def seed_data():
    """Insert initial sample products if the database is empty."""
    db = SessionLocal()
    try:
        if db.query(Producto).count() == 0:
            productos_seed = [
                Producto(
                    nombre="Café Americano",
                    descripcion="Café negro intenso preparado con agua caliente",
                    precio=1.50,
                    stock=100,
                    categoria="Bebidas Calientes",
                    imagen_url="https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400"
                ),
                Producto(
                    nombre="Cappuccino",
                    descripcion="Espresso con leche espumada y cacao en polvo",
                    precio=2.50,
                    stock=80,
                    categoria="Bebidas Calientes",
                    imagen_url="https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400"
                ),
                Producto(
                    nombre="Latte Macchiato",
                    descripcion="Leche vaporizada con shot de espresso",
                    precio=2.75,
                    stock=60,
                    categoria="Bebidas Calientes",
                    imagen_url="https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400"
                ),
                Producto(
                    nombre="Té Verde",
                    descripcion="Infusión natural de hojas de té verde",
                    precio=1.25,
                    stock=50,
                    categoria="Bebidas Calientes",
                    imagen_url="https://images.unsplash.com/photo-1556881286-fc6915169721?w=400"
                ),
                Producto(
                    nombre="Jugo de Naranja",
                    descripcion="Jugo natural de naranja recién exprimido",
                    precio=2.00,
                    stock=40,
                    categoria="Bebidas Frías",
                    imagen_url="https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400"
                ),
                Producto(
                    nombre="Smoothie de Fresa",
                    descripcion="Batido cremoso de fresas frescas con yogurt",
                    precio=3.50,
                    stock=30,
                    categoria="Bebidas Frías",
                    imagen_url="https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400"
                ),
                Producto(
                    nombre="Sandwich de Pollo",
                    descripcion="Pan artesanal con pollo a la plancha, lechuga y tomate",
                    precio=4.00,
                    stock=25,
                    categoria="Comidas",
                    imagen_url="https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400"
                ),
                Producto(
                    nombre="Croissant de Jamón",
                    descripcion="Croissant de mantequilla relleno de jamón y queso",
                    precio=3.00,
                    stock=35,
                    categoria="Comidas",
                    imagen_url="https://images.unsplash.com/photo-1530610476181-d83430b64dcd?w=400"
                ),
                Producto(
                    nombre="Ensalada César",
                    descripcion="Lechuga romana, crutones, parmesano y aderezo césar",
                    precio=4.50,
                    stock=20,
                    categoria="Comidas",
                    imagen_url="https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400"
                ),
                Producto(
                    nombre="Muffin de Arándanos",
                    descripcion="Muffin esponjoso con arándanos frescos",
                    precio=2.00,
                    stock=45,
                    categoria="Postres",
                    imagen_url="https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400"
                ),
                Producto(
                    nombre="Brownie de Chocolate",
                    descripcion="Brownie denso de chocolate negro con nueces",
                    precio=2.50,
                    stock=40,
                    categoria="Postres",
                    imagen_url="https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400"
                ),
                Producto(
                    nombre="Galleta de Avena",
                    descripcion="Galleta crujiente de avena con chips de chocolate",
                    precio=1.00,
                    stock=60,
                    categoria="Postres",
                    imagen_url="https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400"
                ),
            ]
            db.add_all(productos_seed)
            db.commit()
            print("[OK] Datos de ejemplo insertados correctamente")
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan: create tables and seed data on startup."""
    Base.metadata.create_all(bind=engine)
    seed_data()
    print("[START] Cafeteria Universitaria API iniciada")
    yield
    print("[STOP] API detenida")


app = FastAPI(
    title="Cafetería Universitaria API",
    description="API REST CRUD para gestión de productos y pedidos de la cafetería universitaria",
    version="1.0.0",
    lifespan=lifespan
)

# CORS - Allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(productos.router)
app.include_router(pedidos.router)


@app.get("/", tags=["Root"])
def root():
    """API root endpoint."""
    return {
        "message": "Bienvenido a la API de la Cafetería Universitaria",
        "version": "1.0.0",
        "docs": "/docs",
        "endpoints": {
            "productos": "/api/productos",
            "pedidos": "/api/pedidos"
        }
    }


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler for unhandled errors."""
    return JSONResponse(
        status_code=500,
        content={
            "message": "Error interno del servidor",
            "detail": str(exc)
        }
    )
