"""
CRUD Router for Producto entity.
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from database import get_db
from models import Producto
from schemas import ProductoCreate, ProductoUpdate, ProductoResponse, MessageResponse

router = APIRouter(prefix="/api/productos", tags=["Productos"])


@router.get("/", response_model=List[ProductoResponse])
def listar_productos(
    categoria: Optional[str] = Query(None, description="Filtrar por categoría"),
    buscar: Optional[str] = Query(None, description="Buscar por nombre"),
    db: Session = Depends(get_db)
):
    """Listar todos los productos con filtros opcionales."""
    query = db.query(Producto)
    if categoria:
        query = query.filter(Producto.categoria == categoria)
    if buscar:
        query = query.filter(Producto.nombre.ilike(f"%{buscar}%"))
    productos = query.order_by(Producto.id.desc()).all()
    return productos


@router.get("/{producto_id}", response_model=ProductoResponse)
def obtener_producto(producto_id: int, db: Session = Depends(get_db)):
    """Buscar un producto por su ID."""
    producto = db.query(Producto).filter(Producto.id == producto_id).first()
    if not producto:
        raise HTTPException(status_code=404, detail=f"Producto con ID {producto_id} no encontrado")
    return producto


@router.post("/", response_model=ProductoResponse, status_code=201)
def crear_producto(producto: ProductoCreate, db: Session = Depends(get_db)):
    """Crear un nuevo producto."""
    # Check if product with same name already exists
    existente = db.query(Producto).filter(Producto.nombre == producto.nombre).first()
    if existente:
        raise HTTPException(
            status_code=400,
            detail=f"Ya existe un producto con el nombre '{producto.nombre}'"
        )

    db_producto = Producto(**producto.model_dump())
    db.add(db_producto)
    db.commit()
    db.refresh(db_producto)
    return db_producto


@router.put("/{producto_id}", response_model=ProductoResponse)
def actualizar_producto(producto_id: int, producto: ProductoUpdate, db: Session = Depends(get_db)):
    """Actualizar un producto existente."""
    db_producto = db.query(Producto).filter(Producto.id == producto_id).first()
    if not db_producto:
        raise HTTPException(status_code=404, detail=f"Producto con ID {producto_id} no encontrado")

    update_data = producto.model_dump(exclude_unset=True)

    # If updating name, check for duplicates
    if "nombre" in update_data:
        existente = db.query(Producto).filter(
            Producto.nombre == update_data["nombre"],
            Producto.id != producto_id
        ).first()
        if existente:
            raise HTTPException(
                status_code=400,
                detail=f"Ya existe otro producto con el nombre '{update_data['nombre']}'"
            )

    for key, value in update_data.items():
        setattr(db_producto, key, value)

    db.commit()
    db.refresh(db_producto)
    return db_producto


@router.delete("/{producto_id}", response_model=MessageResponse)
def eliminar_producto(producto_id: int, db: Session = Depends(get_db)):
    """Eliminar un producto por su ID."""
    db_producto = db.query(Producto).filter(Producto.id == producto_id).first()
    if not db_producto:
        raise HTTPException(status_code=404, detail=f"Producto con ID {producto_id} no encontrado")

    # Check if product is part of any order
    if db_producto.detalles:
        raise HTTPException(
            status_code=400,
            detail="No se puede eliminar el producto porque está asociado a pedidos existentes"
        )

    db.delete(db_producto)
    db.commit()
    return MessageResponse(
        message="Producto eliminado exitosamente",
        detail=f"Se eliminó el producto '{db_producto.nombre}' (ID: {producto_id})"
    )
