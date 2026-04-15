import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import nodemailer from 'npm:nodemailer@6'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email } = await req.json()

    if (!email) {
      return new Response(JSON.stringify({ error: 'Email requerido' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // 1. Verificar que el correo existe en la tabla usuario
    const { data: usuarioData, error: usuarioError } = await supabase
      .from('usuario')
      .select('id')
      .eq('correo_electronico', email)
      .single()

    if (usuarioError || !usuarioData) {
      // Responder ok igual para no revelar si el correo está registrado
      return new Response(JSON.stringify({ message: 'ok' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Buscar el usuario en Supabase Auth por email
    const { data: listData, error: listError } =
      await supabase.auth.admin.listUsers({ page: 1, perPage: 1000 })

    if (listError) throw listError

    const authUser = listData.users.find(
      (u) => u.email?.toLowerCase() === email.toLowerCase(),
    )

    if (!authUser) {
      return new Response(JSON.stringify({ message: 'ok' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 3. Generar contraseña temporal segura (10 caracteres)
    //    Sin caracteres ambiguos: 0/O, 1/l/I
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789'
    const randomBytes = new Uint8Array(10)
    crypto.getRandomValues(randomBytes)
    const tempPassword = Array.from(
      randomBytes,
      (byte) => chars[byte % chars.length],
    ).join('')

    // 4. Actualizar contraseña en Supabase Auth vía admin API
    const { error: updateError } =
      await supabase.auth.admin.updateUserById(authUser.id, {
        password: tempPassword,
      })

    if (updateError) throw updateError

    // 5. Enviar correo vía SMTP
    const transporter = nodemailer.createTransport({
      host: Deno.env.get('SMTP_HOST'),
      port: Number(Deno.env.get('SMTP_PORT') ?? 587),
      secure: Deno.env.get('SMTP_SECURE') === 'true', // true para puerto 465
      auth: {
        user: Deno.env.get('SMTP_USER'),
        pass: Deno.env.get('SMTP_PASS'),
      },
    })

    await transporter.sendMail({
      from: `"EvitaTB" <${Deno.env.get('SMTP_USER')}>`,
      to: email,
      subject: 'Tu contraseña temporal — EvitaTB',
      html: `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;padding:32px 24px;background:#fff;border-radius:12px;border:1px solid #e5e7eb;">
          <div style="text-align:center;margin-bottom:24px;">
            <span style="display:inline-block;background:#67BF63;border-radius:50%;width:56px;height:56px;line-height:56px;font-size:28px;">🔑</span>
          </div>
          <h2 style="color:#1a1a1a;font-size:22px;margin:0 0 8px;">Contraseña temporal</h2>
          <p style="color:#555;font-size:15px;line-height:1.6;margin:0 0 20px;">
            Hola, recibiste este correo porque solicitaste recuperar tu acceso a la app <strong>EvitaTB</strong>.
          </p>
          <p style="color:#555;font-size:15px;margin:0 0 12px;">Tu contraseña temporal es:</p>
          <div style="background:#f3f4f6;border-radius:10px;padding:18px 24px;text-align:center;margin-bottom:20px;">
            <span style="font-size:26px;font-weight:700;letter-spacing:4px;color:#111;font-family:monospace;">
              ${tempPassword}
            </span>
          </div>
          <p style="color:#555;font-size:15px;line-height:1.6;margin:0 0 24px;">
            Ingresa a la app con esta contraseña y luego dirígete a
            <strong>Perfil → Cambiar contraseña</strong> para establecer una contraseña permanente.
          </p>
          <hr style="border:none;border-top:1px solid #e5e7eb;margin:24px 0;" />
          <p style="color:#9ca3af;font-size:12px;margin:0;">
            Si no solicitaste esto, ignora este correo. Nadie más tiene acceso a tu cuenta.
          </p>
        </div>
      `,
    })

    return new Response(JSON.stringify({ message: 'ok' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('reset-password-temp error:', error)
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
