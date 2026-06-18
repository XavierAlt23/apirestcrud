"""
SQLAlchemy ORM models for the Cafetería Universitaria.
Entities: Producto, Pedido, DetallePedido
"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class Producto(Base):
    """Represents a product in the cafeteria catalog."""
    __tablename__ = "productos"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(String(500), nullable=True, default="")
    precio = Column(Float, nullable=False)
    stock = Column(Integer, nullable=False, default=0)
    categoria = Column(String(50), nullable=False, default="General")
    imagen_url = Column(String(500), nullable=True, default="")
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationship
    detalles = relationship("DetallePedido", back_populates="producto")


class Pedido(Base):
    """Represents a customer order."""
    __tablename__ = "pedidos"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    cliente = Column(String(100), nullable=False)
    fecha = Column(DateTime, default=datetime.utcnow)
    total = Column(Float, default=0.0)
    estado = Column(String(20), default="pendiente")  # pendiente, preparando, listo, entregado, cancelado
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationship
    detalles = relationship("DetallePedido", back_populates="pedido", cascade="all, delete-orphan")


class DetallePedido(Base):
    """Represents an order detail (line item) linking an order to a product."""
    __tablename__ = "detalles_pedido"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    pedido_id = Column(Integer, ForeignKey("pedidos.id", ondelete="CASCADE"), nullable=False)
    producto_id = Column(Integer, ForeignKey("productos.id"), nullable=False)
    cantidad = Column(Integer, nullable=False)
    precio_unitario = Column(Float, nullable=False)
    subtotal = Column(Float, nullable=False)

    # Relationships
    pedido = relationship("Pedido", back_populates="detalles")
    producto = relationship("Producto", back_populates="detalles")
