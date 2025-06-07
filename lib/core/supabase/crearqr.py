import qrcode

# Datos que irá en el QR
data = "piramide"

# Crear el objeto QR
qr = qrcode.QRCode(
    version=1,  # Tamaño del QR (1 a 40)
    error_correction=qrcode.constants.ERROR_CORRECT_L,  # Nivel de corrección de errores
    box_size=10,  # Tamaño de cada "cuadro" del QR
    border=4,  # Borde (mínimo 4)
)

qr.add_data(data)
qr.make(fit=True)

# Crear imagen del QR
img = qr.make_image(fill_color="black", back_color="white")

# Guardar como archivo
img.save("codigo_qr2.png")
