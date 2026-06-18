"""
CRUD Router for Pedido entity.
Implements business rules: stock validation, total calculation, stock decrement.
"""
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from database import get_db
from models import Pedido, DetallePedido, Producto
from schemas import PedidoCreate, PedidoUpdate, PedidoResponse, MessageResponse

router = APIRouter(prefix="/api/pedidos", tags=["Pedidos"])


@router.get("/", response_model=List[PedidoResponse])
def listar_pedidos(db: Session = Depends(get_db)):
    """Listar todos los pedidos con sus detalles."""
    pedidos = (
        db.query(Pedido)
        .options(joinedload(Pedido.detalles).joinedload(DetallePedido.producto))
        .order_by(Pedido.id.desc())
        .all()
    )
    return pedidos


@router.get("/{pedido_id}", response_model=PedidoResponse)
def obtener_pedido(pedido_id: int, db: Session = Depends(get_db)):
    """Buscar un pedido por su ID."""
    pedido = (
        db.query(Pedido)
        .options(joinedload(Pedido.detalles).joinedload(DetallePedido.producto))
        .filter(Pedido.id == pedido_id)
        .first()
    )
    if not pedido:
        raise HTTPException(status_code=404, detail=f"Pedido con ID {pedido_id} no encontrado")
    return pedido


@router.post("/", response_model=PedidoResponse, status_code=201)
def crear_pedido(pedido: PedidoCreate, db: Session = Depends(get_db)):
    """
    Crear un nuevo pedido.
    Business Rules:
    - Must have at least 1 product (validated in schema)
    - Cannot order more than available stock
    - Total is calculated from price × quantity
    - Stock is decremented upon creation
    """
    # Validate all products exist and have sufficient stock
    total = 0.0
    detalles_data = []

    for detalle in pedido.detalles:
        producto = db.query(Producto).filter(Producto.id == detalle.producto_id).first()
        if not producto:
            raise HTTPException(
                status_code=404,
                detail=f"Producto con ID {detalle.producto_id} no encontrado"
            )
        if detalle.cantidad > producto.stock:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Stock insuficiente para '{producto.nombre}'. "
                    f"Disponible: {producto.stock}, Solicitado: {detalle.cantidad}"
                )
            )

        subtotal = producto.precio * detalle.cantidad
        total += subtotal
        detalles_data.append({
            "producto": producto,
            "producto_id": detalle.producto_id,
            "cantidad": detalle.cantidad,
            "precio_unitario": producto.precio,
            "subtotal": subtotal
        })

    # Create the order
    db_pedido = Pedido(
        cliente=pedido.cliente,
        total=round(total, 2),
        estado="pendiente"
    )
    db.add(db_pedido)
    db.flush()  # Get the pedido ID

    # Create order details and decrement stock
    for data in detalles_data:
        db_detalle = DetallePedido(
            pedido_id=db_pedido.id,
            producto_id=data["producto_id"],
            cantidad=data["cantidad"],
            precio_unitario=data["precio_unitario"],
            subtotal=data["subtotal"]
        )
        db.add(db_detalle)

        # Decrement product stock
        data["producto"].stock -= data["cantidad"]

    db.commit()

    # Reload with relationships
    pedido_result = (
        db.query(Pedido)
        .options(joinedload(Pedido.detalles).joinedload(DetallePedido.producto))
        .filter(Pedido.id == db_pedido.id)
        .first()
    )
    return pedido_result


@router.put("/{pedido_id}", response_model=PedidoResponse)
def actualizar_pedido(pedido_id: int, pedido: PedidoUpdate, db: Session = Depends(get_db)):
    """
    Actualizar un pedido existente.
    If detalles are provided, the old details are replaced.
    Stock is restored for old items and decremented for new items.
    """
    db_pedido = (
        db.query(Pedido)
        .options(joinedload(Pedido.detalles).joinedload(DetallePedido.producto))
        .filter(Pedido.id == pedido_id)
        .first()
    )
    if not db_pedido:
        raise HTTPException(status_code=404, detail=f"Pedido con ID {pedido_id} no encontrado")

    # Update simple fields
    if pedido.cliente is not None:
        db_pedido.cliente = pedido.cliente
    if pedido.estado is not None:
        db_pedido.estado = pedido.estado

    # If updating details, handle stock
    if pedido.detalles is not None:
        if len(pedido.detalles) == 0:
            raise HTTPException(
                status_code=400,
                detail="Un pedido debe tener al menos un producto"
            )

        # Restore stock from old details
        for detalle in db_pedido.detalles:
            producto = db.query(Producto).filter(Producto.id == detalle.producto_id).first()
            if producto:
                producto.stock += detalle.cantidad

        # Delete old details
        for detalle in db_pedido.detalles:
            db.delete(detalle)
        db.flush()

        # Validate and add new details
        total = 0.0
        for detalle_data in pedido.detalles:
            producto = db.query(Producto).filter(Producto.id == detalle_data.producto_id).first()
            if not producto:
                raise HTTPException(
                    status_code=404,
                    detail=f"Producto con ID {detalle_data.producto_id} no encontrado"
                )
            if detalle_data.cantidad > producto.stock:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Stock insuficiente para '{producto.nombre}'. "
                        f"Disponible: {producto.stock}, Solicitado: {detalle_data.cantidad}"
                    )
                )

            subtotal = producto.precio * detalle_data.cantidad
            total += subtotal

            db_detalle = DetallePedido(
                pedido_id=db_pedido.id,
                producto_id=detalle_data.producto_id,
                cantidad=detalle_data.cantidad,
                precio_unitario=producto.precio,
                subtotal=subtotal
            )
            db.add(db_detalle)
            producto.stock -= detalle_data.cantidad

        db_pedido.total = round(total, 2)

    db.commit()

    # Reload with relationships
    pedido_result = (
        db.query(Pedido)
        .options(joinedload(Pedido.detalles).joinedload(DetallePedido.producto))
        .filter(Pedido.id == db_pedido.id)
        .first()
    )
    return pedido_result


@router.delete("/{pedido_id}", response_model=MessageResponse)
def eliminar_pedido(pedido_id: int, db: Session = Depends(get_db)):
    """
    Eliminar un pedido por su ID.
    If status is 'pendiente' or 'cancelado', stock is restored.
    """
    db_pedido = (
        db.query(Pedido)
        .options(joinedload(Pedido.detalles))
        .filter(Pedido.id == pedido_id)
        .first()
    )
    if not db_pedido:
        raise HTTPException(status_code=404, detail=f"Pedido con ID {pedido_id} no encontrado")

    # Restore stock if order was not yet fulfilled
    if db_pedido.estado in ["pendiente", "preparando"]:
        for detalle in db_pedido.detalles:
            producto = db.query(Producto).filter(Producto.id == detalle.producto_id).first()
            if producto:
                producto.stock += detalle.cantidad

    db.delete(db_pedido)
    db.commit()
    return MessageResponse(
        message="Pedido eliminado exitosamente",
        detail=f"Se eliminó el pedido #{pedido_id} del cliente '{db_pedido.cliente}'"
    )
