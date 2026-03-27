-- RLS para modulo enfermero (Supabase)
-- Aplica aislamiento por asignacion enfermero-paciente usando:
-- usuario.id == enfermero.id y auth.jwt()->>'email' == usuario.correo_electronico

begin;

create or replace function public.current_app_user_id()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select u.id
  from public.usuario u
  where lower(u.correo_electronico) = lower(coalesce(auth.jwt()->>'email', ''))
  limit 1;
$$;

revoke all on function public.current_app_user_id() from public;
grant execute on function public.current_app_user_id() to authenticated;

alter table public.enfermero enable row level security;
alter table public.paciente_enfermero enable row level security;
alter table public.paciente enable row level security;
alter table public.tratamiento_paciente enable row level security;
alter table public.dosis enable row level security;
alter table public.seguimiento_paciente enable row level security;
alter table public.sintomas_paciente enable row level security;
alter table public.sintoma enable row level security;

drop policy if exists enfermero_self_select on public.enfermero;
create policy enfermero_self_select
on public.enfermero
for select
to authenticated
using (id = public.current_app_user_id());

drop policy if exists pe_select_assigned on public.paciente_enfermero;
create policy pe_select_assigned
on public.paciente_enfermero
for select
to authenticated
using (id_enfermero = public.current_app_user_id());

drop policy if exists paciente_select_assigned on public.paciente;
create policy paciente_select_assigned
on public.paciente
for select
to authenticated
using (
  exists (
    select 1
    from public.paciente_enfermero pe
    where pe.id_paciente = paciente.id
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists tratamiento_select_assigned on public.tratamiento_paciente;
create policy tratamiento_select_assigned
on public.tratamiento_paciente
for select
to authenticated
using (
  exists (
    select 1
    from public.paciente_enfermero pe
    where pe.id_paciente = tratamiento_paciente.id_paciente
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists dosis_select_assigned on public.dosis;
create policy dosis_select_assigned
on public.dosis
for select
to authenticated
using (
  exists (
    select 1
    from public.tratamiento_paciente tp
    join public.paciente_enfermero pe on pe.id_paciente = tp.id_paciente
    where tp.id = dosis.id_tratamiento_paciente
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists dosis_write_assigned on public.dosis;
create policy dosis_write_assigned
on public.dosis
for all
to authenticated
using (
  exists (
    select 1
    from public.tratamiento_paciente tp
    join public.paciente_enfermero pe on pe.id_paciente = tp.id_paciente
    where tp.id = dosis.id_tratamiento_paciente
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
)
with check (
  exists (
    select 1
    from public.tratamiento_paciente tp
    join public.paciente_enfermero pe on pe.id_paciente = tp.id_paciente
    where tp.id = dosis.id_tratamiento_paciente
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists seguimiento_select_assigned on public.seguimiento_paciente;
create policy seguimiento_select_assigned
on public.seguimiento_paciente
for select
to authenticated
using (
  exists (
    select 1
    from public.paciente_enfermero pe
    where pe.id_paciente = seguimiento_paciente.id_paciente
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists seguimiento_insert_assigned on public.seguimiento_paciente;
create policy seguimiento_insert_assigned
on public.seguimiento_paciente
for insert
to authenticated
with check (
  exists (
    select 1
    from public.paciente_enfermero pe
    where pe.id_paciente = seguimiento_paciente.id_paciente
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists sintomas_select_assigned on public.sintomas_paciente;
create policy sintomas_select_assigned
on public.sintomas_paciente
for select
to authenticated
using (
  exists (
    select 1
    from public.seguimiento_paciente sp
    join public.paciente_enfermero pe on pe.id_paciente = sp.id_paciente
    where sp.id = sintomas_paciente.id_seguimiento
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists sintomas_insert_assigned on public.sintomas_paciente;
create policy sintomas_insert_assigned
on public.sintomas_paciente
for insert
to authenticated
with check (
  exists (
    select 1
    from public.seguimiento_paciente sp
    join public.paciente_enfermero pe on pe.id_paciente = sp.id_paciente
    where sp.id = sintomas_paciente.id_seguimiento
      and pe.id_enfermero = public.current_app_user_id()
      and coalesce(pe.activo, true) = true
  )
);

drop policy if exists sintoma_catalogo_select on public.sintoma;
create policy sintoma_catalogo_select
on public.sintoma
for select
to authenticated
using (true);

commit;
