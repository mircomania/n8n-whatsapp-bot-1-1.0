-- Fotografía estructural reportada como verificada en Supabase el 2026-11-03.
-- DDL reconstruido a partir del esquema informado por el usuario; sin datos.
-- No es una migración de Supabase CLI. No ejecutar en producción por rutina.
-- Requiere revisión manual y validación en un entorno aislado.

CREATE TABLE public.whatsapp_monitor_monthly (
    waba_id text NOT NULL,
    mes date NOT NULL,
    mensajes_total integer NOT NULL DEFAULT 0,
    mensajes_gratis integer NOT NULL DEFAULT 0,
    mensajes_regulares integer NOT NULL DEFAULT 0,
    mensajes_otros integer NOT NULL DEFAULT 0,
    costo_estimado_usd numeric(12,4) NOT NULL DEFAULT 0,
    ultimo_umbral_mensajes_avisado integer NOT NULL DEFAULT 0,
    consultado_en timestamptz NULL,
    actualizado_en timestamptz NOT NULL DEFAULT now(),
    ultimo_umbral_costo_avisado_usd numeric(12,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (waba_id, mes),
    CONSTRAINT mes_primer_dia CHECK (EXTRACT(DAY FROM mes) = 1)
);

CREATE TABLE public.whatsapp_incident_alerts (
    tipo_incidente text NOT NULL,
    ultimo_aviso_en timestamptz NULL,
    reserva_id uuid NULL,
    reserva_hasta timestamptz NULL,
    actualizado_en timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (tipo_incidente)
);

ALTER TABLE public.whatsapp_monitor_monthly OWNER TO postgres;
ALTER TABLE public.whatsapp_incident_alerts OWNER TO postgres;

ALTER TABLE public.whatsapp_monitor_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_monitor_monthly NO FORCE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_incident_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_incident_alerts NO FORCE ROW LEVEL SECURITY;
-- No se crean políticas: se reportó ausencia de políticas explícitas.

REVOKE ALL PRIVILEGES ON TABLE public.whatsapp_monitor_monthly
    FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ON TABLE public.whatsapp_incident_alerts
    FROM PUBLIC, anon, authenticated;

GRANT ALL PRIVILEGES ON TABLE public.whatsapp_monitor_monthly
    TO service_role, postgres;
GRANT ALL PRIVILEGES ON TABLE public.whatsapp_incident_alerts
    TO service_role, postgres;
