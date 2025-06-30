const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const cors = require('cors')({ origin: true });

// Configura con tus datos reales
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'amando16723@gmail.com',
    pass: 'lxqrepwitdxnlghs',
  },
});

// Función HTTP para enviar correo
exports.enviarCorreo = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const { nombre, email, direccion, orderDetails, total } = req.body; // ✅ Añadido: direccion

    const mailOptions = {
      from: 'Taully Minimarket <tucorreo@gmail.com>',
      to: email,
      subject: '🧾 Confirmación de tu pedido en Taully Minimarket',
      html: `
        <div style="max-width: 600px; margin: auto; font-family: 'Segoe UI', Arial, sans-serif; background: #fffaf0 !important; padding: 24px; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.1); color: #333 !important;">
          <div style="text-align: center;">
            <h1 style="color: #d4a017; margin-bottom: 0;">Taully Minimarket 🛒</h1>
            <p style="font-size: 18px; margin-top: 8px; color: #333 !important;">Hola <strong>${nombre}</strong>, ¡gracias por tu compra!</p>
          </div>

          <hr style="margin: 24px 0; border: none; border-top: 1px solid #ccc;" />

          <h3 style="color: #2c3e50;">🧾 Resumen de tu pedido</h3>
          <pre style="background: #f3f3f3; padding: 16px; border-radius: 6px; font-size: 15px; line-height: 1.6; color: #2c3e50; white-space: pre-wrap;">${orderDetails}</pre>

          <p style="font-size: 16px;"><strong>Total a pagar:</strong> <span style="color: #2980b9; font-weight: bold;">S/ ${total}</span></p>

          <p style="font-size: 16px; margin-top: 12px;"><strong>Dirección de entrega:</strong> ${direccion}</p> <!-- ✅ NUEVO CAMPO -->

          <div style="text-align: center; margin-top: 32px;">
            <a href="https://tu-pagina.com/mi-pedido" style="background: linear-gradient(to right, #2980b9, #6dd5fa); color: white !important; padding: 14px 28px; text-decoration: none; border-radius: 8px; display: inline-block; font-weight: 600; font-size: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);">
              📦 Ver estado del pedido
            </a>
          </div>

          <hr style="margin: 40px 0 24px; border: none; border-top: 1px solid #ccc;" />

          <p style="font-size: 13px; color: #555 !important; text-align: center;">
            Este mensaje fue generado automáticamente por <strong>Taully Minimarket</strong>.<br>
            ¿Necesitas ayuda? Contáctanos en <a href="mailto:soporte@taully.com" style="color: #2980b9;">soporte@taully.com</a>.
          </p>
        </div>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      return res.status(200).send('Correo enviado con éxito');
    } catch (error) {
      console.error('Error al enviar el correo:', error);
      return res.status(500).send(`Error al enviar: ${error.toString()}`);
    }
  });
});
