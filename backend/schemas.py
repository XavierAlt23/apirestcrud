"""
Pydantic schemas for request/response validation.
"""
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, field_validator


# ─── Producto Schemas ────────────────────────────────────────────

class ProductoBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100, description="Nombre del producto")
    descripcion: Optional[str] = Field("", max_length=500, description="Descripción del producto")
    precio: float = Field(..., gt=0, description="Precio del producto (debe ser mayor a 0)")
    stock: int = Field(..., ge=0, description="Stock disponible (debe ser >= 0)")
    categoria: str = Field("General", max_length=50, description="Categoría del producto")
    imagen_url: Optional[str] = Field("", max_length=500, description="URL de la imagen")


class ProductoCreate(ProductoBase):
    pass


class ProductoUpdate(BaseModel):
    nombre: Optional[str] = Field(None, min_length=1, max_length=100)
    descripcion: Optional[str] = Field(None, max_length=500)
    precio: Optional[float] = Field(None, gt=0)
    stock: Optional[int] = Field(None, ge=0)
    categoria: Optional[str] = Field(None, max_length=50)
    imagen_url: Optional[str] = Field(None, max_length=500)


class ProductoResponse(ProductoBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# ─── DetallePedido Schemas ───────────────────────────────────────

class DetallePedidoBase(BaseModel):
    producto_id: int = Field(..., description="ID del producto")
    cantidad: int = Field(..., gt=0, description="Cantidad (debe ser mayor a 0)")


class DetallePedidoResponse(DetallePedidoBase):
    id: int
    precio_unitario: float
    subtotal: float
    producto: Optional[ProductoResponse] = None

    class Config:
        from_attributes = True


# ─── Pedido Schemas ──────────────────────────────────────────────

class PedidoBase(BaseModel):
    cliente: str = Field(..., min_length=1, max_length=100, description="Nombre del cliente")


class PedidoCreate(PedidoBase):
    detalles: List[DetallePedidoBase] = Field(
        ..., min_length=1, description="Lista de productos del pedido (mínimo 1)"
    )

    @field_validator('detalles')
    @classmethod
    def validate_detalles_not_empty(cls, v):
        if not v or len(v) == 0:
            raise ValueError('Un pedido debe tener al menos un producto')
        return v


class PedidoUpdate(BaseModel):
    cliente: Optional[str] = Field(None, min_length=1, max_length=100)
    estado: Optional[str] = Field(None, description="Estado del pedido")
    detalles: Optional[List[DetallePedidoBase]] = None

    @field_validator('estado')
    @classmethod
    def validate_estado(cls, v):
        if v is not None:
            estados_validos = ["pendiente", "preparando", "listo", "entregado", "cancelado"]
            if v not in estados_validos:
                raise ValueError(f'Estado inválido. Opciones: {", ".join(estados_validos)}')
        return v


class PedidoResponse(PedidoBase):
    id: int
    fecha: datetime
    total: float
    estado: str
    created_at: datetime
    detalles: List[DetallePedidoResponse] = []

    class Config:
        from_attributes = True


# ─── Generic Response ────────────────────────────────────────────

class MessageResponse(BaseModel):
    message: str
    detail: Optional[str] = None
