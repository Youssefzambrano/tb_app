import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { nombre, correo, password, nivelAcceso, numeroDocumento } =
      await req.json();

    if (!nombre || !correo || !password || !nivelAcceso) {
      return new Response(
        JSON.stringify({ error: "Faltan campos requeridos." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: authData, error: authError } =
      await supabaseAdmin.auth.admin.createUser({
        email: correo.toLowerCase(),
        password,
        email_confirm: true,
      });

    if (authError) {
      return new Response(JSON.stringify({ error: authError.message }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { error: dbError } = await supabaseAdmin.from("usuario").insert({
      nombre,
      correo_electronico: correo.toLowerCase(),
      nivel_acceso: nivelAcceso,
      numero_documento: numeroDocumento ?? null,
    });

    if (dbError) {
      // Si falla la inserción en la tabla, eliminar el usuario de auth para no dejar inconsistencias
      await supabaseAdmin.auth.admin.deleteUser(authData.user!.id);
      return new Response(JSON.stringify({ error: dbError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
